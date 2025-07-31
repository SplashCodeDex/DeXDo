import 'dart:io';
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.elasticOut; // For overshoot effect
            const secondaryCurve = Curves.easeOutCubic; // For smooth outgoing

            final scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            final fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.375, curve: Curves.easeOutCubic), // 0.15s out of 0.4s
              ),
            );

            final secondaryScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: secondaryCurve),
            );

            final secondaryFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: secondaryCurve),
            );

            return FadeTransition(
              opacity: secondaryFadeAnimation,
              child: ScaleTransition(
                scale: secondaryScaleAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: ScaleTransition(
                    scale: scaleAnimation,
                    child: child,
                  ),
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
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
      if (Platform.isIOS || Platform.isAndroid) {
      Vibrate.feedback(type);
    }
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
              color: Color(0xFF4B4B4B)),
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
        title: Text(
          'DeXDo',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              // TODO: Implement sorting
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            child: SafeArea(
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
                                  direction: DismissDirection.horizontal,
                                  onDismissed: (direction) {
                                    // Add a slight delay to allow the animation to complete
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      _deleteTodo(index);
                                    });
                                  },
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  child: TodoListItem(
                                    key: ValueKey(_todos[index].id),
                                    todo: _todos[index],
                                    onchanged: (value) =>
                                        _toggleTodoStatus(index, value),
                                    onUpdate: (updatedTodo) =>
                                        _updateTodo(index, updatedTodo),
                                  ),
                                ),
                              ],
                            ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}