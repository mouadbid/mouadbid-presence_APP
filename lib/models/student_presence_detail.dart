class StudentPresenceDetail {
  final int idPresence;
  final String statut;
  final String dateSeance;
  final String heureDebut;
  final String heureFin;
  final String moduleNom;

  StudentPresenceDetail({
    required this.idPresence,
    required this.statut,
    required this.dateSeance,
    required this.heureDebut,
    required this.heureFin,
    required this.moduleNom,
  });

  factory StudentPresenceDetail.fromJson(Map<String, dynamic> json) {
    return StudentPresenceDetail(
      idPresence: json['id_presence'],
      statut: json['statut'],
      dateSeance: json['date_seance'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      moduleNom: json['moduleNom'] ?? '',
    );
  }
}
