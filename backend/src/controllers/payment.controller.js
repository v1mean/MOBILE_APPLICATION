import { supabaseAdmin } from '../config/supabase.js';
import { getAllowedOrigins } from '../config/origins.js';
import { stripe, checkCheckoutSession } from '../services/payment.service.js';

// Amount is derived from the tutor's own stored rate, never trusted from
// the client, so a tampered request can't pay less than the listed price.
async function getTutorRate(tutorId) {
  const { data: tutorProfile, error } = await supabaseAdmin
    .from('tutor_profiles')
    .select('hourly_rate')
    .eq('tutor_id', tutorId)
    .single();

  if (error || !tutorProfile) {
    return { status: 404, message: 'Tutor not found' };
  }

  const amount = Number(tutorProfile.hourly_rate) || 0;
  if (amount <= 0) {
    return { status: 400, message: 'Tutor has no bookable rate set' };
  }

  return { amount };
}

export async function createPaymentIntent(req, res) {
  try {
    const { tutor_id, currency = 'usd' } = req.body;

    if (!tutor_id) {
      return res.status(400).json({ success: false, message: 'tutor_id is required' });
    }

    const rate = await getTutorRate(tutor_id);
    if (!rate.amount) {
      return res.status(rate.status).json({ success: false, message: rate.message });
    }

    // Optional: create a customer. For simplicity, we just create a PaymentIntent.
    // A more advanced flow would map the user ID to a Stripe Customer.
    const customer = await stripe.customers.create();

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(rate.amount * 100), // Stripe expects amounts in cents
      currency,
      customer: customer.id,
      automatic_payment_methods: {
        enabled: true,
      },
      // Lets a booking be matched to the payment that paid for it.
      metadata: { tutor_id: String(tutor_id), student_id: req.user.id },
    });

    return res.status(200).json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      customerId: customer.id,
      ephemeralKey: 'none', // Ephemeral key is for saved cards, skipping for basic implementation
    });
  } catch (error) {
    console.error('[createPaymentIntent] error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

// ── POST /api/payments/create-checkout-session ─────────────────────────────
// Browser payment path: the mobile payment sheet doesn't exist on web, so the
// web app redirects to a Stripe-hosted page and comes back with a session id.
export async function createCheckoutSession(req, res) {
  try {
    const { tutor_id, origin, currency = 'usd' } = req.body;

    if (!tutor_id) {
      return res.status(400).json({ success: false, message: 'tutor_id is required' });
    }

    // Only redirect back to our own web app, never to a client-supplied site.
    if (!origin || !getAllowedOrigins().includes(origin)) {
      return res.status(400).json({ success: false, message: 'Origin is not allowed' });
    }

    const rate = await getTutorRate(tutor_id);
    if (!rate.amount) {
      return res.status(rate.status).json({ success: false, message: rate.message });
    }

    const metadata = { tutor_id, student_id: req.user.id };
    const tutorParam = encodeURIComponent(tutor_id);

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [
        {
          price_data: {
            currency,
            product_data: { name: '1-hour tutoring session' },
            unit_amount: Math.round(rate.amount * 100),
          },
          quantity: 1,
        },
      ],
      metadata,
      payment_intent_data: { metadata },
      success_url: `${origin}/?checkout_session_id={CHECKOUT_SESSION_ID}&tutor_id=${tutorParam}`,
      cancel_url: `${origin}/#/mentor/${tutorParam}`,
    });

    return res.status(200).json({ success: true, url: session.url });
  } catch (error) {
    console.error('[createCheckoutSession] error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

// ── GET /api/payments/checkout-session/:id ─────────────────────────────────
export async function getCheckoutSessionStatus(req, res) {
  try {
    const result = await checkCheckoutSession({
      sessionId: req.params.id,
      studentId: req.user.id,
    });

    return res.status(200).json({
      success: true,
      usable: result.usable,
      message: result.reason,
      tutor_id: result.tutorId,
    });
  } catch (error) {
    console.error('[getCheckoutSessionStatus] error:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
}
