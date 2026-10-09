import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitha_doctor_mobile/ui/features/onboarding/screens/get_started_screen.dart';

void main() {
  testWidgets('GetStartedScreen renders logo, doctor hero, text and buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GetStartedScreen(),
      ),
    );

    // Initial pump and animation settle
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify Welcome RichText
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('Welcome to Hitha.lk'),
      ),
      findsOneWidget,
    );

    expect(find.text('Your space to care, anytime, anywhere'), findsOneWidget);

    // Verify Action buttons
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
  });
}
