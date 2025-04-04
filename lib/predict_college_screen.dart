import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'saved_colleges_service.dart';
import 'app_drawer.dart';
import 'user_services.dart';

class PredictCollegeScreen extends StatefulWidget {
  const PredictCollegeScreen({super.key});

  @override
  State<PredictCollegeScreen> createState() => _PredictCollegeScreenState();
}

class _PredictCollegeScreenState extends State<PredictCollegeScreen> {
  final TextEditingController _percentileController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _branches = [];
  List<String> _seatTypes = [];
  List<String> _selectedBranches = [];
  List<String> _selectedSeatTypes = [];
  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _filteredColleges = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _userName = '';
  String _userEmail = '';


  @override
  void initState() {
    super.initState();
    _loadCollegesFromCsv();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetForm();
      _loadUserDetails(); // Load user name and email
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _loadUserDetails() async {
    final userData = await fetchUserData();
    setState(() {
      _userName = userData['full_name'] ?? 'User Name';
      _userEmail = userData['email'] ?? 'user@example.com';
    });
  }


  @override
  void dispose() {
    _percentileController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _percentileController.clear();
      _searchController.clear();
      _selectedBranches = [];
      _selectedSeatTypes = [];
      _filteredColleges = [];
      _searchQuery = '';
    });
  }



  void _loadCollegesFromCsv() async {
    final rawData = await rootBundle.loadString("assets/colleges.csv");
    List<List<dynamic>> csvTable = CsvToListConverter().convert(rawData, eol: '\n');

    List<String> headers = List<String>.from(csvTable[0]);
    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < csvTable.length; i++) {
      Map<String, dynamic> row = {};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = csvTable[i][j];
      }
      data.add(row);
    }

    final uniqueBranches = data.map((e) => e["branch"].toString()).toSet().toList();
    final uniqueSeatTypes = data.map((e) => e["seat_type"].toString()).toSet().toList();

    setState(() {
      _colleges = data;
      _branches = uniqueBranches;
      _seatTypes = uniqueSeatTypes;
      _isLoading = false;
    });
  }

  void _filterColleges() {
    final input = _percentileController.text.trim();
    final bool hasInput = input.isNotEmpty;
    final bool hasBranches = _selectedBranches.isNotEmpty;
    final bool hasSeatTypes = _selectedSeatTypes.isNotEmpty;

    if (!hasInput || !hasBranches || !hasSeatTypes) {
      String message = '';
      if (!hasInput) message += 'Please enter your percentile.\n';
      if (!hasBranches) message += 'Please select at least one branch.\n';
      if (!hasSeatTypes) message += 'Please select at least one seat type.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.trim()),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final double? userPercentile = double.tryParse(input);
    if (userPercentile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid percentile input.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final filtered = _colleges.where((college) {
      final double? min = double.tryParse(college['min']?.toString() ?? '');
      final double? max = double.tryParse(college['max']?.toString() ?? '');
      final String branch = (college['branch'] ?? '').toString().toLowerCase().trim();
      final String seatType = (college['seat_type'] ?? '').toString().toLowerCase().trim();

      return min != null &&
          max != null &&
          userPercentile >= min &&
          userPercentile <= max &&
          _selectedBranches.any((b) => b.toLowerCase().trim() == branch) &&
          _selectedSeatTypes.any((s) => s.toLowerCase().trim() == seatType);
    }).toList();

    setState(() {
      _filteredColleges = filtered;
    });
  }

  void _saveCollege(Map<String, dynamic> college) {
    final savedService = SavedCollegesService();
    setState(() {
      if (savedService.isCollegeSaved(college)) {
        savedService.removeCollege(college);
      } else {
        savedService.saveCollege(college);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchFilteredColleges = _filteredColleges.where((college) {
      final collegeText = [
        college['college_name']?.toString(),
        college['branch']?.toString(),
        college['seat_type']?.toString()
      ].join(' ').toLowerCase();

      return collegeText.contains(_searchQuery.toLowerCase().trim());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Predict College',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
          ),
        ],
      ),
      drawer: AppDrawer(
        userName: _userName, // Replace with actual name from user data
        userEmail: _userEmail, // Replace with actual email
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        onThemeToggle: (isDark) {
          // TODO: implement actual theme change logic here
          print("Theme toggled: $isDark");
        },
        onLogout: () {
          // TODO: implement logout logic
          print("Logout clicked");
        },
        onSelectTab: (index) {
          // Optional: You can use Navigator.pushReplacement here if needed
          print("Tab selected: $index");
        },
        navigateToProfile: () {
          // Navigator.pushNamed(context, '/profile'); // Example
        },
        navigateToSavedColleges: () {
          // Navigator.pushNamed(context, '/saved-colleges'); // Example
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async => _resetForm(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Enter Your Percentile:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _percentileController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Ex: 92.5",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Select Branch(es):",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                MultiSelectDialogField(
                  items: _branches.map((e) => MultiSelectItem(e, e)).toList(),
                  listType: MultiSelectListType.CHIP,
                  title: const Text("Branches"),
                  buttonText: const Text("Choose Branch(es)"),
                  initialValue: _selectedBranches,
                  onConfirm: (values) {
                    setState(() {
                      _selectedBranches = List<String>.from(values);
                    });
                  },
                ),

                const SizedBox(height: 16),
                const Text("Select Seat Type(s):",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                MultiSelectDialogField(
                  items: _seatTypes.map((e) => MultiSelectItem(e, e)).toList(),
                  listType: MultiSelectListType.CHIP,
                  title: const Text("Seat Types"),
                  buttonText: const Text("Choose Seat Type(s)"),
                  initialValue: _selectedSeatTypes,
                  onConfirm: (values) {
                    setState(() {
                      _selectedSeatTypes = List<String>.from(values);
                    });
                  },
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _filterColleges,
                    child: Text('Find Colleges',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _resetForm,
                    child: Text('Reset Form', style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),

                if (_filteredColleges.isNotEmpty) ...[
                  const Text("Recommended Colleges:",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search college, branch or seat type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchFilteredColleges.length,
                    itemBuilder: (context, index) {
                      final college = searchFilteredColleges[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          title: Text(college['college_name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Branch: ${college['branch'] ?? ''}"),
                              Text("Seat Type: ${college['seat_type'] ?? ''}"),
                              Text(
                                  "Percentile Range: ${college['min'] ?? ''} - ${college['max'] ?? ''}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              SavedCollegesService().isCollegeSaved(college)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.blue,
                            ),
                            onPressed: () => _saveCollege(college),
                          ),
                        ),
                      );
                    },
                  ),
                ] else if (_percentileController.text.isNotEmpty) ...[
                  const Text("No colleges found matching your input.",
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
