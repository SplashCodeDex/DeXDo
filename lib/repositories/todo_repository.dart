import 'dart:async';
import '../models/todo_model.dart';

enum SortBy {
  position,
  creationDate,
  dueDate,
}

class TodoRepository {
  // In-memory storage for web compatibility
  final List<Todo> _todos = [];
  final StreamController<List<Todo>> _todosController = StreamController<List<Todo>>();

  TodoRepository();

  Future<List<Todo>> loadTodos() async {
    // Sort todos by position for in-memory storage
    _todos.sort((a, b) => a.position.compareTo(b.position));
    return _todos.toList();
  }

  Future<void> saveTodo(Todo todo) async {
    // If the todo is new, assign it the next available id and position
    if (todo.id == null || todo.id == -1) {
      final id = _todos.length + 1; // Simple auto-increment
      final position = todo.position < 0 ? _todos.length : todo.position;
      final todoToSave = todo.copyWith(
        id: id,
        position: position,
        createdAt: todo.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now()
      );
      _todos.add(todoToSave);
    } else {
      // Otherwise, it's an update, so find and replace it
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo.copyWith(updatedAt: DateTime.now());

        // If a recurring task is marked as done, create a new instance
        if (todo.isRecurring && todo.isDone && todo.recurrenceType != null) {
          final nextDueDate = _calculateNextDueDate(
            todo.dueDate ?? DateTime.now(),
            todo.recurrenceType!,
          );

          // Only create a new recurring task if the recurrence end date is not reached
          if (todo.recurrenceEndDate == null || nextDueDate.isBefore(todo.recurrenceEndDate!)) {
            final newRecurringTodo = todo.copyWith(
              id: null, // Will get new ID
              isDone: false,
              createdAt: DateTime.now(),
              updatedAt: null,
              dueDate: nextDueDate,
              position: _todos.length, // Assign new position
            );
            await saveTodo(newRecurringTodo); // Recursively save the new task
          }
        }
      }
    }

    // Notify stream subscribers
    _todosController.add(_todos.toList());
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
    _todos.removeWhere((todo) => todo.id == id);
    _todosController.add(_todos.toList());
  }

  Future<void> clearAllTodos() async {
    _todos.clear();
    _todosController.add(_todos.toList());
  }

  Future<void> updateTodoPosition(int oldIndex, int newIndex) async {
    final todos = _todos.toList();
    todos.sort((a, b) => a.position.compareTo(b.position));

    if (oldIndex < 0 || oldIndex >= todos.length || newIndex < 0 || newIndex >= todos.length) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final movedTodo = todos.removeAt(oldIndex);
    todos.insert(newIndex, movedTodo);

    // Update positions
    for (int i = 0; i < todos.length; i++) {
      if (todos[i].position != i) {
        final oldTodo = _todos.firstWhere((t) => t.id == todos[i].id);
        final updatedTodo = oldTodo.copyWith(position: i, updatedAt: DateTime.now());
        _todos[_todos.indexOf(oldTodo)] = updatedTodo;
      }
    }

    _todosController.add(_todos.toList());
  }

  Future<void> clearCompletedTodos() async {
    _todos.removeWhere((todo) => todo.isDone);
    _todosController.add(_todos.toList());
  }

  Stream<List<Todo>> watchTodos({
    SortBy sortBy = SortBy.position,
    bool? isDone,
    String? searchQuery,
  }) {
    return _todosController.stream.map((todos) {
      List<Todo> filteredTodos = todos.toList();

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

  // Clean up resources
  void dispose() {
    _todosController.close();
  }
}
