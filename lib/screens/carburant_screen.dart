import 'package:flutter/material.dart';
import '../models/carburant.dart';
import '../db/database_helper.dart';

class CarburantsScreen extends StatefulWidget {
  @override
  _CarburantsScreenState createState() => _CarburantsScreenState();
}

class _CarburantsScreenState extends State<CarburantsScreen> {
  List<Carburant> carburants = [];

  @override
  void initState() {
    super.initState();
    _loadCarburants();
  }

  Future<void> _loadCarburants() async {
    final data = await DatabaseHelper.instance.getAllCarburants();
    setState(() {
      carburants = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des Carburants"),
      ),
      body: carburants.isEmpty
          ? Center(child: Text("Aucun carburant trouvé"))
          : ListView.builder(
              itemCount: carburants.length,
              itemBuilder: (context, index) {
                final c = carburants[index];
                return ListTile(
                  leading: Icon(Icons.local_gas_station),
                  title: Text(c.nom),
                  subtitle: Text("Prix: ${c.prix} FCFA"),
                );
              },
            ),
    );
  }
}
