import 'triage_model.dart';

class TriageEngine {
  final List<PageStep> steps;
  final List<TriageRule> rules;

  TriageEngine({required this.steps, required this.rules});

  factory TriageEngine.defaultEngine() {
    return TriageEngine(steps: _defaultSteps, rules: _defaultRules);
  }

  List<QuestionGroup> visibleGroups(PageStep step, AnswerSheet answers) {
    if (!step.visibility.evaluate(answers)) {
      return const <QuestionGroup>[];
    }

    final groups = <QuestionGroup>[];
    for (final group in step.groups) {
      if (!group.visibility.evaluate(answers)) {
        continue;
      }

      final visibleQuestions = group.questions
          .where((question) => question.visibility.evaluate(answers))
          .toList(growable: false);

      if (visibleQuestions.isEmpty) {
        continue;
      }

      groups.add(
        QuestionGroup(
          id: group.id,
          title: group.title,
          helperText: group.helperText,
          questions: visibleQuestions,
          visibility: group.visibility,
        ),
      );
    }

    return groups;
  }

  List<Question> visibleQuestions(PageStep step, AnswerSheet answers) {
    final groups = visibleGroups(step, answers);
    return groups.expand((group) => group.questions).toList(growable: false);
  }

  Set<String> visibleQuestionIds(AnswerSheet answers) {
    final ids = <String>{};
    for (final step in steps) {
      if (step.isResultStep || !step.visibility.evaluate(answers)) {
        continue;
      }
      final groups = visibleGroups(step, answers);
      for (final group in groups) {
        for (final question in group.questions) {
          ids.add(question.id);
        }
      }
    }
    return ids;
  }

  List<Question> missingRequiredQuestions(PageStep step, AnswerSheet answers) {
    final missing = <Question>[];
    for (final question in visibleQuestions(step, answers)) {
      if (!question.required) {
        continue;
      }
      if (!answers.hasAnswer(question.id)) {
        missing.add(question);
      }
    }
    return missing;
  }

  bool isStepValid(PageStep step, AnswerSheet answers) {
    return missingRequiredQuestions(step, answers).isEmpty;
  }

  TriageResult calculateResult(AnswerSheet answers) {
    final matched = rules.where((rule) => rule.when.evaluate(answers)).toList();

    final level = _pickHighestLevel(matched);
    final matchedCriteria = matched
        .where((rule) => rule.level == level)
        .map((rule) => rule.description)
        .take(4)
        .toList(growable: false);

    return _buildResult(level, matchedCriteria);
  }

  TriageLevel _pickHighestLevel(List<TriageRule> matched) {
    if (matched.any((rule) => rule.level == TriageLevel.red)) {
      return TriageLevel.red;
    }
    if (matched.any((rule) => rule.level == TriageLevel.yellow)) {
      return TriageLevel.yellow;
    }
    if (matched.any((rule) => rule.level == TriageLevel.green)) {
      return TriageLevel.green;
    }
    return TriageLevel.blue;
  }

