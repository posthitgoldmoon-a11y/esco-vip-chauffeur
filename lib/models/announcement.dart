class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isPinned;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'] as String,
        title: map['title'] as String,
        content: map['content'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isPinned: (map['isPinned'] as bool?) ?? false,
      );
}
