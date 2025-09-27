import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
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

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    List<Widget> pages = [pageZero(), pageOne(), pageTwo(), pageThree()];
    return Scaffold(
      body: ConcentricPageView(
        nextButtonBuilder: (context) {
          if (_currentPage == 3) {
            bool canProceed =
                selectedBranch != null &&
                selectedYear != null &&
                selectedSemester != null;
            return GestureDetector(
              onTap: canProceed
                  ? () async {
                      await prefs!.setString('branch', selectedBranch!);
                      await prefs!.setInt('year', selectedYear!);
                      await prefs!.setInt('semester', selectedSemester!);
                      await prefs!.setBool('onboardingComplete', true);
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, 'home');
                      }
                    }
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select your branch, year, and semester',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
              child: Icon(
                Icons.check,
                color: canProceed ? Colors.white : Colors.grey,
              ),
            );
          }
          return Icon(Icons.arrow_forward, color: Colors.white);
        },
        colors: const <Color>[Colors.red, Colors.blue, Colors.red, Colors.blue],
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (int currentPageIndex) {
          return Center(child: pages[currentPageIndex]);
        },
        onChange: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
      ),
    );
  }

  Widget pageZero() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset('assets/logos/vjit_logo.png'),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Welcome to \nVJIT Study Vault',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Orbitron',
              ),
            ),
          ),
          SizedBox(height: 50),
          Text(
            'One app for every branch, every year',
            style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget pageOne() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // replaced IMAGE placeholder with icon
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.file_present, size: 28, color: Colors.white),
          ),

          Text(
            'Everything in one place',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Orbitron',
            ),
          ),

          SizedBox(height: 50),

          Text(
            ' - Subject Notes\n - Previous Question Papers\n - Assignments and Lab Manuals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Orbitron',
            ),
          ),

          SizedBox(height: 50),

          Text(
            'No more messy Drive/WhatsApp groups',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }

  Widget pageTwo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // replaced IMAGE placeholder with icon
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 28, color: Colors.white),
        ),

        Text(
          'Simple And Personal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Orbitron',
          ),
        ),

        SizedBox(height: 50),

        Text(
          '1) Choose your branch & year once\n2) See only your class materials\n3) Download anytime -> use offline anytime',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Orbitron',
          ),
        ),
      ],
    );
  }

  Widget pageThree() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Ready to study smarter?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Orbitron',
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Let\'s set up your branch and year',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Orbitron',
          ),
        ),
        SizedBox(height: 60),

        DropdownMenu<String>(
          onSelected: (value) => setState(() => selectedBranch = value),
          width: 200,
          label: Text('branch'),
          initialSelection: selectedBranch,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 'CSE', label: 'CSE'),
            DropdownMenuEntry(value: 'IT', label: 'IT'),
            DropdownMenuEntry(value: 'AIML', label: 'AIML'),
            DropdownMenuEntry(value: 'DS', label: 'DS'),
            DropdownMenuEntry(value: 'ECE', label: 'ECE'),
            DropdownMenuEntry(value: 'EEE', label: 'EEE'),
          ],
        ),
        SizedBox(height: 10),

        DropdownMenu<int>(
          onSelected: (value) => setState(() => selectedYear = value),
          width: 200,
          label: Text('year'),
          initialSelection: selectedYear,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: '1st Year'),
            DropdownMenuEntry(value: 2, label: '2nd Year'),
            DropdownMenuEntry(value: 3, label: '3rd Year'),
            DropdownMenuEntry(value: 4, label: '4th Year'),
          ],
        ),
        SizedBox(height: 10),

        DropdownMenu<int>(
          onSelected: (value) => setState(() => selectedSemester = value),
          width: 200,
          label: Text('semester'),
          initialSelection: selectedSemester,
          dropdownMenuEntries: [
            DropdownMenuEntry(value: 1, label: '1st Semester'),
            DropdownMenuEntry(value: 2, label: '2nd Semester'),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
