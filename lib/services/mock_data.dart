import '../models/student.dart';
import '../models/teacher.dart';
import '../models/session.dart';

class MockData {
  static Teacher? currentTeacher;

  static final List<Teacher> teachers = [
    Teacher(
      id: 't1',
      fullName: 'Dr. Jane Smith',
      filiere: 'Computer Science',
      department: 'Software Engineering',
      subject: 'Mobile Development',
      specialisation: 'Cross-platform Frameworks',
      classes: ['Class A - 2026', 'Class B - 2026'],
    ),
    Teacher(
      id: 't2',
      fullName: 'Prof. Alan Turing',
      filiere: 'Data Science',
      department: 'Artificial Intelligence',
      subject: 'Machine Learning',
      specialisation: 'Deep Learning',
      classes: ['Class C - 2026', 'Class D - 2026'],
    ),
  ];

  static final List<Student> students = [
    Student(id: 's1', fullName: 'Alice Johnson', department: 'Software Engineering', specialisation: 'Frontend', className: 'Class A - 2026'),
    Student(id: 's2', fullName: 'Bob Williams', department: 'Software Engineering', specialisation: 'Backend', className: 'Class A - 2026'),
    Student(id: 's3', fullName: 'Charlie Brown', department: 'Software Engineering', specialisation: 'DevOps', className: 'Class A - 2026'),
    Student(id: 's4', fullName: 'Diana Prince', department: 'Software Engineering', specialisation: 'Frontend', className: 'Class B - 2026'),
    Student(id: 's5', fullName: 'Evan Wright', department: 'Software Engineering', specialisation: 'AI', className: 'Class B - 2026'),
    Student(id: 's6', fullName: 'Fiona Gallagher', department: 'Artificial Intelligence', specialisation: 'Data Engineering', className: 'Class C - 2026'),
    Student(id: 's7', fullName: 'George Martin', department: 'Artificial Intelligence', specialisation: 'Robotics', className: 'Class C - 2026'),
    Student(id: 's8', fullName: 'Hannah Abbott', department: 'Artificial Intelligence', specialisation: 'NLP', className: 'Class D - 2026'),
  ];

  static List<Session> sessions = [];

  static bool login(String username, String password) {
    // Basic mock logic: username is teacher id (t1, t2), password is password
    try {
      Teacher teacher = teachers.firstWhere((t) => t.id == username);
      if (password == 'password') {
        currentTeacher = teacher;
        return true;
      }
    } catch (_) {}
    return false;
  }

  static void logout() {
    currentTeacher = null;
  }

  static void addSession(Session session) {
    sessions.add(session);
  }

  static void updateAttendance(String sessionId, String studentId, bool isPresent) {
    var session = sessions.firstWhere((s) => s.id == sessionId);
    session.attendance[studentId] = isPresent;
  }
  
  static List<Student> getStudentsForClass(String className) {
    return students.where((s) => s.className == className).toList();
  }

  static List<Session> getSessionsForCurrentTeacher() {
    if (currentTeacher == null) return [];
    return sessions.where((s) => s.teacherId == currentTeacher!.id).toList();
  }
}
