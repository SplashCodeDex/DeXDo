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
        final todoToSave = todo.copyWith(position: count, createdAt: todo.createdAt);
        await isar.todos.put(todoToSave);
      } else {
        // Otherwise, it's an update, so just save it
        await isar.todos.put(todo);

        // If a recurring task is marked as done, create a new instance
        if (todo.isRecurring && todo.isDone && todo.recurrenceType != null) {
          final nextDueDate = _calculateNextDueDate(
            todo.dueDate ?? DateTime.now(),
            todo.recurrenceType!,
          );

          // Only create a new recurring task if the recurrence end date is not reached
          if (todo.recurrenceEndDate == null || nextDueDate.isBefore(todo.recurrenceEndDate!)) {
            final newRecurringTodo = todo.copyWith(
              isDone: false,
              createdAt: DateTime.now(),
              updatedAt: null,
              dueDate: nextDueDate,
              position: await isar.todos.count(), // Assign new position
            );
            await isar.todos.put(newRecurringTodo);
          }
        }
      }
    });
  }

  DateTime _calculateNextDueDate(DateTime currentDueDate, RecurrenceType type) {
    DateTime nextDate = currentDueDate;
    switch (type) {
      case RecurrenceType.daily:
        nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + 1);
        break;
      case RecurrenceType.weekly:
        nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day + 7);
        break;
      case RecurrenceType.monthly:
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        break;
      case RecurrenceType.yearly:
        nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
        break;
    }
    return nextDate;
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
          updatedTodos.add(todos[i].copyWith(position: i, createdAt: todos[i].createdAt));
        }
      }

      if (updatedTodos.isNotEmpty) {
        await isar.todos.putAll(updatedTodos);
      }
    });
  }

  Future<void> clearCompletedTodos() async {
    await isar.writeTxn(() async {
      await isar.todos.where().filter().isDoneEqualTo(true).deleteAll();
    });
  }

  // TODO: This method performs filtering and sorting in-memory, which is inefficient.
  // It should be refactored to use Isar's query builder to perform these operations
  // at the database level. Attempts to do this were blocked by compilation issues
  // with the query builder API in the current project setup.
  Stream<List<Todo>> watchTodos({
    SortBy sortBy = SortBy.position,
    bool? isDone,
    String? searchQuery,
  }) {
    return isar.todos.where().watch(fireImmediately: true).map((todos) {
      List<Todo> filteredTodos = todos;

      if (isDone != null) {
        filteredTodos = filteredTodos.where((todo) => todo.isDone == isDone).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredTodos = filteredTodos.where((todo) {
          return todo.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              todo.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      switch (sortBy) {
        case SortBy.position:
          filteredTodos.sort((a, b) => a.position.compareTo(b.position));
          break;
        case SortBy.creationDate:
          filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case SortBy.dueDate:
          filteredTodos.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) {
              return 0;
            } else if (a.dueDate == null) {
              return 1;
            } else if (b.dueDate == null) {
              return -1;
            } else {
              return a.dueDate!.compareTo(b.dueDate!);
            }
          });
          break;
      }

      return filteredTodos;
    });
  }
}
