import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../theme/app_theme.dart';

class PartnerWebView extends StatefulWidget {
  final String url;
  final String title;

  const PartnerWebView({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PartnerWebView> createState() => _PartnerWebViewState();
}

class _PartnerWebViewState extends State<PartnerWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    
    // Platform-specific initialization could go here if needed
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress;
            });
          },
          onPageStarted: (String url) {
             setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
             setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || _progress < 100)
            LinearProgressIndicator(
              value: _progress / 100.0,
              color: AppTheme.vibrantEmerald,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }
}
