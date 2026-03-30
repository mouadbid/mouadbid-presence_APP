class Session {
  final String id;
  final String teacherId;
  final String className;
  final DateTime date;
  Map<String, bool> attendance;

  Session({
    required this.id,
    required this.teacherId,
    required this.className,
    required this.date,
    required this.attendance,
  });
}
