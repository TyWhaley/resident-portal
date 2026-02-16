import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config.dart';
import '../services/deep_link_service.dart';
import '../services/portal_controller.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  late final WebViewController _webController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);
            if (uri.host == AppConfig.portalDomain) {
              final path = uri.path.toLowerCase();
              if (path.endsWith(".pdf") || path.endsWith(".doc") || path.endsWith(".docx") || path.endsWith(".xls") || path.endsWith(".xlsx") || uri.query.toLowerCase().contains("download")) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _webController),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
