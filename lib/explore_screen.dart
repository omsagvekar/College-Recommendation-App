import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_drawer.dart';
import 'user_services.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Data variables
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _filteredColleges = [];
  Map<String, List<Map<String, dynamic>>> _groupedColleges = {};
  List<String> _uniqueCollegeNames = [];
  String _userName = '';
  String _userEmail = '';

  // Pagination variables
  int _pageSize = 1000;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetails(); // Load user name and email
    });
    _fetchColleges();
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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchColleges() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      if (_currentPage == 0) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _hasError = false;
    });

    try {
      final int from = _currentPage * _pageSize;
      final int to = from + _pageSize - 1;

      final response = await supabase
          .from('colleges')
          .select('*')
          .range(from, to)
          .order('college_name', ascending: true);

      List<Map<String, dynamic>> newColleges =
          List<Map<String, dynamic>>.from(response);

      _hasMore = newColleges.length == _pageSize;

      setState(() {
        if (_currentPage == 0) {
          _colleges = newColleges;
        } else {
          _colleges.addAll(newColleges);
        }
        _processColleges();
        _filteredColleges = _uniqueCollegeNames
            .map((name) => {'college_name': name, 'branches': _groupedColleges[name]})
            .toList();
        _isLoading = false;
        _isLoadingMore = false;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _errorMessage = 'Failed to load colleges: $e';
      });
    }
  }

  void _processColleges() {
    _groupedColleges = {};
    
    // Group colleges by name
    for (var college in _colleges) {
      final name = college['college_name']?.toString() ?? 'Unknown College';
      if (_groupedColleges.containsKey(name)) {
        _groupedColleges[name]!.add(college);
      } else {
        _groupedColleges[name] = [college];
      }
    }
    
    // Get unique college names
    _uniqueCollegeNames = _groupedColleges.keys.toList()..sort();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applySearch(value);
    });
  }

  void _applySearch(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredColleges = _uniqueCollegeNames
            .map((name) => {'college_name': name, 'branches': _groupedColleges[name]})
            .toList();
      } else {
        final lowerCaseSearch = searchText.toLowerCase();
        final filteredNames = _uniqueCollegeNames
            .where((name) => name.toLowerCase().contains(lowerCaseSearch))
            .toList();
            
        _filteredColleges = filteredNames
            .map((name) => {'college_name': name, 'branches': _groupedColleges[name]})
            .toList();
      }
    });
  }

  void _refreshData() {
    setState(() {
      _colleges = [];
      _filteredColleges = [];
      _groupedColleges = {};
      _uniqueCollegeNames = [];
      _currentPage = 0;
      _hasMore = true;
    });
    _fetchColleges();
  }

  void _showCollegeDetails(String collegeName, List<Map<String, dynamic>> branches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCollegeDetailSheet(collegeName, branches),
    );
  }
  
  Future<void> _searchCollegeOnWeb(String collegeName) async {
    final Uri url = Uri.parse('https://www.google.com/search?q=$collegeName college');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open browser for: $collegeName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Colleges',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
        elevation: 0,
        backgroundColor: isDarkMode ? colorScheme.surface : primaryColor,
        foregroundColor: isDarkMode ? colorScheme.onSurface : Colors.white,
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
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading colleges...',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDarkMode ? Colors.red[300] : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildSearchBar(isDarkMode, primaryColor),
                    Expanded(
                      child: Stack(
                        children: [
                          _filteredColleges.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black26,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No colleges found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          _applySearch('');
                                        },
                                        child: const Text('Clear Search'),
                                      ),
                                    ],
                                  ),
                                )
                              : _buildCollegeList(isDarkMode, primaryColor),
                          if (_hasMore)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _isLoadingMore ? null : _fetchColleges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoadingMore
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Load More'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search colleges...',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applySearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildCollegeList(bool isDarkMode, Color primaryColor) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for the Load More button
      itemCount: _filteredColleges.length,
      itemBuilder: (context, index) {
        final college = _filteredColleges[index];
        final collegeName = college['college_name'] as String;
        final branches = college['branches'] as List<Map<String, dynamic>>;
        
        return _buildCollegeCard(collegeName, branches, isDarkMode, primaryColor);
      },
    );
  }

  Widget _buildCollegeCard(
      String collegeName, List<Map<String, dynamic>> branches, bool isDarkMode, Color primaryColor) {
    // Find unique branches count
    final uniqueBranches = branches
        .map((branch) => branch['branch']?.toString() ?? '')
        .toSet()
        .length;

    // Find unique exam types
    final uniqueExamTypes = branches
        .map((branch) => branch['score_type']?.toString() ?? '')
        .toSet()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCollegeDetails(collegeName, branches),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collegeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$uniqueBranches ${uniqueBranches == 1 ? 'Branch' : 'Branches'} Available',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...uniqueExamTypes.take(2).map((examType) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        examType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                  if (uniqueExamTypes.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${uniqueExamTypes.length - 2} more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollegeDetailSheet(String collegeName, List<Map<String, dynamic>> branches) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    // Group branches by branch name
    Map<String, List<Map<String, dynamic>>> branchesByName = {};
    for (var branch in branches) {
      final branchName = branch['branch']?.toString() ?? 'Unknown Branch';
      if (branchesByName.containsKey(branchName)) {
        branchesByName[branchName]!.add(branch);
      } else {
        branchesByName[branchName] = [branch];
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // College header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            collegeName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton.icon(
                      onPressed: () => _searchCollegeOnWeb(collegeName),
                      icon: const Icon(Icons.open_in_browser, size: 16),
                      label: const Text('More Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Branches content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Available Branches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...branchesByName.entries.map((entry) {
                      final branchName = entry.key;
                      final branchEntries = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            branchName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          collapsedBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: branchEntries.length,
                              itemBuilder: (context, index) {
                                final entry = branchEntries[index];
                                final scoreType = entry['score_type']?.toString() ?? 'Unknown Exam';
                                final seatType = entry['seat_type']?.toString() ?? 'General';
                                final minCutoff = entry['min']?.toDouble() ?? 0;
                                final maxCutoff = entry['max']?.toDouble() ?? 0;
                                final meanCutoff = entry['mean']?.toDouble() ?? 0;
                                
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              scoreType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              seatType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _cutoffInfo('Min', minCutoff, isDarkMode, Colors.orange),
                                          _cutoffInfo('Mean', meanCutoff, isDarkMode, Colors.blue),
                                          _cutoffInfo('Max', maxCutoff, isDarkMode, Colors.green),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cutoffInfo(String label, double value, bool isDarkMode, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}