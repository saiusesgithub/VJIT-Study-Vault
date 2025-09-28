import 'package:flutter/material.dart';
import 'package:vjitstudyvault/pages/contribute_page.dart';
import 'package:vjitstudyvault/pages/feedback_and_report_page.dart';
import 'package:vjitstudyvault/pages/homepage.dart';
import 'package:vjitstudyvault/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vjitstudyvault/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? prefs;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoaded = true;
    });
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
