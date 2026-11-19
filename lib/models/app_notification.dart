class AppNotification {
  final String? id;
  final String title;
  final String message;
  final bool isIncome;
  final DateTime time;

  AppNotification({
    this.id,
    required this.title,
    required this.message,
    required this.isIncome,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      isIncome: json['isIncome'] as bool,
      time: json['time'] != null
          ? DateTime.parse(json['time'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'message': message,
      'isIncome': isIncome,
      'time': time.toIso8601String(),
    };
  }
}