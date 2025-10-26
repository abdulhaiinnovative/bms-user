// Example main.dart with proper initialization
// ==========================================
//
// This file shows how to initialize the authentication system
// and other dependencies directly in main.dart

/*

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Import your auth system
import 'lib/providers/auth_provider.dart';
import 'lib/utlis/auth_interceptor.dart';
import 'lib/constants.dart';
import 'lib/utlis/auth_app.dart';

// Import your screens
import 'lib/screens/home/home_screen.dart';
import 'lib/screens/auth/login_screen.dart';
import 'lib/screens/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  await SharedPreferences.getInstance();
  
  // Initialize Dio with AuthInterceptor
  AuthInterceptor.initialize(
    baseUrl: BASE_URL,
    connectTimeout: 30000,
    receiveTimeout: 30000,
    sendTimeout: 30000,
  );
  
  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        
        // Add other providers here as needed
        // ChangeNotifierProvider<UserProvider>(
        //   create: (context) => UserProvider(),
        // ),
        // ChangeNotifierProvider<BookingProvider>(
        //   create: (context) => BookingProvider(),
        // ),
      ],
      child: MaterialApp(
        title: 'BMS Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Add your theme data here
        ),
        home: AuthApp(
          authenticatedChild: HomePage(),
          unauthenticatedChild: LoginPage(),
          loadingChild: SplashScreen(),
          enableSessionWarnings: true,
          onSessionExpired: () {
            // Handle session expiration
            print('Session expired - redirecting to login');
          },
          onSessionWarning: () {
            // Handle session warning
            print('Session expiring soon');
          },
        ),
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/profile': (context) => ProfilePage(),
          // Add other routes
        },
      ),
    );
  }
}

// Alternative approach with direct MaterialApp if you don't want AuthApp wrapper
class MyAppAlternative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'BMS Flutter',
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Initialize auth state on app start
            if (authProvider.state == AuthState.initial) {
              authProvider.initializeAuth();
              return SplashScreen();
            }
            
            // Show appropriate screen based on auth state
            switch (authProvider.state) {
              case AuthState.loading:
                return SplashScreen();
              case AuthState.authenticated:
                return HomePage();
              case AuthState.unauthenticated:
              case AuthState.error:
                return LoginPage();
              default:
                return SplashScreen();
            }
          },
        ),
      ),
    );
  }
}

// Example of accessing auth state in any widget
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return Text('Welcome, ${authProvider.currentUser?.name}!');
        } else {
          return Text('Please log in');
        }
      },
    );
  }
}

// Example of using context extensions
class AnotherExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using the extension methods from AuthInitializer
    if (context.isAuthenticated) {
      return Text('User: ${context.currentUser?.email}');
    } else {
      return ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        child: Text('Login'),
      );
    }
  }
}
```

## Key Points:

1. **Initialize in main()**: All async initialization happens in main() before runApp()
2. **SharedPreferences**: Initialize this first as it's required by AuthManager
3. **Dio Configuration**: Initialize AuthInterceptor with your base URL and timeouts
4. **Provider Setup**: Use MultiProvider to set up all your providers
5. **Auth State Management**: Use Consumer<AuthProvider> or AuthApp wrapper to handle auth states
6. **Context Extensions**: Use the provided extensions for easy auth access

## Benefits of this approach:

✅ Clean separation of concerns
✅ All initialization happens in one place
✅ Easy to add more providers
✅ Proper error handling during initialization
✅ Flexible auth state management

*/
