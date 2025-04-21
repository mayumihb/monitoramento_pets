import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/vaccine.dart';
import '../services/database_service.dart';
import '../widgets/vaccine_card.dart';
import 'pet_form_screen.dart';
import 'vaccine_form_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  _PetDetailsScreenState createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Vaccine> _vaccines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    setState(() {
      _isLoading = true;
    });
    
    final vaccines = await _databaseService.getVaccinesByPetId(widget.pet.id!);
    
    setState(() {
      _vaccines = vaccines;
      _isLoading = false;
    });
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Pet'),
        content: Text('Tem certeza que deseja excluir ${widget.pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _databaseService.deletePet(widget.pet.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetFormScreen(pet: widget.pet),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deletePet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações do Pet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.pets, size: 16),
                            SizedBox(width: 8),
                            Text('Espécie: ${widget.pet.species} | ${widget.pet.breed}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cake, size: 16),
                            SizedBox(width: 8),
                            Text('Nascimento: ${widget.pet.birthdate.day}/${widget.pet.birthdate.month}/${widget.pet.birthdate.year}'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.scale, size: 16),
                            SizedBox(width: 8),
                            Text('Peso: ${widget.pet.weight} kg'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity, // <- força o card a ocupar toda a largura possível
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vacinas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Adicionar'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VaccineFormScreen(petId: widget.pet.id!),
                                ),
                              ).then((_) => _loadVaccines());
                            },
                          ),
                          const SizedBox(height: 8),
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _vaccines.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        'Nenhuma vacina registrada.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _vaccines.length,
                                      itemBuilder: (context, index) {
                                        return VaccineCard(
                                          vaccine: _vaccines[index],
                                          onEdit: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VaccineFormScreen(
                                                  petId: widget.pet.id!,
                                                  vaccine: _vaccines[index],
                                                ),
                                              ),
                                            ).then((_) => _loadVaccines());
                                          },
                                          onDelete: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Excluir Vacina'),
                                                content: Text('Tem certeza que deseja excluir esta vacina?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text('Excluir'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              await _databaseService.deleteVaccine(_vaccines[index].id!);
                                              _loadVaccines();
                                            }
                                          },
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}