
import 'package:dexdo/models/todo_model.dart';
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:dexdo/screens/edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final TodoRepository todoRepository;

  const TodoListItem({super.key, required this.todo, required this.todoRepository});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (value) {
            final updatedTodo = todo.copyWith(isDone: value, updatedAt: DateTime.now());
            todoRepository.saveTodo(updatedTodo);
          },
        ),
        title: Text(
          todo.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  todo.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            if (todo.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Due: ${DateFormat.yMMMd().format(todo.dueDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue ? theme.colorScheme.error : null,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            final updatedTodo = await Navigator.of(context).push<Todo>(
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(todo: todo),
              ),
            );
            if (updatedTodo != null) {
              await todoRepository.saveTodo(updatedTodo);
            }
          },
        ),
      ),
    );
  }
}
