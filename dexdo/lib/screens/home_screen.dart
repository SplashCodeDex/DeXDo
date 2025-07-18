
import 'package:dexdo/screens/add_task_screen.dart';
import 'package:dexdo/widgets/todo_list_item.dart';
import 'package:flutter/material.dart';
import 'package:dexdo/models/todo_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _todos = [
    Todo(id: '1', title: 'Buy milk'),
    Todo(id: '2', title: 'Walk the dog'),
    Todo(id: '3', title: 'Do laundry'),
  ];

  void _toggleTodoStatus(int index, bool? isDone) {
    setState(() {
      _todos[index] = _todos[index].copyWith(isDone: isDone);
    });
  }

  void _addTask() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _todos.add(Todo(
          id: DateTime.now().toString(),
          title: result,
        ));
      });
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('DeXDo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: TodoList(
        todos: _todos,
        onTodoChanged: _toggleTodoStatus,
        onTodoDeleted: _deleteTodo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(int, bool?) onTodoChanged;
  final Function(int) onTodoDeleted;

  const TodoList({
    super.key,
    required this.todos,
    required this.onTodoChanged,
    required this.onTodoDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Dismissible(
          key: Key(todo.id),
          onDismissed: (direction) {
            onTodoDeleted(index);
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: TodoListItem(
            todo: todo,
            onchanged: (value) => onTodoChanged(index, value),
          ),
        );
      },
    );
  }
}
