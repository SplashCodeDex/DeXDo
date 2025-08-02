import 'dart:io';
import 'package:dexdo/screens/edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart'; // Using the new vibration package

class TodoListItem extends ConsumerStatefulWidget {
  final Todo todo;

  const TodoListItem({
    super.key,
    required this.todo,
  });

  @override
  ConsumerState<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends ConsumerState<TodoListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.9), weight: 0.5),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 0.5),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial animation state based on todo status
    if (widget.todo.isDone) {
      _controller.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorAnimation = ColorTween(
      begin: Theme.of(context).cardTheme.color,
      end: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

  void _provideFeedback() {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        Vibration.vibrate(duration: 10); // Using Vibration.vibrate directly
      }
    } catch (e) {
      debugPrint('Vibration not available: $e');
    }
  }

  void _navigateToEditScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(todo: widget.todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _colorAnimation.value,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(
                widget.todo.displayTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: widget.todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationThickness: 2,
                  decorationColor: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.todo.hasDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget.todo.displayDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: widget.todo.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationThickness: 2,
                          decorationColor:
                              theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
                  if (widget.todo.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Due: ${DateFormat.yMMMd().format(widget.todo.dueDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.todo.dueDate!.isBefore(DateTime.now())
                              ? theme.colorScheme.error
                              : theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                ],
              ),
              leading: Checkbox(
                value: widget.todo.isDone,
                onChanged: (value) {
                  _provideFeedback();
                  final updatedTodo = widget.todo.copyWith(isDone: value);
                  ref.read(todoRepositoryProvider).saveTodo(updatedTodo);
                },
                activeColor: theme.colorScheme.primary,
                checkColor: theme.colorScheme.onPrimary,
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: _navigateToEditScreen,
                tooltip: 'Edit Task',
                splashRadius: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}