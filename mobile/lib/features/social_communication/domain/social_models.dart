import 'package:flutter/material.dart';

/// Authored, fixed social-communication content.
///
/// Everything here is caregiver-approved static material: no generative
/// chat, no open-ended inference, per the project safety constraints.

/// One illustrated page of a [SocialStory].
class StoryPage {
  const StoryPage({
    required this.textEn,
    required this.textUr,
    required this.icon,
  });

  final String textEn;
  final String textUr;
  final IconData icon;
}

class ComprehensionQuestion {
  const ComprehensionQuestion({
    required this.promptEn,
    required this.promptUr,
    required this.optionsEn,
    required this.optionsUr,
    required this.correctIndex,
  });

  final String promptEn;
  final String promptUr;
  final List<String> optionsEn;
  final List<String> optionsUr;
  final int correctIndex;

  bool isCorrect(int index) => index == correctIndex;
}

class SocialStory {
  const SocialStory({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.pages,
    required this.questions,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final List<StoryPage> pages;
  final List<ComprehensionQuestion> questions;
}

/// A single branching point in a conversation script.
class ConversationStep {
  const ConversationStep({
    required this.id,
    required this.partnerLineEn,
    required this.partnerLineUr,
    required this.options,
  });

  final String id;

  /// What the practice partner (played by the app) says or asks.
  final String partnerLineEn;
  final String partnerLineUr;

  /// The child's possible replies; every option must lead somewhere.
  final List<ConversationOption> options;
}

class ConversationOption {
  const ConversationOption({
    required this.replyEn,
    required this.replyUr,
    required this.nextStepId,
    this.encouraging = true,
  });

  final String replyEn;
  final String replyUr;

  /// `'next'` continues the script; any other id names the next step.
  final String nextStepId;

  /// Safe-but-unexpected replies stay encouraging and ask to try again;
  /// only clearly fitting replies advance the script.
  final bool encouraging;
}

class ConversationScript {
  const ConversationScript({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.steps,
    required this.startStepId,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final List<ConversationStep> steps;
  final String startStepId;

  ConversationStep? stepById(String id) {
    for (final step in steps) {
      if (step.id == id) return step;
    }
    return null;
  }
}
