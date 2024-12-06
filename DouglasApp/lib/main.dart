import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DouglasApp()); // Alterado para DouglasApp
}

class DouglasApp extends StatelessWidget { // Alterado para DouglasApp
  const DouglasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          ),
        ),
      ),
      home: TodoList(), 
    );
  }
}

// ... (resto do código permanece igual)

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPriority;
  String searchQuery = '';
  int currentPage = 0;
  int itemsPerPage = 4;

  final List<String> _categories = ['Trabalho', 'Casa', 'Pessoal'];
  final List<String> _priorities = ['Alta', 'Média', 'Baixa'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _addTask() {
    if (_controller.text.isNotEmpty && _selectedCategory != null) {
      setState(() {
        _tasks.add({
          'title': _controller.text,
          'category': _selectedCategory,
          'priority': _selectedPriority ?? 'Média',
          'isCompleted': false,
        });
        _controller.clear();
        _selectedCategory = null;
        _selectedPriority = null;
      });
      _saveTasks();
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(_tasks));
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksData));
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    if (searchQuery.isEmpty) {
      return _tasks;
    }
    return _tasks
        .where((task) =>
            task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> _getPaginatedTasks() {
    List<Map<String, dynamic>> filteredTasks = _getFilteredTasks();
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    return filteredTasks.sublist(
      startIndex,
      endIndex > filteredTasks.length ? filteredTasks.length : endIndex,
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red.shade100;
      case 'Média':
        return Colors.yellow.shade100;
      case 'Baixa':
        return Colors.green.shade100;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> paginatedTasks = _getPaginatedTasks();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // Cor da AppBar alterada
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Adicionar nova tarefa',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTask,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Selecione uma categoria'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    hint: const Text('Selecione uma prioridade'),
                    items: _priorities.map((String priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar tarefas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: paginatedTasks.length,
                itemBuilder: (context, index) {
                  final task = paginatedTasks[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _removeTask(index + currentPage * itemsPerPage);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tarefa excluída!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      color: _getPriorityColor(task['priority']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas nos cards
                      ),
                      child: ListTile(
                        title: Text(task['title']),
                        subtitle: Text(
                            'Categoria: ${task['category']} | Prioridade: ${task['priority']}'),
                        leading: Checkbox(
                          value: task['isCompleted'],
                          onChanged: (bool? value) {
                            setState(() {
                              task['isCompleted'] = value!;
                            });
                            _saveTasks();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  child: const Text('Página Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Cor do botão alterada
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (currentPage + 1) * itemsPerPage <
                          _getFilteredTasks().length
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                  child: const Text('Próxima Página'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Cor do botão alterada
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Bordas arredondadas
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}