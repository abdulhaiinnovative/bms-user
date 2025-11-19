import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import 'auth_middleware.dart';

class AuthApp extends StatefulWidget {
  final Widget authenticatedChild;
  final Widget unauthenticatedChild;
  final Widget? loadingChild;
  final bool enableSessionWarnings;
  final VoidCallback? onSessionExpired;
  final VoidCallback? onSessionWarning;

  const AuthApp({
    Key? key,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
    this.loadingChild,
    this.enableSessionWarnings = true,
    this.onSessionExpired,
    this.onSessionWarning,
  }) : super(key: key);

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthMiddleware.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AuthMiddleware.handleAppResume();
        break;
      case AppLifecycleState.paused:
        AuthMiddleware.handleAppPause();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.initializeAuth();

    if (widget.enableSessionWarnings) {
      AuthMiddleware.initializeSessionMonitoring(
        onSessionExpired: () {
          authProvider.logout();
          widget.onSessionExpired?.call();
        },
        onSessionWarning: () {
          widget.onSessionWarning?.call();
          _showSessionWarning();
        },
      );
    }
  }

  void _showSessionWarning() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expiring'),
          content: const Text(
            'Your session will expire soon. Do you want to extend it?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthMiddleware.extendSessionOnActivity();
              },
              child: const Text('Extend Session'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return widget.loadingChild ??
                const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );

          case AuthState.authenticated:
            return widget.authenticatedChild;

          case AuthState.unauthenticated:
          case AuthState.error:
            return widget.unauthenticatedChild;
        }
      },
    );
  }
}

class SessionActivityWrapper extends StatefulWidget {
  final Widget child;
  final bool extendOnActivity;

  const SessionActivityWrapper({
    Key? key,
    required this.child,
    this.extendOnActivity = true,
  }) : super(key: key);

  @override
  State<SessionActivityWrapper> createState() => _SessionActivityWrapperState();
}

class _SessionActivityWrapperState extends State<SessionActivityWrapper> {
  DateTime _lastActivity = DateTime.now();

  static const Duration _extensionCooldown = Duration(minutes: 5);

  void _onUserActivity() {
    if (!widget.extendOnActivity) return;

    final now = DateTime.now();
    if (now.difference(_lastActivity) >= _extensionCooldown) {
      _lastActivity = now;
      AuthMiddleware.extendSessionOnActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onUserActivity,
      onPanUpdate: (_) => _onUserActivity(),
      onScaleUpdate: (_) => _onUserActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

class AuthGuard {
  static Future<bool> canAccess({
    required BuildContext context,
    bool requireAuth = true,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (requireAuth) {
      return authProvider.isAuthenticated;
    }

    return true;
  }

  static Future<void> navigateWithAuthCheck({
    required BuildContext context,
    required String routeName,
    Object? arguments,
    bool requireAuth = true,
    String? fallbackRoute,
  }) async {
    final canAccess = await AuthGuard.canAccess(
      context: context,
      requireAuth: requireAuth,
    );

    if (canAccess) {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushNamed(
        context,
        fallbackRoute ?? '/login',
        arguments: arguments,
      );
    }
  }

  static Future<void> replaceWithAuthCheck({
    required BuildContext context,
    required String routeName,
    Object? arguments,
    bool requireAuth = true,
    String? fallbackRoute,
  }) async {
    final canAccess = await AuthGuard.canAccess(
      context: context,
      requireAuth: requireAuth,
    );

    if (canAccess) {
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushReplacementNamed(
        context,
        fallbackRoute ?? '/login',
        arguments: arguments,
      );
    }
  }
}
