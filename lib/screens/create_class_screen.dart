import 'package:flutter/material.dart';
import '../models/seance.dart';
import '../models/filiere.dart';
import '../models/module.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  Filiere? _selectedFiliere;
  Module? _selectedModule;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedDebut = TimeOfDay.now();
  TimeOfDay _selectedFin = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: TimeOfDay.now().minute);

  List<Filiere> _filieres = [];
  List<Module> _modules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final filieres = await ApiService.getFilieres();
    final modules = await ApiService.getModules();
    setState(() {
      _filieres = filieres;
      _modules = modules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Match modern minimal style
      appBar: AppBar(
        title: const Text('Créer une Séance', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blueGrey, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filière',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueGrey.shade100, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Filiere>(
                  value: _selectedFiliere,
                  hint: const Text('Sélectionner une filière...', style: TextStyle(fontSize: 16)),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blueAccent, size: 28),
                  onChanged: (Filiere? newValue) {
                    setState(() => _selectedFiliere = newValue);
                  },
                  items: _filieres.map<DropdownMenuItem<Filiere>>((Filiere value) {
                    return DropdownMenuItem<Filiere>(
                      value: value,
                      child: Text(value.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Module',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueGrey.shade100, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Module>(
                  value: _selectedModule,
                  hint: const Text('Sélectionner un module...', style: TextStyle(fontSize: 16)),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: Colors.blueAccent, size: 28),
                  onChanged: (Module? newValue) {
                    setState(() => _selectedModule = newValue);
                  },
                  items: _modules.map<DropdownMenuItem<Module>>((Module value) {
                    return DropdownMenuItem<Module>(
                      value: value,
                      child: Text(value.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Date et Horaires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            
            // Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: ThemeData(colorScheme: const ColorScheme.light(primary: Colors.blueAccent)),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueGrey.shade100, width: 2),
                  boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.blueAccent, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time Pickers
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    'Début', 
                    _selectedDebut, 
                    (t) => setState(() => _selectedDebut = t),
                    Colors.orangeAccent,
                    Icons.schedule_rounded
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    'Fin', 
                    _selectedFin, 
                    (t) => setState(() => _selectedFin = t),
                    Colors.deepOrangeAccent,
                    Icons.history_toggle_off_rounded
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (_selectedFiliere == null || _selectedModule == null)
                    ? null
                    : () async {
                        final df = DateFormat('yyyy-MM-dd');
                        final timeD = '${_selectedDebut.hour.toString().padLeft(2,'0')}:${_selectedDebut.minute.toString().padLeft(2,'0')}:00';
                        final timeF = '${_selectedFin.hour.toString().padLeft(2,'0')}:${_selectedFin.minute.toString().padLeft(2,'0')}:00';
                        
                        await ApiService.createSeance(
                          df.format(_selectedDate),
                          timeD,
                          timeF,
                          _selectedFiliere!.id,
                          _selectedModule!.id,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                  shadowColor: Colors.blueAccent.withOpacity(0.5),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('Confirmer la Séance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChange, Color iconColor, IconData icon) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) => Theme(
            data: ThemeData(colorScheme: const ColorScheme.light(primary: Colors.blueAccent)),
            child: child!,
          ),
        );
        if (picked != null) onChange(picked);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueGrey.shade100, width: 2),
          boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
