import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// A Checkout Session pays for exactly one booking. Once a booking is created
// from it, the booking id is written to the PaymentIntent's metadata so the
// same payment can't be reused.
export async function checkCheckoutSession({ sessionId, studentId, tutorId }) {
  let session;
  try {
    session = await stripe.checkout.sessions.retrieve(sessionId, {
      expand: ["payment_intent"],
    });
  } catch (err) {
    return { usable: false, reason: "Payment session not found." };
  }

  if (session.metadata?.student_id !== studentId) {
    return { usable: false, reason: "Payment session belongs to another user." };
  }
  if (tutorId && session.metadata?.tutor_id !== tutorId) {
    return { usable: false, reason: "Payment was made for a different mentor." };
  }
  if (session.payment_status !== "paid") {
    return { usable: false, reason: "Payment has not been completed." };
  }
  if (session.payment_intent?.metadata?.booking_id) {
    return { usable: false, reason: "This payment was already used for a booking." };
  }

  return {
    usable: true,
    tutorId: session.metadata.tutor_id,
    paymentIntentId: session.payment_intent?.id,
  };
}

export async function markCheckoutSessionUsed(paymentIntentId, bookingId) {
  await stripe.paymentIntents.update(paymentIntentId, {
    metadata: { booking_id: String(bookingId) },
  });
}
