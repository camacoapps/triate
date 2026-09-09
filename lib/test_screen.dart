import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'home_screen.dart';
import 'triage_engine.dart';
import 'triage_model.dart';
import 'triage_mode.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_button2.dart';

class _CareLocatorConfig {
  final String buttonText;
  final String helperText;
  final String searchQuery;

  const _CareLocatorConfig({
    required this.buttonText,
    required this.helperText,
    required this.searchQuery,
  });
}

class _AdviceBlock {
  final String title;
  final List<String> lines;

  const _AdviceBlock({required this.title, required this.lines});
}

class TriageTestScreen extends StatefulWidget {
  final TriageContentMode contentMode;

  const TriageTestScreen({
    super.key,
    this.contentMode = TriageContentMode.colloquial,
  });

  @override
  State<TriageTestScreen> createState() => _TriageTestScreenState();
}

class _TriageTestScreenState extends State<TriageTestScreen> {
  static const List<MapEntry<String, String>> _technicalReplacements = [
    MapEntry('dolor en el pecho', 'dolor torácico'),
    MapEntry('Dolor en el pecho', 'Dolor torácico'),
    MapEntry('problemas para respirar', 'dificultad respiratoria'),
    MapEntry('Problemas para respirar', 'Dificultad respiratoria'),
    MapEntry('falta de aire', 'disnea'),
    MapEntry('derrame cerebral', 'ictus'),
    MapEntry('Dolor de barriga', 'Dolor abdominal'),
    MapEntry('dolor de barriga', 'dolor abdominal'),
    MapEntry('no hace pis', 'anuria'),
    MapEntry('defensas bajas', 'inmunosupresión'),
    MapEntry('señales de alarma', 'red flags'),
  ];

