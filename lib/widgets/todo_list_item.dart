import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class TodoListItem extends StatefulWidget {
  final Todo todo;
  final Function(bool?) onchanged;
  final Function(Todo) onUpdate;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onchanged,
    required this.onUpdate,
  });

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

    _thicknessAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial animation state based on todo status
    if (widget.todo.isDone) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant TodoListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Synchronize animation with todo status changes
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
      Vibrate.feedback(FeedbackType.light);
    } catch (e) {
      // Vibration might not be available on all devices
      debugPrint('Vibration not available: $e');
    }
  }

  String _sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }

    final sanitized = _sanitizeInput(value);
    if (sanitized.isEmpty) {
      return 'Title cannot be empty';
    }

    if (sanitized.length > 100) {
      return 'Title must be 100 characters or less';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null) return null;

    final sanitized = _sanitizeInput(value);
    if (sanitized.length > 500) {
      return 'Description must be 500 characters or less';
    }

    return null;
  }

  void _showEditDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: widget.todo.title);
    final descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    final titleFocusNode = FocusNode();
    final descriptionFocusNode = FocusNode();

    // Auto-focus on title field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleFocusNode.requestFocus();
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5DC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Task',
          style: TextStyle(
            color: Color(0xFF4B4B4B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                focusNode: titleFocusNode,
                validator: _validateTitle,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => descriptionFocusNode.requestFocus(),
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter task title',
                  labelStyle: const TextStyle(color: Color(0xFF4B4B4B)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                focusNode: descriptionFocusNode,
                validator: _validateDescription,
                maxLength: 500,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                  labelStyle: const TextStyle(color: Color(0xFF4B4B4B)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  counterText: '',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Properly dispose controllers
              titleController.dispose();
              descriptionController.dispose();
              titleFocusNode.dispose();
              descriptionFocusNode.dispose();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4B4B4B)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade300.withOpacity(0.8),
                  Colors.blue.shade300.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final sanitizedTitle = _sanitizeInput(titleController.text);
                  final sanitizedDescription = _sanitizeInput(
                    descriptionController.text,
                  );

                  final updatedTodo = widget.todo.copyWith(
                    title: sanitizedTitle,
                    description: sanitizedDescription,
                  );

                  widget.onUpdate(updatedTodo);

                  // Properly dispose controllers
                  titleController.dispose();
                  descriptionController.dispose();
                  titleFocusNode.dispose();
                  descriptionFocusNode.dispose();

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      // Ensure controllers are disposed even if dialog is dismissed unexpectedly
      if (titleController.hasListeners) titleController.dispose();
      if (descriptionController.hasListeners) descriptionController.dispose();
      if (titleFocusNode.hasFocus) titleFocusNode.dispose();
      if (descriptionFocusNode.hasFocus) descriptionFocusNode.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Task: ${widget.todo.displayTitle}',
      hint: widget.todo.isDone
          ? 'Completed task'
          : 'Tap to edit, check to complete',
      child: GestureDetector(
        onTap: () {
          _provideFeedback();
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                      widget.todo.displayTitle,
                      style: TextStyle(
                        color: _colorAnimation.value,
                        fontWeight: FontWeight.w600,
                        decoration: widget.todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: const Color(
                          0xFF4B4B4B,
                        ).withOpacity(0.7),
                        decorationThickness: _thicknessAnimation.value,
                      ),
                    ),
                    subtitle: widget.todo.hasDescription
                        ? Text(
                            widget.todo.displayDescription,
                            style: TextStyle(
                              color: _colorAnimation.value,
                              decoration: widget.todo.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: const Color(
                                0xFF4B4B4B,
                              ).withOpacity(0.7),
                              decorationThickness: _thicknessAnimation.value,
                            ),
                          )
                        : null,
                    leading: Semantics(
                      label: widget.todo.isDone
                          ? 'Mark as incomplete'
                          : 'Mark as complete',
                      child: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: widget.todo.isDone,
                          onChanged: (value) {
                            _provideFeedback();
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
                    trailing: widget.todo.isDone
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green.shade400,
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
