
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onchanged;

  const TodoListItem({super.key, required this.todo, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: onchanged,
        ),
      ),
    );
  }
}
