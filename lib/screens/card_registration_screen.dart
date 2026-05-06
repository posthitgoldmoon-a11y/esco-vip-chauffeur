import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/toss_payment_service.dart';
import 'card_registration_webview.dart';

class CardRegistrationScreen extends StatefulWidget {
  const CardRegistrationScreen({super.key});
  @override
  State<CardRegistrationScreen> createState() => _CardRegistrationScreenState();
}

class _CardRegistrationScreenState extends State<CardRegistrationScreen> {
  bool _isLoading = false;
  static const _clientKey = 'test_ck_E92LAa5PVbI72GoXg0B987YmpXyJ';
  static const _successBase = 'https://escovip.page.link/billing-success';
  static const _failBase = 'https://escovip.page.link/billing-fail';

  Future<void> _registerCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')));
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final customerKey = TossPaymentService.generateCustomerKey(user.uid);
      final encodedKey = Uri.encodeComponent(customerKey);
      final billingUrl =
          'https://api.tosspayments.com/v1/billing/authorizations/card'
          '?clientKey=$_clientKey'
          '&customerKey=$encodedKey'
          '&successUrl=${Uri.encodeComponent('$_successBase?customerKey=$encodedKey')}'
          '&failUrl=${Uri.encodeComponent(_failBase)}';

      if (kIsWeb) {
        final uri = Uri.parse(billingUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        if (!mounted) return;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => CardRegistrationWebView(
              billingUrl: billingUrl,
              customerKey: customerKey,
            ),
          ),
        );
        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('카드가 성공적으로 등록되었습니다!')));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 등록'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120, width: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.credit_card, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('카드를 등록하면\n예약 후 자동으로 결제됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('카드 등록하기', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('* 카드 정보는 토스페이먼츠에 안전하게 저장됩니다\n* 등록 후 예약 시 자동 결제됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}