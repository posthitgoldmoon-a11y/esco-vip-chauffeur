import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../models/partner_preference.dart';
import '../models/announcement.dart';
import '../models/payment_card.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── 탑승자 ───────────────────────────────────────────────────
  Future<void> savePassenger(String userId, PassengerInfo p) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('passengers')
          .doc(p.id)
          .set(p.toMap());
    } catch (e) {
      throw Exception('탑승자 저장 실패: $e');
    }
  }

  Future<List<PassengerInfo>> getPassengers(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('passengers')
          .get();
      return snap.docs.map((d) => PassengerInfo.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('탑승자 조회 실패: $e');
    }
  }

  Future<void> deletePassenger(String userId, String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('passengers')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('탑승자 삭제 실패: $e');
    }
  }

  // ─── 차량 ─────────────────────────────────────────────────────
  Future<void> saveVehicle(String userId, VehicleInfo v) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(v.id)
          .set(v.toMap());
    } catch (e) {
      throw Exception('차량 저장 실패: $e');
    }
  }

  Future<List<VehicleInfo>> getVehicles(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .get();
      return snap.docs.map((d) => VehicleInfo.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('차량 조회 실패: $e');
    }
  }

  Future<void> deleteVehicle(String userId, String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('차량 삭제 실패: $e');
    }
  }

  // ─── 즐겨찾기 주소 ────────────────────────────────────────────
  Future<void> saveLocation(String userId, LocationInfo l) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('locations')
          .doc(l.id)
          .set(l.toMap());
    } catch (e) {
      throw Exception('주소 저장 실패: $e');
    }
  }

  Future<List<LocationInfo>> getLocations(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('locations')
          .get();
      return snap.docs.map((d) => LocationInfo.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('주소 조회 실패: $e');
    }
  }

  Future<void> deleteLocation(String userId, String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('locations')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('주소 삭제 실패: $e');
    }
  }

  // ─── 결제 카드 ────────────────────────────────────────────────
  Future<void> savePaymentCard(String userId, PaymentCard card) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('paymentCards')
          .doc(card.id)
          .set(card.toMap());
    } catch (e) {
      throw Exception('카드 저장 실패: $e');
    }
  }

  Future<List<PaymentCard>> getPaymentCards(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('paymentCards')
          .get();
      return snap.docs.map((d) => PaymentCard.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('카드 조회 실패: $e');
    }
  }

  Future<void> deletePaymentCard(String userId, String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('paymentCards')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('카드 삭제 실패: $e');
    }
  }

  // ─── 파트너 선호도 ────────────────────────────────────────────
  Future<void> savePartnerPreference(
      String userId, PartnerPreference p) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('partnerPreferences')
          .doc(p.id)
          .set(p.toMap());
    } catch (e) {
      throw Exception('파트너 선호도 저장 실패: $e');
    }
  }

  Future<List<PartnerPreference>> getPartnerPreferences(
      String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('partnerPreferences')
          .get();
      return snap.docs
          .map((d) => PartnerPreference.fromMap(d.data()))
          .toList();
    } catch (e) {
      throw Exception('파트너 선호도 조회 실패: $e');
    }
  }

  Future<void> deletePartnerPreference(String userId, String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('partnerPreferences')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('파트너 선호도 삭제 실패: $e');
    }
  }

  // ─── 예약 ─────────────────────────────────────────────────────
  Future<void> createBooking(Booking booking) async {
    try {
      await _db.collection('bookings').doc(booking.id).set(booking.toMap());
    } catch (e) {
      throw Exception('예약 생성 실패: $e');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final snap = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => Booking.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('예약 조회 실패: $e');
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await _db.collection('bookings').doc(id).update({'status': status});
    } catch (e) {
      throw Exception('예약 상태 업데이트 실패: $e');
    }
  }

  Future<void> deleteBooking(String id) async {
    try {
      await _db.collection('bookings').doc(id).delete();
    } catch (e) {
      throw Exception('예약 삭제 실패: $e');
    }
  }

  // ─── 공지사항 ─────────────────────────────────────────────────
  Future<void> createAnnouncement(Announcement a) async {
    try {
      await _db
          .collection('announcements')
          .doc(a.id)
          .set(a.toMap());
    } catch (e) {
      throw Exception('공지사항 저장 실패: $e');
    }
  }

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final snap = await _db
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => Announcement.fromMap(d.data())).toList();
    } catch (e) {
      throw Exception('공지사항 조회 실패: $e');
    }
  }

  Future<void> updateAnnouncement(Announcement a) async {
    try {
      await _db
          .collection('announcements')
          .doc(a.id)
          .update(a.toMap());
    } catch (e) {
      throw Exception('공지사항 수정 실패: $e');
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _db.collection('announcements').doc(id).delete();
    } catch (e) {
      throw Exception('공지사항 삭제 실패: $e');
    }
  }
}