  TriageResult _buildResult(TriageLevel level, List<String> matchedCriteria) {
    switch (level) {
      case TriageLevel.red:
        return TriageResult(
          level: TriageLevel.red,
          title: 'Emergencia médica inmediata',
          recommendation:
              'Llama ahora al 112/061 y no esperes a que los síntomas mejoren por sí solos.',
          instructions: const [
            'Si la persona está inconsciente o no respira con normalidad, activa emergencias y sigue sus instrucciones.',
            'No conduzcas por tus propios medios si hay dolor torácico intenso, dificultad respiratoria severa o síntomas neurológicos bruscos.',
            'Ten a mano medicación habitual, alergias y antecedentes para comunicarlos al equipo sanitario.',
          ],
          matchedCriteria: matchedCriteria.isEmpty
              ? const [
                  'Se detectó al menos un signo de alarma mayor que requiere actuación inmediata.',
                ]
              : matchedCriteria,
          legalDisclaimer:
              'Resultado orientativo y no vinculante. No sustituye una valoración médica profesional.',
        );
      case TriageLevel.yellow:
        return TriageResult(
          level: TriageLevel.yellow,
          title: 'Urgencia moderada',
          recommendation:
              'Acude hoy a Urgencias hospitalarias para valoración presencial preferente.',
          instructions: const [
            'Evita retrasar la atención si notas empeoramiento progresivo.',
            'Acude acompañado si presentas mareo, debilidad o dolor importante.',
            'Si aparece algún signo de alarma mayor, pasa a nivel ROJO y llama al 112/061.',
          ],
          matchedCriteria: matchedCriteria.isEmpty
              ? const [
                  'El patrón de síntomas requiere evaluación presencial prioritaria en hospital.',
                ]
              : matchedCriteria,
          legalDisclaimer:
              'Resultado orientativo y no vinculante. No sustituye una valoración médica profesional.',
        );
      case TriageLevel.green:
        return TriageResult(
          level: TriageLevel.green,
          title: 'Urgencia leve',
          recommendation:
              'Consulta en PAC o centro de salud en las próximas 24 horas.',
          instructions: const [
            'Mantén hidratación, reposo y observa evolución de síntomas.',
            'Toma medicación habitual pautada (si no existe contraindicación médica previa).',
            'Si empeoras o aparecen signos de alarma mayor, pasa a nivel ROJO.',
          ],
          matchedCriteria: matchedCriteria.isEmpty
              ? const [
                  'Hay criterios de seguimiento clínico cercano sin alarma vital inmediata.',
                ]
              : matchedCriteria,
          legalDisclaimer:
              'Resultado orientativo y no vinculante. No sustituye una valoración médica profesional.',
        );
      case TriageLevel.blue:
        return TriageResult(
          level: TriageLevel.blue,
          title: 'No urgente',
          recommendation:
              'Autocuidado en domicilio y cita programada si persisten molestias.',
          instructions: const [
            'Continúa observación de los síntomas y medidas de autocuidado básicas.',
            'Solicita cita ordinaria si no hay mejoría en 48-72 horas.',
            'Si aparece cualquier signo de alarma mayor, llama al 112/061.',
          ],
          matchedCriteria: matchedCriteria.isEmpty
              ? const [
                  'No se han detectado signos de alarma ni criterios de urgencia relevante.',
                ]
              : matchedCriteria,
          legalDisclaimer:
              'Resultado orientativo y no vinculante. No sustituye una valoración médica profesional.',
        );
    }
  }
}

