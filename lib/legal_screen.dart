import 'package:flutter/material.dart';
import 'constants.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        title: const Text("Aviso legal"),
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          "Triate es una herramienta orientativa para pacientes. "
          "No sustituye la valoración médica profesional. "
          "En caso de síntomas graves, llama al 112.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
