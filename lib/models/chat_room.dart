class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'unreadCount': unreadCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatRoom.fromMap(Map<String, dynamic> map) => ChatRoom(
        id: map['id'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        lastMessage: map['lastMessage'] as String?,
        lastMessageTime: map['lastMessageTime'] != null
            ? DateTime.parse(map['lastMessageTime'] as String)
            : null,
        unreadCount: (map['unreadCount'] as int?) ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  ChatRoom copyWith({
    String? id,
    String? userId,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
  }) => ChatRoom(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
        createdAt: createdAt ?? this.createdAt,
      );
}
