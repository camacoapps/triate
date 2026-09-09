// lib/triage_logic.dart - SISTEMA COMPLETO MEJORADO
import 'package:flutter/material.dart';
import 'constants.dart';

// 👶 GRUPOS DE EDAD
enum AgeGroup {
  infant('0-1 año', 0, 1),
  child('1-14 años', 1, 14),
  adult('14-85 años', 14, 85),
  elderly('+85 años', 85, 150);

  final String label;
  final int minAge;
  final int maxAge;

  const AgeGroup(this.label, this.minAge, this.maxAge);

  static AgeGroup fromString(String ageString) {
    switch (ageString) {
      case '0-1':
        return infant;
      case '1-14':
        return child;
      case '14-85':
        return adult;
      case '+85':
        return elderly;
      default:
        return adult;
    }
  }
}

// 🚨 NIVELES DE URGENCIA
enum UrgencyLevel {
  red('ROJO', 'Requiere atención inmediata', colorRed, colorRedDark, Icons.warning),
  yellow('AMARILLO', 'Requiere atención pronto', colorYellow, colorYellowDark, Icons.access_time),
  green('VERDE', 'Puede esperar', colorGreen, colorGreenDark, Icons.medical_services),
  blue('AZUL', 'Puede esperar cita programada', colorBlue, colorBlueDark, Icons.calendar_today);

  final String label;
  final String description; // Más cortas
  final Color primaryColor;
  final Color darkColor;
  final IconData icon;

  const UrgencyLevel(
    this.label,
    this.description,
    this.primaryColor,
    this.darkColor,
    this.icon,
  );
}

// 📋 MODELO DE RESPUESTA CON HISTORIAL
class SymptomResponse {
  final String text;
  final UrgencyLevel? immediateLevel;
  final String? nextSymptomId;
  final List<String>? addTags;
  final Map<String, dynamic>? extraData;
  final List<AgeGroup>? onlyForAgeGroups;
  final List<String>? onlyForGenders;

  const SymptomResponse({
    required this.text,
    this.immediateLevel,
    this.nextSymptomId,
    this.addTags,
    this.extraData,
    this.onlyForAgeGroups,
    this.onlyForGenders,
  });

  // Método para verificar si la respuesta es relevante
  bool isRelevantFor(AgeGroup? ageGroup, String? gender) {
    // Si no tenemos datos, asumimos que es relevante
    if (ageGroup == null || gender == null) {
      return true;
    }
    
    // Verificar edad
    if (onlyForAgeGroups != null && !onlyForAgeGroups!.contains(ageGroup)) {
      return false;
    }
    
    // Verificar género
    if (onlyForGenders != null && !onlyForGenders!.contains(gender)) {
      return false;
    }
    
    return true;
  }
}

// 📋 MODELO DE NODO CON HISTORIAL
class SymptomNode {
  final String id;
  final String question;
  final Map<String, SymptomResponse> responses;
  final bool isMultiSelect;
  final Widget? customWidget;
  final List<AgeGroup>? onlyForAgeGroups;
  final List<String>? onlyForGenders;
  final String? fallbackNodeId;

  const SymptomNode({
    required this.id,
    required this.question,
    required this.responses,
    this.isMultiSelect = false,
    this.customWidget,
    this.onlyForAgeGroups,
    this.onlyForGenders,
    this.fallbackNodeId,
  });

  bool isRelevantFor(AgeGroup? ageGroup, String? gender) {
    // Si no tenemos datos de edad/género, asumimos que es relevante
    if (ageGroup == null || gender == null) {
      return true;
    }
    
    // Verificar restricciones de edad
    if (onlyForAgeGroups != null && !onlyForAgeGroups!.contains(ageGroup)) {
      return false;
    }
    
    // Verificar restricciones de género
    if (onlyForGenders != null && !onlyForGenders!.contains(gender)) {
      return false;
    }
    
    return true;
  }
}

// 📋 HISTORIAL DE RESPUESTAS
class AnswerHistory {
  final String nodeId;
  final String responseId;
  final DateTime timestamp;
  final Map<String, dynamic>? extraData;

  AnswerHistory({
    required this.nodeId,
    required this.responseId,
    required this.timestamp,
    this.extraData,
  });
}

