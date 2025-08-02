import 'package:isar/isar.dart';
import '../models/todo_model.dart';

enum SortBy {
  creationDate,
  dueDate,
}

class TodoRepository {
  final Isar isar;

  TodoRepository(this.isar);

  Future<List<Todo>> loadTodos() async {
    return await isar.todos.where().findAll();
  }

  Future<void> saveTodo(Todo todo) async {
    await isar.writeTxn(() async {
      await isar.todos.put(todo);
    });
  }

  Future<void> deleteTodo(int id) async {
    await isar.writeTxn(() async {
      await isar.todos.delete(id);
    });
  }

  Future<void> clearAllTodos() async {
    await isar.writeTxn(() async {
      await isar.todos.clear();
    });
  }

  Stream<List<Todo>> watchTodos({SortBy sortBy = SortBy.creationDate}) {
    QueryBuilder<Todo, Todo, QAfterSortBy> query = isar.todos.where();

    switch (sortBy) {
      case SortBy.creationDate:
        query = query.sortByCreatedAtDesc();
        break;
      case SortBy.dueDate:
        query = query.sortByDueDate();
        break;
    }

    return query.watch(fireImmediately: true);
  }
}


