class Module {
  final int id;
  final String nom;

  Module({
    required this.id,
    required this.nom,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id_module'],
      nom: json['nom_module'],
    );
  }
}
