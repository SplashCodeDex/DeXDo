import 'dart:ui';

import 'package:dexdo/screens/add_task_screen.dart';
import 'package:dexdo/widgets/todo_list_item.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TodoRepository _repository = TodoRepository.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final todos = await _repository.loadTodos();

      if (mounted) {
        setState(() {
          _todos = todos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tasks. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTodoStatus(int index, bool? isDone) async {
    if (index < 0 || index >= _todos.length) return;

    final originalTodo = _todos[index];
    final updatedTodo = originalTodo.copyWith(isDone: isDone);

    // Optimistic update
    setState(() {
      _todos[index] = updatedTodo;
    });

    try {
      final success = await _repository.updateTodo(
        originalTodo.id,
        updatedTodo,
      );
      if (!success) {
        // Revert on failure
        setState(() {
          _todos[index] = originalTodo;
        });
        _showErrorSnackBar('Failed to update task');
      } else {
        _provideFeedback(FeedbackType.light);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _todos[index] = originalTodo;
      });
      _showErrorSnackBar('Failed to update task');
    }
  }

  Future<void> _updateTodo(int index, Todo updatedTodo) async {
    if (index < 0 || index >= _todos.length) return;

    final originalTodo = _todos[index];

    // Optimistic update
    setState(() {
      _todos[index] = updatedTodo;
    });

    try {
      final success = await _repository.updateTodo(
        originalTodo.id,
        updatedTodo,
      );
      if (!success) {
        // Revert on failure
        setState(() {
          _todos[index] = originalTodo;
        });
        _showErrorSnackBar('Failed to update task');
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _todos[index] = originalTodo;
      });
      _showErrorSnackBar('Failed to update task');
    }
  }

  Future<void> _addTask() async {
    try {
      final result = await Navigator.of(context).push<Map<String, String>>(
        MaterialPageRoute(builder: (context) => const AddTaskScreen()),
      );

      if (result != null && result['title'] != null) {
        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: result['title']!,
          description: result['description'] ?? '',
        );

        final success = await _repository.addTodo(newTodo);
        if (success) {
          setState(() {
            _todos.add(newTodo);
          });
        } else {
          _showErrorSnackBar('Failed to add task');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add task');
    }
  }

  Future<void> _deleteTodo(int index) async {
    if (index < 0 || index >= _todos.length) return;

    final todoToDelete = _todos[index];

    // Optimistic update
    setState(() {
      _todos.removeAt(index);
    });

    try {
      final success = await _repository.deleteTodo(todoToDelete.id);
      if (!success) {
        // Revert on failure
        setState(() {
          _todos.insert(index, todoToDelete);
        });
        _showErrorSnackBar('Failed to delete task');
      } else {
        _provideFeedback(FeedbackType.warning);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _todos.insert(index, todoToDelete);
      });
      _showErrorSnackBar('Failed to delete task');
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= _todos.length ||
        newIndex > _todos.length) {
      return;
    }

    final originalTodos = List<Todo>.from(_todos);

    // Optimistic update
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final todo = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, todo);
    });

    try {
      final success = await _repository.reorderTodos(
        oldIndex,
        newIndex,
        originalTodos,
      );
      if (!success) {
        // Revert on failure
        setState(() {
          _todos = originalTodos;
        });
        _showErrorSnackBar('Failed to reorder tasks');
      } else {
        _provideFeedback(FeedbackType.medium);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _todos = originalTodos;
      });
      _showErrorSnackBar('Failed to reorder tasks');
    }
  }

  void _provideFeedback(FeedbackType type) {
    try {
      Vibrate.feedback(type);
    } catch (e) {
      // Vibration might not be available on all devices
      debugPrint('Vibration not available: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadTasks,
          ),
        ),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 16, color: Colors.red.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(fontSize: 16, color: Color(0xFF4B4B4B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
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
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
            ? _buildErrorState()
            : _todos.isEmpty
            ? _buildEmptyState()
            : ReorderableListView(
                onReorder: _onReorder,
                padding: const EdgeInsets.only(top: 100, bottom: 80),
                children: <Widget>[
                  for (int index = 0; index < _todos.length; index++)
                    Dismissible(
                      key: Key(_todos[index].id),
                      onDismissed: (direction) {
                        _deleteTodo(index);
                      },
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFFF5F5DC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Delete Task',
                              style: TextStyle(
                                color: Color(0xFF4B4B4B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${_todos[index].displayTitle}"?',
                              style: const TextStyle(color: Color(0xFF4B4B4B)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF4B4B4B)),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.6),
                              Colors.red.withOpacity(0.2),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
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
