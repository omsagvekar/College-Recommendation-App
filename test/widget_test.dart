import 'package:flutter_test/flutter_test.dart';
import 'package:college_recommendation_app/main.dart'; // Import your main.dart file

void main() {
  testWidgets('WelcomeScreen UI Test', (WidgetTester tester) async {
    // Build the CollegeRecommendationApp widget
    await tester.pumpWidget(CollegeRecommendationApp());

    // Verify that the welcome text is displayed
    expect(find.text('Find Your Perfect College'), findsOneWidget);

    // Verify that the "Get Started" button is displayed
    expect(find.text('Get Started'), findsOneWidget);
  });
}