import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer for debounce

  // Filter variables
  String? _selectedScoreType;
  String? _selectedBranch;
  RangeValues _cutoffRange = const RangeValues(0, 100);
  double _minCutoff = 0;
  double _maxCutoff = 100;

  // Data variables
  List<Map<String, dynamic>> _colleges = [];
  List<Map<String, dynamic>> _filteredColleges = [];
  List<String> _branches = [];
  List<String> _scoreTypes = [];
  bool _isLoading = true;
  bool _hasMore = false;
  bool _isFetchingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Pagination variables
  int _pageSize = 1000;
  int _currentPage = 0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchColleges(isInitial: true);
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        if (_hasMore && !_isFetchingMore) {
          _fetchMoreColleges();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel(); // Cancel the debounce timer
    super.dispose();
  }

  Future<void> _fetchColleges(
      {bool isInitial = false, bool isSearch = false}) async {
    if (isInitial || isSearch) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 0; // Reset to the first page
        _colleges = []; // Clear previous colleges
        _filteredColleges = [];
      });
    }

    try {
      final int from = _currentPage * _pageSize;
      final int to = from + _pageSize - 1;

      // Fetch colleges from Supabase with pagination
      final response = await supabase
          .from('colleges')
          .select('*')
          .range(from, to)
          .order('college_name', ascending: true);

      List<Map<String, dynamic>> newColleges =
          List<Map<String, dynamic>>.from(response);

      // Check if there's more data to load
      _hasMore = newColleges.length == _pageSize;

      // Increment the page counter for next fetch
      _currentPage++;

      setState(() {
        _colleges.addAll(newColleges);
        _applyFilters(); // Apply filters after fetching new data

        // If this is the initial load, extract branches and score types
        if (isInitial) {
          _extractFiltersData();
          _findCutoffRange();
        }

        _isLoading = false;
      });

      // Debug output to check data
      print('Loaded ${_colleges.length} colleges so far');
      if (newColleges.isNotEmpty) {
        print('Sample college: ${newColleges[0]}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load colleges: $e';
        print(_errorMessage); // For debugging
      });
    }
  }

  Future<void> _fetchMoreColleges() async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      await _fetchColleges();
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  void _extractFiltersData() {
    // Extract unique branches and score types
    _branches = _colleges
        .map((college) => college['branch']?.toString() ?? '')
        .where((branch) => branch.isNotEmpty)
        .toSet()
        .toList()
      ..sort(); // Sort alphabetically

    _scoreTypes = _colleges
        .map((college) => college['score_type']?.toString() ?? '')
        .where((scoreType) => scoreType.isNotEmpty)
        .toSet()
        .toList()
      ..sort(); // Sort alphabetically
  }

  void _findCutoffRange() {
    // Find min and max cutoffs
    double minFound = double.infinity;
    double maxFound = 0;

    for (var college in _colleges) {
      double min = college['min'] != null
          ? double.tryParse(college['min'].toString()) ?? 0
          : 0;
      double max = college['max'] != null
          ? double.tryParse(college['max'].toString()) ?? 0
          : 0;

      if (min < minFound && min > 0) minFound = min;
      if (max > maxFound) maxFound = max;
    }

    // Set range values with some padding
    _minCutoff = minFound.isFinite ? minFound : 0;
    _maxCutoff = maxFound > 0 ? maxFound : 100;
    _cutoffRange = RangeValues(_minCutoff, _maxCutoff);
  }

  void _applyFilters() {
    // Debug the current search text
    print('Searching for: "${_searchController.text}"');

    setState(() {
      _filteredColleges = _colleges.where((college) {
        // Apply search filter - Ensure safe conversion to string and proper case handling
        final String? collegeName = college['college_name']?.toString();
        final bool nameMatch = _searchController.text.isEmpty ||
            (collegeName != null &&
                collegeName
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()));

        // Apply score type filter
        final scoreTypeMatch = _selectedScoreType == null ||
            _selectedScoreType!.isEmpty ||
            college['score_type']?.toString() == _selectedScoreType;

        // Apply branch filter
        final branchMatch = _selectedBranch == null ||
            _selectedBranch!.isEmpty ||
            college['branch']?.toString() == _selectedBranch;

        // Apply cutoff range filter - Better handling of numeric conversions
        double min = 0;
        double max = 0;

        if (college['min'] != null) {
          min = double.tryParse(college['min'].toString()) ?? 0;
        }

        if (college['max'] != null) {
          max = double.tryParse(college['max'].toString()) ?? 0;
        }

        final cutoffMatch = (min >= _cutoffRange.start || min == 0) &&
            (max <= _cutoffRange.end || max == 0);

        return nameMatch && scoreTypeMatch && branchMatch && cutoffMatch;
      }).toList();

      // Debug output for filtered results
      print('Filtered colleges count: ${_filteredColleges.length}');
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedScoreType = null;
      _selectedBranch = null;
      _cutoffRange = RangeValues(_minCutoff, _maxCutoff);
      _filteredColleges = List<Map<String, dynamic>>.from(_colleges);
    });
  }

  Future<void> _refreshData() async {
    // Reset pagination and reload all data
    _currentPage = 0;
    _colleges = [];
    await _fetchColleges(isInitial: true);
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchColleges(isSearch: true); // Fetch colleges with search
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          ),
        ],
      ),
      body: _isLoading && _colleges.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _hasError && _colleges.isEmpty
              ? _buildErrorView()
              : _buildContentView(isDarkMode),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchColleges(isInitial: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(bool isDarkMode) {
    return Column(
      children: [
        _buildSearchBar(isDarkMode),
        _buildFilterSection(isDarkMode),
        Expanded(
          child: _filteredColleges.isEmpty
              ? _buildEmptyResultsView()
              : _buildCollegeList(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search colleges...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _resetFilters(); // Reset filters and fetch all colleges
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged, // Use debounce method
      ),
    );
  }

  Widget _buildFilterSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _resetFilters();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'Exam Type',
                  value: _selectedScoreType,
                  items: _scoreTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedScoreType = value;
                      _applyFilters();
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  hint: 'Branch',
                  value: _selectedBranch,
                  items: _branches,
                  onChanged: (value) {
                    setState(() {
                      _selectedBranch = value;
                      _applyFilters();
                    });
                  },
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cutoff Range',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '${_cutoffRange.start.toStringAsFixed(1)} - ${_cutoffRange.end.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _cutoffRange,
            min: _minCutoff,
            max: _maxCutoff,
            divisions: 100,
            activeColor: isDarkMode ? Colors.tealAccent : Colors.indigo,
            inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            labels: RangeLabels(
              _cutoffRange.start.toStringAsFixed(1),
              _cutoffRange.end.toStringAsFixed(1),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _cutoffRange = values;
                _applyFilters();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('All'),
            ),
            ...items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No colleges found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeList(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _filteredColleges.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when loading more
              if (index == _filteredColleges.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                    ),
                  ),
                );
              }

              final college = _filteredColleges[index];
              return _buildCollegeCard(college, isDarkMode);
            },
          ),
          // Only show this when initially loading more data
          if (_isFetchingMore && _filteredColleges.isEmpty)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college, bool isDarkMode) {
    // Extract college data
    final name = college['college_name']?.toString() ?? 'Unknown College';
    final branch = college['branch']?.toString() ?? 'Unknown Branch';
    final scoreType = college['score_type']?.toString() ?? 'Unknown Exam';

    // Safe conversion of numeric values
    final minScore = college['min'] != null
        ? double.tryParse(college['min'].toString())?.toStringAsFixed(1) ??
            'N/A'
        : 'N/A';
    final maxScore = college['max'] != null
        ? double.tryParse(college['max'].toString())?.toStringAsFixed(1) ??
            'N/A'
        : 'N/A';
    final meanScore = college['mean'] != null
        ? double.tryParse(college['mean'].toString())?.toStringAsFixed(1) ??
            'N/A'
        : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCollegeDetails(college),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.indigo[50],
                    child: Icon(
                      Icons.school,
                      color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$branch • $scoreType',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreItem(
                    label: 'Minimum',
                    value: minScore,
                    icon: Icons.arrow_downward,
                    iconColor: Colors.red,
                    isDarkMode: isDarkMode,
                  ),
                  _buildScoreItem(
                    label: 'Average',
                    value: meanScore,
                    icon: Icons.trending_flat,
                    iconColor: Colors.amber,
                    isDarkMode: isDarkMode,
                  ),
                  _buildScoreItem(
                    label: 'Maximum',
                    value: maxScore,
                    icon: Icons.arrow_upward,
                    iconColor: Colors.green,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showCollegeDetails(college),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isDarkMode ? Colors.tealAccent : Colors.indigo,
                      side: BorderSide(
                        color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _saveCollege(college),
                    icon: const Icon(Icons.bookmark_border, size: 16),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? Colors.tealAccent : Colors.indigo,
                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showCollegeDetails(Map<String, dynamic> college) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final collegeName =
        college['college_name']?.toString() ?? 'Unknown College';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          collegeName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.white : Colors.indigo[800],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildDetailCard(
                          title: 'Basic Information',
                          content: [
                            _buildDetailRow(
                                'Branch',
                                college['branch']?.toString() ??
                                    'Not specified'),
                            _buildDetailRow(
                                'Exam Type',
                                college['score_type']?.toString() ??
                                    'Not specified'),
                            _buildDetailRow(
                                'Seat Type',
                                college['seat_type']?.toString() ??
                                    'Not specified'),
                          ],
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailCard(
                          title: 'Cutoff Information',
                          content: [
                            _buildDetailRow('Minimum Score',
                                college['min']?.toString() ?? 'Not available'),
                            _buildDetailRow('Maximum Score',
                                college['max']?.toString() ?? 'Not available'),
                            _buildDetailRow('Average Score',
                                college['mean']?.toString() ?? 'Not available'),
                            _buildDetailRow(
                                'Score Range',
                                _calculateRange(
                                    college['min'], college['max'])),
                            _buildDetailRow(
                                'Deviation from Average',
                                _calculateDeviation(
                                    college['max'], college['mean'])),
                          ],
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailCard(
                          title: 'Additional Statistics',
                          content: [
                            _buildDetailRow(
                                'Number of Seats',
                                college['count']?.toString() ??
                                    'Not available'),
                            _buildDetailRow('Total Score Sum',
                                college['sum']?.toString() ?? 'Not available'),
                          ],
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _saveCollege(college),
                            icon: const Icon(Icons.bookmark),
                            label: const Text('Save College'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.tealAccent
                                  : Colors.indigo,
                              foregroundColor:
                                  isDarkMode ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to calculate range
  String _calculateRange(dynamic min, dynamic max) {
    if (min == null || max == null) return 'Not available';

    double minVal = double.tryParse(min.toString()) ?? 0;
    double maxVal = double.tryParse(max.toString()) ?? 0;

    if (minVal == 0 || maxVal == 0) return 'Not available';

    return (maxVal - minVal).toStringAsFixed(1);
  }

  // Helper method to calculate deviation
  String _calculateDeviation(dynamic max, dynamic mean) {
    if (max == null || mean == null) return 'Not available';

    double maxVal = double.tryParse(max.toString()) ?? 0;
    double meanVal = double.tryParse(mean.toString()) ?? 0;

    if (maxVal == 0 || meanVal == 0) return 'Not available';

    return (maxVal - meanVal).toStringAsFixed(1);
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> content,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.tealAccent : Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCollege(Map<String, dynamic> college) async {
    try {
      // Check if the college is already saved
      final response = await supabase
          .from('saved_colleges')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('college_id', college['id'])
          .single();

      // If no error, the college is already saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This college is already saved!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      try {
        // Insert the saved college
        await supabase.from('saved_colleges').insert({
          'user_id': supabase.auth.currentUser!.id,
          'college_id': college['id'],
          'college_data': college,
          'saved_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('College saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save college: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
