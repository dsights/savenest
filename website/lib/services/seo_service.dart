import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class SeoService {
  /// Injects JSON-LD structured data into the head of the document.
  /// Removes any existing JSON-LD scripts to prevent duplicates.
  static void injectJsonLd(Map<String, dynamic> schema) {
    if (!kIsWeb) return;

    try {
      // Remove existing json-ld to prevent duplicates
      final existingScripts = html.document.head!.querySelectorAll("script[type='application/ld+json']");
      for (var script in existingScripts) {
        script.remove();
      }

      final script = html.ScriptElement();
      script.type = 'application/ld+json';
      script.text = jsonEncode(schema);
      html.document.head!.append(script);
    } catch (e) {
      debugPrint('Error injecting JSON-LD: $e');
    }
  }

  /// Sets the canonical URL for the current page.
  /// Removes any existing canonical links.
  static void setCanonicalUrl(String url) {
    if (!kIsWeb) return;

    try {
      // Remove existing canonical
      final existingLinks = html.document.head!.querySelectorAll("link[rel='canonical']");
      for (var link in existingLinks) {
        link.remove();
      }

      final link = html.LinkElement();
      link.rel = 'canonical';
      link.href = url;
      html.document.head!.append(link);
    } catch (e) {
      debugPrint('Error setting canonical URL: $e');
    }
  }
}
