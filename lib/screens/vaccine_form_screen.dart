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

  Future<void> _saveVaccine() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      try{
      final vaccine = Vaccine(
        id: widget.vaccine?.id,
        petId: widget.petId,
        name: _nameController.text,
        date: _date,
        nextDueDate: _nextDueDate,
        notes: _notesController.text,
      );

      if (widget.vaccine == null) {
        await _databaseService.insertVaccine(vaccine);
      } else {
        await _databaseService.updateVaccine(vaccine);
      }
      Navigator.pop(context);

      await _scheduleNotification(vaccine);
      
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vacina salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar a vacina. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _scheduleNotification(Vaccine vaccine) async {
    if (_pet != null) {
      // Usa o método específico que agenda notificações apenas para esta vacina
      await _notificationService.scheduleVaccineNotification(_pet!, vaccine);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaccine == null ? 'Adicionar Vacina' : 'Editar Vacina'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_pet != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Pet: ${_pet!.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da Vacina',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o nome da vacina';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        title: Text('Data de Vacinação'),
                        subtitle: Text(_formatDate(_date)),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        title: Text('Data da Próxima Vacinação'),
                        subtitle: Text(_formatDate(_nextDueDate)),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectNextDueDate(context),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveVaccine,
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Salvando...'),
                              ],
                            )
                          : Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}