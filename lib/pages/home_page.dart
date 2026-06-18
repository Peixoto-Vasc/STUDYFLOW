import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];
  String selectedFilter = "Todos";
  final subjects = ["Todos", "Matemática", "História", "Português", "Física", "Química"];

  List<Task> get filteredTasks {
    if (selectedFilter == "Todos") return tasks;
    return tasks.where((task) => task.subject == selectedFilter).toList();
  }

  int get completedCount => tasks.where((t) => t.completed).length;
  double get progressPercent => tasks.isEmpty ? 0.0 : completedCount / tasks.length;

  void addTask() {
    final titleController = TextEditingController();
    final minutesController = TextEditingController(text: "25");
    String currentSubject = "Matemática";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Nova Meta de Estudo", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "O que vai estudar?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: currentSubject,
                decoration: InputDecoration(
                  labelText: "Matéria",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: subjects
                    .where((e) => e != "Todos")
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setDialogState(() => currentSubject = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Tempo estimado (min)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                setState(() {
                  tasks.add(Task(
                    title: titleController.text.trim(),
                    subject: currentSubject,
                    estimatedMinutes: int.tryParse(minutesController.text) ?? 25,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir tarefa?"),
        content: Text("Deseja realmente excluir '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() => tasks.remove(task));
              Navigator.pop(context);
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void startPomodoro([Task? task]) {
    showDialog(
      context: context,
      builder: (_) => PomodoroDialog(initialTask: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "StudyFlow",
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: addTask,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Olá, Pedro 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),

            // Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Meta do dia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        "${(progressPercent * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey[100],
                    color: const Color(0xFF2563EB),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$completedCount de ${tasks.length} tarefas concluídas",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final sub = subjects[index];
                  final isSelected = selectedFilter == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(sub),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                      onSelected: (_) => setState(() => selectedFilter = sub),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Tasks List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: task.completed ? 0.6 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.subject,
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => deleteTask(task),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${task.estimatedMinutes} min",
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => startPomodoro(task),
                                  icon: const Icon(Icons.play_circle_fill, color: Color(0xFF3B82F6)),
                                  label: const Text(
                                    "Pomodoro",
                                    style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Checkbox(
                                  activeColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  value: task.completed,
                                  onChanged: (_) => setState(() => task.completed = !task.completed),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class PomodoroDialog extends StatefulWidget {
  final Task? initialTask;
  const PomodoroDialog({super.key, this.initialTask});

  @override
  State<PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<PomodoroDialog> {
  late int seconds;
  Timer? timer;
  bool isRunning = false;
  bool isBreak = false;
  int pomodorosCompleted = 0;

  @override
  void initState() {
    super.initState();
    // Força o uso do tempo da tarefa
    final minutes = widget.initialTask?.estimatedMinutes ?? 25;
    seconds = minutes * 60;
    print("Iniciando Pomodoro com ${minutes} minutos"); // Debug
    _toggleTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        timer.cancel();
        _switchPhase();
      }
    });
  }

  void _switchPhase() {
    if (!isBreak) {
      pomodorosCompleted++;
      setState(() {
        isBreak = true;
        seconds = pomodorosCompleted % 4 == 0 ? 15 * 60 : 5 * 60;
      });
    } else {
      setState(() {
        isBreak = false;
        seconds = (widget.initialTask?.estimatedMinutes ?? 25) * 60;
      });
    }
    _startTimer();
  }

  void _toggleTimer() {
    if (isRunning) {
      timer?.cancel();
    } else {
      _startTimer();
    }
    setState(() => isRunning = !isRunning);
  }

  void _resetTimer() {
    timer?.cancel();
    setState(() {
      final minutes = widget.initialTask?.estimatedMinutes ?? 25;
      seconds = isBreak ? 5 * 60 : minutes * 60;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    final mode = isBreak ? "Pausa" : "Foco";
    final color = isBreak ? Colors.orange : const Color(0xFF2563EB);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mode, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            
            if (widget.initialTask != null) ...[
              const SizedBox(height: 8),
              Text(widget.initialTask!.title, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
              Text("${widget.initialTask!.estimatedMinutes} min", 
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
            
            const SizedBox(height: 20),
            Text("$min:$sec", 
                style: TextStyle(fontSize: 58, fontWeight: FontWeight.bold, color: color)),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: _toggleTimer,
                  child: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.grey, size: 28),
                  onPressed: _resetTimer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Pomodoros: $pomodorosCompleted", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}