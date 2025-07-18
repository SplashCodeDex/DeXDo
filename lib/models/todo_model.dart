class Todo {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }
}