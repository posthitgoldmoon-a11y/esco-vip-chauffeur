import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TossPaymentService {
  static const String _clientKey = "test_ck_E92LAa5PVbI72GoXg0B987YmpXyJ";
  static const String _secretKey = "test_sk_kYG57Eba3G9Lq47Go1X9rpWDOxmA";
  static const String _baseUrl = "https://api.tosspayments.com";

  // 빌링키 발급 페이지 URL 생성
  static String getBillingAuthUrl({
    required String customerKey,
    required String successUrl,
    required String failUrl,
  }) {
    return "https://api.tosspayments.com/v1/billing/authorizations/card?"
        "clientKey=$_clientKey"
        "&customerKey=$customerKey"
        "&successUrl=${Uri.encodeComponent(successUrl)}"
        "&failUrl=${Uri.encodeComponent(failUrl)}";
  }


  // 빌링키 발급
  static Future<Map<String, dynamic>> issueBillingKey({
    required String customerKey,
    required String authKey,
  }) async {
    final String encoded = base64Encode(utf8.encode("$_secretKey:"));

    final response = await http.post(
      Uri.parse("$_baseUrl/v1/billing/authorizations/issue"),
      headers: {
        "Authorization": "Basic $encoded",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "authKey": authKey,
        "customerKey": customerKey,
      }),
    );

    return jsonDecode(response.body);
  }

  // 빌링키로 결제 요청
  static Future<Map<String, dynamic>> payWithBillingKey({
    required String billingKey,
    required String customerKey,
    required int amount,
    required String orderName,
    required String orderId,
    required String customerEmail,
    required String customerName,
  }) async {
    final String encoded = base64Encode(
      utf8.encode("$_secretKey:"),
    );

    final response = await http.post(
      Uri.parse("$_baseUrl/v1/billing/$billingKey"),
      headers: {
        "Authorization": "Basic $encoded",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "customerKey": customerKey,
        "amount": amount,
        "orderId": orderId,
        "orderName": orderName,
        "customerEmail": customerEmail,
        "customerName": customerName,
      }),
    );

    return jsonDecode(response.body);
  }

  // 빌링키 Firestore 저장
  static Future<void> saveBillingKey({
    required String uid,
    required String billingKey,
    required String customerKey,
    required String cardNumber,
    required String cardCompany,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('billing')
        .doc('card')
        .set({
      'billingKey': billingKey,
      'customerKey': customerKey,
      'cardNumber': cardNumber,
      'cardCompany': cardCompany,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 빌링키 조회
  static Future<Map<String, dynamic>?> getBillingKey(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('billing')
        .doc('card')
        .get();
    return doc.data();
  }

  // 고객키 생성
  static String generateCustomerKey(String uid) {
    return "customer_${uid}_${DateTime.now().millisecondsSinceEpoch}";
  }

  // 주문ID 생성
  static String generateOrderId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
