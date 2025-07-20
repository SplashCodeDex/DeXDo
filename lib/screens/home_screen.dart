import 'dart:convert';

import 'package:dexdo/screens/add_task_screen.dart';
import 'package:dexdo/widgets/todo_list_item.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('todos');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      setState(() {
        _todos = tasksJson.map((json) => Todo.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', tasksString);
  }

  void _toggleTodoStatus(int index, bool? isDone) {
    setState(() {
      _todos[index] = _todos[index].copyWith(isDone: isDone);
    });
    _saveTasks();
  }

  void _updateTodo(int index, Todo todo) {
    setState(() {
      _todos[index] = todo;
    });
    _saveTasks();
  }

  void _addTask() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddTaskScreen()));

    if (result != null && result is Map<String, String>) {
      final newTodo = Todo(
        id: DateTime.now().toString(),
        title: result['title']!,
        description:
            result['description'] != null && result['description']!.isNotEmpty
            ? result['description']!
            : '',
      );
      setState(() {
        _todos.add(newTodo);
      });
      _saveTasks();
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTasks();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final todo = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, todo);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DeXDo',
          style: TextStyle(
            color: Color(0xFF4B4B4B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF5F5DC).withOpacity(0.8),
              const Color(0xFFF5F5DC).withOpacity(0.9),
              const Color(0xFFF5F5DC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.task_alt_rounded,
                      size: 120,
                      color: Colors.black.withOpacity(0.1),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B4B4B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first task!',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF4B4B4B).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ReorderableListView(
                onReorder: _onReorder,
                children: <Widget>[
                  for (int index = 0; index < _todos.length; index++)
                    Dismissible(
                      key: Key(_todos[index].id),
                      onDismissed: (direction) {
                        _deleteTodo(index);
                      },
                      background: Container(
                        color: Colors.red.withOpacity(0.5),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: TodoListItem(
                        key: ValueKey(_todos[index].id),
                        todo: _todos[index],
                        onchanged: (value) => _toggleTodoStatus(index, value),
                        onUpdate: (updatedTodo) =>
                            _updateTodo(index, updatedTodo),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade300.withOpacity(0.7),
              Colors.blue.shade300.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addTask,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