  static const List<MapEntry<String, String>> _colloquialReplacements = [
    MapEntry(
      'Síntomas neurológicos (mareo, debilidad, confusión)',
      'Mareo, debilidad, confusión o cambios raros al hablar o moverse',
    ),
    MapEntry(
      'Sospecha de ictus (cara, brazo o habla alterados)',
      'Cara torcida, brazo flojo o habla rara de repente',
    ),
    MapEntry(
      'Hinchazón de lengua/labios o reacción alérgica grave',
      'Se hincha la lengua o los labios, o alergia muy fuerte',
    ),
    MapEntry(
      'Dificultad respiratoria severa en reposo',
      'Le cuesta mucho respirar incluso estando quieto',
    ),
    MapEntry(
      'Dificultad respiratoria severa',
      'Problemas graves para respirar',
    ),
    MapEntry(
      'dificultad respiratoria severa',
      'problemas graves para respirar',
    ),
    MapEntry(
      'Dificultad respiratoria o tos relevante',
      'Problemas para respirar o tos importante',
    ),
    MapEntry(
      'Molestia respiratoria leve, solo con esfuerzo',
      'Le cuesta un poco respirar solo al hacer esfuerzo',
    ),
    MapEntry(
      'Hemorragia importante o no controlable',
      'Sangrado muy abundante o que no para',
    ),
    MapEntry(
      'Convulsión activa o repetida',
      'Convulsiones (temblores fuertes) ahora o repetidas',
    ),
    MapEntry(
      'Signo de alarma mayor: inconsciencia, disnea severa, dolor torácico opresivo, ictus, anafilaxia, hemorragia importante o convulsión activa.',
      'Hay una señal de alarma grave que necesita ayuda médica inmediata.',
    ),
    MapEntry(
      'Disnea crítica con incapacidad para hablar o coloración azulada.',
      'Problemas muy graves para respirar: no puede hablar o se pone morado.',
    ),
    MapEntry(
      'Déficit neurológico focal de inicio brusco compatible con ictus.',
      'De repente pierde fuerza en un lado o habla raro.',
    ),
    MapEntry(
      'Fiebre pediátrica con letargia marcada, rechazo de tomas o anuria.',
      'Niño con fiebre, muy dormido, que no quiere comer o beber, o que no hace pis.',
    ),
    MapEntry(
        'Pediatría: señales de riesgo', 'Niños y bebés: señales de alerta'),
    MapEntry(
      'Visible en fiebre pediátrica (0-14 años).',
      'Solo aparece si el problema principal es fiebre y tiene entre 0 y 14 años.',
    ),
    MapEntry(
      'Lactante pequeño con fiebre alta',
      'Bebé de menos de 3 meses con fiebre',
    ),
    MapEntry(
      'Somnolencia marcada, rechazo de tomas o no orina',
      'Tiene mucho sueño, no quiere comer o beber, o no hace pis',
    ),
    MapEntry(
      'Buen estado general entre picos de fiebre',
      'Entre los ratos de fiebre está bastante bien',
    ),
    MapEntry(
      'Mayores de 85 años: cambios recientes',
      'Personas de más de 85 años: cambios recientes',
    ),
    MapEntry(
      'Embarazo: signos de alarma obstétrica',
      'Embarazo: señales de alarma',
    ),
    MapEntry(
      'Sangrado vaginal, dolor abdominal intenso o mareo',
      'Sangrado por la vagina, dolor fuerte de barriga o mareo',
    ),
    MapEntry('Intensidad y evolución', 'Cómo te encuentras y desde cuándo'),
    MapEntry(
      'Intensidad actual del síntoma principal',
      '¿Cómo de fuerte es lo que notas ahora?',
    ),
    MapEntry('Tiempo de evolución', '¿Desde cuándo te ocurre?'),
    MapEntry('Factores asociados', 'Otras cosas que pueden empeorarlo'),
    MapEntry(
      '¿Hay factores que aumenten el riesgo?',
      '¿Te ocurre alguna de estas cosas?',
    ),
    MapEntry(
      'Vómitos persistentes o repetidos',
      'Vómitos que siguen o se repiten',
    ),
    MapEntry('No puede mantener líquidos', 'Vomita todo lo que bebe'),
    MapEntry(
      'Fiebre alta mantenida (>39 ºC)',
      'Fiebre de más de 39 ºC que no baja',
    ),
    MapEntry(
      'Inmunosupresión, cáncer o pluripatología',
      'Defensas bajas, cáncer o varios problemas de salud importantes',
    ),
    MapEntry(
      'Autocuidado en domicilio y cita programada si persisten molestias.',
      'Cuídate en casa y pide una cita normal si las molestias continúan.',
    ),
    MapEntry(
      'Dolor torácico con irradiación sugestiva de origen cardiaco.',
      'Dolor en el pecho que se extiende al brazo, espalda o mandíbula.',
    ),
    MapEntry(
      'Embarazo con sangrado vaginal o dolor abdominal intenso.',
      'Embarazo con sangrado vaginal o dolor fuerte de barriga.',
    ),
    MapEntry(
      'Inconsciencia o desconexión del entorno',
      'Está desmayado o no responde',
    ),
    MapEntry(
      'Dolor torácico opresivo intenso',
      'Dolor muy fuerte en el pecho, como presión',
    ),
    MapEntry('Dolor torácico opresivo', 'Dolor en el pecho como presión'),
    MapEntry(
      'Dolor opresivo que no cede en 20 minutos',
      'Dolor en el pecho que aprieta y no se va en 20 minutos',
    ),
    MapEntry('Dolor torácico: características', 'Dolor en el pecho: cómo es'),
    MapEntry(
      'Dolor abdominal, vómitos o diarrea',
      'Dolor de barriga, vómitos o diarrea',
    ),
    MapEntry('dolor abdominal intenso', 'dolor fuerte de barriga'),
    MapEntry('Dolor abdominal intenso', 'Dolor fuerte de barriga'),
    MapEntry('Respiratorio: situación actual', 'Respiración: cómo está ahora'),
    MapEntry(
      'Neurológico: hallazgos actuales',
      'Cerebro y nervios: qué notas ahora',
    ),
    MapEntry(
      'Detección de red flags mayores',
      'Búsqueda de señales de alarma graves',
    ),
    MapEntry('Signos de alarma mayores', 'Señales de alarma graves'),
    MapEntry('Bloques específicos por perfil', 'Preguntas según tu caso'),
    MapEntry('Perfil clínico', 'Situación actual'),
    MapEntry(
      'Cuantificación clínica orientativa',
      'Cómo de fuerte es y cuánto dura',
    ),
    MapEntry('Riesgo adicional y evolución', 'Factores de riesgo y tiempo'),
    MapEntry('Motivo principal de consulta', 'Qué te pasa principalmente'),
    MapEntry('Síntoma cardinal', 'Síntoma principal'),
    MapEntry('red flags', 'señales de alarma'),
    MapEntry('dificultad respiratoria', 'problemas para respirar'),
    MapEntry('Dificultad respiratoria', 'Problemas para respirar'),
    MapEntry('disnea severa', 'falta de aire muy fuerte'),
    MapEntry('disnea', 'falta de aire'),
    MapEntry(
      'compatible con ictus',
      'compatible con un problema grave en el cerebro',
    ),
    MapEntry(
      'síntomas neurológicos bruscos',
      'síntomas repentinos como cara torcida, brazo flojo o habla rara',
    ),
    MapEntry('derrame cerebral', 'problema grave en el cerebro'),
    MapEntry('Dolor torácico', 'Dolor en el pecho'),
    MapEntry('dolor torácico', 'dolor en el pecho'),
    MapEntry('Opresivo', 'Que aprieta'),
    MapEntry('opresivo', 'que aprieta'),
    MapEntry('torácico', 'en el pecho'),
    MapEntry('Torácico', 'En el pecho'),
    MapEntry('ictus', 'problema grave en el cerebro'),
    MapEntry('anuria', 'no hace pis'),
    MapEntry('inmunosupresión', 'defensas bajas'),
    MapEntry('anafilaxia', 'alergia muy fuerte'),
    MapEntry('hemorragia', 'sangrado'),
    MapEntry('inconsciencia', 'desmayo o falta de respuesta'),
    MapEntry('coloración azulada', 'se pone morado'),
    MapEntry('irradiación', 'se extiende a otra zona'),
    MapEntry('cardiaco', 'del corazón'),
    MapEntry('cefalea', 'dolor de cabeza'),
    MapEntry('desorientación', 'no sabe dónde está o qué está pasando'),
    MapEntry('pluripatología', 'varios problemas de salud importantes'),
    MapEntry('somnolencia marcada', 'mucho sueño y mucho decaimiento'),
    MapEntry('letargia', 'somnolencia intensa'),
    MapEntry('abdominal', 'de barriga'),
    MapEntry('Abdominal', 'De barriga'),
    MapEntry('obstétrica', 'del embarazo'),
    MapEntry('sintomatología', 'síntomas'),
    MapEntry('déficit focal', 'pérdida de fuerza o sensibilidad en una zona'),
    MapEntry('presencial preferente', 'en persona cuanto antes'),
    MapEntry('presencial prioritaria', 'en persona cuanto antes'),
    MapEntry(
      'valoración presencial preferente',
      'revisión en persona cuanto antes',
    ),
    MapEntry(
      'valoración presencial prioritaria',
      'revisión en persona cuanto antes',
    ),
    MapEntry(
      'deterioro funcional progresivo',
      'cada vez hace peor sus actividades diarias',
    ),
    MapEntry('estado basal', 'estado habitual'),
  ];

