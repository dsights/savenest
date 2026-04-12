class ApiService {
  // For web development, the browser's CORS policy prevents directly calling a different origin.
  // The backend proxy server on the same domain as the Flutter app is used to bypass this.
  // For mobile (not web), you would use the direct backend URL.
  
  // A common approach is to use a relative path for web, and a full URL for mobile.
  // This can be configured at build time using environment variables.
  // For this example, we'll keep it simple and assume a proxy is set up for web.
  
  static const String _webBaseUrl = '/api'; // Assumes a proxy is set up on the web server
  static const String _mobileBaseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  static const String _desktopBaseUrl = 'http://127.0.0.1:8000'; // For desktop

  static String get backendBaseUrl {
    // In a real app, you would use a more robust way to determine the platform
    // like `kIsWeb` from `flutter/foundation.dart`.
    // However, to avoid adding imports to every file, we will use a simple check.
    if (Uri.base.scheme == 'http' || Uri.base.scheme == 'https') {
      // Running on the web
      return _webBaseUrl;
    } else if (Uri.base.scheme == 'file') {
        // This is a rough way to check for desktop. A better way is to use
        // Platform.isAndroid, Platform.isIOS, etc. from 'dart:io'.
        // For simplicity here, we assume 'file' scheme means desktop.
        return _desktopBaseUrl;
    }
    else {
      // Assume mobile
      return _mobileBaseUrl;
    }
  }
}
