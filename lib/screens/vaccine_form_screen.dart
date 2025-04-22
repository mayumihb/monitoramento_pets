import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/vaccine.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class VaccineFormScreen extends StatefulWidget {
  final String petId;
  final Vaccine? vaccine;

  const VaccineFormScreen({
    Key? key,
    required this.petId,
    this.vaccine,
  }) : super(key: key);

  @override
  _VaccineFormScreenState createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(Duration(days: 365));

  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  Pet? _pet;
  bool _isLoading = true;
  bool _isSaving = false;

  static const primaryColor = Color(0xFFD3C5E1);

  @override
  void initState() {
    super.initState();
    _loadPet();

    if (widget.vaccine != null) {
      _nameController.text = widget.vaccine!.name;
      _notesController.text = widget.vaccine!.notes;
      _date = widget.vaccine!.date;
      _nextDueDate = widget.vaccine!.nextDueDate;
    }
  }

  Future<void> _loadPet() async {
    setState(() {
      _isLoading = true;
    });

    final pet = await _databaseService.getPetById(widget.petId);

    setState(() {
      _pet = pet;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        if (_nextDueDate.isBefore(_date)) {
          _nextDueDate = _date.add(Duration(days: 365));
        }
      });
    }
  }

  Future<void> _selectNextDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: _date,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _nextDueDate) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _saveVaccine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final vaccine = Vaccine(
      id: widget.vaccine?.id,
      petId: widget.petId,
      name: _nameController.text,
      date: _date,
      nextDueDate: _nextDueDate,
      notes: _notesController.text,
    );

    bool success = false;
    String errorMessage = 'Erro ao salvar a vacina. Tente novamente.';

    try {
      // Salvar a vacina no banco de dados
      if (widget.vaccine == null) {
        await _databaseService.insertVaccine(vaccine);
      } else {
        await _databaseService.updateVaccine(vaccine);
      }

      // Se chegou aqui sem exceções, a vacina foi salva com sucesso
      success = true;

      // Agendar notificação
      if (_pet != null) {
        try {
          await _notificationService.scheduleVaccineNotification(
            _pet!,
            vaccine,
          );
        } catch (e) {
          print('Erro ao agendar notificação: $e');
          // Não vamos falhar completamente se apenas a notificação falhar
        }
      }
    } catch (e) {
      print('Erro ao salvar vacina: $e');
      success = false;
      errorMessage = 'Erro ao salvar a vacina: ${e.toString()}';
    } finally {
      setState(() {
        _isSaving = false;
      });
      }

    if (success) {
      // Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vacina salva com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop(true);
    } else {
      // Mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: primaryColor,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 40),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                widget.vaccine == null ? 'Adicionar Vacina' : 'Editar Vacina',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (_pet != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Nome do Pet: ${_pet!.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome da Vacina'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Por favor, informe o nome da vacina' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Data da Vacinação'),
                        subtitle: Text(_formatDate(_date)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Próxima Vacinação'),
                        subtitle: Text(_formatDate(_nextDueDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectNextDueDate(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Observações'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveVaccine,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
