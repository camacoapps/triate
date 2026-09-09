// lib/symptom_paths.dart
import 'triage_logic.dart';

class SymptomPaths {
  static Map<String, String> getNextNode({
    required String currentNodeId,
    required String responseKey,
    required AgeGroup? ageGroup,
    required String? gender,
  }) {
    // Mapeo de caminos lógicos
    final paths = {
      // DOLOR - camino general
      'dolor_caracteristicas': 'dolor_frecuencia',
      'dolor_frecuencia': 'sintomas_asociados_generales',
      'dolor_pecho_caracteristicas': 'dolor_pecho_duracion',
      'dolor_pecho_duracion': 'sintomas_asociados_generales',
      
      // FIEBRE
      'fever_symptoms': 'signos_alarma_final',
      'fever_state': 'fever_symptoms',
      
      // Síntomas asociados
      'sintomas_asociados_generales': 'signos_alarma_final',
    };
    
    return paths;
  }
  
  static String? getFallbackNode(String nodeId) {
    final fallbacks = {
      'dolor_caracteristicas': 'dolor_frecuencia',
      'sintomas_asociados_generales': 'signos_alarma_final',
      'fever_symptoms': 'signos_alarma_final',
    };
    
    return fallbacks[nodeId];
  }
}