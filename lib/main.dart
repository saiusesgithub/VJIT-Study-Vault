import 'package:flutter/material.dart';
import 'package:vjitstudyvault/pages/contribute_page.dart';
import 'package:vjitstudyvault/pages/feedback_and_report_page.dart';
import 'package:vjitstudyvault/pages/homepage.dart';
import 'package:vjitstudyvault/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vjitstudyvault/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routes: {
        'onboarding': (context) => const OnboardingPage(),
        'home': (context) => const Homepage(),
        'feedbackreportbug': (context) => const FeedbackAndReportPage(),
        'contribute': (context) => const ContributePage(),
      },
      home: onboardingComplete == true
          ? const Homepage()
          : const OnboardingPage(),
    );
  }
}
