import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _pinKey = 'app_pin_code';

  // Save PIN
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  // Get PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Verify PIN
  static Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin == inputPin;
  }

  // Check if PIN exists
  static Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  // Delete PIN
  static Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  // Clear all secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
