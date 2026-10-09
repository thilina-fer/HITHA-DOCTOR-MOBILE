import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Delete confirmation dialog shows title, message, Cancel and Delete buttons', (tester) async {
    bool? userConfirmed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Availability Window?'),
                    content: const Text('Are you sure you want to delete this weekly window?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete Window'),
                      ),
                    ],
                  ),
                );
                userConfirmed = result;
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Availability Window?'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this weekly window?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete Window'), findsOneWidget);

    // Tap Delete Window
    await tester.tap(find.text('Delete Window'));
    await tester.pumpAndSettle();

    expect(userConfirmed, isTrue);
  });
}
