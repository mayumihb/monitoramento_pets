import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vaccine.dart';
import 'package:intl/intl.dart';

class VaccineCard extends StatelessWidget {
  final Vaccine vaccine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VaccineCard({
    Key? key,
    required this.vaccine,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format dates for display
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(vaccine.date);
    final formattedNextDueDate = dateFormat.format(vaccine.nextDueDate);

    // Check if the vaccine is overdue or due soon
    final now = DateTime.now();
    final isOverdue = vaccine.nextDueDate.isBefore(now);
    final isDueSoon = !isOverdue && vaccine.nextDueDate.isBefore(now.add(const Duration(days: 30)));
    
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
              // Main content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vaccine name
                    Text(
                      vaccine.name,
                      style: GoogleFonts.itim( 
                        textStyle: TextStyle(
                          color: Color.fromRGBO(157, 119, 119, 1),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Última aplicação: $formattedDate',
                            style: GoogleFonts.itim( 
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(157, 119, 119, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 16,
                          color: isOverdue
                              ? Colors.red
                              : isDueSoon
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Próxima dose: $formattedNextDueDate',
                            style: GoogleFonts.itim( 
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: isOverdue
                                    ? Colors.red
                                    : isDueSoon
                                        ? Colors.orange
                                        : const Color.fromRGBO(157, 119, 119, 1),
                                fontWeight: isOverdue || isDueSoon
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (vaccine.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Observações: ${vaccine.notes}',
                              style: GoogleFonts.itim( 
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(157, 119, 119, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Button column
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete button - wrapped in GestureDetector to prevent edit action
                  GestureDetector(
                    onTap: (){ /* Empty to prevent tap propagation */ },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(203, 186, 186, 1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete, size: 25, color: Colors.white),
                        onPressed: onDelete,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}