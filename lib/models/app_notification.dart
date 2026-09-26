import 'dart:convert';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String type; // 'booking', 'reminder', 'system', 'course'
  final String? route;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'system',
    this.route,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'route': route,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] == true,
      type: map['type']?.toString() ?? 'system',
      route: map['route']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AppNotification.fromJson(String source) =>
      AppNotification.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
