import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const primaryColor = Color(0xFFB3A2C4);

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
                icon: const Icon(
                  Icons.refresh, 
                  color: Colors.white, 
                  size: 40
                ),
                onPressed: _loadPets,
              ),
              Text(
                'Meus Pets',
                style: GoogleFonts.emilysCandy(
                  textStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  size: 40,
                  Icons.add, 
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetFormScreen(),
                    ),
                  ).then((_) => _loadPets());
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pets.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum pet cadastrado.\nClique no + para adicionar.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.itim(
                                textStyle: TextStyle(fontSize: 18)
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _pets.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                child: PetCard(
                                  pet: _pets[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PetDetailsScreen(pet: _pets[index]),
                                      ),
                                    ).then((_) => _loadPets());
                                  },
                                ),
                              );
                            },
                          
              ),
            ),
          ),
        ),
        
    );
  }
}
