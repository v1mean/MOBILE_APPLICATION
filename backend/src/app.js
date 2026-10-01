import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";

import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";

import bookingRoutes from "./routes/booking.routes.js";
import reviewRoutes from "./routes/review.routes.js";
import courseRoutes from "./routes/course.routes.js";
import paymentRoutes from "./routes/payment.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import { getAllowedOrigins } from "./config/origins.js";

const app = express();

app.use(helmet());

// Native mobile clients (Android/iOS) don't send an Origin header, so this
// allowlist only restricts browser-based clients (Flutter web / local dev).
const allowedOrigins = getAllowedOrigins();

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
  })
);

app.use(express.json());

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100,
  message: {
    success: false,
    message: "Too many requests. Please try again later.",
  },
});

app.use("/api/auth", authLimiter, authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/courses", courseRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/notifications", notificationRoutes);

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Jomnes backend is running",
  });
});

// Errors raised outside a controller (a rejected origin, a malformed body, a
// refused upload) get the same JSON shape as every other response, so the app
// can show the message instead of failing to parse an HTML error page.
app.use((err, req, res, next) => {
  if (res.headersSent) return next(err);

  let status = err.status || err.statusCode || 500;
  if (err.message === "Not allowed by CORS") status = 403;
  if (err.name === "MulterError") status = 400;

  if (status >= 500) {
    console.error("UNHANDLED ERROR:", err);
    return res.status(status).json({ success: false, message: "Something went wrong." });
  }

  const message =
    err.type === "entity.parse.failed" ? "Invalid request body." : err.message;
  return res.status(status).json({ success: false, message });
});

export default app;