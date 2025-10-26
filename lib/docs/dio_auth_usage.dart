// Dio-based Authentication System Usage Example
// ============================================
//
// This file shows how to use the Dio-based authentication system

/*

## Quick Start with Dio Authentication System

### 1. Initialize in main.dart:

```dart
import 'package:flutter/material.dart';
import 'lib/utlis/auth_initializer.dart';
import 'lib/utlis/auth_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize authentication system
  await AuthInitializer.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthInitializer.createAuthProvider(
      child: MaterialApp(
        title: 'BMS Flutter',
        home: AuthApp(
          authenticatedChild: HomePage(),
          unauthenticatedChild: LoginPage(),
          enableSessionWarnings: true,
        ),
      ),
    );
  }
}
```

### 2. Login Example:

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : () async {
                  final success = await authProvider.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: authProvider.isLoading 
                  ? CircularProgressIndicator()
                  : Text('Login'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 3. Make API Calls with Dio:

```dart
import '../utlis/auth_interceptor.dart';

class UserService {
  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await AuthInterceptor.get(
      '/user/profile',
      requiresAuth: true,
    );
    
    return response.data;
  }
  
  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await AuthInterceptor.put(
      '/user/profile',
      data: data,
      requiresAuth: true,
    );
    
    return response.data;
  }
}
```

### 4. Access Auth State:

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          return Column(
            children: [
              Text('Welcome, ${user?.name ?? 'User'}!'),
              Text('Email: ${user?.email ?? 'No email'}'),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## Key Features with Dio:

✅ Automatic request/response interceptors
✅ Built-in timeout handling
✅ Automatic token injection
✅ Better error handling with DioException
✅ Request/response logging
✅ Automatic retry on token expiry
✅ Connection timeout and retry logic
✅ Centralized HTTP configuration
✅ Type-safe response handling

## Dio Benefits over HTTP:

🚀 Better performance and features
🚀 Built-in interceptors for authentication
🚀 Automatic JSON serialization
🚀 Global configuration options
🚀 Better error handling and types
🚀 Request/response transformation
🚀 Upload progress tracking
🚀 Certificate pinning support

*/
