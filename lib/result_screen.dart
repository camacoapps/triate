// lib/result_screen.dart - CON BOTÓN LLAMAR 112 ABAJO
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/custom_button.dart';
import 'triage_logic.dart';
import 'constants.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final UrgencyLevel urgencyLevel;
  final AgeGroup ageGroup;
  final String gender;
  final Map<String, String> responses;
  final List<String> tags;
  final VoidCallback? onBackPressed;

  const ResultScreen({
    super.key,
    required this.urgencyLevel,
    required this.ageGroup,
    required this.gender,
    required this.responses,
    required this.tags,
    this.onBackPressed,
  });

  Future<void> _call112() async {
    final Uri telLaunchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ResultInfo.getInfo(urgencyLevel);

    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón INICIO arriba a la derecha
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Botón de retroceso (opcional)
                  Container(
                    decoration: BoxDecoration(
                      color: colorWithOpacity(Colors.white, 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  // Botón INICIO verde arriba a la derecha
                  SizedBox(
                    width: 120,
                    child: CustomButton(
                      text: 'INICIO',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      frontColor: colorGreen,
                      backColor: colorGreenDark,
                      textColor: colorGreenDark,
                      height: 40,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENIDO PRINCIPAL - TARJETA BLANCA
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(38, 0, 0, 0),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Parte superior: Icono y título
                    Column(
                      children: [
                        Icon(
                          urgencyLevel.icon,
                          size: 70,
                          color: urgencyLevel.primaryColor,
                        ),
                        const SizedBox(height: 10),
                        // Título ajustado para caber en una línea
                        Text(
                          _getCompactTitle(urgencyLevel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: urgencyLevel.primaryColor,
                            fontFamily: 'VarelaRound',
                            fontSize: _getTitleFontSize(urgencyLevel),
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Descripción más compacta
                        Text(
                          urgencyLevel.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontFamily: 'VarelaRound',
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),

                    // Parte media: Acción recomendada CON MÁS ESPACIO
                    Column(
                      children: [
                        const SizedBox(height: 25), // MÁS ESPACIO aquí
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: urgencyLevel.darkColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            info['action'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'VarelaRound',
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Parte inferior: Instrucciones compactas
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INSTRUCCIONES:',
                                style: TextStyle(
                                  fontFamily: 'VarelaRound',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(info['instructions'] as List<String>).map((instruction) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: TextStyle(
                                      fontSize: 13,
                                      color: urgencyLevel.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    )),
                                    Expanded(
                                      child: Text(
                                        instruction,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.2,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 10),
                              // Aviso legal dentro del mismo recuadro
                              Row(
                                children: [
                                  Icon(Icons.info, color: colorBlue, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Valoración orientativa. Consulte con un profesional médico.',
                                      style: TextStyle(
                                        fontFamily: 'VarelaRound',
                                        fontSize: 12,
                                        color: colorBlueDark,
                                        height: 1.3,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTÓN LLAMAR 112 FUERA DE LA TARJETA (solo para ROJO)
            if (urgencyLevel == UrgencyLevel.red)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _call112,
                    icon: const Icon(Icons.phone, color: Colors.white, size: 24),
                    label: const Text(
                      'LLAMAR 112',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'VarelaRound',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: colorWithOpacity(Colors.red, 0.5),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Método para título compacto
  String _getCompactTitle(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.red:
        return 'EMERGENCIA';
      case UrgencyLevel.yellow:
        return 'URGENCIA MODERADA';
      case UrgencyLevel.green:
        return 'URGENCIA LEVE';
      case UrgencyLevel.blue:
        return 'NO URGENTE';
    }
  }

  // Método para tamaño de fuente dinámico
  double _getTitleFontSize(UrgencyLevel level) {
    final title = _getCompactTitle(level);
    if (title.length > 15) {
      return 22;
    }
    return 26;
  }
}