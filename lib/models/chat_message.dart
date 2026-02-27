class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isAdmin;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isAdmin = false,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'roomId': roomId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'isAdmin': isAdmin,
        'isRead': isRead,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        roomId: map['roomId'] as String,
        senderId: map['senderId'] as String,
        senderName: map['senderName'] as String,
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isAdmin: (map['isAdmin'] as bool?) ?? false,
        isRead: (map['isRead'] as bool?) ?? false,
      );

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isAdmin,
    bool? isRead,
  }) => ChatMessage(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        isAdmin: isAdmin ?? this.isAdmin,
        isRead: isRead ?? this.isRead,
      );
}
