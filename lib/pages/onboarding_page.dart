import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    int currentPageIndex = 0;
    List<Widget> pages = [pageZero(), pageOne(), pageTwo(), pageThree()];
    return Scaffold(
      body: ConcentricPageView(
        nextButtonBuilder: (context) =>
            Icon(Icons.arrow_forward, color: Colors.white),
        colors: const <Color>[Colors.red, Colors.blue, Colors.red, Colors.blue],
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (int currentPageIndex) {
          return Center(child: pages[currentPageIndex]);
        },
      ),
    );
  }

  Widget pageZero() {
    return Container(
      child: Center(
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
            Text(
              'Welcome to VJIT Study Vault',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Orbitron',
              ),
            ),
            SizedBox(height: 50),
            Text(
              'One app for every branch, every year',
              style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
            ),
            SizedBox(height: 20),
            Text(
              'By students, for students',
              style: TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
            ),
          ],
        ),
      ),
    );
  }

  Widget pageOne() {
    return Container();
  }

  Widget pageTwo() {
    return Container();
  }

  Widget pageThree() {
    return Container();
  }
}
