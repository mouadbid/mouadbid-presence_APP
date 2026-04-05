import 'package:flutter/material.dart';
import '../models/seance.dart';
import '../models/etudiant.dart';
import '../models/presence.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final Seance seance;

  const AttendanceScreen({super.key, required this.seance});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Etudiant> etudiants = [];
  Map<int, Presence> presences = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final allFilieres = await ApiService.getFilieres();
    final matchingFiliere = allFilieres.firstWhere(
      (f) => f.nom == widget.seance.filiereNom, 
      orElse: () => allFilieres.first
    );
    
    final fetchedEtuds = await ApiService.getEtudiantsByFiliere(matchingFiliere.id);
    final fetchedPresences = await ApiService.getPresence(widget.seance.id);
    
    // Map existing records
    final PMap = <int, Presence>{};
    for (var p in fetchedPresences) {
      PMap[p.idEtudiant] = p;
    }

    if (mounted) {
      setState(() {
        etudiants = fetchedEtuds;
        presences = PMap;
        isLoading = false;
      });
    }
  }

  void _mark(Etudiant etud, String statut) async {
    // Optimistic UI update
    setState(() {
      if (presences.containsKey(etud.id)) {
        presences[etud.id]!.statut = statut;
      } else {
        presences[etud.id] = Presence(idPresence: 0, idSeance: widget.seance.id, idEtudiant: etud.id, statut: statut);
      }
    });

    await ApiService.updatePresence(widget.seance.id, etud.id, statut);
  }

  @override
  Widget build(BuildContext context) {
    int countP = presences.values.where((p) => p.statut == 'Present').length;
    int countA = presences.values.where((p) => p.statut == 'Absent').length;
    int countR = presences.values.where((p) => p.statut == 'Retard').length;
    int countJ = presences.values.where((p) => p.statut == 'Justifie').length;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Appel', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : Column(
        children: [
          // Header Stats
          Container(
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
                  widget.seance.moduleNom,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.seance.filiereNom,
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        DateFormat('MMM dd').format(widget.seance.dateSeance),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Présents', countP.toString(), Colors.greenAccent),
                    _buildStatCard('Absents', countA.toString(), Colors.redAccent.shade100),
                    _buildStatCard('Retards', countR.toString(), Colors.orangeAccent),
                    _buildStatCard('Justifiés', countJ.toString(), Colors.cyanAccent),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: etudiants.length,
              itemBuilder: (context, index) {
                final student = etudiants[index];
                final p = presences[student.id];
                final currentStatut = p?.statut ?? 'Absent'; // Default to Absent normally but DB default handles that
                final isMarked = p != null;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blueGrey[50],
                            child: Text(
                              student.prenom.substring(0, 1),
                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student.prenom} ${student.nom}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.blueGrey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${student.id}',
                                  style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Modern Segmented Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusButton(student, 'Present', Icons.check_circle_rounded, Colors.green, currentStatut, isMarked),
                          _buildStatusButton(student, 'Absent', Icons.cancel_rounded, Colors.red, currentStatut, isMarked),
                          _buildStatusButton(student, 'Retard', Icons.watch_later_rounded, Colors.orange, currentStatut, isMarked),
                          _buildStatusButton(student, 'Justifie', Icons.assignment_rounded, Colors.blue, currentStatut, isMarked),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(Etudiant student, String statut, IconData icon, Color color, String currentStatut, bool isMarked) {
    bool isSelected = isMarked && currentStatut == statut;
    
    return InkWell(
      onTap: () => _mark(student, statut),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color.withOpacity(0.5) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.blueGrey.shade200, size: 28),
            const SizedBox(height: 4),
            Text(
              statut,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSelected ? color : Colors.blueGrey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
