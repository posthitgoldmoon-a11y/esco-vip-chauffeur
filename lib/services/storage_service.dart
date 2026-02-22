import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/passenger_info.dart';
import '../models/vehicle_info.dart';
import '../models/location_info.dart';
import '../models/booking.dart';
import '../models/announcement.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/payment_card.dart';
import '../models/partner_preference.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// StorageService - Firebase Firestore Adapter
/// 기존 Hive 기반 코드를 수정하지 않고도 Firestore를 사용할 수 있도록
/// StorageService가 내부적으로 FirestoreService를 호출합니다.
class StorageService {
  static final FirestoreService _firestoreService = FirestoreService();
  static final AuthService _authService = AuthService();

  // 현재 사용자 ID 가져오기
  static String? get _currentUserId => _authService.currentUser?.uid;

  static Future<void> init() async {
    await Hive.initFlutter();
    // Hive는 로컬 캐시 및 백업용으로 유지
  }

  // User
  static Future<void> setUserId(String userId) async {
    final box = await Hive.openBox('user');
    await box.put('userId', userId);
  }

  static Future<String?> getUserId() async {
    // Firebase Auth에서 userId 가져오기 (우선순위 1)
    if (_currentUserId != null) return _currentUserId;
    
    // Fallback: Hive에서 가져오기
    final box = await Hive.openBox('user');
    return box.get('userId') as String?;
  }

  static Future<void> setUserName(String userName) async {
    final box = await Hive.openBox('user');
    await box.put('userName', userName);
  }

  static Future<String?> getUserName() async {
    final box = await Hive.openBox('user');
    return box.get('userName') as String?;
  }

  static Future<void> setIsAdmin(bool isAdmin) async {
    final box = await Hive.openBox('user');
    await box.put('isAdmin', isAdmin);
  }

  static Future<bool> getIsAdmin() async {
    if (_currentUserId != null) {
      return await _authService.isAdmin();
    }
    final box = await Hive.openBox('user');
    return (box.get('isAdmin') as bool?) ?? false;
  }

