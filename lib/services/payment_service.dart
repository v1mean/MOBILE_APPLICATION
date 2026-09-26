import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../main.dart'; // For session

class PaymentService {
  static Future<bool> initPaymentSheet(String tutorId) async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) throw Exception('User not logged in');

      // 1. Get client secret from backend (amount is derived server-side
      // from the tutor's stored rate, not sent from the client)
      final clientSecret = await _createPaymentIntent(tutorId, session.accessToken);

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

  static Future<String> _createPaymentIntent(String tutorId, String accessToken) async {
    final uri = Uri.parse('${ApiService.baseUrl}/payments/create-intent');

    // For emulator testing handling localhost
    Uri finalUri = uri;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
       final fallbackBase = ApiService.baseUrl.contains('10.0.2.2')
           ? 'http://localhost:5005/api'
           : 'http://10.0.2.2:5005/api';
       finalUri = Uri.parse('$fallbackBase/payments/create-intent');
    }

    final response = await http.post(
      finalUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'tutor_id': tutorId,
        'currency': 'usd',
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['clientSecret'];
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to create payment intent');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
