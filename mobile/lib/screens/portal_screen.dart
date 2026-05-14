import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config.dart';
import '../services/biometric_auth_service.dart';
import '../services/deep_link_service.dart';
import '../services/portal_controller.dart';
import '../services/storage_service.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  late final WebViewController _webController;
  bool _loading = true;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _paymentAuthValidUntil;
  int _authFailureRedirects = 0;
  static const _maxAuthFailureRedirects = 2;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);
            final scheme = uri.scheme.toLowerCase();

            // Keep normal web navigation inside the in-app webview.
            if (scheme == 'http' || scheme == 'https') {
              if (await _shouldRequirePaymentAuth(uri)) {
                final now = DateTime.now();
                final stillValid = _paymentAuthValidUntil != null && _paymentAuthValidUntil!.isAfter(now);
                if (!stillValid) {
                  final approved = await BiometricAuthService.instance.authenticateForPayment();
                  if (!approved) {
                    return NavigationDecision.prevent;
                  }
                  _paymentAuthValidUntil = now.add(const Duration(minutes: 2));
                }
              }
              return NavigationDecision.navigate;
            }

            // Open non-web schemes externally (tel:, mailto:, sms:, etc.).
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) async {
            await _normalizeViewport();
            await _redirectOnAuthFailure();
            if (mounted) {
              setState(() {
                _loading = false;
                _hasError = false;
                _errorMessage = null;
              });
            }
          },
          onWebResourceError: (error) {
            // Only treat main frame errors as page-level failures.
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _loading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(AppConfig.portalUri);

    final platformController = _webController.platform;
    if (platformController is AndroidWebViewController) {
      platformController.setOnShowFileSelector((_) async {
        final result = await FilePicker.platform.pickFiles(allowMultiple: false);
        if (result == null || result.files.single.path == null) {
          return <String>[];
        }
        return <String>[result.files.single.path!];
      });
    }

    PortalNavigationController.instance.pendingDeepLink.addListener(_applyDeepLink);
  }

  bool _looksLikePaymentNavigation(Uri uri) {
    final text = ('${uri.path}?${uri.query}').toLowerCase();
    return text.contains('payment') || text.contains('payments') || text.contains('paynow') || text.contains('make-payment');
  }

  Future<bool> _shouldRequirePaymentAuth(Uri uri) async {
    if (!_looksLikePaymentNavigation(uri)) return false;
    final enabled = await StorageService.instance.getBiometricPaymentEnabled();
    if (!enabled) return false;
    return StorageService.instance.isLinked();
  }

  Future<void> _redirectOnAuthFailure() async {
    if (_authFailureRedirects >= _maxAuthFailureRedirects) return;
    final result = await _webController.runJavaScriptReturningResult(
      '(document.body && document.body.innerText || "").indexOf("Authorization Failure") !== -1',
    );
    final isAuthFailure = result == true || result == 'true';
    if (isAuthFailure) {
      _authFailureRedirects++;
      await _webController.loadRequest(AppConfig.portalUri);
      return;
    }
    // Reset counter on any successful (non-error) page load.
    _authFailureRedirects = 0;
  }

  Future<void> _normalizeViewport() async {
    await _webController.runJavaScript('''
      (function () {
        var head = document.head || document.getElementsByTagName('head')[0];
        if (!head) return;
        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.setAttribute('name', 'viewport');
          head.appendChild(meta);
        }
        meta.setAttribute('content', 'width=device-width, initial-scale=1, viewport-fit=cover');
        if (document.documentElement) document.documentElement.style.overflowX = 'hidden';
        if (document.body) document.body.style.overflowX = 'hidden';
        window.scrollTo(0, window.scrollY || 0);
      })();
    ''');
  }

  @override
  void dispose() {
    PortalNavigationController.instance.pendingDeepLink.removeListener(_applyDeepLink);
    super.dispose();
  }

  Future<void> _applyDeepLink() async {
    final deepLink = PortalNavigationController.instance.pendingDeepLink.value;
    if (deepLink == null) return;
    final uri = DeepLinkService.portalUriForDeepLink(deepLink);
    await _webController.loadRequest(uri);
    PortalNavigationController.instance.clear();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = null;
    });
    await _webController.loadRequest(AppConfig.portalUri);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _reload,
          child: _hasError
              ? ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load portal',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage ?? 'Check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      child: WebViewWidget(controller: _webController),
                    ),
                  ],
                ),
        ),
        if (_loading)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/coastal_logo_resized.png',
                    width: 200,
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
