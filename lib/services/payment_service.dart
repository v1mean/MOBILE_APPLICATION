import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../main.dart'; // For session

class PaymentService {
  static Future<bool> initPaymentSheet(String tutorId) async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) throw Exception('User not logged in');

      // 1. Get client secret from backend (amount is derived server-side
      // from the tutor's stored rate, not sent from the client)
      final clientSecret = await _createPaymentIntent(
        tutorId,
        session.accessToken,
      );

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Jomnes Platform',
          // Optional parameters can be added here
        ),
      );

      // 3. Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we get here, payment was successful
      return true;
    } catch (e) {
      if (e is StripeException) {
        debugPrint('Error from Stripe: ${e.error.localizedMessage}');
      } else {
        debugPrint('Unforeseen error: $e');
      }
      return false;
    }
  }

  /// Web only: the payment sheet doesn't exist in browsers, so send the user
  /// to a Stripe-hosted checkout page. The page reloads the app on return.
  static Future<bool> startWebCheckout(String tutorId) async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) throw Exception('User not logged in');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/payments/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: jsonEncode({'tutor_id': tutorId, 'origin': Uri.base.origin}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body['success'] != true) {
        throw Exception(body['message'] ?? 'Failed to start checkout');
      }

      return launchUrl(
        Uri.parse(body['url'] as String),
        webOnlyWindowName: '_self',
      );
    } catch (e) {
      debugPrint('Web checkout error: $e');
      return false;
    }
  }

  /// True when the checkout session is paid and not yet used for a booking.
  static Future<bool> isCheckoutSessionUsable(String sessionId) async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) return false;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/payments/checkout-session/$sessionId'),
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      );
      final body = jsonDecode(response.body);
      return body['success'] == true && body['usable'] == true;
    } catch (e) {
      debugPrint('Checkout session check error: $e');
      return false;
    }
  }

  static Future<String> _createPaymentIntent(
    String tutorId,
    String accessToken,
  ) async {
    final uri = Uri.parse('${ApiService.baseUrl}/payments/create-intent');

    Uri finalUri = uri;

    final response = await http.post(
      finalUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'tutor_id': tutorId, 'currency': 'usd'}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        return jsonResponse['clientSecret'];
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to create payment intent',
        );
      }
    } else {
      throw Exception(
        'Server error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
