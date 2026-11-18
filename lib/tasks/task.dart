class CortexTask {
  const CortexTask({
    required this.id,
    required this.title,
    this.dueAt,
    this.notificationId,
    this.isDone = false,
  });

  final String id;
  final String title;
  final DateTime? dueAt;
  final int? notificationId;
  final bool isDone;

  CortexTask copyWith({bool? isDone}) => CortexTask(
    id: id,
    title: title,
    dueAt: dueAt,
    notificationId: notificationId,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueAt': dueAt?.toIso8601String(),
    'notificationId': notificationId,
    'isDone': isDone,
  };

  factory CortexTask.fromJson(Map<String, dynamic> json) => CortexTask(
    id: json['id'] as String,
    title: json['title'] as String,
    dueAt: json['dueAt'] == null
        ? null
        : DateTime.tryParse(json['dueAt'] as String),
    notificationId: json['notificationId'] as int?,
    isDone: json['isDone'] as bool? ?? false,
  );
}
