import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; // Import HomeScreen for navigation

class QuestionsScreen extends StatefulWidget {
  final String userId;

  const QuestionsScreen({super.key, required this.userId});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool isLoading = false;
  Map<String, String> userAnswers = {};

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What stream did you take in 12th?',
      'field': 'stream_12th',
      'options': ['PCM', 'PCB', 'Other'],
    },
    {
      'question': 'What is your preferred branch of engineering?',
      'field': 'preferred_branch',
      'options': ['Computer Science', 'Mechanical', 'Civil', 'Electrical', 'Electronics', 'Chemical'],
    },
    {
      'question': 'What is your preferred location for college?',
      'field': 'preferred_location',
      'options': ['Metropolitan Cities', 'Regional Cities', 'Open to any location'],
    },
    {
      'question': 'Do you prefer a college with a specific ranking?',
      'field': 'college_ranking',
      'options': ['Top 50', 'Top 100', 'No preference'],
    },
    {
      'question': 'What are your priorities when choosing a college?',
      'field': 'college_priorities',
      'options': ['Infrastructure', 'Placement', 'Faculty', 'Research Opportunities', 'Peer Group'],
    },
    {
      'question': 'What is your caste category?',
      'field': 'caste_category',
      'options': [
        'General Category (Open)',
        'OBC (Other Backward Class)',
        'SC (Scheduled Caste)',
        'ST (Scheduled Tribe)',
        'VJNT (Vimukta Jati and Nomadic Tribes)',
        'SBC (Special Backward Classes)',
        'EWS (Economically Weaker Section)',
        'NT (Nomadic Tribes)'
      ],
    },
  ];

  Future<void> storeAnswer() async {
    if (selectedAnswer == null) return;

    setState(() => isLoading = true);

    try {
      String currentField = questions[currentQuestionIndex]['field'];
      userAnswers[currentField] = selectedAnswer!;

      final existing = await Supabase.instance.client
          .from('user_responses')
          .select()
          .eq('user_id', widget.userId)
          .maybeSingle();

      Map<String, dynamic> data = {
        'user_id': widget.userId,
        ...userAnswers,
      };

      if (existing == null) {
        await Supabase.instance.client.from('user_responses').insert(data);
      } else {
        await Supabase.instance.client.from('user_responses').update(data).eq('user_id', widget.userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleNext() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an answer')));
      return;
    }

    await storeAnswer();

    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = userAnswers[questions[currentQuestionIndex]['field']];
      } else {
        // Navigate to HomeScreen after last question
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      questions[currentQuestionIndex]['question'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: questions[currentQuestionIndex]['options'].map<Widget>((option) {
                    bool isSelected = option == selectedAnswer;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswer = option),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: handleNext,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('Next'), Icon(Icons.arrow_forward_ios)],
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
}
