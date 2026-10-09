import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitha_doctor_mobile/ui/core/widgets/floating_pill_nav_bar.dart';

void main() {
  testWidgets('FloatingPillNavBar is positioned at the bottom of the screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          body: const Center(child: Text('Content')),
          bottomNavigationBar: FloatingPillNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
            items: const [
              FloatingNavItem(
                icon: Icons.home,
                label: 'Home',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
              FloatingNavItem(
                icon: Icons.person,
                label: 'Profile',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final navBarFinder = find.byType(FloatingPillNavBar);
    expect(navBarFinder, findsOneWidget);

    final rect = tester.getRect(navBarFinder);
    expect(rect.bottom, equals(600.0));
    expect(rect.top, greaterThan(500.0));
  });

  testWidgets('Tapping tab invokes onItemSelected callback', (tester) async {
    int selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: FloatingPillNavBar(
            selectedIndex: selected,
            onItemSelected: (idx) => selected = idx,
            items: const [
              FloatingNavItem(
                icon: Icons.home,
                label: 'Home',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
              FloatingNavItem(
                icon: Icons.person,
                label: 'Profile',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(selected, equals(1));
  });

  testWidgets('Tapping center elevated action button invokes onCenterButtonPressed callback', (tester) async {
    bool centerTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: FloatingPillNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
            onCenterButtonPressed: () => centerTapped = true,
            centerButtonIcon: Icons.add_rounded,
            items: const [
              FloatingNavItem(
                icon: Icons.home,
                label: 'Home',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
              FloatingNavItem(
                icon: Icons.person,
                label: 'Profile',
                activeColor: Colors.blue,
                activeBgColor: Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(centerTapped, isTrue);
  });
}
