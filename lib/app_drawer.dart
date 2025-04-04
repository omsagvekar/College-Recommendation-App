// app_drawer.dart

import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool isDarkMode;
  final Function(bool) onThemeToggle;
  final VoidCallback onLogout;
  final Function(int) onSelectTab;
  final VoidCallback navigateToProfile;
  final VoidCallback navigateToSavedColleges;

  const AppDrawer({
    required this.userName,
    required this.userEmail,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
    required this.onSelectTab,
    required this.navigateToProfile,
    required this.navigateToSavedColleges,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
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
            ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                onSelectTab(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                navigateToProfile();
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite_outline),
              title: Text('Saved Colleges'),
              onTap: () {
                Navigator.pop(context);
                navigateToSavedColleges();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: onThemeToggle,
              secondary: Icon(Icons.dark_mode),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
