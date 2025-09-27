import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final Future<void> Function() loadMaterials;
  const SettingsPage({super.key, required this.loadMaterials});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentMaxWidth = min(screenWidth - 32.0, 520.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height - 90, // Set specific height
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute elements evenly
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // About card
                SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Made by sAI sRUJAN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "2024-2028 IT Student @ VJIT",
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 25,
                                icon: const Icon(Ionicons.logo_github),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://github.com/saiusesgithub",
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                iconSize: 25,
                                icon: const Icon(Ionicons.logo_linkedin),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://linkedin.com/in/saisrujanpunati",
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                iconSize: 25,
                                icon: const Icon(Ionicons.logo_instagram),
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                      "https://instagram.com/__saisrujan__",
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Branch/Year/Semester display and change
                _BranchYearSemRow(),

                // Bottom: action buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        loadMaterials();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Check For New Materials'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/feedback_report_bug');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Feedback / Report Bug'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/contribute');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Contribute'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// change branch / year / semester
class _BranchYearSemRow extends StatefulWidget {
  @override
  State<_BranchYearSemRow> createState() => _BranchYearSemRowState();
}

class _BranchYearSemRowState extends State<_BranchYearSemRow> {
  String? branch;
  int? year;
  int? semester;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      branch = prefs.getString('branch') ?? '-';
      year = prefs.getInt('year');
      semester = prefs.getInt('semester');
      loading = false;
    });
  }

  void _showChangeDialog() async {
    String? newBranch = branch;
    int? newYear = year;
    int? newSemester = semester;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Branch / Year / Semester'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: newBranch,
                    items: ['CSE', 'IT', 'ECE', 'EEE', 'MECH', 'CIVIL']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => newBranch = v),
                    hint: const Text('Branch'),
                  ),
                  DropdownButton<int>(
                    value: newYear,
                    items: [1, 2, 3, 4]
                        .map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text('Year $y'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => newYear = v),
                    hint: const Text('Year'),
                  ),
                  DropdownButton<int>(
                    value: newSemester,
                    items: [1, 2]
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text('Sem $s')),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => newSemester = v),
                    hint: const Text('Semester'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (newBranch != null &&
                        newYear != null &&
                        newSemester != null) {
                      await prefs.setString('branch', newBranch!);
                      await prefs.setInt('year', newYear!);
                      await prefs.setInt('semester', newSemester!);
                      setState(() {
                        branch = newBranch;
                        year = newYear;
                        semester = newSemester;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Branch: $branch, Year: ${year ?? '-'}, Sem: ${semester ?? '-'}',
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: _showChangeDialog,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
