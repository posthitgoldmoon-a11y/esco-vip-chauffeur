import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/toss_payment_service.dart';
import 'card_registration_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String orderName;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? _billingInfo;
  bool _isLoading = true;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _loadBillingInfo();
  }

  Future<void> _loadBillingInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final billing = await TossPaymentService.getBillingKey(user.uid);
    setState(() {
      _billingInfo = billing;
      _isLoading = false;
    });
  }

  Future<void> _registerCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CardRegistrationScreen()),
    );
    if (result == true) {
      _loadBillingInfo();
    }
  }

  Future<void> _pay() async {
    if (_billingInfo == null) return;

    setState(() => _isPaying = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final result = await TossPaymentService.payWithBillingKey(
        billingKey: _billingInfo!['billingKey'],
        customerKey: _billingInfo!['customerKey'],
        amount: widget.amount,
        orderName: widget.orderName,
        orderId: TossPaymentService.generateOrderId(),
        customerEmail: user.email ?? '',
        customerName: user.displayName ?? '고객',
      );

      if (result['paymentKey'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('결제가 완료되었습니다!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(result['message'] ?? '결제 실패');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 결제 금액
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '결제 금액',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.orderName,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 등록된 카드
                  const Text(
                    '결제 수단',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_billingInfo != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.credit_card, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _billingInfo!['cardCompany'] ?? '카드',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _billingInfo!['cardNumber'] ?? '****',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _registerCard,
                            child: const Text('변경'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: _registerCard,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('카드 등록하기', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // 결제 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_billingInfo == null || _isPaying) ? null : _pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPaying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('결제하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
