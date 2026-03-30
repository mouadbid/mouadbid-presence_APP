import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/student.dart';
import '../services/mock_data.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final Session session;

  const AttendanceScreen({super.key, required this.session});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<Student> students;
  String? _currentlyCallingId;

  @override
  void initState() {
    super.initState();
    students = MockData.getStudentsForClass(widget.session.className);
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = widget.session.attendance.values.where((v) => v).length;
    int absentCount = widget.session.attendance.values.where((v) => !v).length;
    int totalCount = students.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigoAccent, Colors.indigo],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.session.className,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('MMM dd').format(widget.session.date),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total', totalCount.toString(), Colors.white),
                    _buildStatCard('Present', presentCount.toString(), Colors.greenAccent),
                    _buildStatCard('Absent', absentCount.toString(), Colors.redAccent.shade100),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                bool isPresent = widget.session.attendance[student.id] ?? false;
                bool isMarked = widget.session.attendance.containsKey(student.id);
                bool isCalling = _currentlyCallingId == student.id;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isCalling ? Colors.indigo.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCalling ? Colors.indigoAccent : Colors.grey.shade200,
                      width: isCalling ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCalling ? Colors.indigo.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onTap: () {
                      setState(() {
                         if(_currentlyCallingId == student.id) {
                            _currentlyCallingId = null;
                         } else {
                            _currentlyCallingId = student.id;
                         }
                      });
                    },
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            student.fullName.substring(0, 1),
                            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        if (isCalling)
                          const Positioned(
                            right: -4,
                            bottom: -4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.record_voice_over_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          '${student.department} • ${student.specialisation}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Absent Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                               MockData.updateAttendance(widget.session.id, student.id, false);
                               _currentlyCallingId = null; // Auto-advance feature basically could be added here
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMarked && !isPresent ? Colors.red.withOpacity(0.15) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.cancel_rounded,
                              color: isMarked && !isPresent ? Colors.red : Colors.grey.shade300,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Present Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                               MockData.updateAttendance(widget.session.id, student.id, true);
                               _currentlyCallingId = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMarked && isPresent ? Colors.green.withOpacity(0.15) : Colors.transparent,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: isMarked && isPresent ? Colors.green : Colors.grey.shade300,
                              size: 32,
                            ),
                          ),
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
    );
  }

  Widget _buildStatCard(String title, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
