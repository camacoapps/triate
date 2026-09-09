enum TriageContentMode {
  colloquial,
  technical,
}

extension TriageContentModeX on TriageContentMode {
  String get label {
    switch (this) {
      case TriageContentMode.colloquial:
        return 'Coloquial';
      case TriageContentMode.technical:
        return 'Técnico';
    }
  }

  String get description {
    switch (this) {
      case TriageContentMode.colloquial:
        return 'Lenguaje sencillo para pacientes.';
      case TriageContentMode.technical:
        return 'Lenguaje clínico o científico.';
    }
  }
}
