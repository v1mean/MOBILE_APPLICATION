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

// The payment-sheet path: the id of this student's succeeded payment for the
// tutor that no booking has claimed yet, or null. Looks back two hours.
export async function findUnusedPayment({ studentId, tutorId }) {
  const since = Math.floor(Date.now() / 1000) - 2 * 60 * 60;
  const intents = await stripe.paymentIntents.list({
    limit: 100,
    created: { gte: since },
  });

  const match = intents.data.find(
    (intent) =>
      intent.status === "succeeded" &&
      intent.metadata?.student_id === studentId &&
      intent.metadata?.tutor_id === tutorId &&
      !intent.metadata?.booking_id
  );
  return match?.id ?? null;
}

export async function markCheckoutSessionUsed(paymentIntentId, bookingId) {
  await stripe.paymentIntents.update(paymentIntentId, {
    metadata: { booking_id: String(bookingId) },
  });
}
