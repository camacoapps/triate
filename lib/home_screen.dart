import 'package:flutter/material.dart';

import 'constants.dart';
import 'test_screen.dart';
import 'triage_mode.dart';
import 'widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TriageContentMode _contentMode = TriageContentMode.colloquial;

  Future<void> _showModeOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modo de lenguaje',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'El modo coloquial es el predeterminado y está pensado para pacientes.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorGrayDark,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...TriageContentMode.values.map((mode) {
                      final isSelected = _contentMode == mode;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          setState(() => _contentMode = mode);
                          Navigator.pop(context);
                        },
                        title: Text(
                          mode.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          mode.description,
                          style: TextStyle(color: colorGrayDark),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? colorGreen : colorGrayDark,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _startTriage() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return TriageTestScreen(contentMode: _contentMode);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = isWide ? 32.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    20,
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(isWide),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: isWide
                              ? _buildWideLayout()
                              : _buildNarrowLayout(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isWide) {
    return Row(
      children: [
        Image.asset(
          'assets/banner.png',
          width: isWide ? 170 : 132,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _showModeOptions,
          icon: const Icon(Icons.tune, color: Colors.white, size: 18),
          label: Text(
            isWide ? _contentMode.label : 'Modo',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: colorWithOpacity(Colors.white, 0.16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildIntroduction(isWide: true)),
        const SizedBox(width: 44),
        SizedBox(width: 380, child: _buildStartCard()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildIntroduction(isWide: false),
        const SizedBox(height: 20),
        _buildStartCard(),
      ],
    );
  }

  Widget _buildIntroduction({required bool isWide}) {
    return Padding(
      padding: EdgeInsets.only(top: isWide ? 38 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: colorWithOpacity(Colors.white, 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorWithOpacity(Colors.white, 0.22)),
            ),
            child: const Text(
              'QUÉ HACER SI TE ENCUENTRAS MAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Te orientamos sobre qué hacer ahora.',
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 45 : 31,
              height: 1.08,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Triate es una herramienta de autotriaje diseñada para ayudarte a evaluar la urgencia de tus síntomas médicos. Responde unas preguntas sencillas y te orientará sobre si debes llamar al 112/061, ir al hospital, consultar en un PAC o pedir cita.',
              style: TextStyle(
                color: colorWithOpacity(Colors.white, 0.92),
                fontSize: isWide ? 18 : 16,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildFeature(
            icon: Icons.speed_rounded,
            title: 'Rápido y guiado',
            text: 'Cada pantalla muestra solo las preguntas necesarias.',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            icon: Icons.lock_outline_rounded,
            title: 'Sin cuenta ni historial',
            text: 'Las respuestas se usan solo durante este cuestionario.',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            icon: Icons.fact_check_outlined,
            title: 'Recomendaciones claras según nivel de urgencia',
            text: 'Te indica si debes llamar, acudir a un hospital, PAC o pedir cita.',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            icon: Icons.accessibility_new_rounded,
            title: 'Adaptado a cada persona',
            text: 'Tiene en cuenta edad, sexo y señales de alarma.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorWithOpacity(Colors.white, 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'VarelaRound', height: 1.35),
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: text,
                  style: TextStyle(
                    color: colorWithOpacity(Colors.white, 0.82),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(48, 23, 55, 79),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Antes de empezar',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'El cuestionario tarda unos 3 minutos. Responde según cómo está la persona ahora mismo.',
            style: TextStyle(color: colorGrayDark, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          _buildStep('1', 'Identifica a la persona', 'Edad y sexo.'),
          _buildStep(
            '2',
            'Describe lo que ocurre',
            'Síntoma principal y señales de alarma.',
          ),
          _buildStep(
            '3',
            'Recibe una orientación',
            'Con el siguiente paso recomendado.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorWithOpacity(colorBlue, 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorWithOpacity(colorBlue, 0.22)),
            ),
            child: Text(
              'Triate es una herramienta orientativa y no sustituye la valoración de un profesional sanitario. Si empeoras de forma brusca o hay peligro inmediato, llama al 112/061.',
              style: TextStyle(
                color: colorBlueDark,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'COMENZAR ORIENTACIÓN',
            onPressed: _startTriage,
            frontColor: colorGreen,
            backColor: colorGreenDark,
            textColor: Colors.white,
            height: 54,
            fontSize: 17,
            wrapText: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: colorBlue,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'VarelaRound', height: 1.3),
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: text,
                    style: TextStyle(color: colorGrayDark, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
