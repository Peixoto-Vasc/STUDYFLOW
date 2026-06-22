// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../repositories/task_repository.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TaskRepository repository;
  List<Task> tasks = [];
  String selectedFilter = "Todos";
  List<String> subjects = [];

  final AuthService _authService = AuthService();

  List<Task> get filteredTasks {
    if (selectedFilter == "Todos") return tasks;
    return tasks.where((task) => task.subject == selectedFilter).toList();
  }

  int get completedCount => tasks.where((t) => t.completed).length;
  double get progressPercent => tasks.isEmpty ? 0.0 : completedCount / tasks.length;

  @override
  void initState() {
    super.initState();
    repository = TaskRepository(userId: widget.user.email);
    _loadData();
  }

  Future<void> _loadData() async {
    final tasksList = await repository.getAllTasks();
    final subjectsList = await repository.getSubjects();
    
    setState(() {
      tasks = tasksList;
      subjects = subjectsList;
    });
  }

  void addNewSubject(String newSubject) {
    if (!subjects.contains(newSubject)) {
      repository.addSubject(newSubject);
      setState(() => subjects.add(newSubject));
    }
  }

  void removeSubject(String subject) {
    if (subject != "Todos") {
      repository.removeSubject(subject);
      setState(() {
        subjects.remove(subject);
        tasks.removeWhere((task) => task.subject == subject);
      });
    }
  }

  void addTask() {
    final titleController = TextEditingController();
    final minutesController = TextEditingController(text: "25");
    String currentSubject = subjects.firstWhere((s) => s != "Todos", orElse: () => "Matemática");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Nova Meta de Estudo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "O que vai estudar?",
                    hintText: "Ex: Exercícios de Matemática",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: currentSubject,
                  decoration: InputDecoration(
                    labelText: "Matéria",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  items: subjects
                      .where((e) => e != "Todos")
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setDialogState(() => currentSubject = value!),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Tempo estimado (minutos)",
                    hintText: "25",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                
                final newTask = Task(
                  title: titleController.text.trim(),
                  subject: currentSubject,
                  estimatedMinutes: int.tryParse(minutesController.text) ?? 25,
                );
                
                final id = await repository.insertTask(newTask);
                if (id > 0) {
                  setState(() {
                    tasks.add(newTask);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Salvar Meta",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text("Excluir tarefa?"),
        content: Text("Deseja realmente excluir '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (task.id != null) {
                await repository.deleteTask(task.id!);
              }
              setState(() => tasks.remove(task));
              Navigator.pop(context);
            },
            child: const Text(
              "Excluir",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void toggleTaskCompletion(Task task) async {
    final newStatus = !task.completed;
    if (task.id != null) {
      final success = await repository.updateCompleted(task.id!, newStatus);
      if (success) {
        setState(() {
          task.completed = newStatus;
        });
      }
    } else {
      setState(() {
        task.completed = newStatus;
      });
    }
  }

  void startPomodoro([Task? task]) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF2563EB), size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    subjects: subjects,
                    onSubjectAdded: addNewSubject,
                    onSubjectRemoved: removeSubject,
                    user: widget.user,
                  ),
                ),
              );
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, size: 28),
        onPressed: addTask,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, ${widget.user.name} 👋",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              "Vamos focar hoje?",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progresso do Dia",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${(progressPercent * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$completedCount de ${tasks.length} tarefas concluídas",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              "Matérias",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final sub = subjects[index];
                  final isSelected = selectedFilter == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(sub),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      onSelected: (_) => setState(() => selectedFilter = sub),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Suas Metas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${filteredTasks.length} tarefas",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (tasks.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) =>
                    _buildTaskCard(filteredTasks[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.task_alt_outlined, size: 90, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Nenhuma meta ainda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "Adicione sua primeira meta clicando no botão +",
              style: TextStyle(color: Colors.grey[500], fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.subject,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => deleteTask(task),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${task.estimatedMinutes} min"),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => startPomodoro(task),
                    icon: const Icon(Icons.play_circle, color: Color(0xFF2563EB)),
                    label: const Text(
                      "Pomodoro",
                      style: TextStyle(color: Color(0xFF2563EB)),
                    ),
                  ),
                  Checkbox(
                    value: task.completed,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (_) => toggleTaskCompletion(task),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== POMODORO DIALOG COMPLETO ====================

class PomodoroDialog extends StatefulWidget {
  final Task? initialTask;
  const PomodoroDialog({super.key, this.initialTask});

  @override
  State<PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<PomodoroDialog> {
  // ⭐ CONFIGURAÇÕES DO POMODORO
  static const int _focusMinutes = 25;
  static const int _shortBreakMinutes = 5;
  static const int _longBreakMinutes = 15;
  static const int _cyclesBeforeLongBreak = 4;

  // ⭐ ESTADO DO TIMER
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  
  // ⭐ ESTADO DO POMODORO
  PomodoroPhase _currentPhase = PomodoroPhase.focus;
  int _completedCycles = 0;
  int _totalPomodoros = 0;

  // ⭐ CONTROLLERS PARA EDIÇÃO
  final TextEditingController _minutesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final minutes = widget.initialTask?.estimatedMinutes ?? _focusMinutes;
    _secondsRemaining = minutes * 60;
    _minutesController.text = minutes.toString();
    _startTimer();
  }

  // ⭐ INICIAR TIMER
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _switchPhase();
      }
    });
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
  }

  // ⭐ PAUSAR TIMER
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  // ⭐ RETOMAR TIMER
  void _resumeTimer() {
    _startTimer();
  }

  // ⭐ ALTERNAR PLAY/PAUSE
  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else if (_isPaused) {
      _resumeTimer();
    } else {
      _startTimer();
    }
  }

  // ⭐ ALTERNAR FASE (Foco ↔ Pausa)
  void _switchPhase() {
    if (_currentPhase == PomodoroPhase.focus) {
      // ⭐ FOCUS COMPLETO → PAUSA
      _completedCycles++;
      _totalPomodoros++;
      
      // ⭐ MARCA TAREFA COMO CONCLUÍDA SE FOR O PRIMEIRO POMODORO
      if (_completedCycles == 1 && widget.initialTask != null) {
        // Tarefa concluída! (opcional)
      }
      
      // ⭐ DECIDE ENTRE PAUSA CURTA OU LONGA
      final isLongBreak = _completedCycles % _cyclesBeforeLongBreak == 0;
      final breakMinutes = isLongBreak ? _longBreakMinutes : _shortBreakMinutes;
      
      setState(() {
        _currentPhase = isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
        _secondsRemaining = breakMinutes * 60;
        _minutesController.text = breakMinutes.toString();
        _isEditing = false;
      });
    } else {
      // ⭐ PAUSA COMPLETA → VOLTA AO FOCO
      final minutes = widget.initialTask?.estimatedMinutes ?? _focusMinutes;
      setState(() {
        _currentPhase = PomodoroPhase.focus;
        _secondsRemaining = minutes * 60;
        _minutesController.text = minutes.toString();
        _isEditing = false;
      });
    }
    
    // ⭐ INICIA PRÓXIMA FASE
    _startTimer();
  }

  // ⭐ RESETAR TIMER
  void _resetTimer() {
    _timer?.cancel();
    
    final minutes = _currentPhase == PomodoroPhase.focus
        ? (widget.initialTask?.estimatedMinutes ?? _focusMinutes)
        : (_currentPhase == PomodoroPhase.longBreak ? _longBreakMinutes : _shortBreakMinutes);
    
    setState(() {
      _secondsRemaining = minutes * 60;
      _isRunning = false;
      _isPaused = false;
      _minutesController.text = minutes.toString();
      _isEditing = false;
    });
  }

  // ⭐ PARAR E FECHAR
  void _stopAndClose() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  // ⭐ ALTERAR TEMPO MANUALMENTE
  void _editTime() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveTime() {
    final newMinutes = int.tryParse(_minutesController.text) ?? _focusMinutes;
    if (newMinutes > 0) {
      setState(() {
        _secondsRemaining = newMinutes * 60;
        _isEditing = false;
        if (_isRunning) {
          _timer?.cancel();
          _startTimer();
        }
      });
    }
  }

  // ⭐ FORMATAR TEMPO
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocus = _currentPhase == PomodoroPhase.focus;
    final phaseName = isFocus ? '🎯 Foco' : (_currentPhase == PomodoroPhase.longBreak ? '☕ Pausa Longa' : '🧘 Pausa Curta');
    final phaseColor = isFocus ? const Color(0xFF2563EB) : (_currentPhase == PomodoroPhase.longBreak ? const Color(0xFF7C3AED) : const Color(0xFFF59E0B));
    final progress = _currentPhase == PomodoroPhase.focus
        ? 1 - (_secondsRemaining / ((widget.initialTask?.estimatedMinutes ?? _focusMinutes) * 60))
        : 1 - (_secondsRemaining / (_currentPhase == PomodoroPhase.longBreak ? _longBreakMinutes * 60 : _shortBreakMinutes * 60));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⭐ CABEÇALHO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phaseName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                    if (widget.initialTask != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.initialTask!.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: _stopAndClose,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ⭐ TIMER
            GestureDetector(
              onDoubleTap: _editTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _minutesController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onSubmitted: (_) => _saveTime(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('min'),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: _saveTime,
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'Toque duas vezes para editar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ⭐ BARRA DE PROGRESSO
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: phaseColor.withOpacity(0.2),
                color: phaseColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),

            // ⭐ BOTÕES DE CONTROLE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ⭐ PLAY/PAUSE
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: phaseColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    minimumSize: const Size(64, 64),
                    elevation: 4,
                  ),
                  onPressed: _toggleTimer,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // ⭐ RESET
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.grey, size: 28),
                  onPressed: _resetTimer,
                  tooltip: 'Reiniciar',
                ),
                const SizedBox(width: 8),

                // ⭐ PULAR FASE
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.grey, size: 28),
                  onPressed: _switchPhase,
                  tooltip: 'Pular fase',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ⭐ ESTATÍSTICAS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$_totalPomodoros',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const Text(
                        'Pomodoros',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      Text(
                        '$_completedCycles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      const Text(
                        'Ciclos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ⭐ LEGENDA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF2563EB), 'Foco'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFF59E0B), 'Pausa Curta'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFF7C3AED), 'Pausa Longa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

// ⭐ ENUM PARA AS FASES DO POMODORO
enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak,
}