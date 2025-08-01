import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

class TodoRepository {
  static const String _todosKey = 'todos';
  static TodoRepository? _instance;

  TodoRepository._internal();

  static TodoRepository get instance {
    _instance ??= TodoRepository._internal();
    return _instance!;
  }

  Future<List<Todo>> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosString = prefs.getString(_todosKey);

      if (todosString == null || todosString.isEmpty) {
        return [];
      }

      final List<dynamic> todosJson = jsonDecode(todosString);
      return todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .where((todo) => todo.title.isNotEmpty) // Filter out invalid todos
          .toList();
    } catch (e) {
      // Log error in production, you might want to use a logging service
      // print('Error loading todos: $e');
      return [];
    }
  }

  Future<bool> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosString = jsonEncode(
        todos.map((todo) => todo.toJson()).toList(),
      );
      return await prefs.setString(_todosKey, todosString);
    } catch (e) {
      // print('Error saving todos: $e');
      return false;
    }
  }

  Future<bool> addTodo(Todo todo) async {
    try {
      final todos = await loadTodos();
      todos.add(todo);
      return await saveTodos(todos);
    } catch (e) {
      // print('Error adding todo: $e');
      return false;
    }
  }

  Future<bool> updateTodo(String id, Todo updatedTodo) async {
    try {
      final todos = await loadTodos();
      final index = todos.indexWhere((todo) => todo.id == id);

      if (index == -1) {
        return false;
      }

      todos[index] = updatedTodo;
      return await saveTodos(todos);
    } catch (e) {
      // print('Error updating todo: $e');
      return false;
    }
  }

  Future<bool> deleteTodo(String id) async {
    try {
      final todos = await loadTodos();
      todos.removeWhere((todo) => todo.id == id);
      return await saveTodos(todos);
    } catch (e) {
      // print('Error deleting todo: $e');
      return false;
    }
  }

  Future<bool> reorderTodos(
    int oldIndex,
    int newIndex,
    List<Todo> todos,
  ) async {
    try {
      if (oldIndex < 0 ||
          newIndex < 0 ||
          oldIndex >= todos.length ||
          newIndex >= todos.length) {
        return false;
      }

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final todo = todos.removeAt(oldIndex);
      todos.insert(newIndex, todo);

      return await saveTodos(todos);
    } catch (e) {
      // print('Error reordering todos: $e');
      return false;
    }
  }

  Future<bool> clearAllTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_todosKey);
    } catch (e) {
      // print('Error clearing todos: $e');
      return false;
    }
  }

  Future<int> getTodoCount() async {
    try {
      final todos = await loadTodos();
      return todos.length;
    } catch (e) {
      // print('Error getting todo count: $e');
      return 0;
    }
  }

  Future<int> getCompletedTodoCount() async {
    try {
      final todos = await loadTodos();
      return todos.where((todo) => todo.isDone).length;
    } catch (e) {
      // print('Error getting completed todo count: $e');
      return 0;
    }
  }
}
