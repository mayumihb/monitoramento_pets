import 'package:flutter/material.dart';
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
    
    // Check if vaccine is due or overdue
    final now = DateTime.now();
    final isOverdue = vaccine.nextDueDate.isBefore(now);
    final isDueSoon = !isOverdue && 
        vaccine.nextDueDate.isBefore(now.add(const Duration(days: 30)));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vaccine.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aplicação: $formattedDate',
                    style: const TextStyle(fontSize: 14),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: isOverdue
                          ? Colors.red
                          : isDueSoon
                              ? Colors.orange
                              : null,
                      fontWeight: isOverdue || isDueSoon
                          ? FontWeight.bold
                          : FontWeight.normal,
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
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}