import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedBirthdate = dateFormat.format(pet.birthdate);

    IconData petIcon = Icons.pets;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(242, 234, 247, 1),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              offset: Offset(0.0, 4.0),
              blurRadius: 4.0,
              color: Color.fromRGBO(75, 75, 75, 0.5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  petIcon,
                  size: 30,
                  color: Color.fromRGBO(203, 186, 186, 1),
                ),
              ),
              const SizedBox(width: 16),
              // Pet details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: GoogleFonts.itim( 
                        textStyle: TextStyle(
                          color: Color.fromRGBO(157, 119, 119, 1),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${pet.species} | ${pet.breed}',
                      style: GoogleFonts.itim( 
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(157, 119, 119, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake, size: 16, color: Color.fromRGBO(157, 119, 119, 1)),
                        const SizedBox(width: 8),
                        Text(
                          '$formattedBirthdate ($ageText)',
                          style: GoogleFonts.itim( 
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(157, 119, 119, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.scale, size: 16, color: Color.fromRGBO(157, 119, 119, 1)),
                        const SizedBox(width: 8),
                        Text(
                          '${pet.weight} kg',
                          style: GoogleFonts.itim( 
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(157, 119, 119, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
