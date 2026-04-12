import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:meta_seo/meta_seo.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'package:flutter/foundation.dart';

void main() {
  usePathUrlStrategy();
  if (kIsWeb) {
    MetaSEO().config();
  }
  runApp(const ProviderScope(child: SaveNestApp()));
}

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SaveNestApp extends StatelessWidget {
  const SaveNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SaveNest',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: goRouter,
    );
  }
}
