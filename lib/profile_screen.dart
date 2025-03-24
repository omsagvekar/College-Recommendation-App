import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // User data
  String userName = '';
  String userEmail = '';
  String userId = '';
  bool isLoading = true;
  bool isDarkMode = false;
  
  // User responses data
  String? stream12th;
  String? preferredBranch;
  String? preferredLocation;
  String? collegeRanking;
  String? collegePriorities;
  String? casteCategory;
  DateTime? createdAt;

  // Edit mode controllers
  final TextEditingController nameController = TextEditingController();
  bool isEditingProfile = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // Load user's basic data and preferences
  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        userId = user.id;
        
        // Fetch user profile data
        final userData = await supabase
            .from('users')
            .select('full_name, email')
            .eq('id', user.id)
            .single();
        
        // Fetch user responses if they exist
        final userResponses = await supabase
            .from('user_responses')
            .select('*')
            .eq('user_id', user.id)
            .maybeSingle();
        
        setState(() {
          // Set user data
          userName = userData['full_name'] ?? 'User Name';
          userEmail = userData['email'] ?? 'user@example.com';
          nameController.text = userName;
          
          // Set user responses if they exist
          if (userResponses != null) {
            stream12th = userResponses['stream_12th'];
            preferredBranch = userResponses['preferred_branch'];
            preferredLocation = userResponses['preferred_location'];
            collegeRanking = userResponses['college_ranking'];
            collegePriorities = userResponses['college_priorities'];
            casteCategory = userResponses['caste_category'];
            
            if (userResponses['created_at'] != null) {
              createdAt = DateTime.parse(userResponses['created_at']);
            }
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save user profile changes
  Future<void> saveProfileChanges() async {
    try {
      await supabase
          .from('users')
          .update({'full_name': nameController.text})
          .eq('id', userId);
      
      setState(() {
        userName = nameController.text;
        isEditingProfile = false;
      });
      
      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigate to the preferences form
  void navigateToPreferencesForm() {
    // This would navigate to a screen where the user can update their preferences
    // You can implement this screen separately
    Navigator.of(context).pushNamed('/preferences-form').then((_) {
      // Reload data when returning from preferences screen
      loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme mode from context if available
    final brightness = Theme.of(context).brightness;
    isDarkMode = brightness == Brightness.dark;
    
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
            ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadUserData,
              tooltip: 'Refresh Profile',
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode ? Colors.tealAccent : Colors.indigo.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: isDarkMode ? Colors.grey[900] : Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          isEditingProfile
                              ? _buildEditProfileForm()
                              : Column(
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.indigo[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          isEditingProfile = true;
                                        });
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit Profile'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // College Preferences Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'College Preferences',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.indigo[800],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: navigateToPreferencesForm,
                                  tooltip: 'Edit Preferences',
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _hasUserResponses()
                                ? _buildPreferencesInfo()
                                : _buildNoPreferences(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Activity Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Activity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.indigo[800],
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildActivityItem(
                              icon: Icons.calendar_today,
                              title: 'Account Created',
                              subtitle: createdAt != null
                                  ? '${_formatDate(createdAt!)}' 
                                  : 'Unknown',
                            ),
                            _buildActivityItem(
                              icon: Icons.school,
                              title: 'Saved Colleges',
                              subtitle: '4 colleges',
                              trailing: TextButton(
                                onPressed: () {
                                  // Navigate to saved colleges
                                },
                                child: const Text('View All'),
                              ),
                            ),
                            _buildActivityItem(
                              icon: Icons.history,
                              title: 'Application Status',
                              subtitle: 'No active applications',
                              trailing: TextButton(
                                onPressed: () {
                                  // Navigate to applications
                                },
                                child: const Text('Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Actions Section
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.indigo[800],
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: Icon(
                                Icons.lock_outline,
                                color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                              ),
                              title: const Text('Change Password'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navigate to change password screen
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.notifications_outlined,
                                color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                              ),
                              title: const Text('Notification Settings'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navigate to notification settings
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.help_outline,
                                color: isDarkMode ? Colors.tealAccent : Colors.indigo,
                              ),
                              title: const Text('Help & Support'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navigate to help and support
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onTap: () async {
                                await supabase.auth.signOut();
                                if (!mounted) return;
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // Edit profile form
  Widget _buildEditProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveProfileChanges();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    nameController.text = userName;
                    isEditingProfile = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Check if user has responses
  bool _hasUserResponses() {
    return stream12th != null || 
           preferredBranch != null || 
           preferredLocation != null || 
           collegeRanking != null || 
           collegePriorities != null || 
           casteCategory != null;
  }

  // Widget for no preferences
  Widget _buildNoPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline,
          size: 50,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          'No preferences set',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set your preferences to get personalized college recommendations',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: navigateToPreferencesForm,
          icon: const Icon(Icons.add),
          label: const Text('Add Preferences'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  // Widget for preferences info
  Widget _buildPreferencesInfo() {
    return Column(
      children: [
        _buildPreferenceItem(
          icon: Icons.school,
          title: '12th Stream',
          value: stream12th,
        ),
        _buildPreferenceItem(
          icon: Icons.category,
          title: 'Preferred Branch',
          value: preferredBranch,
        ),
        _buildPreferenceItem(
          icon: Icons.location_on,
          title: 'Preferred Location',
          value: preferredLocation,
        ),
        _buildPreferenceItem(
          icon: Icons.trending_up,
          title: 'College Ranking',
          value: collegeRanking,
        ),
        _buildPreferenceItem(
          icon: Icons.list_alt,
          title: 'College Priorities',
          value: collegePriorities,
        ),
        _buildPreferenceItem(
          icon: Icons.group,
          title: 'Caste Category',
          value: casteCategory,
        ),
      ],
    );
  }

  // Preference item widget
  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.tealAccent : Colors.indigo,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not set',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Activity item widget
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.tealAccent : Colors.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}