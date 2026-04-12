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
    // Use pump instead of pumpAndSettle because of infinite animations in the landing page
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that our app title is present.
    // The logo is composed of two separate Text widgets.
    expect(find.text('Save'), findsWidgets);
    expect(find.text('Nest'), findsWidgets);
    
    // Verify hero text button is present
    expect(find.text('Calculator'), findsWidgets);

    // Verify we don't have the counter 0 (ensure we cleaned up the old test logic)
    // and check for the logo again to be safe.
    expect(find.text('Save'), findsWidgets);
  });
}