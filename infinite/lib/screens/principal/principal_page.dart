import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infinite/repository/text_repository.dart';
import 'package:infinite/screens/add_tasks/add_tasks_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:infinite/repository/db_helper.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  _PrincipalPageState createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  List<Map<String, dynamic>> _tasks = [];
  String? _email;
  String? _senha;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email');
      _senha = prefs.getString('senha');
    });

    if (_email != null && _senha != null) {
      await _loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: email ou senha não definidos.')),
      );
    }
  }

  Future<void> _loadTasks() async {
    if (_email != null && _senha != null) {
      try {
        final tasks = await ContactRepository.getTasks(_email!, _senha!);
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(tasks);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar as tarefas: $e')),
        );
      }
    }
  }

  Future<void> _addTask(Map<String, dynamic> taskData) async {
    try {
      final result = await someAsyncTaskFunction(taskData);
      if (result != null) {
        setState(() {
          _tasks.add(result);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa adicionada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Não foi possível adicionar a tarefa.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: Ocorreu um problema. $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> someAsyncTaskFunction(Map<String, dynamic> taskData) async {
    await Future.delayed(const Duration(seconds: 1));
    return taskData;
  }

  Future<void> _editTask(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(task: _tasks[index]),
      ),
    );

    if (result != null) {
      await ContactRepository.updateTask(_tasks[index]['id'], result);
      _loadTasks();
    }
  }

  Future<void> _deleteTask(int id) async {
    await ContactRepository.deleteTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Infinite',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/infinite.png',
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color(int.parse(_tasks[index]['color'])),
                    child: ListTile(
                      title: Text(_tasks[index]['title']),
                      subtitle: Text(
                          'Tarefa: ${_tasks[index]['task']}, Prazo: ${_tasks[index]['dueDate']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(_tasks[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskScreen(),
            ),
          );

          if (result != null) {
            await _addTask(result);
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
