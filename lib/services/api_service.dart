import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/professeur.dart';
import '../models/filiere.dart';
import '../models/module.dart';
import '../models/seance.dart';
import '../models/etudiant.dart';
import '../models/presence.dart';
import '../models/student_presence_detail.dart';

class ApiService {
  // Utilisez 127.0.0.1 ou localhost car "Failed to fetch" indique que vous testez sur Chrome / Web
  // Si jamais vous repassez sur un Emulateur Android, remettez 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8000'; 
  static String? _token;
  static Professeur? currentTeacher;
  static Etudiant? currentStudent;
  static String? currentUserRole;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    if (_token != null) {
      await getMe();
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        
        await getMe();
        return null; // Return null on success
      } else {
        return 'Erreur Serveur ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      print('Login error: $e');
      return 'Erreur Réseau: $e';
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _token = null;
    currentTeacher = null;
    currentStudent = null;
    currentUserRole = null;
  }

  static Future<void> getMe() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentUserRole = data['role'];
        if (currentUserRole == 'professeur') {
          currentTeacher = Professeur.fromJson(data);
        } else if (currentUserRole == 'etudiant') {
          currentStudent = Etudiant.fromJson(data);
        }
      }
    } catch (e) {
      print('GetMe error: $e');
    }
  }

  static Future<List<Filiere>> getFilieres() async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filieres'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Filiere.fromJson(j)).toList();
      }
    } catch (e) {
      print('Filieres error: $e');
    }
    return [];
  }

  static Future<List<Module>> getModules() async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/modules'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Module.fromJson(j)).toList();
      }
    } catch (e) {
      print('Modules error: $e');
    }
    return [];
  }

  static Future<List<Seance>> getSeances() async {
    if (_token == null) return [];
    try {
      // Trying /seances/me first, then fallback to /seances
      var response = await http.get(
        Uri.parse('$baseUrl/seances/me'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode != 200) {
        response = await http.get(
          Uri.parse('$baseUrl/seances'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Seance.fromJson(j)).toList();
      }
    } catch (e) {
      print('Get seances error: $e');
    }
    return [];
  }

  static Future<bool> createSeance(String dateStr, String debutStr, String finStr, int idFiliere, int idModule) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/seances'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'date_seance': dateStr, // YYYY-MM-DD
          'heure_debut': debutStr, // HH:MM:SS
          'heure_fin': finStr,     // HH:MM:SS
          'id_filiere': idFiliere,
          'id_module': idModule
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Create seance error: $e');
    }
    return false;
  }

  static Future<List<Etudiant>> getEtudiantsByFiliere(int idFiliere) async {
    if (_token == null) return [];
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/filieres/$idFiliere/etudiants'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode != 200) {
        response = await http.get(
          Uri.parse('$baseUrl/etudiants'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Etudiant.fromJson(j)).where((e) => e.idFiliere == idFiliere).toList();
      }
    } catch (e) {
      print('Etudiants error: $e');
    }
    return [];
  }

  static Future<List<Presence>> getPresence(int idSeance) async {
     if (_token == null) return [];
     try {
       final response = await http.get(
         Uri.parse('$baseUrl/seances/$idSeance/presence'),
         headers: {'Authorization': 'Bearer $_token'},
       );
       if (response.statusCode == 200) {
         final List<dynamic> data = json.decode(response.body);
         return data.map((j) => Presence.fromJson(j)).toList();
       }
     } catch(e) {
       print('Get presence error: $e');
     }
     return [];
  }

  static Future<bool> updatePresence(int idSeance, int idEtudiant, String statut) async {
    if (_token == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/seances/$idSeance/presence'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_etudiant': idEtudiant,
          'statut': statut, // 'Present', 'Absent', 'Retard', 'Justifie'
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update presence error: $e');
    }
    return false;
  }

  static Future<List<StudentPresenceDetail>> getStudentPresences() async {
    if (_token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiants/me/presences'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => StudentPresenceDetail.fromJson(j)).toList();
      }
    } catch(e) {
      print('Get student presences error: $e');
    }
    return [];
  }
}

