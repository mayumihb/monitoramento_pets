import 'package:firebase_database/firebase_database.dart';
import '../models/pet.dart';
import '../models/vaccine.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // App version management
  Future<String?> getVersion() async {
    final event = await _database.child('version').once();
    return event.snapshot.value?.toString();
  }

  // Pet CRUD operations
  Future<String> insertPet(Pet pet) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final petWithId = Pet(
      id: id,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      birthdate: pet.birthdate,
      weight: pet.weight,
      imageUrl: pet.imageUrl,
    );
    
    await _database.child('pets').child(id).set(petWithId.toMap());
    return id;
  }

  Future<List<Pet>> getPets() async {
    final event = await _database.child('pets').once();
    final snapshot = event.snapshot;
    
    if (snapshot.value == null) return [];
    
    final petsData = snapshot.value as Map<dynamic, dynamic>;
    List<Pet> petsList = [];
    
    petsData.forEach((key, value) {
      final petMap = Map<String, dynamic>.from(value as Map);
      petsList.add(Pet.fromMap(petMap));
    });
    
    return petsList;
  }

  Future<Pet?> getPetById(String id) async {
    final event = await _database.child('pets').child(id).once();
    final snapshot = event.snapshot;
    
    if (snapshot.value == null) return null;
    
    final petData = snapshot.value as Map<dynamic, dynamic>;
    return Pet.fromMap(Map<String, dynamic>.from(petData));
  }

  Future<void> updatePet(Pet pet) async {
    if (pet.id == null) {
      throw Exception("Cannot update a pet without an ID");
    }
    await _database.child('pets').child(pet.id!).update(pet.toMap());
  }

  Future<void> deletePet(String id) async {
    await _database.child('pets').child(id).remove();
    
    // Also delete all vaccines for this pet
    final vaccinesEvent = await _database.child('vaccines')
        .orderByChild('petId')
        .equalTo(id)
        .once();
    
    if (vaccinesEvent.snapshot.value != null) {
      final vaccinesData = vaccinesEvent.snapshot.value as Map<dynamic, dynamic>;
      vaccinesData.forEach((key, _) {
        _database.child('vaccines').child(key).remove();
      });
    }
  }

  // Vaccine CRUD operations
  Future<String> insertVaccine(Vaccine vaccine) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final vaccineWithId = Vaccine(
      id: id,
      petId: vaccine.petId,
      name: vaccine.name,
      date: vaccine.date,
      nextDueDate: vaccine.nextDueDate,
      notes: vaccine.notes,
    );
    
    await _database.child('vaccines').child(id).set(vaccineWithId.toMap());
    return id;
  }

  Future<List<Vaccine>> getVaccinesByPetId(String petId) async {
    final event = await _database.child('vaccines')
        .orderByChild('petId')
        .equalTo(petId)
        .once();
    final snapshot = event.snapshot;
    
    if (snapshot.value == null) return [];
    
    final vaccinesData = snapshot.value as Map<dynamic, dynamic>;
    List<Vaccine> vaccinesList = [];
    
    vaccinesData.forEach((key, value) {
      final vaccineMap = Map<String, dynamic>.from(value as Map);
      vaccinesList.add(Vaccine.fromMap(vaccineMap));
    });
    
    return vaccinesList;
  }

  Future<List<Vaccine>> getUpcomingVaccines() async {
    final now = DateTime.now();
    final oneWeekLater = now.add(Duration(days: 7));
    
    final event = await _database.child('vaccines').once();
    final snapshot = event.snapshot;
    
    if (snapshot.value == null) return [];
    
    final vaccinesData = snapshot.value as Map<dynamic, dynamic>;
    List<Vaccine> upcomingVaccines = [];
    
    vaccinesData.forEach((key, value) {
      final vaccineMap = Map<String, dynamic>.from(value as Map);
      try {
        final vaccine = Vaccine.fromMap(vaccineMap);
        
        if (vaccine.nextDueDate.isAfter(now) && 
            vaccine.nextDueDate.isBefore(oneWeekLater)) {
          upcomingVaccines.add(vaccine);
        }
      } catch (e) {
        print('Error parsing vaccine data: $e');
      }
    });
    
    return upcomingVaccines;
  }

  Future<void> updateVaccine(Vaccine vaccine) async {
    if (vaccine.id == null) {
      throw Exception("Cannot update a vaccine without an ID");
    }
    await _database.child('vaccines').child(vaccine.id!).update(vaccine.toMap());
  }

  Future<void> deleteVaccine(String id) async {
    await _database.child('vaccines').child(id).remove();
  }
  
  // Get all due vaccines across all pets
  Future<List<Map<String, dynamic>>> getDueVaccines() async {
    final now = DateTime.now();
    final event = await _database.child('vaccines').once();
    
    if (event.snapshot.value == null) return [];
    
    final vaccinesData = event.snapshot.value as Map<dynamic, dynamic>;
    List<Map<String, dynamic>> dueVaccines = [];
    
    for (var key in vaccinesData.keys) {
      final vaccineMap = Map<String, dynamic>.from(vaccinesData[key] as Map);
      try {
        final vaccine = Vaccine.fromMap(vaccineMap);
        
        if (vaccine.nextDueDate.isBefore(now)) {
          // Get pet information
          final petEvent = await _database.child('pets').child(vaccine.petId).once();
          if (petEvent.snapshot.value != null) {
            final petData = petEvent.snapshot.value as Map<dynamic, dynamic>;
            final pet = Pet.fromMap(Map<String, dynamic>.from(petData));
            
            dueVaccines.add({
              'vaccine': vaccine,
              'pet': pet,
            });
          }
        }
      } catch (e) {
        print('Error processing vaccine data: $e');
      }
    }
    
    return dueVaccines;
  }
}