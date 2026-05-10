import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TossPaymentService {
  // 클라이언트 키만 보유 (시크릿 키는 서버 Cloud Functions에서만 사용)
  static const String clientKey = 'test_ck_zXLkKEypNArWmo50nX3lmeaxYG5R';

  // 고객 고유키 생성 (uid 기반)
  static String generateCustomerKey(String uid) {
    return 'customer_${uid}_${const Uuid().v4().substring(0, 8)}';
  }

  // 빌링키 Firestore에 저장 (uid 파라미터 포함)
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
        .collection('paymentCards')
        .add({
      'billingKey': billingKey,
      'customerKey': customerKey,
      'cardNumber': cardNumber,
      'cardCompany': cardCompany,
      'createdAt': DateTime.now().toIso8601String(),
      'isDefault': false,
    });
  }

  // 빌링키로 결제 승인 (Cloud Function 호출)
  static Future<Map<String, dynamic>> approveBillingPayment({
    required String billingKey,
    required String customerKey,
    required int amount,
    required String orderName,
    String? customerEmail,
    String? customerName,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('approveBillingPayment');

      final result = await callable.call({
        'billingKey': billingKey,
        'customerKey': customerKey,
        'amount': amount,
        'orderName': orderName,
        'customerEmail': customerEmail ?? '',
        'customerName': customerName ?? '고객',
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('결제 실패: ${e.message}');
    } catch (e) {
      throw Exception('결제 오류: $e');
    }
  }

  // 빌링키 발급 승인 (Cloud Function 호출)
  static Future<Map<String, dynamic>> issueBillingKey({
    required String authKey,
    required String customerKey,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('issueBillingKey');

      final result = await callable.call({
        'authKey': authKey,
        'customerKey': customerKey,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('빌링키 발급 실패: ${e.message}');
    } catch (e) {
      throw Exception('빌링키 발급 오류: $e');
    }
  }
}
