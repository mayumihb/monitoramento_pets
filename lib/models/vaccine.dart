class Vaccine {
  final String? id;
  final String petId;
  final String name;
  final DateTime date;
  final DateTime nextDueDate;
  final String notes;

  Vaccine({
    this.id,
    required this.petId,
    required this.name,
    required this.date,
    required this.nextDueDate,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'date': date.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
  return Vaccine(
    id: map['id'],
    petId: map['petId'],
    name: map['name'],
    date: _parseDate(map['date']),
    nextDueDate: _parseDate(map['nextDueDate']),
    notes: map['notes'] ?? '',
  );
}

static DateTime _parseDate(dynamic value) {
  if (value is String) {
    return DateTime.parse(value);
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  } else {
    throw Exception('Invalid date format: $value');
  }
}

}