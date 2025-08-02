import 'package:dexdo/main.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Todo todo;

  const EditTaskScreen({super.key, required this.todo});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _dueDate;
  static const int _maxTitleLength = 100;
  static const int _maxDescriptionLength = 500;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
    _dueDate = widget.todo.dueDate;
    // Auto-focus on title field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  String _sanitizeInput(String input) {
    // Remove leading/trailing whitespace and normalize internal whitespace
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    final sanitized = _sanitizeInput(value);
    if (sanitized.isEmpty) {
      return 'Title cannot be empty or contain only whitespace';
    }
    if (sanitized.length > _maxTitleLength) {
      return 'Title must be $_maxTitleLength characters or less';
    }
    // Check for potentially problematic characters
    if (sanitized.contains(RegExp(r'[<>"]'))) {
      return 'Title contains invalid characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null) return null;
    final sanitized = _sanitizeInput(value);
    if (sanitized.length > _maxDescriptionLength) {
      return 'Description must be $_maxDescriptionLength characters or less';
    }
    return null;
  }

  void _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _submitTask() async {
    setState(() {
      _errorMessage = null;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final sanitizedTitle = _sanitizeInput(_titleController.text);
      final sanitizedDescription = _sanitizeInput(_descriptionController.text);
      final updatedTodo = widget.todo.copyWith(
        title: sanitizedTitle,
        description: sanitizedDescription,
        dueDate: _dueDate,
      );
      await ref.read(todoRepositoryProvider).saveTodo(updatedTodo);
      // Simulate a brief delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update task. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Standard AppBar height
        child: AppBar(
          title: Text(
            'Edit Task',
            style: theme.appBarTheme.titleTextStyle,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            tooltip: 'Go back',
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.tertiary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.error),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    validator: _validateTitle,
                    maxLength: _maxTitleLength,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _descriptionFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      hintText: 'Enter task title',
                      labelStyle: theme.textTheme.bodyLarge,
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.border,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    validator: _validateDescription,
                    maxLength: _maxDescriptionLength,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitTask(),
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Enter task description',
                      labelStyle: theme.textTheme.bodyLarge,
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      border: theme.inputDecorationTheme.border,
                      enabledBorder: theme.inputDecorationTheme.border,
                      focusedBorder: theme.inputDecorationTheme.border,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _pickDueDate,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Set Due Date'),
                      ),
                      if (_dueDate != null)
                        Text(
                          'Due: \${_dueDate!.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitTask,
                    style: theme.elevatedButtonTheme.style,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '* Required field',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
