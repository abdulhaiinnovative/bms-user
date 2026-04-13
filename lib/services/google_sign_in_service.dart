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
      // Check if platform supports authenticate method
      if (_googleSignIn.supportsAuthenticate()) {
        final account = await _googleSignIn.authenticate();

        // Get authorization for email and profile scopes
        final authorization = await account.authorizationClient
            .authorizationForScopes(['email', 'profile']);

        if (authorization == null) {
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

        return GoogleSignInResult.success(
          accountData: accountData,
          idToken: account.id,
          accessToken: authorization.accessToken,
        );
      } else {
        return GoogleSignInResult.error(
          'Google Sign-In not supported on this platform',
        );
      }
    } catch (e) {
      // Check if user cancelled
      if (e.toString().contains('sign_in_canceled') ||
          e.toString().contains('cancelled')) {
        return GoogleSignInResult.cancelled();
      }

      return GoogleSignInResult.error('Google Sign-In failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Handle sign-out error
    }
  }

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      // Handle disconnect error
    }
  }

  /// Get user info from the result
  /// Use this to extract user information from GoogleSignInResult
  Map<String, String> getUserInfoFromResult(GoogleSignInResult result) {
    if (!result.isSuccess || result.accountData == null) {
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
    return {};
  }
}
