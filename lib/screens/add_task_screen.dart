import 'package:dexdo/main.dart';
import 'package:dexdo/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _dueDate;
  bool _isRecurring = false;
  RecurrenceType? _recurrenceType;
  DateTime? _recurrenceEndDate;
  static const int _maxTitleLength = 100;
  static const int _maxDescriptionLength = 500;

  @override
  void initState() {
    super.initState();
    // Auto-focus on title field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _pickRecurrenceEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _recurrenceEndDate = pickedDate;
      });
    }
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
      final newTodo = Todo(
        title: sanitizedTitle,
        description: sanitizedDescription,
        dueDate: _dueDate,
        isRecurring: _isRecurring,
        recurrenceType: _isRecurring ? _recurrenceType ?? RecurrenceType.daily : RecurrenceType.daily,
        recurrenceEndDate: _isRecurring ? _recurrenceEndDate : null,
        createdAt: DateTime.now(),
      );
      final todoRepository = await ref.read(todoRepositoryProvider.future);
      await todoRepository.saveTodo(newTodo);
      // Simulate a brief delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to create task. Please try again.';
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
            'Add New Task',
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
                          'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Recurring Task',
                      style: theme.textTheme.bodyLarge,
                    ),
                    value: _isRecurring,
                    onChanged: (bool value) {
                      setState(() {
                        _isRecurring = value;
                        if (!value) {
                          _recurrenceType = null;
                          _recurrenceEndDate = null;
                        } else {
                          _recurrenceType = RecurrenceType.daily; // Default to daily
                        }
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RecurrenceType>(
                      value: _recurrenceType,
                      decoration: InputDecoration(
                        labelText: 'Recurrence Type',
                        labelStyle: theme.textTheme.bodyLarge,
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                        border: theme.inputDecorationTheme.border,
                        enabledBorder: theme.inputDecorationTheme.border,
                        focusedBorder: theme.inputDecorationTheme.border,
                      ),
                      items: RecurrenceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name.capitalize()),
                        );
                      }).toList(),
                      onChanged: (RecurrenceType? newValue) {
                        setState(() {
                          _recurrenceType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _pickRecurrenceEndDate,
                          icon: const Icon(Icons.event_busy),
                          label: const Text('Recurrence End Date'),
                        ),
                        if (_recurrenceEndDate != null)
                          Text(
                            'Ends: ${ _recurrenceEndDate!.toLocal().toString().split(' ')[0]}',
                            style: theme.textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ],
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
                            'Add Task',
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
