import 'package:app/screens/search_final/search_provider_new.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/SearchProvider.dart';
import 'package:app/screens/splash/splash_screen.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:flutter/material.dart';



Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();


  // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAMWOBzXQOa1G1rCW5sZITUr-Z4uHXQcU4",
        appId: "1:87062363095:ios:dfc8f26f5ac5d0ec9ce992",
        messagingSenderId: "87062363095",
        projectId: "bookmyspot-c8bdb",
      )
  );


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => SearchProviderNew()),
      ],
      child: MyApp(),
    ),
  );
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookMySpot',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      // initialRoute: SearchFetchAPIData.routeName,
      routes: routes,
    );
  }
}
