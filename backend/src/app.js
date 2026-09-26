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

const app = express();

app.use(helmet());

// Native mobile clients (Android/iOS) don't send an Origin header, so this
// allowlist only restricts browser-based clients (Flutter web / local dev).
const allowedOrigins = (
  process.env.CORS_ORIGINS || "http://localhost:5173,http://localhost:8080"
)
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

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

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Jomnes backend is running",
  });
});

export default app;