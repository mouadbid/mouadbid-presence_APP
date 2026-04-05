class Etudiant {
  final int id;
  final String nom;
  final String prenom;
  final int idFiliere;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.idFiliere,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id_etudiant'],
      nom: json['nom'],
      prenom: json['prenom'],
      idFiliere: json['id_filiere'],
    );
  }
}