  final TriageEngine _engine = TriageEngine.defaultEngine();
  final AnswerSheet _answers = AnswerSheet();
  late final TriageContentMode _contentMode;

  late final PageController _pageController;

  int _currentStepIndex = 0;
  bool _isAnimating = false;
  TriageResult? _result;

  List<PageStep> get _steps => _engine.steps;

  PageStep get _currentStep => _steps[_currentStepIndex];

  bool get _isResultStep => _currentStep.isResultStep;

  bool _isStepRenderable(PageStep step) {
    if (step.isResultStep) {
      return true;
    }
    return _engine.visibleGroups(step, _answers).isNotEmpty;
  }

  List<int> get _visibleStepIndexes {
    final indexes = <int>[];
    for (var i = 0; i < _steps.length; i++) {
      if (_isStepRenderable(_steps[i])) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  int? _nextRenderableIndex(int fromIndex) {
    for (var i = fromIndex + 1; i < _steps.length; i++) {
      if (_isStepRenderable(_steps[i])) {
        return i;
      }
    }
    return null;
  }

  int? _previousRenderableIndex(int fromIndex) {
    for (var i = fromIndex - 1; i >= 0; i--) {
      if (_isStepRenderable(_steps[i])) {
        return i;
      }
    }
    return null;
  }

  bool get _canProceed {
    if (_isResultStep) {
      return true;
    }
    if (!_isStepRenderable(_currentStep)) {
      return true;
    }
    return _engine.isStepValid(_currentStep, _answers);
  }

  Color get _nextFrontColor {
    if (_isResultStep || _canProceed) {
      return colorGreen;
    }
    return colorGray;
  }

  Color get _nextBackColor {
    if (_isResultStep || _canProceed) {
      return colorGreenDark;
    }
    return colorGrayDark;
  }

  String get _nextLabel {
    if (_isResultStep) {
      return 'INICIO';
    }
    return 'SIGUIENTE';
  }

  @override
  void initState() {
    super.initState();
    _contentMode = widget.contentMode;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int targetIndex) async {
    if (_isAnimating) {
      return;
    }
    if (targetIndex < 0 || targetIndex >= _steps.length) {
      return;
    }
    if (targetIndex == _currentStepIndex) {
      return;
    }

    setState(() {
      _isAnimating = true;
    });

    await _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnimating = false;
    });
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentStepIndex = index;
      if (_steps[index].isResultStep) {
        _result = _engine.calculateResult(_answers);
      }
    });

    if (!_steps[index].isResultStep && !_isStepRenderable(_steps[index])) {
      final target =
          _nextRenderableIndex(index) ?? _previousRenderableIndex(index);
      if (target != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _goToPage(target);
          }
        });
      }
    }
  }

  void _onBackPressed() {
    if (_currentStepIndex == 0) {
      Navigator.pop(context);
      return;
    }

    final previousIndex = _previousRenderableIndex(_currentStepIndex);
    if (previousIndex == null) {
      Navigator.pop(context);
      return;
    }
    _goToPage(previousIndex);
  }

  void _onNextPressed() {
    if (_isResultStep) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    if (!_isStepRenderable(_currentStep)) {
      final nextIndex = _nextRenderableIndex(_currentStepIndex);
      if (nextIndex == null) {
        return;
      }
      if (_steps[nextIndex].isResultStep) {
        setState(() {
          _result = _engine.calculateResult(_answers);
        });
      }
      _goToPage(nextIndex);
      return;
    }

    if (!_canProceed) {
      _showValidationSnackBar();
      return;
    }

    final nextIndex = _nextRenderableIndex(_currentStepIndex);
    if (nextIndex == null) {
      return;
    }

    if (_steps[nextIndex].isResultStep) {
      setState(() {
        _result = _engine.calculateResult(_answers);
      });
    }

    _goToPage(nextIndex);
  }

  void _showValidationSnackBar() {
    final missing = _engine.missingRequiredQuestions(_currentStep, _answers);
    final firstMissing =
        missing.isEmpty ? null : _displayText(missing.first.title);
    final message = firstMissing == null
        ? 'Completa las preguntas obligatorias para continuar.'
        : 'Completa "$firstMissing" para continuar.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorYellow,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _onOptionPressed(Question question, String optionId) {
    setState(() {
      if (question.selectionMode == SelectionMode.single) {
        _answers.setSingle(question.id, optionId);
      } else {
        if (optionId == 'none') {
          final wasSelected = _answers.isSelected(question.id, 'none');
          _answers.clear(question.id);
          if (!wasSelected) {
            _answers.toggleMulti(question.id, 'none');
          }
        } else {
          if (_answers.isSelected(question.id, 'none')) {
            _answers.removeOption(question.id, 'none');
          }
          _answers.toggleMulti(question.id, optionId);
        }
      }

      _purgeHiddenAnswers();

      if (_isResultStep) {
        _result = _engine.calculateResult(_answers);
      }
    });
  }

  void _purgeHiddenAnswers() {
    bool changed;
    do {
      changed = false;
      final visibleIds = _engine.visibleQuestionIds(_answers);
      final answeredIds = _answers.questionIds.toList(growable: false);

      for (final questionId in answeredIds) {
        if (!visibleIds.contains(questionId)) {
          _answers.clear(questionId);
          changed = true;
        }
      }
    } while (changed);
  }

  String _displayText(String text) {
    if (_contentMode == TriageContentMode.technical) {
      return _toTechnicalText(text);
    }
    return _toColloquialText(text);
  }

  String _toTechnicalText(String text) {
    return _applyTextReplacements(text, _technicalReplacements);
  }

  String _toColloquialText(String text) {
    return _applyTextReplacements(text, _colloquialReplacements);
  }

  String _applyTextReplacements(
    String text,
    List<MapEntry<String, String>> replacements,
  ) {
    var value = text;
    for (final replacement in replacements) {
      value = value.replaceAll(replacement.key, replacement.value);
    }
    return value;
  }

  _CareLocatorConfig? _careLocatorConfig(TriageResult result) {
    switch (result.level) {
      case TriageLevel.red:
        return null;
      case TriageLevel.yellow:
        return const _CareLocatorConfig(
          buttonText: 'BUSCAR HOSPITAL CERCANO',
          helperText:
              'Acude a tu hospital de referencia o al hospital más cercano si no puedes acudir al tuyo.',
          searchQuery: 'urgencias hospital cerca de mi',
        );
      case TriageLevel.green:
        return const _CareLocatorConfig(
          buttonText: 'BUSCAR PAC CERCANO',
          helperText:
              'Acude a tu PAC de referencia o al PAC más cercano si no puedes acudir al tuyo.',
          searchQuery: 'PAC punto de atencion continuada cerca de mi',
        );
      case TriageLevel.blue:
        return const _CareLocatorConfig(
          buttonText: 'BUSCAR PAC / CENTRO DE SALUD',
          helperText:
              'Si necesitas valoración, acude a tu PAC o centro de salud de referencia, o al más cercano si no puedes acudir al tuyo.',
          searchQuery: 'PAC centro de salud cerca de mi',
        );
    }
  }

  Future<void> _openNearbyCareSearch(_CareLocatorConfig config) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(config.searchQuery)}',
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened || !mounted) {
        return;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorYellow,
        behavior: SnackBarBehavior.floating,
        content: const Text(
          'No se ha podido abrir el mapa en este dispositivo.',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _callEmergencyNumber() async {
    final uri = Uri(scheme: 'tel', path: '112');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened || !mounted) {
        return;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorYellow,
        behavior: SnackBarBehavior.floating,
        content: const Text(
          'No se ha podido iniciar la llamada. Marca el 112 desde tu teléfono.',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  _AdviceBlock? _specificSelfCareAdvice(TriageResult result) {
    final isLowUrgency =
        result.level == TriageLevel.green || result.level == TriageLevel.blue;
    if (!isLowUrgency) {
      return null;
    }

    if (_answers.isSelected('q_symptom_cardinal', 'digestive')) {
      return const _AdviceBlock(
        title: 'Consejos orientativos para gastroenteritis',
        lines: [
          'Bebe pequeñas cantidades de líquido con frecuencia (agua o suero oral si puedes).',
          'Come suave si te apetece y lo toleras; evita alcohol y comidas copiosas.',
          'Consulta antes si hay sangre en heces, no puedes retener líquidos, fiebre alta o mucha debilidad.',
        ],
      );
    }

    if (_answers.isSelected('q_symptom_cardinal', 'respiratory') ||
        _answers.isSelected('q_symptom_cardinal', 'fever')) {
      return const _AdviceBlock(
        title: 'Consejos orientativos para catarro o cuadro viral leve',
        lines: [
          'Descansa, bebe líquidos y evita humo o esfuerzo si te encuentras cansado.',
          'Para fiebre o malestar, usa solo medicación habitual que ya toleras y sigue las dosis recomendadas.',
          'Consulta antes si te falta el aire, la fiebre es alta varios días o empeoras claramente.',
        ],
      );
    }

    return null;
  }

  Widget _buildCareLocatorCard(TriageResult result, _CareLocatorConfig config) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorWithOpacity(colorBlue, 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorWithOpacity(colorBlue, 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayText(config.helperText),
            style: TextStyle(color: colorBlueDark, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: _displayText(config.buttonText),
            onPressed: () => _openNearbyCareSearch(config),
            frontColor: result.frontColor,
            backColor: result.backColor,
            textColor: result.titleColor,
            height: 48,
            fontSize: 15,
            wrapText: false,
          ),
        ],
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
            final horizontalPadding = isWide ? 32.0 : 18.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    16,
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(isWide),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildHeader(),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isWide) ...[
                              SizedBox(
                                width: 250,
                                child: _buildDesktopProgress(),
                              ),
                              const SizedBox(width: 18),
                            ],
                            Expanded(child: _buildQuestionCard()),
                          ],
                        ),
                      ),
                      if (!isWide) ...[
                        const SizedBox(height: 10),
                        SizedBox(height: 20, child: _buildPageIndicator()),
                      ],
                      const SizedBox(height: 10),
                      _buildNavigation(isWide),
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
          width: isWide ? 158 : 126,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          label: Text(
            isWide ? 'SALIR DEL CUESTIONARIO' : 'SALIR',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: colorWithOpacity(Colors.white, 0.15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(38, 0, 0, 0),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _steps.length,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, index) {
          final step = _steps[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: step.isResultStep
                ? _buildResultCard()
                : _buildQuestionPage(step),
          );
        },
      ),
    );
  }

  Widget _buildDesktopProgress() {
    final visibleIndexes = _visibleStepIndexes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWithOpacity(Colors.white, 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorWithOpacity(Colors.white, 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TU PROGRESO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: visibleIndexes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final stepIndex = visibleIndexes[index];
                final step = _steps[stepIndex];
                final isCurrent = stepIndex == _currentStepIndex;
                final isCompleted = stepIndex < _currentStepIndex &&
                    (step.isResultStep || _engine.isStepValid(step, _answers));
                final icon = isCompleted
                    ? Icons.check
                    : step.isResultStep
                        ? Icons.assignment_turned_in_outlined
                        : Icons.circle_outlined;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: isCurrent || isCompleted
                          ? colorGreen
                          : colorWithOpacity(Colors.white, 0.55),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _displayText(step.title),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorWithOpacity(Colors.white, 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tus respuestas no se guardan al cerrar esta página.',
              style: TextStyle(
                color: colorWithOpacity(Colors.white, 0.86),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(bool isWide) {
    final buttons = Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'ATRÁS',
            onPressed: _onBackPressed,
            frontColor: colorBlue,
            backColor: colorBlueDark,
            textColor: Colors.white,
            height: 50,
            fontSize: 17,
            wrapText: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: _nextLabel,
            onPressed: _onNextPressed,
            frontColor: _nextFrontColor,
            backColor: _nextBackColor,
            textColor: Colors.white,
            height: 50,
            fontSize: 17,
            wrapText: false,
          ),
        ),
      ],
    );

    if (!isWide) {
      return buttons;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(width: 560, child: buttons),
    );
  }

  Widget _buildHeader() {
    final visibleQuestionIndexes = _visibleStepIndexes
        .where((index) => !_steps[index].isResultStep)
        .toList(growable: false);
    final questionSteps = visibleQuestionIndexes.length;
    final currentStepNumber =
        visibleQuestionIndexes.indexOf(_currentStepIndex) + 1;
    final safeCurrentStepNumber = currentStepNumber < 1 ? 1 : currentStepNumber;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayText(_currentStep.title),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _displayText(_currentStep.subtitle),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorWithOpacity(Colors.white, 0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            _isResultStep
                ? 'Resultado'
                : 'Paso $safeCurrentStepNumber/$questionSteps',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionPage(PageStep step) {
    final groups = _engine.visibleGroups(step, _answers);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [for (final group in groups) _buildQuestionGroup(group)],
    );
  }

  Widget _buildQuestionGroup(QuestionGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorWithOpacity(colorBlue, 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorWithOpacity(colorBlue, 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayText(group.title),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (group.helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              _displayText(group.helperText!),
              style: TextStyle(fontSize: 12, color: colorGrayDark, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          for (final question in group.questions) _buildQuestion(question),
        ],
      ),
    );
  }

  Widget _buildQuestion(Question question) {
    final visibleOptions = question.options
        .where((option) => option.visibility.evaluate(_answers))
        .toList(growable: false);
    final isAgeGroupQuestion = question.id == 'q_age_group';

    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = isAgeGroupQuestion ||
            (constraints.maxWidth >= 620 && visibleOptions.length >= 4);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayText(question.title),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.25,
              ),
            ),
            if (question.helperText != null) ...[
              const SizedBox(height: 4),
              Text(
                _displayText(question.helperText!),
                style: TextStyle(
                  fontSize: 12,
                  color: colorGrayDark,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (useGrid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  childAspectRatio: isAgeGroupQuestion ? 2.4 : 3.3,
                ),
                itemBuilder: (context, index) {
                  return _buildOptionButton(
                    question,
                    visibleOptions[index],
                    height: isAgeGroupQuestion ? 54 : 58,
                    fontSize: isAgeGroupQuestion ? 14 : 14,
                    maxLines: isAgeGroupQuestion ? 1 : 2,
                    wrapText: !isAgeGroupQuestion,
                  );
                },
              )
            else
              for (final option in visibleOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _buildOptionButton(
                    question,
                    option,
                    height: 58,
                    fontSize: 15,
                    maxLines: 3,
                  ),
                ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  Widget _buildOptionButton(
    Question question,
    Option option, {
    required double height,
    required double fontSize,
    required int maxLines,
    bool wrapText = true,
  }) {
    return CustomButton2(
      text: _displayText(option.label),
      isSelected: _answers.isSelected(question.id, option.id),
      onPressed: () => _onOptionPressed(question, option.id),
      frontColor: colorBlue,
      backColor: colorBlueDark,
      textColor: Colors.white,
      selectedFrontColor: colorGreen,
      selectedBackColor: colorGreenDark,
      selectedTextColor: Colors.white,
      height: height,
      fontSize: fontSize,
      maxLines: maxLines,
      wrapText: wrapText,
    );
  }

  Widget _buildResultCard() {
    final result = _result ?? _engine.calculateResult(_answers);
    final locatorConfig = _careLocatorConfig(result);
    final specificAdvice = _specificSelfCareAdvice(result);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(result.icon, color: result.frontColor, size: 54),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: result.frontColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                result.levelLabel,
                style: TextStyle(
                  color: result.titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _displayText(result.title),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: result.backColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _displayText(result.recommendation),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (result.level == TriageLevel.red) ...[
            CustomButton(
              text: 'LLAMAR AL 112',
              onPressed: _callEmergencyNumber,
              frontColor: colorRed,
              backColor: colorRedDark,
              textColor: Colors.white,
              height: 50,
              fontSize: 17,
              wrapText: false,
            ),
            const SizedBox(height: 12),
          ],
          if (locatorConfig != null) ...[
            _buildCareLocatorCard(result, locatorConfig),
            const SizedBox(height: 10),
          ],
          _buildResultBlock(
            title: 'Criterios detectados',
            lines: result.matchedCriteria,
            accent: result.frontColor,
          ),
          const SizedBox(height: 10),
          _buildResultBlock(
            title: 'Recomendaciones',
            lines: result.instructions,
            accent: colorBlue,
          ),
          if (specificAdvice != null) ...[
            const SizedBox(height: 10),
            _buildResultBlock(
              title: specificAdvice.title,
              lines: specificAdvice.lines,
              accent: colorGreen,
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorWithOpacity(colorBlue, 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorWithOpacity(colorBlue, 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.gavel, color: colorBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _displayText(result.legalDisclaimer),
                    style: TextStyle(
                      color: colorBlueDark,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBlock({
    required String title,
    required List<String> lines,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorWithOpacity(colorGray, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorWithOpacity(colorGray, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayText(title),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _displayText(line),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final visibleIndexes = _visibleStepIndexes;
    final currentVisibleIndex = visibleIndexes.indexOf(_currentStepIndex);

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(visibleIndexes.length, (index) {
          final stepIndex = visibleIndexes[index];
          final step = _steps[stepIndex];
          final isCurrent = stepIndex == _currentStepIndex;
          final isCompleted = currentVisibleIndex >= 0 &&
              index < currentVisibleIndex &&
              (step.isResultStep ? true : _engine.isStepValid(step, _answers));

          final color = isCurrent
              ? Colors.white
              : isCompleted
                  ? colorGreen
                  : colorWithOpacity(Colors.white, 0.35);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isCurrent ? 10 : 8,
            height: isCurrent ? 10 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}
