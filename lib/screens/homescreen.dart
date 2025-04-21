import 'package:flutter/material.dart';
import 'package:monitoramento_pets/screens/pet_details_screen.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import '../widgets/pet_card.dart';
import 'pet_form_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });
    
    final pets = await _databaseService.getPets();
    
    setState(() {
      _pets = pets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pets'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPets,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum pet cadastrado.\nClique no + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _pets.length,
                  itemBuilder: (context, index) {
                    return PetCard(
                      pet: _pets[index],
                      onTap: () {
                        // Navegar para detalhes do pet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetDetailsScreen(pet: _pets[index]),
                          ),
                        ).then((_) => _loadPets());
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetFormScreen(),
            ),
          ).then((_) => _loadPets());
        },
      ),
    );
  }
}