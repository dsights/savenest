import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savenest/main.dart';
import 'package:savenest/features/blog/blog_provider.dart';

void main() {
  testWidgets('SaveNest landing screen smoke test', (WidgetTester tester) async {
    // Set a large screen size to avoid layout overflows
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset the values after the test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    // We override the blog provider to return an empty list immediately to avoid async delays in test
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          blogPostsProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const SaveNestApp(),
      ),
    );

    // Allow time for the FutureProvider to resolve (even if immediate) and widgets to settle
    await tester.pumpAndSettle();

    // Verify that our app title is present.
    // Use findsWidgets because it might appear in multiple places (e.g. hidden drawer)
    expect(find.text('SaveNest'), findsWidgets); 
    
    // Verify hero text button is present
    expect(find.text('Savings Calculator'), findsWidgets);

    // Verify we don't have the counter 0 (ensure we cleaned up the old test logic)
    expect(find.text('0'), findsNothing);
  });
}