import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In Result Model
class GoogleSignInResult {
  final Map<String, dynamic>? accountData;
  final String? idToken;
  final String? accessToken;
  final String? error;
  final bool isSuccess;
  final bool isCancelled;

  const GoogleSignInResult._({
    this.accountData,
    this.idToken,
    this.accessToken,
    this.error,
    required this.isSuccess,
    required this.isCancelled,
  });

  factory GoogleSignInResult.success({
    required Map<String, dynamic> accountData,
    required String idToken,
    String? accessToken,
  }) {
    return GoogleSignInResult._(
      accountData: accountData,
      idToken: idToken,
      accessToken: accessToken,
      isSuccess: true,
      isCancelled: false,
    );
  }

  factory GoogleSignInResult.error(String error) {
    return GoogleSignInResult._(
      error: error,
      isSuccess: false,
      isCancelled: false,
    );
  }

  factory GoogleSignInResult.cancelled() {
    return const GoogleSignInResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  String? get email => accountData?['email'];
  String? get displayName => accountData?['displayName'];

  @override
  String toString() {
    if (isSuccess) {
      return 'GoogleSignInResult.success(email: ${accountData?['email']})';
    } else if (isCancelled) {
      return 'GoogleSignInResult.cancelled()';
    } else {
      return 'GoogleSignInResult.error($error)';
    }
  }
}

class GoogleSignInService {
  // Singleton pattern
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  // Google Sign In instance (will be initialized in main.dart)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Sign in with Google using new authenticate() API
  /// Returns GoogleSignInResult with account data and tokens
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      log('🔵 GoogleSignInService: Starting Google Sign-In...');

      // Check if platform supports authenticate method
      if (_googleSignIn.supportsAuthenticate()) {
        final account = await _googleSignIn.authenticate();

        log('✅ GoogleSignInService: Authentication successful');
        log('   Email: ${account.email}');
        log('   Display Name: ${account.displayName}');
        log('   ID: ${account.id}');

        // Get authorization for email and profile scopes
        final authorization = await account.authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (authorization == null) {
          log('❌ GoogleSignInService: Failed to get authorization');
          return GoogleSignInResult.error('Failed to get authorization');
        }

        // Extract user info
        final displayName = account.displayName ?? '';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final accountData = {
          'id': account.id,
          'email': account.email,
          'displayName': displayName,
          'photoUrl': account.photoUrl ?? '',
          'firstName': firstName,
          'lastName': lastName,
        };

        log('✅ GoogleSignInService: Got access token');

        return GoogleSignInResult.success(
          accountData: accountData,
          idToken: account.id,
          accessToken: authorization.accessToken,
        );
      } else {
        log('❌ GoogleSignInService: authenticate() not supported on this platform');
        return GoogleSignInResult.error(
          'Google Sign-In not supported on this platform',
        );
      }
    } catch (e) {
      log('❌ GoogleSignInService: Sign-In error - $e');

      // Check if user cancelled
      if (e.toString().contains('sign_in_canceled') ||
          e.toString().contains('cancelled')) {
        log('⚠️ GoogleSignInService: Sign-In cancelled by user');
        return GoogleSignInResult.cancelled();
      }

      return GoogleSignInResult.error('Google Sign-In failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      log('🔵 GoogleSignInService: Signing out...');
      await _googleSignIn.signOut();
      log('✅ GoogleSignInService: Sign-Out successful');
    } catch (e) {
      log('❌ GoogleSignInService: Sign-Out error - $e');
    }
  }

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      log('🔵 GoogleSignInService: Disconnecting...');
      await _googleSignIn.disconnect();
      log('✅ GoogleSignInService: Disconnect successful');
    } catch (e) {
      log('❌ GoogleSignInService: Disconnect error - $e');
    }
  }

  /// Get user info from the result
  /// Use this to extract user information from GoogleSignInResult
  Map<String, String> getUserInfoFromResult(GoogleSignInResult result) {
    if (!result.isSuccess || result.accountData == null) {
      log('⚠️ GoogleSignInService: No account data available');
      return {};
    }

    final accountData = result.accountData!;

    return {
      'email': accountData['email'] ?? '',
      'name': accountData['displayName'] ?? '',
      'first_name': accountData['firstName'] ?? '',
      'last_name': accountData['lastName'] ?? '',
      'provider': 'google',
      'provider_id': accountData['id'] ?? '',
      'image': accountData['photoUrl'] ?? '',
    };
  }

  /// Legacy getUserInfo() method - kept for backwards compatibility
  /// Deprecated: This won't work with the new authenticate() API
  @Deprecated('Use getUserInfoFromResult() with GoogleSignInResult instead')
  Map<String, String> getUserInfo() {
    log('⚠️ GoogleSignInService: getUserInfo() is deprecated');
    return {};
  }
}
