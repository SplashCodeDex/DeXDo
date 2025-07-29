import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

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
    if (sanitized.contains(RegExp(r'[<>"\'\\]'))) {
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

      // Simulate a brief delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.of(context).pop({
          'title': sanitizedTitle,
          'description': sanitizedDescription,
        });
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
    return Hero(
      tag: 'add_task_hero',
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF4B4B4B)),
          title: const Text(
            'Add New Task',
            style: TextStyle(
              color: Color(0xFF4B4B4B),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            tooltip: 'Go back',
          ),
        ),
        body: Form(
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
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade600),
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

                const SizedBox(height: 32),

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
                    onPressed: _isLoading ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '* Required field',
                  style: TextStyle(
                    color: const Color(0xFF4B4B4B).withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
