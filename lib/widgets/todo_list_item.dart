
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class TodoListItem extends StatefulWidget {
  final Todo todo;
  final Function(bool?) onchanged;
  final Function(Todo) onUpdate;

  const TodoListItem(
      {super.key,
      required this.todo,
      required this.onchanged,
      required this.onUpdate});

  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _thicknessAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF4B4B4B),
      end: const Color(0xFF4B4B4B).withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _thicknessAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.todo.isDone) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant TodoListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todo.isDone != oldWidget.todo.isDone) {
      if (widget.todo.isDone) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: widget.todo.title);
    final descriptionController =
        TextEditingController(text: widget.todo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5DC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: Color(0xFF4B4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Color(0xFF4B4B4B)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Color(0xFF4B4B4B)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4B4B4B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedTodo = widget.todo.copyWith(
                title: titleController.text,
                description: descriptionController.text,
              );
              widget.onUpdate(updatedTodo);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.light);
        _showEditDialog();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.4),
                    _controller.value,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    widget.todo.title,
                    style: TextStyle(
                      color: _colorAnimation.value,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor:
                          const Color(0xFF4B4B4B).withOpacity(0.7),
                      decorationThickness: _thicknessAnimation.value,
                    ),
                  ),
                  subtitle: widget.todo.description != null &&
                          widget.todo.description!.isNotEmpty
                      ? Text(
                          widget.todo.description!,
                          style: TextStyle(
                            color: _colorAnimation.value,
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                const Color(0xFF4B4B4B).withOpacity(0.7),
                            decorationThickness: _thicknessAnimation.value,
                          ),
                        )
                      : null,
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: widget.todo.isDone,
                      onChanged: (value) {
                        widget.onchanged(value);
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.purple.shade300,
                      side: BorderSide(
                        color: Colors.purple.shade300,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

