import 'package:flutter/material.dart';

class SolictMedicalScreen extends StatelessWidget {
  const SolictMedicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Médicas'),
      ),
      body: const Center(
        child: Text(
          'Esta es una pantalla vacía para Solicitudes Médicas',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}