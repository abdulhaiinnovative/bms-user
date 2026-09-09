import 'package:google_sign_in/google_sign_in.dart';

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
}

class GoogleSignInService {
  static final GoogleSignInService _instance =
      GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        return GoogleSignInResult.error(
            "Google Sign-In not supported on this platform");
      }

      final account = await _googleSignIn.authenticate();

      // ✅ IMPORTANT FIX: handle null
      if (account == null) {
        return GoogleSignInResult.cancelled();
      }

      final auth = await account.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      if (auth == null) {
        return GoogleSignInResult.error("Authorization failed");
      }

      final displayName = account.displayName ?? '';
      final parts = displayName.split(' ');

      final data = {
        'id': account.id,
        'email': account.email,
        'displayName': displayName,
        'photoUrl': account.photoUrl ?? '',
        'firstName': parts.isNotEmpty ? parts.first : '',
        'lastName': parts.length > 1 ? parts.sublist(1).join(' ') : '',
      };

      return GoogleSignInResult.success(
        accountData: data,
        idToken: account.id,
        accessToken: auth.accessToken,
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains("cancel")) {
        return GoogleSignInResult.cancelled();
      }

      return GoogleSignInResult.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Map<String, String> getUserInfoFromResult(GoogleSignInResult result) {
    if (!result.isSuccess || result.accountData == null) return {};

    final d = result.accountData!;

    return {
      'email': d['email'] ?? '',
      'name': d['displayName'] ?? '',
      'first_name': d['firstName'] ?? '',
      'last_name': d['lastName'] ?? '',
      'provider': 'google',
      'provider_id': d['id'] ?? '',
      'image': d['photoUrl'] ?? '',
    };
  }
}