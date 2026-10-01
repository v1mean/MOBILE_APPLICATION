import express from 'express';
import { requireAuth } from '../middleware/auth.middleware.js';
import {
  createPaymentIntent,
  createCheckoutSession,
  getCheckoutSessionStatus,
} from '../controllers/payment.controller.js';

const router = express.Router();

router.post('/create-intent', requireAuth, createPaymentIntent);
router.post('/create-checkout-session', requireAuth, createCheckoutSession);
router.get('/checkout-session/:id', requireAuth, getCheckoutSessionStatus);

export default router;
