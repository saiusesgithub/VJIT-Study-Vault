import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  SharedPreferences? prefs;
  bool _prefsLoaded = false;
  String? selectedBranch;
  int? selectedYear;
  int? selectedSemester;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefsLoaded = true;
    });
  }

  Future<void> _logAnalyticsEvent() async {
    if (selectedBranch != null &&
        selectedYear != null &&
        selectedSemester != null) {
      await FirebaseAnalytics.instance.logEvent(
        name: 'onboarding_selection',
        parameters: {
          'branch': selectedBranch ?? '',
          'year': selectedYear ?? 0,
          'semester': selectedSemester ?? 0,
        },
      );
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'branch',
        value: selectedBranch,
      );
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'year',
        value: selectedYear.toString(),
      );
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'semester',
        value: selectedSemester.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF00838F)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF00838F)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            PageViewModel(
              title: "Welcome to \nVJIT Study Vault",
              body: "One app for every branch, every year",
              image: Center(
                child: Image.asset('assets/logos/VjitLogo.png', height: 150),
              ),
              decoration: const PageDecoration(
                pageColor: Colors.transparent,
                titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
                bodyTextStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
              ),
            ),
            PageViewModel(
              title: "Everything in one place",
              body:
                  "- Question Banks\n- Subject Notes\n- Previous Question Papers\n- Assignments and Lab Manuals",
              image: const Icon(
                Icons.file_present,
                size: 100,
                color: Colors.white,
              ),
              decoration: const PageDecoration(
                pageColor: Colors.transparent,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
                bodyTextStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
              ),
            ),
            PageViewModel(
              title: "Simple And Personal",
              body:
                  "1) Choose your branch & year once\n2) See only your class materials\n3) Download anytime -> use offline anytime",
              image: const Icon(Icons.person, size: 100, color: Colors.white),
              decoration: const PageDecoration(
                pageColor: Colors.transparent,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
                bodyTextStyle: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                ),
              ),
            ),
            PageViewModel(
              titleWidget: const SizedBox.shrink(),
              bodyWidget: LayoutBuilder(
                builder: (context, constraints) {
                  final mediaQuery = MediaQuery.of(context);
                  final availableHeight = constraints.hasBoundedHeight
                      ? constraints.maxHeight
                      : mediaQuery.size.height - mediaQuery.padding.vertical;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(availableHeight, 0),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Ready to study smarter?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Orbitron',
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                dropdownColor: Color(0xFF0D47A1),
                                style: TextStyle(color: Colors.white),
                                initialValue: selectedBranch,
                                onChanged: (value) =>
                                    setState(() => selectedBranch = value),
                                decoration: InputDecoration(
                                  labelText: 'Branch',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'CSE',
                                    child: Text('CSE'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'IT',
                                    child: Text('IT'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AIML',
                                    child: Text('AIML'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DS',
                                    child: Text('DS'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ECE',
                                    child: Text('ECE'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'EEE',
                                    child: Text('EEE'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                dropdownColor: Color(0xFF0D47A1),
                                style: TextStyle(color: Colors.white),
                                initialValue: selectedYear,
                                onChanged: (value) =>
                                    setState(() => selectedYear = value),
                                decoration: InputDecoration(
                                  labelText: 'Year',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('1st Year'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('2nd Year'),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text('3rd Year'),
                                  ),
                                  DropdownMenuItem(
                                    value: 4,
                                    child: Text('4th Year'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                dropdownColor: Color(0xFF0D47A1),
                                style: TextStyle(color: Colors.white),
                                initialValue: selectedSemester,
                                onChanged: (value) =>
                                    setState(() => selectedSemester = value),
                                decoration: InputDecoration(
                                  labelText: 'Semester',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('1st Semester'),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text('2nd Semester'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              decoration: const PageDecoration(
                bodyAlignment: Alignment.center,
                pageColor: Colors.transparent,
              ),
            ),
          ],
          onDone: () async {
            if (selectedBranch != null &&
                selectedYear != null &&
                selectedSemester != null) {
              await prefs!.setString('branch', selectedBranch!);
              await prefs!.setInt('year', selectedYear!);
              await prefs!.setInt('semester', selectedSemester!);
              await prefs!.setBool('onboardingComplete', true);

              await _logAnalyticsEvent();

              if (mounted) {
                Navigator.pushReplacementNamed(context, 'home');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please select your branch, year, and semester',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          showSkipButton: true,
          skip: const Text("Skip"),
          next: const Icon(Icons.arrow_forward),
          done: const Text(
            "Done",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.white70,
            activeSize: Size(22.0, 10.0),
            activeColor: Colors.white,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          baseBtnStyle: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),
    );
  }
}
