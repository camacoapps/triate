import 'package:flutter_test/flutter_test.dart';
import 'package:triate/triage_engine.dart';
import 'package:triate/triage_model.dart';

void main() {
  final engine = TriageEngine.defaultEngine();

  AnswerSheet answers(Map<String, Set<String>> values) {
    return AnswerSheet(values);
  }

  Map<String, Set<String>> baseAnswers({
    required String symptom,
    String intensity = 'intensity_mild',
    String duration = 'duration_24_72',
  }) {
    return <String, Set<String>>{
      'q_sex': {'male'},
      'q_age_group': {'adult'},
      'q_symptom_cardinal': {symptom},
      'q_general_red_flags': {'none'},
      'q_intensity': {intensity},
      'q_duration': {duration},
      'q_associated': {'none'},
    };
  }

  group('TriageEngine', () {
    test('da prioridad ROJA a cualquier señal de alarma mayor', () {
      final values = baseAnswers(symptom: 'other');
      values['q_general_red_flags'] = {'rf_unconscious'};

      final result = engine.calculateResult(answers(values));

      expect(result.level, TriageLevel.red);
    });

    test('clasifica problemas importantes para respirar como AMARILLO', () {
      final values = baseAnswers(symptom: 'respiratory');
      values['q_respiratory_severity'] = {'resp_moderate'};

      final result = engine.calculateResult(answers(values));

      expect(result.level, TriageLevel.yellow);
    });

    test('clasifica síntomas leves recientes sin alarma como VERDE', () {
      final result = engine.calculateResult(
        answers(baseAnswers(symptom: 'other')),
      );

      expect(result.level, TriageLevel.green);
    });

    test('clasifica síntomas leves de meses sin alarma como AZUL', () {
      final result = engine.calculateResult(
        answers(baseAnswers(symptom: 'other', duration: 'duration_gt4w')),
      );

      expect(result.level, TriageLevel.blue);
    });

    test('omite el bloque específico cuando se elige otro síntoma', () {
      final step = engine.steps.firstWhere(
        (step) => step.id == 'bloque_especifico',
      );
      final values = baseAnswers(symptom: 'other');

      expect(engine.visibleGroups(step, answers(values)), isEmpty);
    });

    test('muestra las señales de embarazo si el embarazo es posible', () {
      final step = engine.steps.firstWhere(
        (step) => step.id == 'bloque_especifico',
      );
      final values = baseAnswers(symptom: 'other');
      values['q_sex'] = {'female'};
      values['q_pregnancy'] = {'preg_unsure'};

      final visibleQuestionIds = engine
          .visibleQuestions(step, answers(values))
          .map((question) => question.id);

      expect(visibleQuestionIds, contains('q_pregnancy_alarm'));
    });
  });
}
