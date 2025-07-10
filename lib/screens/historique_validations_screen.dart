import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/models/demande_ticket.dart';

class ValidationScreen extends StatefulWidget {
  final String token;
  final DemandeTicket demande;

  const ValidationScreen({
    super.key,
    required this.token,
    required this.demande,
  });

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final TextEditingController _commentController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _validerDemande() async {
    setState(() {
      _isProcessing = true;
    });

    // Simule un appel API pour valider la demande
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      widget.demande.statut = 'Validée';
      widget.demande.commentaire = _commentController.text;
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demande validée avec succès')),
    );

    Navigator.of(context).pop(true); // Retourne true pour indiquer la modif
  }

  Future<void> _refuserDemande() async {
    setState(() {
      _isProcessing = true;
    });

    // Simule un appel API pour refuser la demande
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      widget.demande.statut = 'Refusée';
      widget.demande.commentaire = _commentController.text;
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demande refusée')),
    );

    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demande = widget.demande;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation de la demande'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demandeur : ${demande.demandeur}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Station : ${demande.station}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
           Text(
               'Date : ${DateTime.parse(demande.dateDemande).toLocal().toString().split(" ")[0]}',
               ),

            const SizedBox(height: 8),
            Text('Quantité demandée : ${demande.quantite} L', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Statut : ${demande.statut}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaires / Motif (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (demande.statut == 'En attente')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _validerDemande,
                    child: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 194, 250),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _refuserDemande,
                    child: const Text('Refuser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  'Demande déjà ${demande.statut}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: demande.statut == 'Validée' ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
