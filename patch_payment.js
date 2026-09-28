const fs = require('fs');
let file = 'lib/services/payment_service.dart';
let content = fs.readFileSync(file, 'utf8');

const target = `    // For emulator testing handling localhost
    Uri finalUri = uri;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final fallbackBase = ApiService.baseUrl.contains('10.0.2.2')
          ? 'http://localhost:5005/api'
          : 'http://10.0.2.2:5005/api';
      finalUri = Uri.parse('$fallbackBase/payments/create-intent');
    }`;

const replace = `    Uri finalUri = uri;`;

content = content.replace(target, replace);
fs.writeFileSync(file, content);
