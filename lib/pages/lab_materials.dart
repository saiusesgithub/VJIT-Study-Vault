import 'package:flutter/material.dart';

class LabMaterialsPage extends StatefulWidget {
  const LabMaterialsPage({super.key});

  @override
  State<LabMaterialsPage> createState() => _LabMaterialsPageState();
}

class _LabMaterialsPageState extends State<LabMaterialsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Coming Soon!',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Orbitron',
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
