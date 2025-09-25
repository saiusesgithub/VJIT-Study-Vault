import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vjitstudyvault/pages/subject_related_materials_page.dart';
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
      final url = 'https://gist.githubusercontent.com/saiusesgithub/cfd9b4aea14e62eb0b35538059905354/raw/8bd0efc779f1e7c2d4461636da1d282aec0298b7/materials.json?cb=${DateTime.now().millisecondsSinceEpoch}';
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
    // Filter materials by selected year, semester, branch, and unique subject
    final filteredMaterials = <dynamic>[];
    final seenSubjects = <String>{};
    for (var item in _materials) {
      if (item['year'] == year &&
          item['semester'] == semester &&
          item['branch'] == branch &&
          !seenSubjects.contains(item['subject'])) {
        filteredMaterials.add(item);
        seenSubjects.add(item['subject']);
      }
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
      body: RefreshIndicator(
        onRefresh: _loadMaterials,
        child: Builder(
          builder: (context) {
            if (!_materialsLoaded) {
              return ListView(
                children: const [
                  SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              children: [
                Text(
                  'Materials Of '
                  '${numberWithSuffix(year)} year '
                  '${numberWithSuffix(semester)} sem of '
                  '${branch != null ? branch : 'Not set'} branch',
                  style: const TextStyle(
                    fontSize: 16,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      final item = filteredMaterials[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectRelatedMaterialsPage(
                                subjectName: item['subject'],
                                allMaterials: _materials,
                              ),
                            ),
                          );
                        },
                        child: Card(
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
                                  item['textbook_url']?.toString() ??
                                      'No textbook image available',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
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
