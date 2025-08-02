import 'package:isar/isar.dart';
import '../models/todo_model.dart';

enum SortBy {
  position,
  creationDate,
  dueDate,
}

class TodoRepository {
  final Isar isar;

  TodoRepository(this.isar);

  Future<List<Todo>> loadTodos() async {
    return await isar.todos.where().sortByPosition().findAll();
  }

  Future<void> saveTodo(Todo todo) async {
    await isar.writeTxn(() async {
      // If the todo is new, assign it the next available position
      if (todo.id == Isar.autoIncrement) {
        final count = await isar.todos.count();
        final todoToSave = todo.copyWith(position: count);
        await isar.todos.put(todoToSave);
      } else {
        // Otherwise, it's an update, so just save it
        await isar.todos.put(todo);
      }
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

  Future<void> updateTodoPosition(int oldIndex, int newIndex) async {
    await isar.writeTxn(() async {
      final todos = await isar.todos.where().sortByPosition().findAll();

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final movedTodo = todos.removeAt(oldIndex);
      todos.insert(newIndex, movedTodo);

      final List<Todo> updatedTodos = [];
      for (int i = 0; i < todos.length; i++) {
        if (todos[i].position != i) {
          updatedTodos.add(todos[i].copyWith(position: i));
        }
      }

      if (updatedTodos.isNotEmpty) {
        await isar.todos.putAll(updatedTodos);
      }
    });
  }

  Stream<List<Todo>> watchTodos({SortBy sortBy = SortBy.position}) {
    QueryBuilder<Todo, Todo, QAfterSortBy> query = isar.todos.where();

    switch (sortBy) {
      case SortBy.position:
        query = query.sortByPosition();
        break;
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


