import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import screens
import 'profile_screen.dart';
// You'll need to create these other screens
// import 'explore_screen.dart';
// import 'saved_colleges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  final SupabaseClient supabase = Supabase.instance.client;
  String userName = '';
  String userEmail = '';
  
  // For bottom navigation
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  
  // List of screens for bottom navigation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    
    // Initialize screens for bottom navigation
    _screens = [
      _buildHomeContent(),
      // Create placeholder widgets for other tabs (to be replaced with actual screens)
      const Center(child: Text('Explore Screen - Coming Soon')),
      const Center(child: Text('Saved Colleges - Coming Soon')),
      const ProfileScreen(), // Use the profile screen we created
    ];
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('users')
          .select('full_name, email')
          .eq('id', user.id)
          .single();
      setState(() {
        userName = response['full_name'] ?? 'User Name';
        userEmail = response['email'] ?? 'user@example.com';
      });
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    // Navigate to login screen
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login'); // Adjust this to your actual login route
  }
  
  // Navigate to profile screen
  void navigateToProfile() {
    setState(() {
      _selectedIndex = 3;
      _pageController.jumpToPage(3);
    });
  }
  
  // Navigate to saved colleges
  void navigateToSavedColleges() {
    setState(() {
      _selectedIndex = 2;
      _pageController.jumpToPage(2);
    });
  }
  
  // Navigate to college ranking screen
  void navigateToCollegeRankings() {
    // You can implement navigation to a specific college rankings screen
    // For now, navigate to explore tab
    setState(() {
      _selectedIndex = 1;
      _pageController.jumpToPage(1);
    });
  }
  
  // Navigate to college comparison screen
  void navigateToCollegeComparison() {
    // You can implement navigation to a specific college comparison screen
    // For now, navigate to explore tab
    setState(() {
      _selectedIndex = 1;
      _pageController.jumpToPage(1);
    });
  }
  
  // Navigate to recommendations screen
  void navigateToRecommendations() {
    // You can implement navigation to a specific recommendations screen
    // For now, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommendations'),
        content: const Text('Personalized recommendations feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.indigo,
              colorScheme: ColorScheme.dark(
                primary: Colors.indigo,
                secondary: Colors.tealAccent,
                surface: Colors.grey[850]!,
              ),
              cardTheme: CardTheme(
                elevation: 6,
                shadowColor: Colors.indigo.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[850],
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.indigo,
              colorScheme: ColorScheme.light(
                primary: Colors.indigo,
                secondary: Colors.tealAccent,
                surface: Colors.white,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shadowColor: Colors.indigo.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.indigo,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
      child: Scaffold(
        appBar: _selectedIndex == 0 ? AppBar(
          title: const Text(
            'College Finder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Keep original search logic
                showSearch(
                  context: context,
                  delegate: CollegeSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Add notification functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ) : null, // Only show app bar on home screen
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _screens,
        ),
        floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
          onPressed: () {
            // Add college filtering/advanced search
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Colleges',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.indigo[800],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Filter options coming soon!'),
                    ],
                  ),
                );
              },
            );
          },
          backgroundColor: isDarkMode ? Colors.tealAccent : Colors.indigo,
          child: const Icon(Icons.filter_list),
        ) : null, // Only show FAB on home screen
        drawer: Drawer(
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                        isDarkMode ? Colors.tealAccent : Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: isDarkMode ? Colors.grey[900] : Colors.indigo,
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.grey[850]!, Colors.grey[800]!]
                          : [Colors.indigo[700]!, Colors.indigo],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = 0;
                      _pageController.jumpToPage(0);
                    });
                  },
                  isSelected: _selectedIndex == 0,
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToProfile();
                  },
                  isSelected: _selectedIndex == 3,
                ),
                _buildDrawerItem(
                  icon: Icons.favorite_outline,
                  title: 'Saved Colleges',
                  onTap: () {
                    Navigator.pop(context);
                    navigateToSavedColleges();
                  },
                  isSelected: _selectedIndex == 2,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Application History',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application history feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Deadlines',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deadlines feature coming soon!'),
                      ),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            isDarkMode = value;
                          });
                        },
                        activeColor: Colors.tealAccent,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: logout, // Using the improved logout function
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
              _pageController.jumpToPage(index);
            });
          },
        ),
      ),
    );
  }

  // Build the home content - extracted to a separate method for clarity
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchUserData();
        // Add logic to refresh college data
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${userName.split(" ").first}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? Colors.white : Colors.indigo[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find your perfect college match',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // College Recommendation Card
              Card(
                elevation: 8,
                shadowColor: Colors.indigo.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: navigateToRecommendations,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo[700]!,
                          Colors.indigo[400]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Personalized Recommendation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Discover colleges that match your preferences and academic profile',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Get Recommendations',
                            style: TextStyle(
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.leaderboard_rounded,
                      title: 'College Rankings',
                      color: Colors.orange,
                      onTap: navigateToCollegeRankings,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.compare_rounded,
                      title: 'Compare Colleges',
                      color: Colors.green,
                      onTap: navigateToCollegeComparison,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Saved Colleges Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Colleges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.indigo[800],
                    ),
                  ),
                  TextButton(
                    onPressed: navigateToSavedColleges,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Saved Colleges Grid
              GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Increased from 0.8 to give more height
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _buildCollegeCard(
                    context: context,
                    collegeName: 'University ${index + 1}',
                    location: 'City, State',
                    rating: '4.${index + 2}',
                    isFavorite: true,
                    index: index,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Trending Colleges Section
              Text(
                'Trending Colleges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.indigo[800],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildTrendingCollegeCard(
                      context: context,
                      collegeName: 'Trending University ${index + 1}',
                      location: 'Major City, State',
                      ranking: '#${index + 1}',
                      acceptanceRate: '${85 - index * 5}%',
                      imageIndex: index,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? (isDarkMode ? Colors.tealAccent : Colors.indigo)
            : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? (isDarkMode ? Colors.tealAccent : Colors.indigo)
              : (isDarkMode ? Colors.grey[200] : Colors.black87),
        ),
      ),
      onTap: onTap,
      tileColor: isSelected
          ? (isDarkMode ? Colors.grey[850] : Colors.indigo.withOpacity(0.1))
          : null,
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )
          : null,
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollegeCard({
    required BuildContext context,
    required String collegeName,
    required String location,
    required String rating,
    required bool isFavorite,
    required int index,
  }) {
    final List<Color> cardColors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.purple[100]!,
      Colors.orange[100]!,
    ];

    final List<Color> textColors = [
      Colors.blue[800]!,
      Colors.green[800]!,
      Colors.purple[800]!,
      Colors.orange[800]!,
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[850]
              : cardColors[index % cardColors.length].withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added this to help with sizing
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      collegeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.white
                            : textColors[index % textColors.length],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 22,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Toggle favorite
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFavorite 
                            ? 'Removed from favorites' 
                            : 'Added to favorites'
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.school,
                    size: 40,
                    color: isDarkMode
                        ? Colors.grey[600]
                        : textColors[index % textColors.length],
                  ),
                ),
              ),
              const SizedBox(height: 8), // Reduced from 12 to 8
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Reduced from 6 to 4
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Use a fixed size instead of Spacer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // View college details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(collegeName),
                        content: const Text('College details coming soon!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    backgroundColor: isDarkMode
                        ? Colors.tealAccent.withOpacity(0.8)
                        : textColors[index % textColors.length],
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCollegeCard({
    required BuildContext context,
    required String collegeName,
    required String location,
    required String ranking,
    required String acceptanceRate,
    required int imageIndex,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // View college details
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(collegeName),
                content: const Text('Trending college details coming soon!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal
                  ][imageIndex % 5],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    [
                      Icons.school,
                      Icons.account_balance,
                      Icons.apartment,
                      Icons.business,
                      Icons.domain
                    ][imageIndex % 5],
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collegeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ranking,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.indigo,
                            ),
                          ),
                        ),
                        Text(
                          acceptanceRate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search functionality
class CollegeSearchDelegate extends SearchDelegate<String> {
  final List<String> collegeNames = [
    'Harvard University',
    'Stanford University',
    'MIT',
    'Yale University',
    'Princeton University',
    'Columbia University',
    'University of California, Berkeley',
    'University of Chicago',
    'University of Pennsylvania',
    'Duke University',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = collegeNames
        .where((college) => college.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? collegeNames
        : collegeNames
            .where((college) => college.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return _buildSearchResultsList(context, suggestions);
  }

  Widget _buildSearchResultsList(BuildContext context, List<String> colleges) {
    return ListView.builder(
      itemCount: colleges.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.school),
          title: Text(colleges[index]),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(colleges[index]),
                content: const Text('College details coming soon!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}