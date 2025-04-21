class Pet {
  final String? id;
  final String name;
  final String species; // cachorro, gato, etc
  final String breed;
  final DateTime birthdate;
  final double weight;
  final String? imageUrl;

  Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthdate,
    required this.weight,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthdate': birthdate.toIso8601String(),
      'weight': weight,
      'imageUrl': imageUrl,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthdate: DateTime.parse(map['birthdate']),
      weight: map['weight'],
      imageUrl: map['imageUrl'],
    );
  }
}