  // Passengers - Firestore 사용
  static Future<void> savePassenger(PassengerInfo passenger) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.savePassenger(_currentUserId!, passenger.toMap());
  }

  static Future<List<PassengerInfo>> getPassengers() async {
    if (_currentUserId == null) return [];
    final data = await _firestoreService.getPassengers(_currentUserId!);
    return data.map((e) => PassengerInfo.fromMap(e)).toList();
  }

  static Future<void> deletePassenger(String id) async {
    await _firestoreService.deletePassenger(id);
  }

  // Vehicles - Firestore 사용
  static Future<void> saveVehicle(VehicleInfo vehicle) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.saveVehicle(_currentUserId!, vehicle.toMap());
  }

  static Future<List<VehicleInfo>> getVehicles() async {
    if (_currentUserId == null) return [];
    final data = await _firestoreService.getVehicles(_currentUserId!);
    return data.map((e) => VehicleInfo.fromMap(e)).toList();
  }

  static Future<void> deleteVehicle(String id) async {
    await _firestoreService.deleteVehicle(id);
  }

  // Locations - Firestore 사용
  static Future<void> saveLocation(LocationInfo location) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.saveLocation(_currentUserId!, location.toMap());
  }

  static Future<List<LocationInfo>> getLocations() async {
    if (_currentUserId == null) return [];
    final data = await _firestoreService.getLocations(_currentUserId!);
    return data.map((e) => LocationInfo.fromMap(e)).toList();
  }

  static Future<void> deleteLocation(String id) async {
    await _firestoreService.deleteLocation(id);
  }

  // Bookings - Firestore 사용
  static Future<void> saveBooking(Booking booking) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.createBooking(_currentUserId!, booking);
  }

  static Future<List<Booking>> getBookings([String? userId]) async {
    final uid = userId ?? _currentUserId;
    if (uid == null) return [];
    return await _firestoreService.getUserBookings(uid);
  }

  static Future<void> deleteBooking(String id) async {
    await _firestoreService.deleteBooking(id);
  }

  static Future<void> updateBooking(Booking booking) async {
    await _firestoreService.updateBooking(booking);
  }

  // Partner Preferences - Firestore 사용
  static Future<void> savePartnerPreference(PartnerPreference preference) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.savePartnerPreference(_currentUserId!, preference.toMap());
  }

  static Future<List<PartnerPreference>> getPartnerPreferences() async {
    if (_currentUserId == null) return [];
    final data = await _firestoreService.getPartnerPreferences(_currentUserId!);
    return data.map((e) => PartnerPreference.fromMap(e)).toList();
  }

  static Future<void> deletePartnerPreference(String id) async {
    await _firestoreService.deletePartnerPreference(id);
  }

  // Payment Cards - Firestore 사용
  static Future<void> savePaymentCard(PaymentCard card) async {
    if (_currentUserId == null) throw Exception('로그인이 필요합니다');
    await _firestoreService.savePaymentCard(_currentUserId!, card.toMap());
  }

  static Future<List<PaymentCard>> getPaymentCards() async {
    if (_currentUserId == null) return [];
    final data = await _firestoreService.getPaymentCards(_currentUserId!);
    return data.map((e) => PaymentCard.fromMap(e)).toList();
  }

  static Future<void> deletePaymentCard(String id) async {
    await _firestoreService.deletePaymentCard(id);
  }

  // Announcements - Firestore 사용
  static Future<void> saveAnnouncement(Announcement announcement) async {
    await _firestoreService.createAnnouncement(announcement.toMap());
  }

  static Future<List<Announcement>> getAnnouncements() async {
    final data = await _firestoreService.getAnnouncements();
    return data.map((e) => Announcement.fromMap(e)).toList();
  }

  static Future<void> updateAnnouncement(Announcement announcement) async {
    await _firestoreService.updateAnnouncement(announcement.id, announcement.toMap());
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _firestoreService.deleteAnnouncement(id);
  }

  // Chat Messages - Hive 사용 (실시간 기능은 Firestore Realtime이 더 적합)
  static Future<void> saveChatMessage(ChatMessage message) async {
    final box = await Hive.openBox('chatMessages');
    await box.put(message.id, message.toMap());
  }

  static Future<List<ChatMessage>> getChatMessages(String roomId) async {
    final box = await Hive.openBox('chatMessages');
    final messages = box.values
        .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((msg) => msg.roomId == roomId)
        .toList();
    messages.sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;
      if (aTime == null || bTime == null) return 0;
      return aTime.compareTo(bTime);
    });
    return messages;
  }

  // Chat Rooms - Hive 사용
  static Future<void> saveChatRoom(ChatRoom room) async {
    final box = await Hive.openBox('chatRooms');
    await box.put(room.id, room.toMap());
  }

  static Future<List<ChatRoom>> getChatRooms() async {
    final box = await Hive.openBox('chatRooms');
    final rooms = box.values
        .map((e) => ChatRoom.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    rooms.sort((a, b) {
      final aTime = a.lastMessageTime;
      final bTime = b.lastMessageTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return rooms;
  }

  static Future<void> updateChatRoom(ChatRoom room) async {
    await saveChatRoom(room);
  }

  static Future<void> deleteChatRoom(String id) async {
    final box = await Hive.openBox('chatRooms');
    await box.delete(id);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  static Future<void> clearAllData() async {
    await clearAll();
  }

  // Booking methods with alternative names
  static Future<List<Booking>> getUserBookings([String? userId]) async {
    return await getBookings(userId);
  }

  // Chat methods
  static Future<List<ChatRoom>> getAllChatRooms() async {
    return await getChatRooms();
  }

  static Future<List<ChatMessage>> getRoomMessages(String roomId) async {
    return await getChatMessages(roomId);
  }

  static Future<void> markMessagesAsRead(String roomId, String userId) async {
    // TODO: Implement if needed
  }

  static Future<ChatRoom?> getOrCreateChatRoom(String userId, String userName) async {
    final rooms = await getChatRooms();
    try {
      return rooms.firstWhere((room) => room.userId == userId);
    } catch (e) {
      // Create new room
      final now = DateTime.now();
      final newRoom = ChatRoom(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        lastMessage: '',
        lastMessageTime: now,
        unreadCount: 0,
        createdAt: now,
      );
      await saveChatRoom(newRoom);
      return newRoom;
    }
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    final bookings = await getBookings();
    final booking = bookings.firstWhere((b) => b.id == bookingId);
    final updatedBooking = booking.copyWith(status: status);
    await updateBooking(updatedBooking);
  }

  static Future<void> setDefaultPaymentCard(String cardId) async {
    // TODO: Implement default card logic
  }
}
