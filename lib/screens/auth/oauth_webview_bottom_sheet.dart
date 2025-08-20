import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/logger.dart';

class OAuthWebViewBottomSheet extends StatefulWidget {
  final String oauthUrl;
  final String redirectUrlScheme;
  final Function(String) onAuthCodeReceived;
  final VoidCallback onCancel;

  const OAuthWebViewBottomSheet({
    super.key,
    required this.oauthUrl,
    required this.redirectUrlScheme,
    required this.onAuthCodeReceived,
    required this.onCancel,
  });

  @override
  State<OAuthWebViewBottomSheet> createState() => _OAuthWebViewBottomSheetState();
}

class _OAuthWebViewBottomSheetState extends State<OAuthWebViewBottomSheet> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header with drag handle and close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // Drag handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                
                // Close button
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          // Progress bar
          if (progress > 0 && progress < 1)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          
          // WebView
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.oauthUrl)),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    allowsInlineMediaPlayback: true,
                    mediaPlaybackRequiresUserGesture: false,
                    supportZoom: false,
                    useWideViewPort: true,
                    loadWithOverviewMode: true,
                    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
                  ),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    Logger.info('OAuth WebView created');
                  },
                  onLoadStart: (controller, url) {
                    Logger.info('OAuth WebView loading: ${url.toString()}');
                    setState(() {
                      isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) {
                    Logger.info('OAuth WebView loaded: ${url.toString()}');
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final url = navigationAction.request.url.toString();
                    Logger.info('OAuth navigation intercepted: $url');
                    
                    // Check if this is our redirect URL (custom scheme or localhost)
                    if (url.startsWith(widget.redirectUrlScheme) || 
                        url.startsWith('http://localhost') || 
                        url.startsWith('https://localhost')) {
                      Logger.info('OAuth redirect detected: $url');
                      
                      final uri = Uri.parse(url);
                      
                      // Check for authorization code in query parameters
                      final code = uri.queryParameters['code'];
                      if (code != null) {
                        Logger.info('OAuth code received: ${code.substring(0, 10)}...');
                        widget.onAuthCodeReceived(code);
                        return NavigationActionPolicy.CANCEL;
                      }
                      
                      // Check for access token in fragment (for implicit flow or localhost)
                      if (uri.fragment.isNotEmpty) {
                        final fragment = uri.fragment;
                        Logger.info('OAuth fragment received: ${fragment.substring(0, 20)}...');
                        // Pass the complete URL so the service can extract the access token
                        widget.onAuthCodeReceived(url);
                        return NavigationActionPolicy.CANCEL;
                      }
                      
                      // Check for error
                      final error = uri.queryParameters['error'];
                      if (error != null) {
                        Logger.error('OAuth error: $error');
                        widget.onCancel();
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    
                    return NavigationActionPolicy.ALLOW;
                  },
                  onReceivedError: (controller, request, error) {
                    Logger.error('OAuth WebView error: ${error.description}');
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                
                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Google 로그인 페이지를 로드하는 중...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the OAuth bottom sheet
Future<String?> showOAuthBottomSheet(
  BuildContext context,
  String oauthUrl,
  String redirectUrlScheme,
) async {
  String? authCode;
  
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => OAuthWebViewBottomSheet(
      oauthUrl: oauthUrl,
      redirectUrlScheme: redirectUrlScheme,
      onAuthCodeReceived: (code) {
        authCode = code;
        Navigator.of(context).pop();
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    ),
  );
  
  return authCode;
}