final List<PageStep> _defaultSteps = [
  PageStep(
    id: 'identificacion',
    title: 'Identificación',
    subtitle: 'Datos básicos para adaptar el triaje',
    groups: [
      QuestionGroup(
        id: 'grupo_identificacion',
        title: 'Perfil del paciente',
        helperText:
            'Selecciona sexo y grupo de edad. Estas variables modifican la priorización clínica.',
        questions: [
          Question(
            id: 'q_sex',
            title: 'Sexo',
            options: const [
              Option(id: 'male', label: 'Masculino'),
              Option(id: 'female', label: 'Femenino'),
            ],
          ),
          Question(
            id: 'q_age_group',
            title: 'Grupo de edad',
            options: const [
              Option(id: 'infant', label: '0-1 años'),
              Option(id: 'child', label: '1-14 años'),
              Option(id: 'adult', label: '14-85 años'),
              Option(id: 'elderly', label: '+85 años'),
            ],
          ),
        ],
      ),
    ],
  ),
  PageStep(
    id: 'sintoma_cardinal',
    title: 'Síntoma cardinal',
    subtitle: 'Motivo principal de consulta',
    groups: [
      QuestionGroup(
        id: 'grupo_principal',
        title: 'Qué ocurre ahora',
        helperText:
            'Elige el síntoma que mejor describe el motivo principal de consulta.',
        questions: [
          Question(
            id: 'q_symptom_cardinal',
            title: 'Síntoma principal',
            options: const [
              Option(
                id: 'respiratory',
                label: 'Dificultad respiratoria o tos relevante',
              ),
              Option(id: 'chest_pain', label: 'Dolor torácico'),
              Option(
                id: 'neurological',
                label: 'Síntomas neurológicos (mareo, debilidad, confusión)',
              ),
              Option(id: 'allergic', label: 'Reacción alérgica'),
              Option(id: 'bleeding', label: 'Sangrado'),
              Option(id: 'fever', label: 'Fiebre'),
              Option(
                id: 'digestive',
                label: 'Dolor abdominal, vómitos o diarrea',
              ),
              Option(id: 'urinary', label: 'Molestias urinarias o renales'),
              Option(id: 'trauma', label: 'Golpe, caída o lesión'),
              Option(id: 'other', label: 'Otro síntoma'),
            ],
          ),
        ],
      ),
      QuestionGroup(
        id: 'grupo_contexto',
        title: 'Contexto adicional',
        questions: [
          Question(
            id: 'q_pregnancy',
            title: '¿Existe embarazo conocido o posible?',
            helperText:
                'Solo se muestra en mujeres adultas por relevancia clínica del triaje.',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_sex',
                  operator: RuleOperator.anySelected,
                  optionIds: {'female'},
                ),
                Rule(
                  questionId: 'q_age_group',
                  operator: RuleOperator.anySelected,
                  optionIds: {'adult'},
                ),
              ],
            ),
            options: const [
              Option(id: 'preg_yes', label: 'Sí'),
              Option(id: 'preg_no', label: 'No'),
              Option(id: 'preg_unsure', label: 'No lo sé'),
            ],
          ),
        ],
      ),
    ],
  ),
  PageStep(
    id: 'signos_alarma',
    title: 'Signos de alarma',
    subtitle: 'Detección de red flags mayores',
    groups: [
      QuestionGroup(
        id: 'grupo_red_flags',
        title: 'Signos de alarma mayores',
        helperText:
            'Marca una o varias opciones si están presentes. Si no hay ninguna, marca "Ninguna".',
        questions: [
          Question(
            id: 'q_general_red_flags',
            title: '¿Presenta alguno de estos signos de alarma?',
            selectionMode: SelectionMode.multiple,
            options: const [
              Option(
                id: 'rf_unconscious',
                label: 'Inconsciencia o desconexión del entorno',
              ),
              Option(
                id: 'rf_severe_dyspnea',
                label: 'Dificultad respiratoria severa en reposo',
              ),
              Option(
                id: 'rf_chest_oppressive',
                label: 'Dolor torácico opresivo intenso',
              ),
              Option(
                id: 'rf_stroke',
                label: 'Sospecha de ictus (cara, brazo o habla alterados)',
              ),
              Option(
                id: 'rf_anaphylaxis',
                label: 'Hinchazón de lengua/labios o reacción alérgica grave',
              ),
              Option(
                id: 'rf_major_bleeding',
                label: 'Hemorragia importante o no controlable',
              ),
              Option(id: 'rf_seizure', label: 'Convulsión activa o repetida'),
              Option(id: 'none', label: 'Ninguna de las anteriores'),
            ],
          ),
        ],
      ),
    ],
  ),
  PageStep(
    id: 'bloque_especifico',
    title: 'Perfil clínico',
    subtitle: 'Bloques específicos por perfil',
    groups: [
      QuestionGroup(
        id: 'grupo_especifico',
        title: 'Bloques específicos por perfil',
        questions: [
          Question(
            id: 'q_respiratory_severity',
            title: 'Respiratorio: situación actual',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_symptom_cardinal',
                  operator: RuleOperator.anySelected,
                  optionIds: {'respiratory'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'resp_critical',
                label: 'No puede hablar frases completas o se pone morado',
              ),
              Option(
                id: 'resp_moderate',
                label: 'Respira muy rápido o se ahoga al caminar pocos pasos',
              ),
              Option(
                id: 'resp_mild',
                label: 'Molestia respiratoria leve, solo con esfuerzo',
              ),
              Option(id: 'resp_none', label: 'Ninguna de las anteriores'),
            ],
          ),
          Question(
            id: 'q_chest_features',
            title: 'Dolor torácico: características',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_symptom_cardinal',
                  operator: RuleOperator.anySelected,
                  optionIds: {'chest_pain'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'chest_oppressive_20',
                label: 'Dolor opresivo que no cede en 20 minutos',
              ),
              Option(
                id: 'chest_radiated',
                label: 'Se irradia a brazo, espalda o mandíbula',
              ),
              Option(
                id: 'chest_localized',
                label: 'Dolor localizado o punzante sin empeoramiento',
              ),
              Option(id: 'chest_none', label: 'Ninguna de las anteriores'),
            ],
          ),
          Question(
            id: 'q_neuro_features',
            title: 'Neurológico: hallazgos actuales',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_symptom_cardinal',
                  operator: RuleOperator.anySelected,
                  optionIds: {'neurological'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'neuro_focal',
                label:
                    'Inicio brusco con debilidad de un lado o habla alterada',
              ),
              Option(
                id: 'neuro_confusion',
                label: 'Confusión persistente o desorientación nueva',
              ),
              Option(
                id: 'neuro_mild',
                label: 'Mareo o cefalea leve sin déficit focal',
              ),
              Option(id: 'neuro_none', label: 'Ninguna de las anteriores'),
            ],
          ),
          Question(
            id: 'q_pediatric_fever',
            title: 'Pediatría: señales de riesgo',
            helperText: 'Visible en fiebre pediátrica (0-14 años).',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_symptom_cardinal',
                  operator: RuleOperator.anySelected,
                  optionIds: {'fever'},
                ),
              ],
              any: const [
                Rule(
                  questionId: 'q_age_group',
                  operator: RuleOperator.anySelected,
                  optionIds: {'infant'},
                ),
                Rule(
                  questionId: 'q_age_group',
                  operator: RuleOperator.anySelected,
                  optionIds: {'child'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'ped_fever_lt3m',
                label: 'Lactante pequeño con fiebre alta',
              ),
              Option(
                id: 'ped_lethargy',
                label: 'Somnolencia marcada, rechazo de tomas o no orina',
              ),
              Option(
                id: 'ped_good_state',
                label: 'Buen estado general entre picos de fiebre',
              ),
            ],
          ),
          Question(
            id: 'q_elderly_features',
            title: 'Mayores de 85 años: cambios recientes',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_age_group',
                  operator: RuleOperator.anySelected,
                  optionIds: {'elderly'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'elder_confusion_fall',
                label: 'Confusión aguda, caída reciente o incapacidad súbita',
              ),
              Option(
                id: 'elder_decline',
                label: 'Deterioro funcional progresivo sin signo mayor',
              ),
              Option(
                id: 'elder_none',
                label: 'Sin cambios relevantes respecto a su estado basal',
              ),
            ],
          ),
          Question(
            id: 'q_pregnancy_alarm',
            title: 'Embarazo: signos de alarma obstétrica',
            visibility: Condition(
              all: const [
                Rule(
                  questionId: 'q_pregnancy',
                  operator: RuleOperator.anySelected,
                  optionIds: {'preg_yes', 'preg_unsure'},
                ),
              ],
            ),
            options: const [
              Option(
                id: 'preg_alarm',
                label: 'Sangrado vaginal, dolor abdominal intenso o mareo',
              ),
              Option(id: 'preg_none', label: 'No presenta estos signos'),
            ],
          ),
        ],
      ),
    ],
  ),
  PageStep(
    id: 'intensidad_duracion',
    title: 'Intensidad y evolución',
    subtitle: 'Cuantificación clínica orientativa',
    groups: [
      QuestionGroup(
        id: 'grupo_intensidad',
        title: 'Intensidad y tiempo',
        questions: [
          Question(
            id: 'q_intensity',
            title: 'Intensidad actual del síntoma principal',
            options: const [
              Option(id: 'intensity_mild', label: 'Leve (0-3/10)'),
              Option(id: 'intensity_moderate', label: 'Moderada (4-6/10)'),
              Option(id: 'intensity_severe', label: 'Intensa (7-8/10)'),
              Option(
                id: 'intensity_unbearable',
                label: 'Muy intensa / insoportable (9-10/10)',
              ),
            ],
          ),
          Question(
            id: 'q_duration',
            title: 'Tiempo de evolución',
            options: const [
              Option(id: 'duration_lt6', label: 'Menos de 6 horas'),
              Option(id: 'duration_6_24', label: 'Entre 6 y 24 horas'),
              Option(id: 'duration_24_72', label: 'Entre 24 y 72 horas'),
              Option(id: 'duration_gt72', label: 'Entre 3 y 7 días'),
              Option(id: 'duration_1_4w', label: 'Entre 1 y 4 semanas'),
              Option(id: 'duration_gt4w', label: 'Más de 1 mes'),
            ],
          ),
        ],
      ),
    ],
  ),
  PageStep(
    id: 'factores_asociados',
    title: 'Factores asociados',
    subtitle: 'Riesgo adicional y evolución',
    groups: [
      QuestionGroup(
        id: 'grupo_asociados',
        title: 'Factores asociados',
        helperText:
            'Selecciona una o varias opciones. Si no aplica ninguna, marca "Ninguna".',
        questions: [
          Question(
            id: 'q_associated',
            title: '¿Hay factores que aumenten el riesgo?',
            selectionMode: SelectionMode.multiple,
            options: const [
              Option(
                id: 'assoc_vomiting',
                label: 'Vómitos persistentes o repetidos',
              ),
              Option(
                id: 'assoc_no_hydration',
                label: 'No puede mantener líquidos',
              ),
              Option(
                id: 'assoc_high_fever',
                label: 'Fiebre alta mantenida (>39 ºC)',
              ),
              Option(
                id: 'assoc_vulnerable',
                label: 'Inmunosupresión, cáncer o pluripatología',
              ),
              Option(
                id: 'assoc_no_improvement',
                label: 'No mejora tras 24 horas de autocuidados',
              ),
              Option(id: 'none', label: 'Ninguna de las anteriores'),
            ],
          ),
        ],
      ),
    ],
  ),
  const PageStep(
    id: 'resultado',
    title: 'Resultado',
    subtitle: 'Tarjeta orientativa final',
    groups: [],
    isResultStep: true,
  ),
];

