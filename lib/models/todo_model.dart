import 'package:isar/isar.dart';

part 'todo_model.g.dart';

@collection
class Todo {
  Id id = Isar.autoIncrement;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Todo({
    required this.title,
    this.description = '',
    this.isDone = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
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
    return 'Todo(id: $id, title: $title, isDone: $isDone)';
  }

  // Helper methods
  bool get hasDescription => description.isNotEmpty;

  String get displayTitle =>
      title.trim().isEmpty ? 'Untitled Task' : title.trim();

  String get displayDescription => description.trim();
}

