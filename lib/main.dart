import 'package:flutter/material.dart';

// import 'package:pick_location/screens/landing_screen.dart';
import 'package:url_strategy/url_strategy.dart';

import 'utils/go_router.dart';

void main() {
  setPathUrlStrategy(); // Removes the # from URLs

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // return MaterialApp(
      title: 'تطبيق الطوارئ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo,
        primarySwatch: Colors.indigo,
        fontFamily: 'Cairo',
      ),
      // home: const LandingScreen(),

      routerConfig: router,
    );
  }
}