final List<TriageRule> _defaultRules = [
  TriageRule(
    id: 'red_general_flags',
    level: TriageLevel.red,
    description:
        'Signo de alarma mayor: inconsciencia, disnea severa, dolor torácico opresivo, ictus, anafilaxia, hemorragia importante o convulsión activa.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_general_red_flags',
          operator: RuleOperator.anySelected,
          optionIds: {
            'rf_unconscious',
            'rf_severe_dyspnea',
            'rf_chest_oppressive',
            'rf_stroke',
            'rf_anaphylaxis',
            'rf_major_bleeding',
            'rf_seizure',
          },
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'red_respiratory_critical',
    level: TriageLevel.red,
    description:
        'Disnea crítica con incapacidad para hablar o coloración azulada.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_respiratory_severity',
          operator: RuleOperator.anySelected,
          optionIds: {'resp_critical'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'red_chest_oppressive',
    level: TriageLevel.red,
    description: 'Dolor torácico opresivo mantenido más de 20 minutos.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_chest_features',
          operator: RuleOperator.anySelected,
          optionIds: {'chest_oppressive_20'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'red_stroke_pattern',
    level: TriageLevel.red,
    description:
        'Déficit neurológico focal de inicio brusco compatible con ictus.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_neuro_features',
          operator: RuleOperator.anySelected,
          optionIds: {'neuro_focal'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'red_pediatric_lethargy',
    level: TriageLevel.red,
    description:
        'Fiebre pediátrica con letargia marcada, rechazo de tomas o anuria.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_pediatric_fever',
          operator: RuleOperator.anySelected,
          optionIds: {'ped_lethargy'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'red_chest_pain_combo',
    level: TriageLevel.red,
    description: 'Dolor torácico muy intenso de inicio reciente.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_symptom_cardinal',
          operator: RuleOperator.anySelected,
          optionIds: {'chest_pain'},
        ),
        Rule(
          questionId: 'q_intensity',
          operator: RuleOperator.anySelected,
          optionIds: {'intensity_unbearable'},
        ),
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.anySelected,
          optionIds: {'duration_lt6'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_respiratory_moderate',
    level: TriageLevel.yellow,
    description: 'Disnea moderada en reposo o con mínimos esfuerzos.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_respiratory_severity',
          operator: RuleOperator.anySelected,
          optionIds: {'resp_moderate'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_chest_radiation',
    level: TriageLevel.yellow,
    description: 'Dolor torácico con irradiación sugestiva de origen cardiaco.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_chest_features',
          operator: RuleOperator.anySelected,
          optionIds: {'chest_radiated'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_neuro_confusion',
    level: TriageLevel.yellow,
    description: 'Confusión o desorientación persistente de nueva aparición.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_neuro_features',
          operator: RuleOperator.anySelected,
          optionIds: {'neuro_confusion'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_infant_fever',
    level: TriageLevel.yellow,
    description:
        'Fiebre en lactante pequeño que requiere valoración hospitalaria precoz.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_pediatric_fever',
          operator: RuleOperator.anySelected,
          optionIds: {'ped_fever_lt3m'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_elderly_confusion_fall',
    level: TriageLevel.yellow,
    description:
        'Persona mayor con confusión aguda o caída reciente con deterioro funcional.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_elderly_features',
          operator: RuleOperator.anySelected,
          optionIds: {'elder_confusion_fall'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_pregnancy_alarm',
    level: TriageLevel.yellow,
    description: 'Embarazo con sangrado vaginal o dolor abdominal intenso.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_pregnancy_alarm',
          operator: RuleOperator.anySelected,
          optionIds: {'preg_alarm'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_high_intensity',
    level: TriageLevel.yellow,
    description: 'Síntoma de alta intensidad (7/10 o superior).',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_intensity',
          operator: RuleOperator.anySelected,
          optionIds: {'intensity_severe', 'intensity_unbearable'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_hydration_risk',
    level: TriageLevel.yellow,
    description: 'Riesgo de deshidratación con evolución prolongada.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_associated',
          operator: RuleOperator.anySelected,
          optionIds: {'assoc_vomiting', 'assoc_no_hydration'},
        ),
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.anySelected,
          optionIds: {
            'duration_24_72',
            'duration_gt72',
            'duration_1_4w',
            'duration_gt4w',
          },
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'yellow_vulnerable_complex',
    level: TriageLevel.yellow,
    description: 'Paciente vulnerable con evolución prolongada o mal control.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_associated',
          operator: RuleOperator.anySelected,
          optionIds: {'assoc_vulnerable'},
        ),
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.anySelected,
          optionIds: {
            'duration_24_72',
            'duration_gt72',
            'duration_1_4w',
            'duration_gt4w',
          },
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'green_moderate_intensity',
    level: TriageLevel.green,
    description: 'Sintomatología moderada que requiere valoración en 24 horas.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.noneSelected,
          optionIds: {'duration_1_4w', 'duration_gt4w'},
        ),
      ],
      any: const [
        Rule(
          questionId: 'q_intensity',
          operator: RuleOperator.anySelected,
          optionIds: {'intensity_moderate'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'green_respiratory_mild',
    level: TriageLevel.green,
    description: 'Síntoma respiratorio leve sin criterios de gravedad mayor.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_respiratory_severity',
          operator: RuleOperator.anySelected,
          optionIds: {'resp_mild'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'green_elderly_decline',
    level: TriageLevel.green,
    description:
        'Mayor de 85 años con deterioro progresivo sin señal de alarma roja.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_elderly_features',
          operator: RuleOperator.anySelected,
          optionIds: {'elder_decline'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'green_persistent_no_risk_short_term',
    level: TriageLevel.green,
    description: 'Síntomas leves o moderados de corta evolución sin red flags.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_general_red_flags',
          operator: RuleOperator.anySelected,
          optionIds: {'none'},
        ),
        Rule(
          questionId: 'q_associated',
          operator: RuleOperator.anySelected,
          optionIds: {'none'},
        ),
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.anySelected,
          optionIds: {
            'duration_lt6',
            'duration_6_24',
            'duration_24_72',
            'duration_gt72',
          },
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'green_followup_factors',
    level: TriageLevel.green,
    description: 'Factores asociados que aconsejan valoración en PAC.',
    when: Condition(
      any: const [
        Rule(
          questionId: 'q_associated',
          operator: RuleOperator.anySelected,
          optionIds: {'assoc_high_fever', 'assoc_no_improvement'},
        ),
      ],
    ),
  ),
  TriageRule(
    id: 'blue_chronic_stable',
    level: TriageLevel.blue,
    description:
        'Síntomas de semanas o meses sin signos de alarma ni factores de riesgo activos.',
    when: Condition(
      all: const [
        Rule(
          questionId: 'q_general_red_flags',
          operator: RuleOperator.anySelected,
          optionIds: {'none'},
        ),
        Rule(
          questionId: 'q_associated',
          operator: RuleOperator.anySelected,
          optionIds: {'none'},
        ),
        Rule(
          questionId: 'q_intensity',
          operator: RuleOperator.anySelected,
          optionIds: {'intensity_mild', 'intensity_moderate'},
        ),
        Rule(
          questionId: 'q_duration',
          operator: RuleOperator.anySelected,
          optionIds: {'duration_1_4w', 'duration_gt4w'},
        ),
      ],
    ),
  ),
];
