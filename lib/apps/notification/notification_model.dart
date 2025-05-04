class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
