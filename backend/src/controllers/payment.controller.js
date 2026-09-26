import Stripe from 'stripe';
import { supabaseAdmin } from '../config/supabase.js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function createPaymentIntent(req, res) {
  try {
    const { tutor_id, currency = 'usd' } = req.body;

    if (!tutor_id) {
      return res.status(400).json({ success: false, message: 'tutor_id is required' });
    }

    // Amount is derived from the tutor's own stored rate, never trusted from
    // the client, so a tampered request can't pay less than the listed price.
    const { data: tutorProfile, error: tutorError } = await supabaseAdmin
      .from('tutor_profiles')
      .select('hourly_rate')
      .eq('tutor_id', tutor_id)
      .single();

    if (tutorError || !tutorProfile) {
      return res.status(404).json({ success: false, message: 'Tutor not found' });
    }

    const amount = Number(tutorProfile.hourly_rate) || 0;
    if (amount <= 0) {
      return res.status(400).json({ success: false, message: 'Tutor has no bookable rate set' });
    }

    // Optional: create a customer. For simplicity, we just create a PaymentIntent.
    // A more advanced flow would map the user ID to a Stripe Customer.
    const customer = await stripe.customers.create();

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe expects amounts in cents
      currency,
      customer: customer.id,
      automatic_payment_methods: {
        enabled: true,
      },
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
