import 'package:flutter/material.dart';
import 'constants.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        title: const Text("Información"),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Triate ayuda a los pacientes a identificar la urgencia de sus síntomas "
          "mediante un cuestionario adaptado por edad y sexo.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
