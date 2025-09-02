class Todo {
  int? id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final int position;
  final bool isRecurring;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;

  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.position = 0,
    this.isRecurring = false,
    this.recurrenceType = RecurrenceType.daily,
    this.recurrenceEndDate,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    int? position,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      position: position ?? this.position,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isDone: $isDone, isRecurring: $isRecurring, recurrenceType: $recurrenceType, recurrenceEndDate: $recurrenceEndDate)';
  }

  // Helper methods
  bool get hasDescription => description.isNotEmpty;

  String get displayTitle =>
      title.trim().isEmpty ? 'Untitled Task' : title.trim();

  String get displayDescription => description.trim();
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}
