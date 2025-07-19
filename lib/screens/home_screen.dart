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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
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
      final newTodo = Todo(
        id: DateTime.now().toString(),
        title: result,
      );
      setState(() {
        _todos.add(newTodo);
        _listKey.currentState?.insertItem(_todos.length - 1);
      });
    }
  }

  void _deleteTodo(int index) {
    final removedTodo = _todos.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => FadeTransition(
        opacity: animation,
        child: TodoListItem(
          todo: removedTodo,
          onchanged: (value) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade200,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DeXDo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade300,
              Colors.pink.shade200,
              Colors.amber.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _todos.isEmpty
            ? const Center(
                child: Text(
                  'You have no tasks yet. Add one!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            : AnimatedList(
                key: _listKey,
                initialItemCount: _todos.length,
                itemBuilder: (context, index, animation) {
                  final todo = _todos[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: Dismissible(
                        key: Key(todo.id),
                        onDismissed: (direction) {
                          _deleteTodo(index);
                        },
                        background: Container(
                          color: Colors.red.withOpacity(0.5),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: TodoListItem(
                          todo: todo,
                          onchanged: (value) => _toggleTodoStatus(index, value),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Hero(
        tag: 'add_task_hero',
        child: FloatingActionButton(
          onPressed: _addTask,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add,
            color: Colors.deepPurple.shade300,
          ),
        ),
      ),
    );
  }
}