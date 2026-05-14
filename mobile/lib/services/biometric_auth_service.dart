import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService._();
  static final instance = BiometricAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final deviceSupported = await _auth.isDeviceSupported();
    final canCheck = await _auth.canCheckBiometrics;
    return deviceSupported && canCheck;
  }

  Future<bool> authenticateForAppUnlock() {
    return _authenticate('Unlock Coastal Hub');
  }

  Future<bool> authenticateForPayment() {
    return _authenticate('Confirm payment in Coastal Hub');
  }

  Future<bool> _authenticate(String reason) async {
    try {
      if (!await isAvailable()) {
        return false;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
