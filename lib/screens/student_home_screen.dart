import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/student_presence_detail.dart';
import 'login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<StudentPresenceDetail> _presences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final presences = await ApiService.getStudentPresences();
    if (mounted) {
      setState(() {
        _presences = presences;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    int absentCount = _presences.where((p) => p.statut == 'Absent').length;
    int presentCount = _presences.where((p) => p.statut == 'Present').length;
    int retardCount = _presences.where((p) => p.statut == 'Retard').length;
    int justifieCount = _presences.where((p) => p.statut == 'Justifie').length;

    bool hasExcessiveAbsences = absentCount >= 3;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Match modern design system
      appBar: AppBar(
        title: const Text('Espace Étudiant', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${ApiService.currentStudent?.prenom ?? "Étudiant"}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voici le résumé de votre assiduité.',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Présents', presentCount.toString(), Colors.greenAccent),
                      _buildStatCard('Absents', absentCount.toString(), Colors.redAccent.shade100),
                      _buildStatCard('Retards', retardCount.toString(), Colors.orangeAccent),
                      _buildStatCard('Justifiés', justifieCount.toString(), Colors.cyanAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (hasExcessiveAbsences)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attention !',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vous avez accumulé $absentCount absences. Veuillez justifier vos absences.',
                            style: TextStyle(color: Colors.redAccent.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final presence = _presences[index];
                  return _buildPresenceItem(presence);
                },
                childCount: _presences.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildPresenceItem(StudentPresenceDetail presence) {
    IconData icon;
    Color color;

    switch (presence.statut) {
      case 'Present':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'Absent':
        icon = Icons.cancel_rounded;
        color = Colors.redAccent;
        break;
      case 'Retard':
        icon = Icons.timer_rounded;
        color = Colors.orange;
        break;
      case 'Justifie':
        icon = Icons.assignment_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.shade50),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  presence.moduleNom,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blueGrey.shade300),
                    const SizedBox(width: 4),
                    Text(
                      presence.dateSeance,
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.blueGrey.shade300),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatTime(presence.heureDebut)} - ${_formatTime(presence.heureFin)}',
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              presence.statut,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    if (time.length >= 5) {
      return time.substring(0, 5); // Assumes "HH:MM:SS" format, returns "HH:MM"
    }
    return time;
  }
}
