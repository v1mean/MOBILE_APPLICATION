import http from "node:http";

// A stand-in for Supabase's HTTP API, just enough for the backend's own calls.
// Tests point SUPABASE_URL at it, seed `state`, and inspect `state.calls`.
export async function startFakeSupabase() {
  const state = { users: [], tables: {}, calls: [] };
  let nextId = 1;

  const authUser = (user) => ({
    id: user.id,
    email: user.email,
    app_metadata: user.app_metadata ?? {},
    user_metadata: {},
    aud: "authenticated",
  });

  // PostgREST filters arrive as `column=eq.value` query parameters.
  const matches = (row, params) => {
    for (const [column, filter] of params) {
      if (["select", "order", "limit", "on_conflict", "columns"].includes(column)) continue;
      const [op, ...rest] = filter.split(".");
      const value = rest.join(".");
      if (op === "eq" && String(row[column]) !== value) return false;
      if (op === "neq" && String(row[column]) === value) return false;
      if (op === "in") {
        const list = value.replace(/^\(|\)$/g, "").split(",").map((v) => v.replace(/"/g, ""));
        if (!list.includes(String(row[column]))) return false;
      }
    }
    return true;
  };

  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, "http://fake");
    let raw = "";
    for await (const chunk of req) raw += chunk;
    let body = null;
    try {
      body = raw ? JSON.parse(raw) : null;
    } catch {
      body = raw;
    }

    const send = (status, json) => {
      res.writeHead(status, { "content-type": "application/json" });
      res.end(json === undefined ? "" : JSON.stringify(json));
    };

    const bearer = (req.headers.authorization || "").replace("Bearer ", "");
    const path = decodeURIComponent(url.pathname);
    state.calls.push({ method: req.method, path, body, bearer });

    // ── Auth ───────────────────────────────────────────────────────────────
    if (path === "/auth/v1/user" && req.method === "GET") {
      const user = state.users.find((u) => u.token === bearer);
      return user ? send(200, authUser(user)) : send(401, { msg: "invalid JWT" });
    }

    if (path === "/auth/v1/user" && req.method === "PUT") {
      const user = state.users.find((u) => u.token === bearer);
      if (!user) return send(401, { msg: "invalid JWT" });
      if (body?.password) user.password = body.password;
      return send(200, authUser(user));
    }

    if (path === "/auth/v1/token" && req.method === "POST") {
      const user = state.users.find(
        (u) => u.email === body?.email && u.password === body?.password
      );
      if (!user) {
        return send(400, { error_code: "invalid_credentials", msg: "Invalid login credentials" });
      }
      return send(200, {
        access_token: user.token,
        token_type: "bearer",
        expires_in: 3600,
        expires_at: Math.floor(Date.now() / 1000) + 3600,
        refresh_token: `refresh-${user.id}`,
        user: authUser(user),
      });
    }

    if (path === "/auth/v1/admin/users" && req.method === "GET") {
      const page = Number(url.searchParams.get("page") || 1);
      const perPage = Number(url.searchParams.get("per_page") || 50);
      const users = state.users.slice((page - 1) * perPage, page * perPage);
      return send(200, { users: users.map(authUser), aud: "authenticated" });
    }

    if (path.startsWith("/auth/v1/admin/users/") && req.method === "PUT") {
      const user = state.users.find((u) => u.id === path.split("/").pop());
      if (!user) return send(404, { msg: "User not found" });
      if (body?.password) user.password = body.password;
      return send(200, authUser(user));
    }

    // ── Tables ─────────────────────────────────────────────────────────────
    if (path.startsWith("/rest/v1/")) {
      const table = path.slice("/rest/v1/".length);
      const rows = (state.tables[table] ??= []);
      const wantsObject = (req.headers.accept || "").includes("vnd.pgrst.object");

      if (req.method === "GET") {
        const found = rows.filter((row) => matches(row, url.searchParams));
        if (!wantsObject) return send(200, found);
        return found.length === 1
          ? send(200, found[0])
          : send(406, { code: "PGRST116", message: "no single row", details: `${found.length} rows` });
      }

      if (req.method === "POST") {
        const inserted = [].concat(body).map((row) => ({ id: `row-${nextId++}`, ...row }));
        rows.push(...inserted);
        return send(201, wantsObject ? inserted[0] : inserted);
      }

      if (req.method === "PATCH") {
        const found = rows.filter((row) => matches(row, url.searchParams));
        found.forEach((row) => Object.assign(row, body));
        if (!wantsObject) return send(200, found);
        return found.length === 1
          ? send(200, found[0])
          : send(406, { code: "PGRST116", message: "no single row", details: `${found.length} rows` });
      }
    }

    // ── Storage ────────────────────────────────────────────────────────────
    if (path.startsWith("/storage/v1/object/")) {
      return send(200, { Key: path.slice("/storage/v1/object/".length) });
    }

    return send(404, { message: `not faked: ${req.method} ${path}` });
  });

  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));

  return {
    state,
    url: `http://127.0.0.1:${server.address().port}`,
    close: () => new Promise((resolve) => server.close(resolve)),
  };
}
