import 'dart:io';
import 'dart:ui';

import 'package:dexdo/main.dart';
import 'package:dexdo/screens/add_task_screen.dart';
import 'package:dexdo/widgets/todo_list_item.dart';
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

enum FeedbackType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

final sortByProvider = StateProvider<SortBy>((ref) => SortBy.position);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(sortByProvider);
    final todosStream = ref.watch(todoRepositoryProvider).watchTodos(sortBy: sortBy);

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
              ref.read(sortByProvider.notifier).state =
                  sortBy == SortBy.position
                      ? SortBy.dueDate
                      : SortBy.position;
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () => _showClearCompletedDialog(context, ref),
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
              child: StreamBuilder<List<Todo>>(
                stream: todosStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final todos = snapshot.data!;

                  return ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(todoRepositoryProvider)
                          .updateTodoPosition(oldIndex, newIndex);
                    },
                    padding: const EdgeInsets.only(top: 100, bottom: 80),
                    children: <Widget>[
                      for (final todo in todos)
                        Dismissible(
                          key: Key(todo.id.toString()),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) {
                            ref.read(todoRepositoryProvider).deleteTodo(todo.id);
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
                            key: ValueKey(todo.id),
                            todo: todo,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTaskScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.elasticOut;
          const secondaryCurve = Curves.easeOutCubic;

          final scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          final fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.375, curve: Curves.easeOutCubic),
            ),
          );

          final secondaryScaleAnimation =
              Tween<double>(begin: 1.0, end: 0.95).animate(
            CurvedAnimation(parent: secondaryAnimation, curve: secondaryCurve),
          );

          final secondaryFadeAnimation =
              Tween<double>(begin: 1.0, end: 0.0).animate(
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
        title: result['title']!,
        description: result['description'] ?? '',
      );
      await ref.read(todoRepositoryProvider).saveTodo(newTodo);
    }
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks?'),
        content: const Text('Are you sure you want to delete all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(todoRepositoryProvider).clearCompletedTodos();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
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
            errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red.shade500),
            textAlign: TextAlign.center,
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
}
