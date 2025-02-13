import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

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
        'General (Open)',
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
      backgroundColor: Colors.black, // Matching the Login & Signup screen
      appBar: AppBar(
        title: const Text('Questions', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    questions[currentQuestionIndex]['question'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: questions[currentQuestionIndex]['options'].map<Widget>((option) {
                    bool isSelected = option == selectedAnswer;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswer = option),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade400 : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? Colors.blue.shade300 : Colors.white38, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Next', style: TextStyle(fontSize: 18, color: Colors.white)),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
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
