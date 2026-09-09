import 'package:flutter/material.dart';

import 'constants.dart';

enum SelectionMode {
  single,
  multiple,
}

enum RuleOperator {
  anySelected,
  allSelected,
  noneSelected,
  answered,
  notAnswered,
}

enum TriageLevel {
  red,
  yellow,
  green,
  blue,
}

class AnswerSheet {
  final Map<String, Set<String>> _answers;

  AnswerSheet([Map<String, Set<String>>? seed])
      : _answers = {
          if (seed != null)
            ...seed.map((key, value) => MapEntry(key, Set<String>.from(value))),
        };

  Iterable<String> get questionIds => _answers.keys;

  Set<String> optionsFor(String questionId) {
    return _answers[questionId] ?? const <String>{};
  }

  bool hasAnswer(String questionId) {
    return _answers[questionId]?.isNotEmpty ?? false;
  }

  bool isSelected(String questionId, String optionId) {
    return _answers[questionId]?.contains(optionId) ?? false;
  }

  void setSingle(String questionId, String optionId) {
    _answers[questionId] = {optionId};
  }

  void toggleMulti(String questionId, String optionId) {
    final values = _answers.putIfAbsent(questionId, () => <String>{});
    if (values.contains(optionId)) {
      values.remove(optionId);
    } else {
      values.add(optionId);
    }
    if (values.isEmpty) {
      _answers.remove(questionId);
    }
  }

  void removeOption(String questionId, String optionId) {
    final values = _answers[questionId];
    if (values == null) return;
    values.remove(optionId);
    if (values.isEmpty) {
      _answers.remove(questionId);
    }
  }

  void clear(String questionId) {
    _answers.remove(questionId);
  }
}

class Rule {
  final String questionId;
  final RuleOperator operator;
  final Set<String> optionIds;

  const Rule({
    required this.questionId,
    required this.operator,
    this.optionIds = const <String>{},
  });

  bool evaluate(AnswerSheet answers) {
    final selected = answers.optionsFor(questionId);

    switch (operator) {
      case RuleOperator.anySelected:
        if (optionIds.isEmpty) {
          return selected.isNotEmpty;
        }
        return optionIds.any(selected.contains);
      case RuleOperator.allSelected:
        if (optionIds.isEmpty) {
          return false;
        }
        return optionIds.every(selected.contains);
      case RuleOperator.noneSelected:
        return optionIds.every((id) => !selected.contains(id));
      case RuleOperator.answered:
        return selected.isNotEmpty;
      case RuleOperator.notAnswered:
        return selected.isEmpty;
    }
  }
}

class Condition {
  final List<Rule> all;
  final List<Rule> any;

  const Condition({
    this.all = const <Rule>[],
    this.any = const <Rule>[],
  });

  static const always = Condition();

  bool evaluate(AnswerSheet answers) {
    final allPass = all.every((rule) => rule.evaluate(answers));
    final anyPass = any.isEmpty || any.any((rule) => rule.evaluate(answers));
    return allPass && anyPass;
  }
}

class Option {
  final String id;
  final String label;
  final List<String> tags;
  final Condition visibility;

  const Option({
    required this.id,
    required this.label,
    this.tags = const <String>[],
    this.visibility = Condition.always,
  });
}

class Question {
  final String id;
  final String title;
  final String? helperText;
  final SelectionMode selectionMode;
  final bool required;
  final List<Option> options;
  final Condition visibility;

  const Question({
    required this.id,
    required this.title,
    this.helperText,
    this.selectionMode = SelectionMode.single,
    this.required = true,
    required this.options,
    this.visibility = Condition.always,
  });
}

class QuestionGroup {
  final String id;
  final String title;
  final String? helperText;
  final List<Question> questions;
  final Condition visibility;

  const QuestionGroup({
    required this.id,
    required this.title,
    this.helperText,
    required this.questions,
    this.visibility = Condition.always,
  });
}

class PageStep {
  final String id;
  final String title;
  final String subtitle;
  final List<QuestionGroup> groups;
  final bool isResultStep;
  final Condition visibility;

  const PageStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.groups,
    this.isResultStep = false,
    this.visibility = Condition.always,
  });
}

class TriageRule {
  final String id;
  final TriageLevel level;
  final String description;
  final Condition when;

  const TriageRule({
    required this.id,
    required this.level,
    required this.description,
    required this.when,
  });
}

class TriageResult {
  final TriageLevel level;
  final String title;
  final String recommendation;
  final List<String> instructions;
  final List<String> matchedCriteria;
  final String legalDisclaimer;

  const TriageResult({
    required this.level,
    required this.title,
    required this.recommendation,
    required this.instructions,
    required this.matchedCriteria,
    required this.legalDisclaimer,
  });

  String get levelLabel {
    switch (level) {
      case TriageLevel.red:
        return 'ROJO';
      case TriageLevel.yellow:
        return 'AMARILLO';
      case TriageLevel.green:
        return 'VERDE';
      case TriageLevel.blue:
        return 'AZUL';
    }
  }

  IconData get icon {
    switch (level) {
      case TriageLevel.red:
        return Icons.emergency;
      case TriageLevel.yellow:
        return Icons.local_hospital;
      case TriageLevel.green:
        return Icons.medical_information;
      case TriageLevel.blue:
        return Icons.calendar_today;
    }
  }

  Color get frontColor {
    switch (level) {
      case TriageLevel.red:
        return colorRed;
      case TriageLevel.yellow:
        return colorYellow;
      case TriageLevel.green:
        return colorGreen;
      case TriageLevel.blue:
        return colorBlue;
    }
  }

  Color get backColor {
    switch (level) {
      case TriageLevel.red:
        return colorRedDark;
      case TriageLevel.yellow:
        return colorYellowDark;
      case TriageLevel.green:
        return colorGreenDark;
      case TriageLevel.blue:
        return colorBlueDark;
    }
  }

  Color get titleColor {
    switch (level) {
      case TriageLevel.yellow:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }
}
