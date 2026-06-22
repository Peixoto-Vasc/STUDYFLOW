class Task {
  final int? id;
  final String title;
  final String subject;
  final int estimatedMinutes;
  bool completed;
  final DateTime? createdAt;

  Task({
    this.id,
    required this.title,
    required this.subject,
    this.estimatedMinutes = 25,
    this.completed = false,
    this.createdAt,
  });

  // Para salvar no SharedPreferences (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'estimatedMinutes': estimatedMinutes,
      'completed': completed,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Para carregar do SharedPreferences (JSON)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? '',
      subject: json['subject'] ?? 'Matemática',
      estimatedMinutes: json['estimatedMinutes'] ?? 25,
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  // Criar cópia com campos atualizados
  Task copyWith({
    int? id,
    String? title,
    String? subject,
    int? estimatedMinutes,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, subject: $subject, estimatedMinutes: $estimatedMinutes, completed: $completed, createdAt: $createdAt)';
  }
}