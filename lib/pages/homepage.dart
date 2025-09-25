import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

  List<dynamic> _materials = [];
  bool _materialsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final String jsonString = await rootBundle.loadString(
      'assets/materials.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _materials = jsonData['items'] ?? [];
      _materialsLoaded = true;
    });
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
    // Filter materials by selected year, semester, branch
    final filteredMaterials = _materials.where((item) {
      return item['year'] == year &&
          item['semester'] == semester &&
          item['branch'] == branch;
    }).toList();

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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        children: [
          Text(
            'Materials Of '
            '${year != null ? year : 'Not set'} year '
            '${semester != null ? semester : 'Not set'} sem of '
            '${branch != null ? branch : 'Not set'} branch',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) {
                final item = filteredMaterials[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['subject'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Orbitron',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['textbook_url']?.toString() ?? 'No textbook',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
        currentIndex: 0,
        onTap: (int index) {
          // TODO: handle navigation
        },
      ),
    );
  }
}
