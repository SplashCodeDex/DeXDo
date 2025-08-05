import 'package:dexdo/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final Todo todo;

  const EditTaskScreen({super.key, required this.todo});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _dueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        updatedAt: DateTime.now(),
      );
      Navigator.of(context).pop(updatedTodo);
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(_dueDate == null ? 'No due date' : DateFormat.yMMMd().format(_dueDate!)),
                trailing: TextButton(onPressed: _selectDueDate, child: const Text('Select Date')),
                onTap: _selectDueDate,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitTask,
        label: const Text('Save Changes'),
        icon: const Icon(Icons.save_alt_outlined),
      ),
    );
  }
}