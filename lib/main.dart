import 'package:app/features/search/presentation/providers/search_provider_new.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:app/providers/cart_provider.dart';
import 'package:app/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:app/features/home/presentation/viewmodels/top_salons_view_model.dart';
import 'package:app/presentation/viewmodels/favourites/favourites_view_model.dart';
import 'package:app/features/profile/presentation/viewmodels/profile_view_model.dart';
import 'package:app/features/notifications/presentation/viewmodels/notifications_view_model.dart';
import 'package:app/presentation/viewmodels/salon/salon_view_model.dart';
import 'package:app/presentation/viewmodels/bookings/bookings_view_model.dart';
import 'package:app/features/auth/presentation/screens/splash/splash_screen.dart';
import 'package:app/utils/restriction_handler.dart';
import 'package:app/screens/profile/edit_profile_screen.dart';
import 'package:app/services/notifications/notification_service.dart';
import 'package:app/screens/test/salon_details_scrolling_tabs_effect_b.dart';
import 'package:app/features/home/presentation/screens/service_detail_screen.dart';
import 'package:app/features/home/presentation/screens/deals_list_screen.dart';
import 'firebase_options.dart';
import 'theme.dart';
// Booking flow screens
import 'package:app/screens/test_scroll/select_professionals.dart';
import 'package:app/screens/test_scroll/SelectDateScreen.dart';
import 'package:app/screens/test_scroll/select_time_screen.dart';
import 'package:app/screens/test_scroll/confirm_booking_screen.dart';
import 'package:app/features/bookings/presentation/screens/booking_details_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const _deepLinkChannel = MethodChannel('com.bms.app/deeplink');

void _navigateDeepLink(String type, int id) {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return;

  switch (type) {
    case 'salon':
      navigator.push(MaterialPageRoute(
        builder: (_) => const SalonDetailsScrollingTabsEffectB(),
        settings: RouteSettings(arguments: '$id'),
      ));
    case 'service':
      navigator.push(MaterialPageRoute(
        builder: (_) => ServiceDetailScreen(serviceId: id),
      ));
    case 'deal':
      navigator.push(MaterialPageRoute(
        builder: (_) => DealsListScreen(initialDealId: id),
      ));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '87062363095-mrde6nmhi2d2v9ptrfotoqdpgu2a26pr.apps.googleusercontent.com',
  );

  // Initialize Notification Service
  await NotificationService.initialize(navigatorKey: navigatorKey);

  // Handle deep links from native Android (bookmyspot://go/...)
  _deepLinkChannel.setMethodCallHandler((call) async {
    if (call.method == 'navigate' && call.arguments is Map) {
      final args = call.arguments as Map;
      final type = args['type'] as String?;
      final id = args['id'] as int?;
      if (type != null && id != null) {
        _navigateDeepLink(type, id);
      }
    }
  });

  runApp(
    MultiProvider(
      providers: [
        // Authentication Provider (keep for auth infrastructure)
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Cart Provider
        ChangeNotifierProvider(create: (context) => CartProvider()),

        // MVVM ViewModels
        ChangeNotifierProvider(create: (context) => SearchProviderNew()),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => TopSalonsViewModel()),
        ChangeNotifierProvider(create: (context) => FavouritesViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (context) => SalonViewModel()),
        ChangeNotifierProvider(create: (context) => BookingsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Initialize restriction handler with app context
    RestrictionHandler.initialize(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'BookMySpot',
      theme: AppTheme.lightTheme(context),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        // Handle booking flow routes
        switch (settings.name) {
          case '/edit_profile':
            return MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
              settings: settings,
            );
          case '/select_professionals':
            if (!context.read<AuthProvider>().isAuthenticated) {
              return MaterialPageRoute(
                builder: (context) => const _AuthRequiredDialogScreen(),
                settings: settings,
              );
            }
            return MaterialPageRoute(
              builder: (context) => const SelectProfessionals(),
              settings: settings,
            );
          case '/select-date':
            return MaterialPageRoute(
              builder: (context) => const SelectDateScreen(),
              settings: settings,
            );
          case '/select-time':
            return MaterialPageRoute(
              builder: (context) => const SelectTimeScreen(),
              settings: settings,
            );
          case '/confirm-booking':
            return MaterialPageRoute(
              builder: (context) => const ConfirmBookingScreen(),
              settings: settings,
            );
          case '/appointment':
            final args = settings.arguments as Map<String, dynamic>?;
            final id = args?['id'] ?? args?['appointmentId'] ?? args?['bookingId'];
            if (id != null) {
              return MaterialPageRoute(
                builder: (context) => BookingDetailsScreen(
                  bookingId: id is int ? id : int.tryParse(id.toString()) ?? 0,
                ),
                settings: settings,
              );
            }
            return null;
          default:
            return null; // Let Flutter handle unknown routes
        }
      },
    );
  }
}

class _AuthRequiredDialogScreen extends StatefulWidget {
  const _AuthRequiredDialogScreen();

  @override
  State<_AuthRequiredDialogScreen> createState() =>
      _AuthRequiredDialogScreenState();
}

class _AuthRequiredDialogScreenState extends State<_AuthRequiredDialogScreen> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Sign in required'),
            content: const Text(
              'Please sign in to continue booking.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Not now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Sign in'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (result == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
