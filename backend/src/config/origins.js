export function getAllowedOrigins() {
  return (
    process.env.CORS_ORIGINS || "http://localhost:5173,http://localhost:8080"
  )
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
}
