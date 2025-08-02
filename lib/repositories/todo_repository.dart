import 'package:isar/isar.dart';
import '../models/todo_model.dart';

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

  Stream<List<Todo>> watchTodos() {
    return isar.todos.where().watch(fireImmediately: true);
  }
}

