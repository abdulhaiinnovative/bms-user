import 'package:flutter/material.dart';
import 'auth_manager.dart';
import '../presentation/screens/auth/auth_screen.dart';

/// Auth Guard Widget - Protects routes by checking authentication status
/// Wrap any screen that requires authentication with this widget
class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool redirectToLogin;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectToLogin = true,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await AuthManager.isLoggedIn();

    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isChecking = false;
      });

      // If not authenticated and should redirect, navigate to login
      if (!isLoggedIn && widget.redirectToLogin) {
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated && !widget.redirectToLogin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please login to access this feature',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AuthScreen.routeName);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Function to check if user is authenticated before navigation
Future<bool> checkAuthentication(BuildContext context) async {
  final isLoggedIn = await AuthManager.isLoggedIn();

  if (!isLoggedIn) {
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }
    return false;
  }

  return true;
}
