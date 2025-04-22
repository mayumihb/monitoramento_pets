import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pet.dart';
import '../services/database_service.dart';

class PetFormScreen extends StatefulWidget {
  final Pet? pet;

  const PetFormScreen({Key? key, this.pet}) : super(key: key);

  @override
  _PetFormScreenState createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  String _species = 'Cachorro';
  DateTime _birthdate = DateTime.now();
  final List<String> _speciesList = ['Cachorro', 'Gato', 'Ave', 'Roedor', 'Outro'];

  static const primaryColor = Color(0xFFB3A2C4);

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _weightController.text = widget.pet!.weight.toString();
      _species = widget.pet!.species;
      _birthdate = widget.pet!.birthdate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthdate) {
      setState(() {
        _birthdate = picked;
      });
    }
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.pet?.id,
        name: _nameController.text,
        species: _species,
        breed: _breedController.text,
        birthdate: _birthdate,
        weight: double.parse(_weightController.text),
      );

      final dbService = DatabaseService();

      if (widget.pet == null) {
        await dbService.insertPet(pet);
      } else {
        await dbService.updatePet(pet);
      }

      Navigator.pop(context);
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
                widget.pet == null ? 'Adicionar Pet' : 'Editar Pet',
                style: GoogleFonts.emilysCandy( 
                  textStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 40), // espaço para equilibrar o layout
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, informe o nome do pet' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _species,
                  decoration: const InputDecoration(labelText: 'Espécie'),
                  items: _speciesList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _species = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(labelText: 'Raça'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, informe a raça do pet' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de Nascimento'),
                  subtitle:
                      Text('${_birthdate.day}/${_birthdate.month}/${_birthdate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o peso do pet';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Por favor, informe um valor numérico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _savePet,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
