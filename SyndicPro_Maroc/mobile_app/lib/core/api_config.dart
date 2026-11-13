import 'package:flutter/foundation.dart';

class ApiConfig {
  // Chrome/Edge/Windows use localhost. Android emulator uses 10.0.2.2.
  // For a real phone, replace with your computer's LAN IPv4 address.
  static String get baseUrl => kIsWeb || defaultTargetPlatform == TargetPlatform.windows
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';
}
