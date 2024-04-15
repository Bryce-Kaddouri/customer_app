class NotificationModel {
  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
  final String? userId;
  final int? orderId;
  final DateTime? order_date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.userId,
    required this.orderId,
    required this.order_date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      orderId: json['order_id'],
      order_date: json['order_date'] != null ? DateTime.parse(json['order_date']) : null,
    );
  }
}
