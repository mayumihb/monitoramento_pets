import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'package:intl/intl.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const PetCard({
    Key? key,
    required this.pet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate pet's age
    final now = DateTime.now();
    final age = now.difference(pet.birthdate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    String ageText;
    if (years > 0) {
      ageText = months > 0 
          ? '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}'
          : '$years ${years == 1 ? 'ano' : 'anos'}';
    } else {
      ageText = '$months ${months == 1 ? 'mês' : 'meses'}';
    }

    // Format the birthdate
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedBirthdate = dateFormat.format(pet.birthdate);

    // Determine an icon based on the species
    IconData petIcon = Icons.pets; // Default icon

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet icon or avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  petIcon,
                  size: 36,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Pet information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.species} | ${pet.breed}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$formattedBirthdate ($ageText)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${pet.weight} kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}