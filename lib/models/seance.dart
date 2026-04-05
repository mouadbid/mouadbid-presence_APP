import 'package:flutter/material.dart';

class Seance {
  final int id;
  final DateTime dateSeance;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final String filiereNom;
  final String moduleNom;

  Seance({
    required this.id,
    required this.dateSeance,
    required this.heureDebut,
    required this.heureFin,
    required this.filiereNom,
    required this.moduleNom,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id_seance'],
      dateSeance: DateTime.parse(json['date_seance']),
      heureDebut: _parseTime(json['heure_debut']),
      heureFin: _parseTime(json['heure_fin']),
      filiereNom: json['filiere'] ?? 'Filière ${json['id_filiere']}',
      moduleNom: json['module'] ?? 'Module ${json['id_module']}',
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
