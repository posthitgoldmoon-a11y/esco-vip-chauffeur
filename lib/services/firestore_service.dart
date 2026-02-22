import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== BOOKINGS ====================

  // 예약 생성
  Future<void> createBooking(String userId, Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
    } catch (e) {
      throw Exception('예약 생성 실패: $e');
    }
  }

  // 사용자의 모든 예약 가져오기
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data()))
          .toList();

      // 최신순으로 정렬
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return bookings;
    } catch (e) {
      throw Exception('예약 목록 가져오기 실패: $e');
    }
  }

  // 예약 업데이트
  Future<void> updateBooking(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toMap());
    } catch (e) {
      throw Exception('예약 업데이트 실패: $e');
    }
  }

  // 예약 삭제
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('예약 삭제 실패: $e');
    }
  }

  // ==================== PASSENGERS ====================

  // 탑승자 정보 저장
  Future<void> savePassenger(String userId, Map<String, dynamic> passenger) async {
    try {
      final docId = passenger['id'] ?? _firestore.collection('passengers').doc().id;
      await _firestore.collection('passengers').doc(docId).set({
        ...passenger,
        'id': docId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('탑승자 정보 저장 실패: $e');
    }
  }

  // 탑승자 정보 가져오기
  Future<List<Map<String, dynamic>>> getPassengers(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('passengers')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('탑승자 정보 가져오기 실패: $e');
    }
  }

  // 탑승자 정보 삭제
  Future<void> deletePassenger(String passengerId) async {
    try {
      await _firestore.collection('passengers').doc(passengerId).delete();
    } catch (e) {
      throw Exception('탑승자 정보 삭제 실패: $e');
    }
  }

  // ==================== VEHICLES ====================

  // 차량 정보 저장
  Future<void> saveVehicle(String userId, Map<String, dynamic> vehicle) async {
    try {
      final docId = vehicle['id'] ?? _firestore.collection('vehicles').doc().id;
      await _firestore.collection('vehicles').doc(docId).set({
        ...vehicle,
        'id': docId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('차량 정보 저장 실패: $e');
    }
  }

  // 차량 정보 가져오기
  Future<List<Map<String, dynamic>>> getVehicles(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('vehicles')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('차량 정보 가져오기 실패: $e');
    }
  }

  // 차량 정보 삭제
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      throw Exception('차량 정보 삭제 실패: $e');
    }
  }

  // ==================== LOCATIONS ====================

  // 장소 저장
  Future<void> saveLocation(String userId, Map<String, dynamic> location) async {
    try {
      final docId = location['id'] ?? _firestore.collection('locations').doc().id;
      await _firestore.collection('locations').doc(docId).set({
        ...location,
        'id': docId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('장소 저장 실패: $e');
    }
  }

  // 장소 가져오기
  Future<List<Map<String, dynamic>>> getLocations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('locations')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('장소 가져오기 실패: $e');
    }
  }

  // 장소 삭제
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore.collection('locations').doc(locationId).delete();
    } catch (e) {
      throw Exception('장소 삭제 실패: $e');
    }
  }

  // ==================== PARTNER PREFERENCES ====================

  // 파트너 선호사항 저장
  Future<void> savePartnerPreference(
      String userId, Map<String, dynamic> preference) async {
    try {
      final docId = preference['id'] ?? _firestore.collection('partnerPreferences').doc().id;
      await _firestore.collection('partnerPreferences').doc(docId).set({
        ...preference,
        'id': docId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('파트너 선호사항 저장 실패: $e');
    }
  }

  // 파트너 선호사항 가져오기
  Future<List<Map<String, dynamic>>> getPartnerPreferences(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('partnerPreferences')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('파트너 선호사항 가져오기 실패: $e');
    }
  }

  // 파트너 선호사항 삭제
  Future<void> deletePartnerPreference(String preferenceId) async {
    try {
      await _firestore.collection('partnerPreferences').doc(preferenceId).delete();
    } catch (e) {
      throw Exception('파트너 선호사항 삭제 실패: $e');
    }
  }

  // ==================== ANNOUNCEMENTS ====================

  // 공지사항 생성 (관리자만)
  Future<void> createAnnouncement(Map<String, dynamic> announcement) async {
    try {
      final docId = announcement['id'] ?? _firestore.collection('announcements').doc().id;
      await _firestore.collection('announcements').doc(docId).set({
        ...announcement,
        'id': docId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('공지사항 생성 실패: $e');
    }
  }

  // 모든 공지사항 가져오기
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final querySnapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('공지사항 가져오기 실패: $e');
    }
  }

  // 공지사항 업데이트
  Future<void> updateAnnouncement(String announcementId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('공지사항 업데이트 실패: $e');
    }
  }

  // 공지사항 삭제
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).delete();
    } catch (e) {
      throw Exception('공지사항 삭제 실패: $e');
    }
  }

  // ==================== PAYMENT CARDS ====================

  // 결제 카드 저장
  Future<void> savePaymentCard(String userId, Map<String, dynamic> card) async {
    try {
      final docId = card['id'] ?? _firestore.collection('paymentCards').doc().id;
      await _firestore.collection('paymentCards').doc(docId).set({
        ...card,
        'id': docId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('결제 카드 저장 실패: $e');
    }
  }

  // 결제 카드 가져오기
  Future<List<Map<String, dynamic>>> getPaymentCards(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('paymentCards')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('결제 카드 가져오기 실패: $e');
    }
  }

  // 결제 카드 삭제
  Future<void> deletePaymentCard(String cardId) async {
    try {
      await _firestore.collection('paymentCards').doc(cardId).delete();
    } catch (e) {
      throw Exception('결제 카드 삭제 실패: $e');
    }
  }
}
