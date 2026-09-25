import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function createPaymentIntent(req, res) {
  try {
    const { amount, currency = 'usd' } = req.body;

    if (!amount) {
      return res.status(400).json({ success: false, message: 'Amount is required' });
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
