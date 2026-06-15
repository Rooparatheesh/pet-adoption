import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        // We set up 'adb reverse tcp:3000 tcp:3000' so we can use localhost
        return 'http://localhost:3000/api';
      }
    } catch (_) {
      // Platform check can throw on web if not careful, fallback
    }
    return 'http://localhost:3000/api';
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String categories = '/categories';
  static const String pets = '/pets';
  static const String myPets = '/pets/my';
  static const String favorites = '/favorites';
  static const String adoptions = '/adoptions';
}
