// lib/repositories/task_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskRepository {
  final String userId;
  
  TaskRepository({this.userId = 'default_user'});

  // ==================== CHAVES DO SHAREDPREFERENCES ====================

  String get _tasksKey => 'tasks_$userId';
  String get _subjectsKey => 'subjects_$userId';

  // ==================== TAREFAS ====================

  Future<List<Task>> getAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null) return [];
      
      final List<dynamic> decoded = jsonDecode(tasksJson);
      return decoded.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      print('Erro ao buscar tarefas: $e');
      return [];
    }
  }

  Future<Task?> getTaskById(int id) async {
    try {
      final tasks = await getAllTasks();
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      print('Erro ao buscar tarefa por ID: $e');
      return null;
    }
  }

  Future<List<Task>> getTasksByCompletion(bool completed) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.completed == completed).toList();
    } catch (e) {
      print('Erro ao buscar tarefas por status: $e');
      return [];
    }
  }

  Future<List<Task>> getTasksBySubject(String subject) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.subject == subject).toList();
    } catch (e) {
      print('Erro ao buscar tarefas por matéria: $e');
      return [];
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where(
        (task) => 
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.subject.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erro ao pesquisar tarefas: $e');
      return [];
    }
  }

  // ==================== INSERÇÃO ====================

  Future<int> insertTask(Task task) async {
    try {
      final tasks = await getAllTasks();
      
      // Gerar ID automático
      final newId = tasks.isEmpty ? 1 : tasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      
      final newTask = Task(
        id: newId,
        title: task.title,
        subject: task.subject,
        estimatedMinutes: task.estimatedMinutes,
        completed: task.completed,
        createdAt: DateTime.now(),
      );
      
      tasks.add(newTask);
      await _saveTasks(tasks);
      return newId;
    } catch (e) {
      print('Erro ao inserir tarefa: $e');
      return -1;
    }
  }

  Future<List<int>> insertMultipleTasks(List<Task> tasksList) async {
    try {
      final tasks = await getAllTasks();
      final ids = <int>[];
      
      for (var task in tasksList) {
        final newId = tasks.isEmpty ? 1 : tasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
        final newTask = task.copyWith(id: newId, createdAt: DateTime.now());
        tasks.add(newTask);
        ids.add(newId);
      }
      
      await _saveTasks(tasks);
      return ids;
    } catch (e) {
      print('Erro ao inserir múltiplas tarefas: $e');
      return [];
    }
  }

  // ==================== ATUALIZAÇÃO ====================

  Future<bool> updateCompleted(int id, bool completed) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((task) => task.id == id);
      
      if (index == -1) return false;
      
      tasks[index] = tasks[index].copyWith(completed: completed);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      print('Erro ao atualizar status: $e');
      return false;
    }
  }

  Future<bool> updateTask(int id, Task task) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((t) => t.id == id);
      
      if (index == -1) return false;
      
      tasks[index] = task.copyWith(id: id);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      print('Erro ao atualizar tarefa: $e');
      return false;
    }
  }

  Future<bool> updateTitle(int id, String title) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((task) => task.id == id);
      
      if (index == -1) return false;
      
      tasks[index] = tasks[index].copyWith(title: title);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      print('Erro ao atualizar título: $e');
      return false;
    }
  }

  Future<bool> updateSubject(int id, String subject) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((task) => task.id == id);
      
      if (index == -1) return false;
      
      tasks[index] = tasks[index].copyWith(subject: subject);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      print('Erro ao atualizar matéria: $e');
      return false;
    }
  }

  Future<bool> updateEstimatedTime(int id, int minutes) async {
    try {
      final tasks = await getAllTasks();
      final index = tasks.indexWhere((task) => task.id == id);
      
      if (index == -1) return false;
      
      tasks[index] = tasks[index].copyWith(estimatedMinutes: minutes);
      await _saveTasks(tasks);
      return true;
    } catch (e) {
      print('Erro ao atualizar tempo estimado: $e');
      return false;
    }
  }

  // ==================== DELEÇÃO ====================

  Future<int> deleteTask(int id) async {
    try {
      final tasks = await getAllTasks();
      final removedCount = tasks.where((task) => task.id == id).length;
      tasks.removeWhere((task) => task.id == id);
      await _saveTasks(tasks);
      return removedCount;
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
      return -1;
    }
  }

  Future<int> deleteAllTasks() async {
    try {
      await _saveTasks([]);
      return 1;
    } catch (e) {
      print('Erro ao deletar todas as tarefas: $e');
      return -1;
    }
  }

  Future<int> deleteCompletedTasks() async {
    try {
      final tasks = await getAllTasks();
      final removedCount = tasks.where((task) => task.completed).length;
      tasks.removeWhere((task) => task.completed);
      await _saveTasks(tasks);
      return removedCount;
    } catch (e) {
      print('Erro ao deletar tarefas concluídas: $e');
      return -1;
    }
  }

  Future<int> deleteTasksBySubject(String subject) async {
    try {
      final tasks = await getAllTasks();
      final removedCount = tasks.where((task) => task.subject == subject).length;
      tasks.removeWhere((task) => task.subject == subject);
      await _saveTasks(tasks);
      return removedCount;
    } catch (e) {
      print('Erro ao deletar tarefas por matéria: $e');
      return -1;
    }
  }

  Future<int> deleteTasksByEstimatedTimeLessThan(int minutes) async {
    try {
      final tasks = await getAllTasks();
      final removedCount = tasks.where((task) => task.estimatedMinutes < minutes).length;
      tasks.removeWhere((task) => task.estimatedMinutes < minutes);
      await _saveTasks(tasks);
      return removedCount;
    } catch (e) {
      print('Erro ao deletar tarefas por tempo estimado: $e');
      return -1;
    }
  }

  // ==================== CONTAGEM ====================

  Future<int> countTasks() async {
    try {
      final tasks = await getAllTasks();
      return tasks.length;
    } catch (e) {
      print('Erro ao contar tarefas: $e');
      return 0;
    }
  }

  Future<int> countTasksByCompletion(bool completed) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.completed == completed).length;
    } catch (e) {
      print('Erro ao contar tarefas por status: $e');
      return 0;
    }
  }

  Future<int> countTasksBySubject(String subject) async {
    try {
      final tasks = await getAllTasks();
      return tasks.where((task) => task.subject == subject).length;
    } catch (e) {
      print('Erro ao contar tarefas por matéria: $e');
      return 0;
    }
  }

  Future<int> getTotalEstimatedTime() async {
    try {
      final tasks = await getAllTasks();
      return tasks.fold<int>(0, (sum, task) => sum + task.estimatedMinutes);
    } catch (e) {
      print('Erro ao calcular tempo total: $e');
      return 0;
    }
  }

  Future<int> getTotalEstimatedTimePending() async {
    try {
      final tasks = await getAllTasks();
      return tasks
          .where((task) => !task.completed)
          .fold<int>(0, (sum, task) => sum + task.estimatedMinutes);
    } catch (e) {
      print('Erro ao calcular tempo total pendente: $e');
      return 0;
    }
  }

  // ==================== MÉTODOS AUXILIARES ====================

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  // ==================== MATÉRIAS ====================

  Future<List<String>> getSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? subjects = prefs.getStringList(_subjectsKey);
      
      if (subjects == null || subjects.isEmpty) {
        return ["Todos", "Matemática", "História", "Português", "Física", "Química"];
      }
      
      return subjects;
    } catch (e) {
      print('Erro ao buscar matérias: $e');
      return ["Todos", "Matemática", "História", "Português", "Física", "Química"];
    }
  }

  Future<void> saveSubjects(List<String> subjects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_subjectsKey, subjects);
    } catch (e) {
      print('Erro ao salvar matérias: $e');
    }
  }

  Future<void> addSubject(String subject) async {
    try {
      final subjects = await getSubjects();
      if (!subjects.contains(subject)) {
        subjects.add(subject);
        await saveSubjects(subjects);
      }
    } catch (e) {
      print('Erro ao adicionar matéria: $e');
    }
  }

  Future<void> removeSubject(String subject) async {
    try {
      final subjects = await getSubjects();
      if (subject != "Todos") {
        subjects.remove(subject);
        await saveSubjects(subjects);
        // Remover tarefas da matéria
        await deleteTasksBySubject(subject);
      }
    } catch (e) {
      print('Erro ao remover matéria: $e');
    }
  }

  // ==================== TRANSAÇÕES (SIMULADAS) ====================

  Future<void> markMultipleAsCompleted(List<int> ids) async {
    try {
      for (final id in ids) {
        await updateCompleted(id, true);
      }
    } catch (e) {
      print('Erro ao marcar múltiplas tarefas: $e');
    }
  }

  Future<void> moveTasksToSubject(String fromSubject, String toSubject) async {
    try {
      final tasks = await getTasksBySubject(fromSubject);
      for (final task in tasks) {
        if (task.id != null) {
          await updateSubject(task.id!, toSubject);
        }
      }
    } catch (e) {
      print('Erro ao mover tarefas: $e');
    }
  }

  Future<int> duplicateTask(int id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) return -1;
      
      final newTask = Task(
        title: '${task.title} (cópia)',
        subject: task.subject,
        estimatedMinutes: task.estimatedMinutes,
        completed: false,
      );
      
      return await insertTask(newTask);
    } catch (e) {
      print('Erro ao duplicar tarefa: $e');
      return -1;
    }
  }
} 