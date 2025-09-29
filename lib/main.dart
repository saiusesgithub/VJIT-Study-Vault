import 'package:flutter/material.dart';
import 'package:vjitstudyvault/pages/contribute_page.dart';
import 'package:vjitstudyvault/pages/feedback_and_report_page.dart';
import 'package:vjitstudyvault/pages/homepage.dart';
import 'package:vjitstudyvault/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vjitstudyvault/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  SharedPreferences? prefs;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    FirebaseAnalytics.instance.logAppOpen();
    logDeviceInfo(); // Log device information during app initialization

    // Check internet connectivity on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInternetOnAppStart(context);
    });
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> logDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = '${androidInfo.manufacturer} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = '${iosInfo.name} (${iosInfo.model})';
    }

    // Log device name as a user property
    await FirebaseAnalytics.instance.setUserProperty(
      name: 'device_name',
      value: deviceName,
    );

    // Optionally log as an event
    await FirebaseAnalytics.instance.logEvent(
      name: 'device_info',
      parameters: {
        'device_name': deviceName,
      },
    );
  }

  Future<void> checkInternetOnAppStart(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Center(child: CircularProgressIndicator());
    }
    final bool? onboardingComplete = prefs?.getBool('onboardingComplete');
    return MaterialApp(
      title: 'VJIT Study Vault',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      //   fontFamily: 'Poppins',
      // ),
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routes: {
        'onboarding': (context) => const OnboardingPage(),
        'home': (context) => const Homepage(),
        '/feedback_report_bug': (context) => const FeedbackAndReportPage(),
        '/contribute': (context) => const ContributePage(),
      },
      home: onboardingComplete == true
          ? const Homepage()
          : const OnboardingPage(),
    );
  }
}
