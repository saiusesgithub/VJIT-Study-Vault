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
    List<Widget> pages = [pageZero()];
    return Scaffold(
      body: ConcentricPageView(
        colors: const <Color>[Colors.red, Colors.blue, Colors.red, Colors.blue],
        itemCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (int index) {
          return Center(child: pages[index]);
        },
      ),
    );
  }

  Widget pageZero() {
    return Container(
      // color: Colors.red,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logos/vjit_logo.png'),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logos/vjit_logo.png'),
                ),
              ),
            ),
            Text('Welcome to VJIT Study Vault'),
            Text('One app for every branch, every year'),
            Text('By students, for students'),
          ],
        ),
      ),
    );
  }
}
