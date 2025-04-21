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
    // Define a theme color matching the Figma design
    const primaryColor = Color(0xFFD3C5E1); // Light purple/lavender color
    const cardColor = Color(0xFFF2EAF7); // Lighter purple for vaccine cards
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(220), // Altura ajustada
        child: Container(
          color: primaryColor,
          child: SafeArea(
            child: Stack(
              children: [
                // Conteúdo principal centralizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 114,
                            height: 114,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: widget.pet.imageUrl != null && widget.pet.imageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(widget.pet.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            ),
                            child: widget.pet.imageUrl == null || widget.pet.imageUrl!.isEmpty
                              ? const Icon(Icons.pets, size: 60, color: Colors.grey)
                              : null,
                          ),
                          const SizedBox(width: 20),
                          // Informações
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.pet.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  'Espécie: ${widget.pet.species} | Raça: ${widget.pet.breed}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nascimento: ${widget.pet.birthdate.day}/${widget.pet.birthdate.month}/${widget.pet.birthdate.year}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Peso: ${widget.pet.weight} kg',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botão de voltar
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: const Icon(
                      size: 30,
                      Icons.close,
                      color: Colors.white
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                // Botão de menu posicionado no topo
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      size: 40,
                      Icons.more_vert, 
                      color: Colors.white
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Editar Pet'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PetFormScreen(pet: widget.pet),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Excluir Pet'),
                              onTap: () async {
                                Navigator.pop(context);
                                await _deletePet();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity, // <- força o card a ocupar toda a largura possível
                child: Card(
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vaccines header with add button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: <Widget>[
                                  Text(
                                    'Vacinas',
                                    style: TextStyle(
                                      shadows: const <Shadow>[
                                        Shadow(
                                          offset: Offset(0.0, 4.0),
                                          blurRadius: 4.0,
                                          color: Color.fromARGB(255, 75, 75, 75),
                                        ),
                                      ],
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 7
                                      ..color = Color.fromRGBO(203, 186, 186, 1)
                                      ..strokeJoin = StrokeJoin.round
                                    ),
                                  ),
                                  Text(
                                    'Vacinas',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]
                              ),
                              ElevatedButton.icon(
                                label: const Text(
                                  '+ Adicionar',
                                  style: TextStyle(
                                    color: Color.fromRGBO(203, 186, 186, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Color.fromARGB(255, 75, 75, 75),
                                  fixedSize: const Size(130, 40),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color.fromRGBO(203, 186, 186, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VaccineFormScreen(petId: widget.pet.id!),
                                    ),
                                  ).then((_) => _loadVaccines());
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Vaccines list
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _vaccines.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Nenhuma vacina registrada.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
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
                                                title: const Text('Excluir Vacina'),
                                                content: const Text('Tem certeza que deseja excluir esta vacina?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Excluir'),
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
            ),
          ],
        ),
      ),
    );
  }
}