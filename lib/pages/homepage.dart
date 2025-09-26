import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vjitstudyvault/pages/lab_materials.dart';
import 'package:vjitstudyvault/pages/sem_materials_page.dart';
import 'package:vjitstudyvault/pages/settings_page.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int? year;
  int? semester;
  String? branch;
  bool _prefsLoaded = false;
  int currentIndex = 0;
  // Remove pages list, build with up-to-date data in build()

  List<dynamic> _materials = [];
  bool _materialsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _materialsLoaded = false;
    });
    try {
      final url = 'https://vjit-study-vault.web.app/materials.json';
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {"Cache-Control": "no-cache"},
        ),
      );
      final Map<String, dynamic> jsonData = json.decode(response.data);
      setState(() {
        _materials = jsonData['items'] ?? [];
        _materialsLoaded = true;
      });
    } catch (e) {
      setState(() {
        _materialsLoaded = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load materials: $e')));
      }
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      year = prefs.getInt('year');
      semester = prefs.getInt('semester');
      branch = prefs.getString('branch');
      _prefsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded || !_materialsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    Widget body;
    switch (currentIndex) {
      case 0:
        body = SemMaterialsPage(
          year: year,
          semester: semester,
          branch: branch,
          materials: _materials,
          materialsLoaded: _materialsLoaded,
          loadMaterials: _loadMaterials,
        );
        break;
      case 1:
        body = const LabMaterialsPage();
        break;
      case 2:
        body = const SettingsPage();
        break;
      default:
        body = const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logos/vjit_logo.png', height: 32, width: 32),
            const SizedBox(width: 8),
            const Text(
              'VJIT STUDY VAULT',
              style: TextStyle(fontFamily: 'Orbitron'),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Sem Materials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Lab Materials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  String numberWithSuffix(int? year) {
    if (year == null) return '';
    switch (year) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      case 4:
        return '4th';
      default:
        return '$year';
    }
  }
}
