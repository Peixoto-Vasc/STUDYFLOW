class Task {
  String title;
  String subject;
  int estimatedMinutes;
  bool completed;

  Task({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    this.completed = false,
  });
}