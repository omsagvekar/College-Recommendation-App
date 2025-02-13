import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
    // Navigate to login screen or perform other actions
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.grey[900],
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: Colors.grey[100],
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('College Recommendation'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Keep original search logic
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // College Recommendation Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic for college recommendation
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Your College Recommendation',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Ranking of Colleges Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic for ranking of colleges
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ranking of Colleges',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Saved Colleges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'College ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Keep original favorite logic
                                  },
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Row(
                              children: [
                                Icon(Icons.location_on, size: 14),
                                SizedBox(width: 4),
                                Text('City, State',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                SizedBox(width: 4),
                                Text('4.5', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Top Colleges in Maharashtra Table
              const Text(
                'Top Colleges in Maharashtra',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FixedColumnWidth(40),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(50),
                },
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueAccent),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rank',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('College Name',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Location',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rating',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('1')),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('IIT Bombay')),
                    Padding(
                        padding: EdgeInsets.all(8.0), child: Text('Mumbai')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('4.9')),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('2')),
                    Padding(
                        padding: EdgeInsets.all(8.0), child: Text('COEP Pune')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Pune')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('4.7')),
                  ]),
                  TableRow(children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('3')),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('VJTI Mumbai')),
                    Padding(
                        padding: EdgeInsets.all(8.0), child: Text('Mumbai')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('4.6')),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