// 📋 BASE DE SÍNTOMAS COMPLETA
class SymptomRepository {
  static final Map<String, SymptomNode> _symptomNodes = {
    // ========== SÍNTOMAS GENERALES ==========
    'start': SymptomNode(
      id: 'start',
      question: '¿Cuál es el síntoma principal que preocupa?',
      responses: {
        'dolor': SymptomResponse(
          text: 'Dolor en alguna parte del cuerpo',
          nextSymptomId: 'dolor_location',
        ),
        'respiratorio': SymptomResponse(
          text: 'Problemas para respirar o tos',
          nextSymptomId: 'respiratory_main',
        ),
        'fiebre': SymptomResponse(
          text: 'Fiebre o temperatura alta',
          nextSymptomId: 'fever_start',
        ),
        'trauma': SymptomResponse(
          text: 'Golpe, caída, herida o quemadura',
          nextSymptomId: 'trauma_type',
        ),
        'digestivo': SymptomResponse(
          text: 'Vómitos, diarrea o dolor abdominal',
          nextSymptomId: 'digestive_main',
        ),
        'neurologico': SymptomResponse(
          text: 'Mareo, confusión, debilidad o convulsiones',
          nextSymptomId: 'neuro_main',
        ),
        'hemorragia': SymptomResponse(
          text: 'Sangrado',
          nextSymptomId: 'bleeding_type',
        ),
        'piel': SymptomResponse(
          text: 'Erupción, manchas o cambios en la piel',
          nextSymptomId: 'skin_type',
        ),
        'pediatrico': SymptomResponse(
          text: 'Niño/lactante con comportamiento anormal',
          nextSymptomId: 'pediatric_behavior',
          onlyForAgeGroups: [AgeGroup.infant, AgeGroup.child],
        ),
        'ginecologico': SymptomResponse(
          text: 'Problemas ginecológicos o embarazo',
          nextSymptomId: 'gynecological_main',
          onlyForGenders: ['femenino'],
        ),
        'urgencia_comun': SymptomResponse(
          text: 'Otro problema de salud común',
          nextSymptomId: 'common_problems',
        ),
      },
    ),

 

// ========== DOLOR - ESTRUCTURA COMPLETA ==========

'dolor_location': SymptomNode(
  id: 'dolor_location',
  question: '¿Dónde está localizado el dolor?',
  responses: {
    'cabeza': SymptomResponse(
      text: 'En la cabeza',
      nextSymptomId: 'dolor_cabeza_intensidad',
    ),
    'pecho': SymptomResponse(
      text: 'En el pecho/tórax',
      nextSymptomId: 'dolor_pecho_intensidad',
    ),
    'abdomen': SymptomResponse(
      text: 'En el abdomen/vientre',
      nextSymptomId: 'dolor_abdomen_intensidad',
    ),
    'espalda': SymptomResponse(
      text: 'En la espalda',
      nextSymptomId: 'dolor_espalda_intensidad',
    ),
    'garganta': SymptomResponse(
      text: 'En la garganta/cuello',
      nextSymptomId: 'dolor_garganta_intensidad',
    ),
    'extremidad': SymptomResponse(
      text: 'En brazo o pierna',
      nextSymptomId: 'dolor_extremidad_intensidad',
    ),
    'generalizado': SymptomResponse(
      text: 'Generalizado (varios sitios)',
      nextSymptomId: 'dolor_general_intensidad',
    ),
  },
),

// ========== ESCALA EVA PARA DOLOR ==========

'dolor_cabeza_intensidad': SymptomNode(
  id: 'dolor_cabeza_intensidad',
  question: '¿Qué número del 0 al 10 le pondría a su dolor de cabeza?',
  responses: {
    '1_3': SymptomResponse(
      text: '1-3 - Dolor leve (molesto pero permite actividades)',
      addTags: ['dolor_leve'],
      nextSymptomId: 'dolor_caracteristicas',
    ),
    '4_6': SymptomResponse(
      text: '4-6 - Dolor moderado (interfiere actividades)',
      addTags: ['dolor_moderado'],
      nextSymptomId: 'dolor_caracteristicas',
    ),
    '7_9': SymptomResponse(
      text: '7-9 - Dolor severo (impide actividades básicas)',
      addTags: ['dolor_severo'],
      nextSymptomId: 'dolor_caracteristicas',
    ),
    '10': SymptomResponse(
      text: '10 - Dolor insoportable (el peor imaginable)',
      immediateLevel: UrgencyLevel.red,
      addTags: ['dolor_insoportable'],
    ),
  },
),

'dolor_pecho_intensidad': SymptomNode(
  id: 'dolor_pecho_intensidad',
  question: '¿Qué número del 0 al 10 le pondría a su dolor en el pecho?',
  responses: {
    '1_3': SymptomResponse(
      text: '1-3 - Dolor leve',
      addTags: ['dolor_leve'],
      nextSymptomId: 'dolor_pecho_caracteristicas',
    ),
    '4_6': SymptomResponse(
      text: '4-6 - Dolor moderado',
      addTags: ['dolor_moderado'],
      nextSymptomId: 'dolor_pecho_caracteristicas',
    ),
    '7_9': SymptomResponse(
      text: '7-9 - Dolor severo',
      immediateLevel: UrgencyLevel.yellow,
      addTags: ['dolor_severo'],
      nextSymptomId: 'dolor_pecho_caracteristicas',
    ),
    '10': SymptomResponse(
      text: '10 - Dolor insoportable',
      immediateLevel: UrgencyLevel.red,
      addTags: ['dolor_insoportable'],
    ),
  },
),

// ========== CARACTERÍSTICAS DEL DOLOR ==========

'dolor_caracteristicas': SymptomNode(
  id: 'dolor_caracteristicas',
  question: '¿Cómo describiría el tipo de dolor?',
  isMultiSelect: true,
  responses: {
    'punzante': SymptomResponse(
      text: 'Punzante o como pinchazos',
      addTags: ['dolor_punzante'],
    ),
    'opresivo': SymptomResponse(
      text: 'Opresivo o como una presión',
      addTags: ['dolor_opresivo'],
    ),
    'quemazon': SymptomResponse(
      text: 'Quemazón o ardor',
      addTags: ['dolor_quemazon'],
    ),
    'pulsatil': SymptomResponse(
      text: 'Pulsátil (como latidos)',
      addTags: ['dolor_pulsatil'],
    ),
    'calambre': SymptomResponse(
      text: 'Como calambres',
      addTags: ['dolor_calambre'],
    ),
    'hormigueo': SymptomResponse(
      text: 'Hormigueo o adormecimiento',
      addTags: ['dolor_hormigueo'],
    ),
    'sordo': SymptomResponse(
      text: 'Sordo o constante',
      addTags: ['dolor_sordo'],
    ),
  },
  fallbackNodeId: 'dolor_frecuencia',
),

'dolor_frecuencia': SymptomNode(
  id: 'dolor_frecuencia',
  question: '¿Es el dolor constante o viene y va?',
  responses: {
    'constante': SymptomResponse(
      text: 'Constante (no desaparece)',
      addTags: ['dolor_constante'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
    'intermitente': SymptomResponse(
      text: 'Intermitente (viene y va)',
      addTags: ['dolor_intermitente'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
    'mejora': SymptomResponse(
      text: 'Mejora con reposo/medicación',
      addTags: ['dolor_mejora'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
    'empeora': SymptomResponse(
      text: 'Empeora con movimiento/actividad',
      addTags: ['dolor_empeora'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
  },
),

// ========== SÍNTOMAS ASOCIADOS GENERALES ==========

'sintomas_asociados_generales': SymptomNode(
  id: 'sintomas_asociados_generales',
  question: '¿Tiene alguno de estos síntomas asociados?',
  isMultiSelect: true,
  responses: {
    'ninguno': SymptomResponse(  // MOVIDO A LA PRIMERA POSICIÓN
      text: 'Ninguno de estos síntomas',
      nextSymptomId: 'signos_alarma_final',
    ),
    'nauseas': SymptomResponse(
      text: 'Náuseas',
      addTags: ['nauseas'],
    ),
    'vomitos': SymptomResponse(
      text: 'Vómitos',
      addTags: ['vomitos'],
    ),
    'mareo': SymptomResponse(
      text: 'Mareo o vértigo',
      addTags: ['mareo'],
    ),
    'sudoracion': SymptomResponse(
      text: 'Sudoración fría',
      addTags: ['sudoracion'],
    ),
    'palpitaciones': SymptomResponse(
      text: 'Palpitaciones',
      addTags: ['palpitaciones'],
    ),
    'fiebre': SymptomResponse(
      text: 'Fiebre',
      addTags: ['fiebre_asociada'],
    ),
    'debilidad': SymptomResponse(
      text: 'Debilidad general',
      addTags: ['debilidad'],
    ),
    'otros': SymptomResponse(  // CAMBIADO de "ninguno" a "otros"
      text: 'Otros síntomas no listados',
      nextSymptomId: 'signos_alarma_final',
    ),
  },
  fallbackNodeId: 'signos_alarma_final',
),

// ========== CARACTERÍSTICAS ESPECÍFICAS PARA DOLOR DE PECHO ==========

'dolor_pecho_caracteristicas': SymptomNode(
  id: 'dolor_pecho_caracteristicas',
  question: '¿El dolor en el pecho se siente como:',
  isMultiSelect: true,
  responses: {
    'opresion': SymptomResponse(
      text: 'Opresión o peso en el pecho',
      immediateLevel: UrgencyLevel.red,
      addTags: ['dolor_toracico_opresivo'],
    ),
    'irradiacion': SymptomResponse(
      text: 'Se irradia al brazo, mandíbula o espalda',
      immediateLevel: UrgencyLevel.red,
      addTags: ['dolor_irradiado'],
    ),
    'punzante_respirar': SymptomResponse(
      text: 'Punzante al respirar',
      addTags: ['dolor_pleuritico'],
    ),
    'ardor': SymptomResponse(
      text: 'Ardor o acidez',
      addTags: ['dolor_ardor'],
    ),
    'mejora_reposo': SymptomResponse(
      text: 'Mejora con reposo',
      addTags: ['dolor_mejora_reposo'],
    ),
    'empeora_esfuerzo': SymptomResponse(
      text: 'Empeora con esfuerzo',
      addTags: ['dolor_esfuerzo'],
    ),
  },
  fallbackNodeId: 'dolor_pecho_duracion',
),

'dolor_pecho_duracion': SymptomNode(
  id: 'dolor_pecho_duracion',
  question: '¿Cuánto tiempo lleva con el dolor?',
  responses: {
    'minutos': SymptomResponse(
      text: 'Minutos (menos de 30 minutos)',
      immediateLevel: UrgencyLevel.red,
      addTags: ['dolor_toracico_agudo'],
    ),
    'horas': SymptomResponse(
      text: 'Horas',
      addTags: ['dolor_toracico_horas'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
    'dias': SymptomResponse(
      text: 'Días',
      addTags: ['dolor_toracico_cronico'],
      nextSymptomId: 'sintomas_asociados_generales',
    ),
  },
),

// ========== FIEBRE - ESTRUCTURA COMPLETA ==========

'fever_start': SymptomNode(
  id: 'fever_start',
  question: '¿Cuánto tiempo lleva con fiebre?',
  responses: {
    'horas': SymptomResponse(
      text: 'Horas (menos de 24 horas)',
      nextSymptomId: 'fever_temperature',
    ),
    'dias': SymptomResponse(
      text: 'Días (1-3 días)',
      nextSymptomId: 'fever_temperature',
    ),
    'muchos_dias': SymptomResponse(
      text: 'Muchos días (más de 3 días)',
      addTags: ['fiebre_prolongada'],
      nextSymptomId: 'fever_temperature',
    ),
  },
),

'fever_temperature': SymptomNode(
  id: 'fever_temperature',
  question: '¿Ha tomado la temperatura? ¿Cuántos grados?',
  responses: {
    'baja': SymptomResponse(
      text: 'Menos de 38°C',
      addTags: ['fiebre_baja'],
      nextSymptomId: 'fever_symptoms',
    ),
    'moderada': SymptomResponse(
      text: '38°C - 39°C',
      addTags: ['fiebre_moderada'],
      nextSymptomId: 'fever_symptoms',
    ),
    'alta': SymptomResponse(
      text: 'Más de 39°C',
      addTags: ['fiebre_alta'],
      nextSymptomId: 'fever_state',
    ),
    'no_sabe': SymptomResponse(
      text: 'No he tomado la temperatura',
      nextSymptomId: 'fever_feel',
    ),
  },
),

'fever_state': SymptomNode(
  id: 'fever_state',
  question: '¿Cómo se siente en general?',
  responses: {
    'muy_mal': SymptomResponse(
      text: 'Muy mal, apenas puede moverse',
      immediateLevel: UrgencyLevel.red,
      addTags: ['mal_estado_grave'],
    ),
    'decaido': SymptomResponse(
      text: 'Decaído pero puede moverse',
      immediateLevel: UrgencyLevel.yellow,
      addTags: ['mal_estado'],
      nextSymptomId: 'fever_symptoms',
    ),
    'regular': SymptomResponse(
      text: 'Regular, con malestar',
      nextSymptomId: 'fever_symptoms',
    ),
    'bien': SymptomResponse(
      text: 'Bien, a pesar de la fiebre',
      nextSymptomId: 'fever_symptoms',
    ),
  },
),

'fever_symptoms': SymptomNode(
  id: 'fever_symptoms',
  question: '¿Tiene alguno de estos síntomas además de la fiebre?',
  isMultiSelect: true,
  responses: {
    'ninguno': SymptomResponse(  // PRIMERO
      text: 'Ninguno de los anteriores',
      nextSymptomId: 'signos_alarma_final',
    ),
    'dolor_cabeza': SymptomResponse(
      text: 'Dolor de cabeza intenso',
      addTags: ['cefalea_febril'],
    ),
    'rigidez_cuello': SymptomResponse(
      text: 'Rigidez en el cuello',
      immediateLevel: UrgencyLevel.red,
      addTags: ['meningismo'],
    ),
    // ... resto de opciones
    'otros': SymptomResponse(  // ÚLTIMO
      text: 'Otros síntomas no listados',
      nextSymptomId: 'signos_alarma_final',
    ),
  },
  fallbackNodeId: 'signos_alarma_final',
),

    // ========== GINECOLÓGICO ==========
    'gynecological_main': SymptomNode(
      id: 'gynecological_main',
      question: '¿Qué problema ginecológico tiene?',
      onlyForGenders: ['femenino'],
      responses: {
        'embarazo_dolor': SymptomResponse(
          text: 'Estoy embarazada y tengo dolor o sangrado',
          nextSymptomId: 'pregnancy_problems',
        ),
        'dolor_pelvico': SymptomResponse(
          text: 'Dolor pélvico o abdominal intenso',
          nextSymptomId: 'pelvic_pain',
        ),
        'sangrado_vaginal': SymptomResponse(
          text: 'Sangrado vaginal abundante',
          nextSymptomId: 'vaginal_bleeding',
        ),
        'infeccion': SymptomResponse(
          text: 'Secreción vaginal anormal o picor',
          nextSymptomId: 'vaginal_infection',
        ),
        'amenorrea': SymptomResponse(
          text: 'Falta de menstruación o sospecha de embarazo',
          nextSymptomId: 'amenorrhea',
        ),
      },
    ),

    'pregnancy_problems': SymptomNode(
      id: 'pregnancy_problems',
      question: '¿Qué sucede durante el embarazo?',
      onlyForGenders: ['femenino'],
      responses: {
        'sangrado': SymptomResponse(
          text: 'Sangrado vaginal',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['embarazo_sangrado'],
        ),
        'dolor_fuerte': SymptomResponse(
          text: 'Dolor abdominal fuerte',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['embarazo_dolor_abdominal'],
        ),
        'perdida_liquido': SymptomResponse(
          text: 'Pérdida de líquido amniótico',
          immediateLevel: UrgencyLevel.red,
          addTags: ['rotura_bolsa'],
        ),
        'contracciones': SymptomResponse(
          text: 'Contracciones antes de tiempo',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['amenaza_parto'],
        ),
        'menos_movimiento': SymptomResponse(
          text: 'El bebé se mueve menos',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['disminucion_movimientos'],
        ),
      },
    ),

    // ========== PROBLEMAS COMUNES ==========
    'common_problems': SymptomNode(
      id: 'common_problems',
      question: '¿Qué otro problema de salud tiene?',
      responses: {
        'infeccion_garganta': SymptomResponse(
          text: 'Dolor de garganta o dificultad para tragar',
          nextSymptomId: 'throat_problems',
        ),
        'infeccion_orina': SymptomResponse(
          text: 'Dolor al orinar o necesidad frecuente',
          nextSymptomId: 'urinary_problems',
        ),
        'dolor_muscular': SymptomResponse(
          text: 'Dolor muscular o articular',
          nextSymptomId: 'muscle_pain',
        ),
        'fatiga': SymptomResponse(
          text: 'Cansancio extremo o debilidad',
          nextSymptomId: 'fatigue_level',
        ),
        'ansiedad': SymptomResponse(
          text: 'Ansiedad, nerviosismo o ataques de pánico',
          nextSymptomId: 'anxiety_level',
        ),
        'vision': SymptomResponse(
          text: 'Problemas de visión',
          nextSymptomId: 'vision_problems',
        ),
      },
      fallbackNodeId: 'signos_alarma_final',
    ),

    'throat_problems': SymptomNode(
      id: 'throat_problems',
      question: '¿Tiene dificultad para respirar o tragar?',
      responses: {
        'respirar': SymptomResponse(
          text: 'Sí, dificultad para respirar',
          immediateLevel: UrgencyLevel.red,
          addTags: ['obstruccion_vias_respiratorias'],
        ),
        'tragar': SymptomResponse(
          text: 'Sí, dificultad para tragar líquidos',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['disfagia'],
        ),
        'fiebre': SymptomResponse(
          text: 'Tengo fiebre alta',
          addTags: ['amigdalitis_febril'],
          nextSymptomId: 'signos_alarma_final',
        ),
        'leve': SymptomResponse(
          text: 'No, solo dolor leve',
          addTags: ['faringitis_leve'],
          nextSymptomId: 'signos_alarma_final',
        ),
      },
    ),

    'urinary_problems': SymptomNode(
      id: 'urinary_problems',
      question: '¿Tiene fiebre o dolor en la espalda baja?',
      responses: {
        'fiebre_dolor': SymptomResponse(
          text: 'Sí, fiebre y dolor lumbar',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['pielonefritis_posible'],
        ),
        'sangre': SymptomResponse(
          text: 'Sí, sangre en la orina',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['hematuria'],
        ),
        'solo_dolor': SymptomResponse(
          text: 'Solo dolor al orinar',
          addTags: ['cistitis_posible'],
          nextSymptomId: 'signos_alarma_final',
        ),
      },
    ),

    // ========== PEDIÁTRICO ESPECÍFICO ==========
    'pediatric_behavior': SymptomNode(
      id: 'pediatric_behavior',
      question: '¿Cómo está el niño/lactante?',
      onlyForAgeGroups: [AgeGroup.infant, AgeGroup.child],
      responses: {
        'inconsolable': SymptomResponse(
          text: 'Llora inconsolablemente',
          immediateLevel: UrgencyLevel.red,
          addTags: ['llanto_inconsolable'],
        ),
        'decaido': SymptomResponse(
          text: 'Muy decaído, no reacciona',
          immediateLevel: UrgencyLevel.red,
          addTags: ['letargia'],
        ),
        'no_bebe': SymptomResponse(
          text: 'No quiere beber líquidos',
          immediateLevel: UrgencyLevel.yellow,
          addTags: ['rechazo_alimento'],
        ),
        'fontanela': SymptomResponse(
          text: 'Fontanela (mollera) hundida o abultada',
          immediateLevel: UrgencyLevel.red,
          addTags: ['alteracion_fontanela'],
        ),
        'irritable': SymptomResponse(
          text: 'Irritable pero responde',
          nextSymptomId: 'pediatric_fever',
        ),
        'normal': SymptomResponse(
          text: 'Relativamente normal',
          nextSymptomId: 'pediatric_fever',
        ),
      },
    ),

    'pediatric_fever': SymptomNode(
      id: 'pediatric_fever',
      question: '¿El niño tiene fiebre?',
      onlyForAgeGroups: [AgeGroup.infant, AgeGroup.child],
      responses: {
        'si_alta': SymptomResponse(
          text: 'Sí, más de 38.5°C',
          addTags: ['fiebre_pediatrica'],
          nextSymptomId: 'pediatric_fever_symptoms',
        ),
        'si_moderada': SymptomResponse(
          text: 'Sí, entre 37.5°C y 38.5°C',
          nextSymptomId: 'pediatric_fever_symptoms',
        ),
        'no': SymptomResponse(
          text: 'No tiene fiebre',
          nextSymptomId: 'signos_alarma_final',
        ),
      },
    ),

    'pediatric_fever_symptoms': SymptomNode(
      id: 'pediatric_fever_symptoms',
      question: '¿El niño tiene alguno de estos síntomas?',
      onlyForAgeGroups: [AgeGroup.infant, AgeGroup.child],
      isMultiSelect: true,
      responses: {
        'manchas': SymptomResponse(
          text: 'Manchas en la piel que no desaparecen al presionar',
          immediateLevel: UrgencyLevel.red,
          addTags: ['petequias_pediatricas'],
        ),
        'rigidez': SymptomResponse(
          text: 'Rigidez en el cuello',
          immediateLevel: UrgencyLevel.red,
          addTags: ['meningismo_pediatrico'],
        ),
        'dificultad_respirar': SymptomResponse(
          text: 'Dificultad para respirar',
          immediateLevel: UrgencyLevel.red,
          addTags: ['disnea_pediatrica'],
        ),
        'vomitos': SymptomResponse(
          text: 'Vómitos persistentes',
          addTags: ['vomitos_pediatricos'],
        ),
        'diarrea': SymptomResponse(
          text: 'Diarrea abundante',
          addTags: ['diarrea_pediatrica'],
        ),
        'ninguno': SymptomResponse(
          text: 'Ninguno de los anteriores',
          nextSymptomId: 'signos_alarma_final',
        ),
      },
      fallbackNodeId: 'signos_alarma_final',
    ),

    // ========== SIGNOS DE ALARMA FINALES ==========
    'signos_alarma_final': SymptomNode(
  id: 'signos_alarma_final',
  question: '¿Tiene alguno de estos signos de alarma?',
  isMultiSelect: true,
  responses: {
    'ninguno': SymptomResponse(  // PRIMERO
      text: 'Ninguno de los anteriores',
      // Finaliza el cuestionario
    ),
    'dolor_pecho': SymptomResponse(
      text: 'Dolor en el pecho intenso',
      addTags: ['signo_alarma_dolor_pecho'],
    ),
    // ... resto de opciones
    'otros': SymptomResponse(  // ÚLTIMO
      text: 'Otro signo de alarma',
      addTags: ['signo_alarma_otro'],
    ),
  },
  fallbackNodeId: null,
),
  };

// lib/triage_logic.dart - CORREGIDO (líneas específicas)

// ... (mantener todo lo anterior igual hasta el método getNode)

static SymptomNode? getNode(String id, {AgeGroup? ageGroup, String? gender}) {
  final node = _symptomNodes[id];
  if (node == null) return null;

  // 1. Verificar si el nodo es relevante para edad/género
  // Si ageGroup o gender son null, asumimos que el nodo es relevante
  if (ageGroup != null && gender != null && !node.isRelevantFor(ageGroup, gender)) {
    return null;
  }

  // 2. Filtrar respuestas por edad/género
  final filteredResponses = <String, SymptomResponse>{};
  
  node.responses.forEach((responseKey, response) {
    // Verificar si la respuesta es relevante
    if (ageGroup != null && gender != null && !response.isRelevantFor(ageGroup, gender)) {
      return;
    }
    
    // Verificar si lleva a un nodo que también sea relevante
    if (response.nextSymptomId != null) {
      final nextNode = _symptomNodes[response.nextSymptomId!];
      if (nextNode != null && 
          ageGroup != null && 
          gender != null && 
          !nextNode.isRelevantFor(ageGroup, gender)) {
        // Si el siguiente nodo no es relevante, usar nodo de fallback
        if (node.fallbackNodeId != null && _symptomNodes[node.fallbackNodeId!] != null) {
          filteredResponses[responseKey] = SymptomResponse(
            text: response.text,
            immediateLevel: response.immediateLevel,
            nextSymptomId: node.fallbackNodeId, // Usar fallback
            addTags: response.addTags,
            extraData: response.extraData,
            onlyForAgeGroups: response.onlyForAgeGroups,
            onlyForGenders: response.onlyForGenders,
          );
        }
        return;
      }
    }
    
    filteredResponses[responseKey] = response;
  });

  // 3. Si no hay respuestas después de filtrar
  if (filteredResponses.isEmpty) {
    // Si hay un nodo de fallback, usarlo
    if (node.fallbackNodeId != null) {
      // Pasar los parámetros si están disponibles
      if (ageGroup != null && gender != null) {
        return getNode(node.fallbackNodeId!, ageGroup: ageGroup, gender: gender);
      } else {
        return getNode(node.fallbackNodeId!);
      }
    }
    return null;
  }

  // 4. Retornar nodo con respuestas filtradas
  return SymptomNode(
    id: node.id,
    question: node.question,
    responses: filteredResponses,
    isMultiSelect: node.isMultiSelect,
    customWidget: node.customWidget,
    onlyForAgeGroups: node.onlyForAgeGroups,
    onlyForGenders: node.onlyForGenders,
    fallbackNodeId: node.fallbackNodeId,
  );
}

  static List<SymptomNode> getInitialNodes() {
    return [_symptomNodes['start']!];
  }
}

// 🧠 ALGORITMO DE DECISIÓN COMPLETO
class TriageDecision {
  static UrgencyLevel calculateUrgency({
    required AgeGroup ageGroup,
    required Map<String, String> responses,
    required List<String> tags,
  }) {
    debugPrint('=== CALCULO DE TRIAGE ===');
    debugPrint('Grupo edad: ${ageGroup.label}');
    debugPrint('Tags: $tags');
    debugPrint('Respuestas clave: $responses');

    // 1. EMERGENCIAS INMEDIATAS (ROJO)
    if (_isRedEmergency(responses, tags)) {
      debugPrint('→ Nivel: ROJO (Emergencia inmediata)');
      return UrgencyLevel.red;
    }

    // 2. URGENCIAS MODERADAS (AMARILLO)
    if (_isYellowUrgent(responses, tags, ageGroup)) {
      debugPrint('→ Nivel: AMARILLO (Urgencia moderada)');
      return UrgencyLevel.yellow;
    }

    // 3. URGENCIAS LEVES (VERDE)
    if (_isGreenMild(responses, tags)) {
      debugPrint('→ Nivel: VERDE (Urgencia leve)');
      return UrgencyLevel.green;
    }

    // 4. NO URGENTE (AZUL)
    debugPrint('→ Nivel: AZUL (No urgente)');
    return UrgencyLevel.blue;
  }

  static bool _isRedEmergency(Map<String, String> responses, List<String> tags) {
    final redTags = [
      'dolor_toracico_opresivo',
      'dolor_irradiado',
      'abdomen_quirurgico',
      'cefalea_peor_vida',
      'meningismo',
      'meningismo_pediatrico',
      'sintomas_visuales',
      'deficit_neurologico',
      'mal_estado_grave',
      'disnea_grave',
      'disnea_pediatrica',
      'hemoptisis',
      'asfixia',
      'trauma_craneal_grave',
      'hemorragia_activa',
      'hemorragia_masiva',
      'hemorragia_incontrolable',
      'hemorragia_arterial',
      'hemorragia_digestiva',
      'quemadura_extensa',
      'quemadura_zona_critica',
      'quemadura_especial',
      'petequias',
      'petequias_pediatricas',
      'llanto_inconsolable',
      'letargia',
      'alteracion_fontanela',
      'convulsion',
      'alteracion_conciencia',
      'vomitos_incontrolables',
      'obstruccion_intestinal',
      'deficit_motor',
      'afasia',
      'alteracion_visual',
      'rotura_bolsa',
      'obstruccion_vias_respiratorias',
      'signo_alarma_perdida_conciencia',
      'signo_alarma_convulsion',
    ];

    // Verificar tags de emergencia
    for (var tag in tags) {
      if (redTags.contains(tag)) {
        debugPrint('  ✓ Tag de emergencia: $tag');
        return true;
      }
    }

    // Verificar respuestas específicas de emergencia
    final emergencyResponses = [
      'respiratory_severity' == 'no_hablar',
      'trauma_severity' == 'si_perdida',
      'fever_state' == 'muy_mal',
      'bleeding_type' == 'abundante',
      'bleeding_type' == 'no_para',
      'bleeding_type' == 'arterial',
      'burn_type' == 'grande',
      'burn_type' == 'cara_manos',
      'burn_type' == 'electricidad',
      'pediatric_behavior' == 'inconsolable',
      'pediatric_behavior' == 'decaido',
      'pediatric_behavior' == 'fontanela',
    ];

    return emergencyResponses.any((condition) => condition);
  }

  static bool _isYellowUrgent(Map<String, String> responses, List<String> tags, AgeGroup ageGroup) {
    final yellowTags = [
      'abdomen_agudo',
      'mal_estado',
      'disnea_moderada',
      'fiebre_prolongada',
      'fiebre_alta',
      'fiebre_pediatrica',
      'trauma_craneal_moderado',
      'amnesia',
      'herida_profunda',
      'herida_grande',
      'herida_contaminada',
      'quemadura_2grado',
      'vomitos_frecuentes',
      'vomitos_pediatricos',
      'hemorragia_moderada',
      'ampollas',
      'rechazo_alimento',
      'cefalea_febril',
      'disnea_febril',
      'dolor_toracico_febril',
      'abdomen_agudo_febril',
      'exantema_febril',
      'dolor_severo',
      'colico',
      'tos_crupal',
      'disfagia',
      'pielonefritis_posible',
      'hematuria',
      'cistitis_posible',
      'embarazo_sangrado',
      'embarazo_dolor_abdominal',
      'amenaza_parto',
      'disminucion_movimientos',
      'diarrea_pediatrica',
      'amigdalitis_febril',
      // Signos de alarma
      'signo_alarma_dolor_pecho',
      'signo_alarma_disnea',
      'signo_alarma_debilidad',
      'signo_alarma_hemorragia',
      'signo_alarma_vomitos',
      'signo_alarma_fiebre',
      'signo_alarma_dolor',
      'signo_alarma_conciencia',
    ];

    // Verificar tags
    for (var tag in tags) {
      if (yellowTags.contains(tag)) {
        debugPrint('  ✓ Tag de urgencia moderada: $tag');
        return true;
      }
    }

    // Verificar respuestas específicas
    final yellowResponses = [
      responses['fever_state'] == 'decaido',
      responses['respiratory_severity'] == 'frases_cortas',
      responses['trauma_severity'] == 'confusion',
      responses['trauma_severity'] == 'amnesia',
      responses['wound_type'] == 'profunda',
      responses['burn_type'] == 'ampollas',
      responses['vomiting_frequency'] == 'muchas_veces',
      responses['bleeding_type'] == 'moderado',
      responses['pediatric_behavior'] == 'no_bebe',
      responses['dolor_abdomen'] == 'intenso_constante',
      responses['throat_problems'] == 'tragar',
      responses['urinary_problems'] == 'fiebre_dolor',
      responses['urinary_problems'] == 'sangre',
    ];

    if (yellowResponses.any((condition) => condition)) {
      return true;
    }

    // Reglas específicas por edad
    if (ageGroup == AgeGroup.infant || ageGroup == AgeGroup.child) {
      // Niños con fiebre alta o moderada
      if (tags.contains('fiebre_alta') || tags.contains('fiebre_moderada') || tags.contains('fiebre_pediatrica')) {
        return true;
      }
      
      // Niños con vómitos o diarrea
      if (responses.containsKey('vomiting_frequency') || 
          responses.containsKey('diarrhea_frequency') ||
          tags.contains('vomitos_pediatricos') ||
          tags.contains('diarrea_pediatrica')) {
        return true;
      }
    }

    // Si tiene 2 o más signos de alarma generales
    int alarmSigns = 0;
    for (var tag in tags) {
      if (tag.startsWith('signo_alarma_')) {
        alarmSigns++;
      }
    }
    if (alarmSigns >= 2) return true;

    return false;
  }

  static bool _isGreenMild(Map<String, String> responses, List<String> tags) {
    // Síntomas leves
    final greenTags = [
      'dolor_moderado',
      'dolor_leve',
      'fiebre_moderada',
      'dolor_pleuritico',
      'exantema_febril',
      'faringitis_leve',
      'cistitis_posible',
    ];

    for (var tag in tags) {
      if (greenTags.contains(tag)) {
        debugPrint('  ✓ Tag de urgencia leve: $tag');
        return true;
      }
    }

    // Síntomas sin complicaciones
    if (responses['fever_state'] == 'regular' || responses['fever_state'] == 'bien') {
      if (!tags.contains('fiebre_alta')) {
        return true;
      }
    }

    if (responses['dolor_intensidad'] == '1_4' || responses['dolor_intensidad'] == '5_7') {
      if (!tags.contains('dolor_severo') && !tags.any((t) => t.startsWith('signo_alarma_'))) {
        return true;
      }
    }

    final mildResponses = [
      responses['wound_type'] == 'pequena',
      responses['burn_type'] == 'leve',
      responses['vomiting_frequency'] == 'ocasional',
      responses['throat_problems'] == 'leve',
      responses['urinary_problems'] == 'solo_dolor',
    ];

    return mildResponses.any((condition) => condition);
  }
}


class ResultInfo {
  static Map<String, dynamic> getInfo(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.red:
        return {
          //'title': 'EMERGENCIA', // SOLO una vez
          'action': 'LLAMAR AL 112 INMEDIATAMENTE',
          'instructions': [
            '🚨 LLAME AL 112 AHORA MISMO',
            'No conduzca usted mismo al hospital',
            'Mantenga al paciente tranquilo y acostado',
            'Si hay sangrado, aplique presión directa con gasas o paño limpio',
            'Si deja de respirar, inicie RCP (30 compresiones + 2 respiraciones)',
            'No dé nada de comer, beber ni medicamentos',
            'Si es posible, tenga a mano: DNI, tarjeta sanitaria, medicación habitual',
          ],
          'examples': [
            'Dolor torácico con opresión o irradiación',
            'Dificultad respiratoria grave',
            'Pérdida de conocimiento o convulsión',
            'Sangrado abundante que no para',
            'Traumatismo craneal con pérdida de conciencia',
            'Dolor abdominal insoportable',
            'Quemaduras extensas o en cara/manos',
            'Signos de ictus (boca torcida, brazo caído)',
            'Lactante muy decaído o con fontanela abultada',
          ],
          'color': colorRed,
          'darkColor': colorRedDark,
        };
        
      case UrgencyLevel.yellow:
        return {
          //'title': 'URGENCIA MODERADA', // SOLO una vez
          'action': 'ACUDIR AL HOSPITAL EN LAS PRÓXIMAS 4-6 HORAS',
          'instructions': [
            '📍 Acuda al servicio de urgencias hospitalario',
            'Si no puede desplazarse, llame al 112 para transporte medicalizado',
            'No demore la consulta más de 4-6 horas',
            'Manténgase hidratado (sorbos pequeños de agua)',
            'No tome analgésicos fuertes sin valoración médica',
            'Si empeora, reevalúe y considere llamar al 112',
            'Lleve: DNI, tarjeta sanitaria, informes médicos relevantes',
          ],
          'examples': [
            'Fiebre alta con mal estado general',
            'Dolor abdominal intenso y constante',
            'Herida profunda que necesita sutura',
            'Quemadura con ampollas',
            'Vómitos o diarrea frecuentes',
            'Dificultad respiratoria moderada',
            'Traumatismo sin pérdida de conciencia pero con confusión',
            'Sangrado moderado pero controlado',
            'Niño que no bebe líquidos',
          ],
          'color': colorYellow,
          'darkColor': colorYellowDark,
        };
        
      case UrgencyLevel.green:
        return {
          //'title': 'URGENCIA LEVE', // SOLO una vez
          'action': 'CONSULTAR EN CENTRO DE SALUD O PAC',
          'instructions': [
            '🏥 Puede acudir a su centro de salud en horario de atención',
            'También puede ir a un PAC (Punto de Atención Continuada)',
            'Puede esperar algunas horas si los síntomas son estables',
            'Descanse y manténgase bien hidratado',
            'Puede tomar analgésicos comunes si no hay contraindicaciones',
            'Si aparece fiebre alta, dolor intenso o dificultad respiratoria, reevalúe',
            'Solicite cita previa si su centro lo requiere',
          ],
          'examples': [
            'Fiebre moderada sin complicaciones',
            'Dolor leve o moderado controlable',
            'Tos o resfriado común',
            'Diarrea o vómitos ocasionales',
            'Heridas superficiales pequeñas',
            'Erupciones cutáneas sin fiebre',
            'Dolor de garganta u oído',
            'Esguinces leves',
            'Controles de enfermedades crónicas estables',
          ],
          'color': colorGreen,
          'darkColor': colorGreenDark,
        };
        
      case UrgencyLevel.blue:
        return {
          //'title': 'NO URGENTE', // SOLO una vez
          'action': 'PEDIR CITA CON SU MÉDICO DE CABECERA',
          'instructions': [
            '📅 Solicite cita programada con su médico',
            'No necesita acudir a servicios de urgencias',
            'Siga medidas de autocuidado según sus síntomas',
            'Mantenga un diario de síntomas si son crónicos',
            'Si aparecen signos de alarma, reevalúe con este cuestionario',
            'Para dudas no urgentes, consulte a su farmacéutico',
            'Utilice los servicios de atención telefónica de su centro de salud',
          ],
          'examples': [
            'Molestias leves crónicas (más de 7 días)',
            'Controles rutinarios de tensión, diabetes, etc.',
            'Certificados médicos',
            'Renovación de recetas',
            'Resfriado común sin complicaciones',
            'Dolores musculares leves',
            'Problemas dermatológicos no urgentes',
            'Consulta por resultados de pruebas',
            'Seguimiento de tratamientos crónicos',
          ],
          'color': colorBlue,
          'darkColor': colorBlueDark,
        };
    }
  }
}