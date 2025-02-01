import 'package:college_recommendation_app/questions_screen.dart';
import 'package:college_recommendation_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'supabase.dart';
import 'home_screen.dart'; // Import Supabase config

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print("Attempting login with Email: ${_emailController.text}");

        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.session != null) {
          String userId = response.user!.id;

          // Check if user has already completed the questionnaire
          final userResponse = await SupabaseConfig.client
              .from('user_responses')
              .select()
              .eq('user_id', userId)
              .maybeSingle(); // Get a single record or null

          if (userResponse != null) {
            // If responses exist, navigate to Home Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(), // Replace with actual home screen
              ),
            );
          } else {
            // If no responses, go to Questions Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionsScreen(userId: userId),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid email or password')),
          );
        }
      } catch (e) {
        print("Login Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Login Illustration
                Image.asset(
                  'assets/login_image.jpeg', // Add your image in assets folder
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black), // Text color fix
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle:
                        TextStyle(color: Colors.black), // Label color fix
                    prefixIcon: Icon(Icons.email, color: Colors.blue.shade900),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Background color fix
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black), // Text color fix
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle:
                        TextStyle(color: Colors.black), // Label color fix
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Background color fix
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Login Button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                SizedBox(height: 20),

                // Don't have an account? Sign Up
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:college_recommendation_app/questions_screen.dart';
// import 'package:college_recommendation_app/signup_screen.dart';
// import 'package:flutter/material.dart';
// import 'supabase.dart'; // Import Supabase config

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;

//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         print("Attempting login with Email: ${_emailController.text}");

//         final response = await SupabaseConfig.client.auth.signInWithPassword(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//         );

//         if (response.session != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login successful!')),
//           );

//           // Navigate to the home screen (replace with your home screen)
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => QuestionsScreen(userId: response.user!.id),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Invalid email or password')),
//           );
//         }
//       } catch (e) {
//         print("Login Error: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//         backgroundColor: Colors.blue.shade900,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Login Illustration
//                 Image.asset(
//                   'assets/login_image.jpeg', // Add your image in assets folder
//                   width: 200,
//                   height: 200,
//                 ),
//                 SizedBox(height: 20),

//                 // Email Input Field
//                 TextFormField(
//                   controller: _emailController,
//                   style: TextStyle(color: Colors.black), // Text color fix
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     labelStyle:
//                         TextStyle(color: Colors.black), // Label color fix
//                     prefixIcon: Icon(Icons.email, color: Colors.blue.shade900),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white, // Background color fix
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!value.contains('@')) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Password Input Field
//                 TextFormField(
//                   controller: _passwordController,
//                   style: TextStyle(color: Colors.black), // Text color fix
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     labelStyle:
//                         TextStyle(color: Colors.black), // Label color fix
//                     prefixIcon: Icon(Icons.lock, color: Colors.blue.shade900),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white, // Background color fix
//                   ),
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Login Button
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: _login,
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 15),
//                           backgroundColor: Colors.blue.shade900,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: Text(
//                           'Login',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                 SizedBox(height: 20),

//                 // Don't have an account? Sign Up
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => SignUpScreen()),
//                     );
//                   },
//                   child: Text(
//                     'Don\'t have an account? Sign Up',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.blue.shade900,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
