import express from 'express';
import { requireAuth } from '../middleware/auth.middleware.js';
import { createPaymentIntent } from '../controllers/payment.controller.js';

const router = express.Router();

router.post('/create-intent', requireAuth, createPaymentIntent);

export default router;
