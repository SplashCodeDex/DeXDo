
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onchanged;

  const TodoListItem({super.key, required this.todo, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                color: Colors.white,
                decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: Colors.white70,
              ),
            ),
            leading: Checkbox(
              value: todo.isDone,
              onChanged: onchanged,
              checkColor: Colors.deepPurple.shade300,
              activeColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

