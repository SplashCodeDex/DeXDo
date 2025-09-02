import 'dart:ui';

import 'package:dexdo/main.dart';
import 'package:dexdo/screens/add_task_screen.dart';
import 'package:dexdo/widgets/todo_list_item.dart';
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sortByProvider = StateProvider<SortBy>((ref) => SortBy.position);
final filterIsDoneProvider = StateProvider<bool?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(sortByProvider);
    final filterIsDone = ref.watch(filterIsDoneProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final todoRepository = ref.watch(todoRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeXDo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: TaskSearchDelegate(ref)),
          ),
          PopupMenuButton<SortBy>(
            onSelected: (newSortBy) => ref.read(sortByProvider.notifier).state = newSortBy,
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortBy.position, child: Text('Sort by Position')),
              const PopupMenuItem(value: SortBy.dueDate, child: Text('Sort by Due Date')),
              const PopupMenuItem(value: SortBy.creationDate, child: Text('Sort by Creation Date')),
            ],
          ),
          PopupMenuButton<bool?>(
            onSelected: (value) => ref.read(filterIsDoneProvider.notifier).state = value,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Tasks')),
              const PopupMenuItem(value: true, child: Text('Completed')),
              const PopupMenuItem(value: false, child: Text('Incomplete')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearCompletedDialog(context, ref, todoRepository),
          ),
        ],
      ),
      body: StreamBuilder<List<Todo>>(
        stream: todoRepository.watchTodos(
          sortBy: sortBy,
          isDone: filterIsDone,
          searchQuery: searchQuery,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          final todos = snapshot.data!;
          final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

          return AnimatedList(
            key: listKey,
            initialItemCount: todos.length,
            padding: const EdgeInsets.only(bottom: 80), // FAB space
            itemBuilder: (context, index, animation) {
              final todo = todos[index];
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: TodoListItem(
                    todo: todo,
                    todoRepository: todoRepository,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context, ref, todoRepository),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref, TodoRepository todoRepository) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (result != null) {
      final newTodo = Todo(
        title: result['title']!,
        description: result['description'] ?? '',
        createdAt: DateTime.now(),
        dueDate: result['dueDate'],
      );
      await todoRepository.saveTodo(newTodo);
    }
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref, TodoRepository todoRepository) {
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
              todoRepository.clearCompletedTodos();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(errorMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.task_alt_rounded, size: 120, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text('No tasks yet', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Tap the + button to add your first task!', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  TaskSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    ref.read(searchQueryProvider.notifier).state = query;
    return const SizedBox.shrink(); // Results are displayed in the home screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // You could build suggestions here based on the query
    return const SizedBox.shrink();
  }
}
