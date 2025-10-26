import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../models/auth/auth_response.dart';

class AuthInitializer {
  /// Create the auth provider for dependency injection
  static ChangeNotifierProvider<AuthProvider> createAuthProvider({
    required Widget child,
  }) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(),
      child: child,
    );
  }

  /// Create multiple providers if you have other providers
  static MultiProvider createMultiProvider({
    required Widget child,
    List<ChangeNotifierProvider>? additionalProviders,
  }) {
    final providers = <ChangeNotifierProvider>[
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(),
      ),
      if (additionalProviders != null) ...additionalProviders,
    ];

    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}

/// Extension methods for easier auth access
extension AuthContext on BuildContext {
  AuthProvider get auth => Provider.of<AuthProvider>(this, listen: false);

  AuthProvider get authWatch => Provider.of<AuthProvider>(this);

  bool get isAuthenticated => auth.isAuthenticated;

  UserData? get currentUser => auth.currentUser;

  bool get isAuthLoading => auth.isLoading;
}

class Auth {
  static AuthProvider? _instance;

  static AuthProvider get instance {
    if (_instance == null) {
      throw Exception(
          'Auth provider not initialized. Make sure to wrap your app with AuthProvider.');
    }
    return _instance!;
  }

  static void setInstance(AuthProvider provider) {
    _instance = provider;
  }

  static bool get isAuthenticated => _instance?.isAuthenticated ?? false;
  static UserData? get currentUser => _instance?.currentUser;
  static bool get isLoading => _instance?.isLoading ?? false;
  static AuthState get state => _instance?.state ?? AuthState.initial;
}
