import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/toss_payment_service.dart';

class CardRegistrationWebView extends StatefulWidget {
  final String billingUrl;
  final String customerKey;
  const CardRegistrationWebView({
    super.key,
    required this.billingUrl,
    required this.customerKey,
  });
  @override
  State<CardRegistrationWebView> createState() => _CardRegistrationWebViewState();
}

class _CardRegistrationWebViewState extends State<CardRegistrationWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  static const _successBase = 'https://escovip.page.link/billing-success';
  static const _failBase = 'https://escovip.page.link/billing-fail';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (req) {
          final url = req.url;
          if (url.startsWith(_successBase)) {
            final uri = Uri.parse(url);
            final authKey = uri.queryParameters['authKey'];
            final customerKey = uri.queryParameters['customerKey'] ?? widget.customerKey;
            if (authKey != null) _issueBillingKey(authKey: authKey, customerKey: customerKey);
            return NavigationDecision.prevent;
          }
          if (url.startsWith(_failBase)) {
            _showError('카드 등록에 실패했습니다.');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.billingUrl));
  }

  Future<void> _issueBillingKey({
    required String authKey,
    required String customerKey,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (mounted) {
      showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }
    try {
      final result = await TossPaymentService.issueBillingKey(
        customerKey: customerKey,
        authKey: authKey,
      );
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (result['billingKey'] != null) {
        await TossPaymentService.saveBillingKey(
          uid: user.uid,
          billingKey: result['billingKey'],
          customerKey: customerKey,
          cardNumber: result['card']?['number'] ?? '****-****-****-****',
          cardCompany: result['card']?['issuerCode'] ?? result['card']?['company'] ?? '카드사',
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError(result['message'] ?? '빌링키 발급 실패');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showError('오류: $e');
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 등록'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}