class Presence {
  final int idPresence;
  final int idSeance;
  final int idEtudiant;
  String statut; // Present, Absent, Retard, Justifie

  Presence({
    required this.idPresence,
    required this.idSeance,
    required this.idEtudiant,
    required this.statut,
  });

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      idPresence: json['id_presence'],
      idSeance: json['id_seance'],
      idEtudiant: json['id_etudiant'],
      statut: json['statut'],
    );
  }
}
