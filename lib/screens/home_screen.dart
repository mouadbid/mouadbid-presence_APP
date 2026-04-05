import 'package:flutter/material.dart';
import '../models/seance.dart';
import '../services/api_service.dart';
import 'create_class_screen.dart';
import 'attendance_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Seance> seances = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeances();
  }

  void _loadSeances() async {
    final fetched = await ApiService.getSeances();
    if (mounted) {
      setState(() {
        seances = fetched;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prof = ApiService.currentTeacher;
    if (prof == null) {
      return const Scaffold(body: Center(child: Text("Authentification requise.")));
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Tableau de bord', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ApiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/'); 
            },
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : RefreshIndicator(
            onRefresh: () async => _loadSeances(),
            color: Colors.blueAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.blueGrey[50],
                            child: Text(
                              prof.nom.substring(0, 1),
                              style: const TextStyle(fontSize: 28, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prof. ${prof.prenom} ${prof.nom}',
                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  prof.email,
                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('Vos Séances', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                  const SizedBox(height: 16),
                  
                  if (seances.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy_rounded, size: 80, color: Colors.blueGrey[200]),
                            const SizedBox(height: 16),
                            Text('Aucune séance trouvée.', style: TextStyle(fontSize: 18, color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seances.reversed.length,
                      itemBuilder: (context, index) {
                        final seance = seances.reversed.toList()[index];
                        final formatter = DateFormat('dd MMM yyyy', 'fr_FR');
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceScreen(seance: seance),
                                ),
                              ).then((_) => _loadSeances());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          seance.moduleNom,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                        child: Text(
                                          '${seance.heureDebut.format(context)} - ${seance.heureFin.format(context)}',
                                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.groups_rounded, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 8),
                                      Text(seance.filiereNom, style: TextStyle(color: Colors.blueGrey[600], fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      const Icon(Icons.date_range_rounded, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 8),
                                      Text(formatter.format(seance.dateSeance), style: TextStyle(color: Colors.blueGrey[600], fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateClassScreen()),
          ).then((_) => _loadSeances());
        },
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text('Nouvelle Séance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
