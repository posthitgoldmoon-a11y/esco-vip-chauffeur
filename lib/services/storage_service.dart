import 'package:hive_flutter/hive_flutter.dart';
import '../models/booking.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../models/partner_preference.dart';
import '../models/announcement.dart';
import '../models/payment_card.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class StorageService {
  static final FirestoreService _firestoreService = FirestoreService();
  static final AuthService _authService = AuthService();
  static String? get _currentUserId => _authService.currentUser?.uid;

  // Hive 초기화
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
    await Hive.openBox('chatBox');
  }

  // ─── 유저 정보 ───────────────────────────────────────────────
  static Future<void> setUserId(String id) async =>
      Hive.box('userBox').put('userId', id);
  static Future<String?> getUserId() async =>
      Hive.box('userBox').get('userId') as String?;
  static Future<void> setUserName(String name) async =>
      Hive.box('userBox').put('userName', name);
  static Future<String?> getUserName() async =>
      Hive.box('userBox').get('userName') as String?;
  static Future<void> setIsAdmin(bool isAdmin) async =>
      Hive.box('userBox').put('isAdmin', isAdmin);
  static Future<bool> getIsAdmin() async {
    if (_currentUserId != null) return await _authService.isAdmin();
    return Hive.box('userBox').get('isAdmin', defaultValue: false) as bool;
  }

  // ─── 탑승자 ───────────────────────────────────────────────────
  static Future<void> savePassenger(PassengerInfo p) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.savePassenger(_currentUserId!, p);
  }

  static Future<List<PassengerInfo>> getPassengers() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getPassengers(_currentUserId!);
  }

  static Future<void> deletePassenger(String id) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.deletePassenger(_currentUserId!, id);
  }

  // ─── 차량 ─────────────────────────────────────────────────────
  static Future<void> saveVehicle(VehicleInfo v) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.saveVehicle(_currentUserId!, v);
  }

  static Future<List<VehicleInfo>> getVehicles() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getVehicles(_currentUserId!);
  }

  static Future<void> deleteVehicle(String id) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.deleteVehicle(_currentUserId!, id);
  }

  // ─── 즐겨찾기 주소 ────────────────────────────────────────────
  static Future<void> saveLocation(LocationInfo l) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.saveLocation(_currentUserId!, l);
  }

  static Future<List<LocationInfo>> getLocations() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getLocations(_currentUserId!);
  }

  static Future<void> deleteLocation(String id) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.deleteLocation(_currentUserId!, id);
  }

  // ─── 결제 카드 ────────────────────────────────────────────────
  static Future<void> savePaymentCard(PaymentCard card) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.savePaymentCard(_currentUserId!, card);
  }

  static Future<List<PaymentCard>> getPaymentCards() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getPaymentCards(_currentUserId!);
  }

  static Future<void> deletePaymentCard(String id) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.deletePaymentCard(_currentUserId!, id);
  }

  // ─── 파트너 선호도 ────────────────────────────────────────────
  static Future<void> savePartnerPreference(PartnerPreference p) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.savePartnerPreference(_currentUserId!, p);
  }

  static Future<List<PartnerPreference>> getPartnerPreferences() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getPartnerPreferences(_currentUserId!);
  }

  static Future<void> deletePartnerPreference(String id) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다.');
    await _firestoreService.deletePartnerPreference(_currentUserId!, id);
  }

  // ─── 예약 ─────────────────────────────────────────────────────
  static Future<void> createBooking(Booking booking) async {
    await _firestoreService.createBooking(booking);
  }

  static Future<List<Booking>> getUserBookings() async {
    if (_currentUserId == null) return [];
    return _firestoreService.getUserBookings(_currentUserId!);
  }

  static Future<void> updateBookingStatus(String id, String status) async {
    await _firestoreService.updateBookingStatus(id, status);
  }

  static Future<void> deleteBooking(String id) async {
    await _firestoreService.deleteBooking(id);
  }

  // ─── 공지사항 ─────────────────────────────────────────────────
  static Future<void> saveAnnouncement(Announcement a) async {
    await _firestoreService.createAnnouncement(a);
  }

  static Future<List<Announcement>> getAnnouncements() async {
    return _firestoreService.getAnnouncements();
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _firestoreService.deleteAnnouncement(id);
  }

  // ─── 채팅 (Hive 로컬) ─────────────────────────────────────────
  static List<Map<String, dynamic>> _getMessagesFromBox(
      Box box, String roomId) {
    final raw = box.get('messages_$roomId');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
        (raw as List).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  static List<Map<String, dynamic>> _getAllChatRoomsFromBox(Box box) {
    final raw = box.get('chatRooms');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
        (raw as List).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  static Future<void> saveChatMessage(ChatMessage m) async {
    final box = Hive.box('chatBox');
    final msgs = _getMessagesFromBox(box, m.roomId);
    msgs.add(m.toMap());
    await box.put('messages_${m.roomId}', msgs);

    final rooms = _getAllChatRoomsFromBox(box);
    final idx = rooms.indexWhere((r) => r['id'] == m.roomId);
    if (idx != -1) {
      rooms[idx]['lastMessage'] = m.content;
      rooms[idx]['lastMessageTime'] = m.timestamp.toIso8601String();
      if (!m.isAdmin) {
        rooms[idx]['unreadCount'] =
            (rooms[idx]['unreadCount'] as int? ?? 0) + 1;
      }
      await box.put('chatRooms', rooms);
    }
  }

  static Future<List<ChatMessage>> getRoomMessages(String roomId) async {
    final box = Hive.box('chatBox');
    final msgs = _getMessagesFromBox(box, roomId);
    return msgs.map((m) => ChatMessage.fromMap(m)).toList();
  }

  static Future<List<ChatRoom>> getAllChatRooms() async {
    final box = Hive.box('chatBox');
    final rooms = _getAllChatRoomsFromBox(box);
    return rooms.map((r) => ChatRoom.fromMap(r)).toList();
  }

  static Future<ChatRoom> getOrCreateChatRoom(
      String userId, String userName) async {
    final box = Hive.box('chatBox');
    final rooms = _getAllChatRoomsFromBox(box);
    final idx = rooms.indexWhere((r) => r['userId'] == userId);
    if (idx != -1) return ChatRoom.fromMap(rooms[idx]);

    final newRoom = ChatRoom(
      id: userId,
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
    );
    rooms.add(newRoom.toMap());
    await box.put('chatRooms', rooms);
    return newRoom;
  }

  static Future<void> markMessagesAsRead(String roomId) async {
    final box = Hive.box('chatBox');
    final msgs = _getMessagesFromBox(box, roomId);
    final updated = msgs.map((m) => {...m, 'isRead': true}).toList();
    await box.put('messages_$roomId', updated);

    final rooms = _getAllChatRoomsFromBox(box);
    final idx = rooms.indexWhere((r) => r['id'] == roomId);
    if (idx != -1) {
      rooms[idx]['unreadCount'] = 0;
      await box.put('chatRooms', rooms);
    }
  }

  // ─── 데이터 초기화 ────────────────────────────────────────────
  static Future<void> clearAllData() async =>
      Hive.box('userBox').clear();

  static Future<void> clearAll() async {
    await clearAllData();
    await Hive.box('chatBox').clear();
  }
}
