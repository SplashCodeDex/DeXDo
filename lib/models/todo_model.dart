class Todo {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    try {
      return Todo(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        isDone: json['isDone'] == true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
    } catch (e) {
      // Return a default todo if parsing fails
      return Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Invalid Task',
        description: 'This task had corrupted data',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
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
