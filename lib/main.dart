import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/web/web.dart';
import 'theme/theme_provider.dart';

//Android < 7.1.1 Internet Certificate error fix
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

main() async {
  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: AppTheme().darkTheme,
      theme: AppTheme().lightTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: "Custom Error Page",
      home: const Scaffold(
        body: SafeArea(
          child: WebScreen(),
        ),
      ),
    );
  }
}
