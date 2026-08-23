import 'package:flutter/material.dart';

/// One selectable interest in the caregiver-managed profile.
class InterestOption {
  const InterestOption({
    required this.id,
    required this.labelEn,
    required this.labelUr,
    required this.icon,
  });

  final String id;
  final String labelEn;
  final String labelUr;
  final IconData icon;

  String labelFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? labelUr : labelEn;
}

/// Fixed catalog; path order always follows this list, never the order
/// interests were picked in, so paths are fully deterministic.
const List<InterestOption> interestCatalog = [
  InterestOption(
    id: 'cars',
    labelEn: 'Cars',
    labelUr: 'گاڑیاں',
    icon: Icons.directions_car_outlined,
  ),
  InterestOption(
    id: 'animals',
    labelEn: 'Animals',
    labelUr: 'جانور',
    icon: Icons.pets_outlined,
  ),
  InterestOption(
    id: 'trains',
    labelEn: 'Trains',
    labelUr: 'ریل گاڑیاں',
    icon: Icons.train_outlined,
  ),
  InterestOption(
    id: 'space',
    labelEn: 'Space',
    labelUr: 'خلا',
    icon: Icons.rocket_launch_outlined,
  ),
];

/// A mapped topic sitting between interests and activities.
class LearningTopic {
  const LearningTopic({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.icon,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final IconData icon;

  String titleFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? titleUr : titleEn;
}

const Map<String, LearningTopic> learningTopics = {
  'things-that-go': LearningTopic(
    id: 'things-that-go',
    titleEn: 'Things that go',
    titleUr: 'چیزیں جو چلتی ہیں',
    icon: Icons.commute_outlined,
  ),
  'animal-friends': LearningTopic(
    id: 'animal-friends',
    titleEn: 'Animal friends',
    titleUr: 'جانور دوست',
    icon: Icons.pets_outlined,
  ),
  'train-journeys': LearningTopic(
    id: 'train-journeys',
    titleEn: 'Train journeys',
    titleUr: 'ریل کے سفر',
    icon: Icons.tram_outlined,
  ),
  'space-exploration': LearningTopic(
    id: 'space-exploration',
    titleEn: 'Space exploration',
    titleUr: 'خلا کی سیر',
    icon: Icons.public_outlined,
  ),
};

/// Deterministic interest → topic table. Topics may be shared by more
/// than one interest; the builder de-duplicates activities.
const Map<String, List<String>> interestTopicMap = {
  'cars': ['things-that-go'],
  'animals': ['animal-friends'],
  'trains': ['things-that-go', 'train-journeys'],
  'space': ['space-exploration'],
};

/// One fixed comprehension question inside an activity.
class QuizQuestion {
  const QuizQuestion({
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

  String promptFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? promptUr : promptEn;

  String optionFor(Locale? locale, int index) =>
      locale?.languageCode == 'ur' ? optionsUr[index] : optionsEn[index];
}

/// An authored, bilingual themed activity (a tiny quiz).
class LearningActivity {
  const LearningActivity({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.icon,
    required this.questions,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final IconData icon;
  final List<QuizQuestion> questions;

  String titleFor(Locale? locale) =>
      locale?.languageCode == 'ur' ? titleUr : titleEn;
}

const Map<String, List<LearningActivity>> topicActivities = {
  'things-that-go': [
    LearningActivity(
      id: 'wheels-count',
      titleEn: 'Count the wheels',
      titleUr: 'پہیے گنیں',
      icon: Icons.album_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'How many wheels does a bicycle have?',
          promptUr: 'سائیکل کے کتنے پہیے ہوتے ہیں؟',
          optionsEn: ['Two', 'Four', 'Ten'],
          optionsUr: ['دو', 'چار', 'دس'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'How many wheels does a car have?',
          promptUr: 'کار کے کتنے پہیے ہوتے ہیں؟',
          optionsEn: ['Three', 'Four', 'One'],
          optionsUr: ['تین', 'چار', 'ایک'],
          correctIndex: 1,
        ),
      ],
    ),
    LearningActivity(
      id: 'go-and-stop',
      titleEn: 'Go and stop',
      titleUr: 'چلو اور رکو',
      icon: Icons.traffic_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'What does a red traffic light mean?',
          promptUr: 'سرخ ٹریفک بتی کا کیا مطلب ہے؟',
          optionsEn: ['Stop', 'Go fast', 'Sleep'],
          optionsUr: ['رکیں', 'تیز چلیں', 'سویں'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'What does a green traffic light mean?',
          promptUr: 'سبز ٹریفک بتی کا کیا مطلب ہے؟',
          optionsEn: ['Stop', 'Go', 'Turn around'],
          optionsUr: ['رکیں', 'چلیں', 'پیچھے مڑیں'],
          correctIndex: 1,
        ),
      ],
    ),
  ],
  'animal-friends': [
    LearningActivity(
      id: 'animal-sounds',
      titleEn: 'Animal sounds',
      titleUr: 'جانوروں کی آوازیں',
      icon: Icons.campaign_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'Which animal says "meow"?',
          promptUr: 'کون سا جانور «میاؤں» کرتا ہے؟',
          optionsEn: ['Cat', 'Dog', 'Duck'],
          optionsUr: ['بلی', 'کتا', 'بطخ'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'Which animal says "moo"?',
          promptUr: 'کون سا جانور «موو» کرتا ہے؟',
          optionsEn: ['Cow', 'Hen', 'Lion'],
          optionsUr: ['گائے', 'مرغی', 'شیر'],
          correctIndex: 0,
        ),
      ],
    ),
    LearningActivity(
      id: 'animal-food',
      titleEn: 'Animal food',
      titleUr: 'جانوروں کی خوراک',
      icon: Icons.grass_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'What does a rabbit love to eat?',
          promptUr: 'خرگوش کو کیا کھانا پسند ہے؟',
          optionsEn: ['Carrots', 'Fish', 'Bread'],
          optionsUr: ['گاجر', 'مچھلی', 'روٹی'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'Which animal eats grass?',
          promptUr: 'کون سا جانور گھاس کھاتا ہے؟',
          optionsEn: ['Goat', 'Cat', 'Eagle'],
          optionsUr: ['بکرا', 'بلی', 'عقاب'],
          correctIndex: 0,
        ),
      ],
    ),
  ],
  'train-journeys': [
    LearningActivity(
      id: 'train-stations',
      titleEn: 'At the station',
      titleUr: 'اسٹیشن پر',
      icon: Icons.directions_railway_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'Where does a train stop to pick people?',
          promptUr: 'ریل گاڑی لوگوں کو لینے کہاں رکتی ہے؟',
          optionsEn: ['Station', 'Kitchen', 'Park'],
          optionsUr: ['اسٹیشن', 'باورچی خانہ', 'پارک'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'What runs on the tracks?',
          promptUr: 'پٹریوں پر کیا چلتا ہے؟',
          optionsEn: ['A train', 'A cat', 'A boat'],
          optionsUr: ['ریل گاڑی', 'بلی', 'کشتی'],
          correctIndex: 0,
        ),
      ],
    ),
  ],
  'space-exploration': [
    LearningActivity(
      id: 'planets-order',
      titleEn: 'Our sky',
      titleUr: 'ہمارا آسمان',
      icon: Icons.star_border_outlined,
      questions: [
        QuizQuestion(
          promptEn: 'What shines in the sky at night?',
          promptUr: 'رات کے آسمان میں کیا چمکتا ہے؟',
          optionsEn: ['Stars', 'Cars', 'Chairs'],
          optionsUr: ['ستارے', 'گاڑیاں', 'کرسیاں'],
          correctIndex: 0,
        ),
        QuizQuestion(
          promptEn: 'Where do astronauts travel?',
          promptUr: 'خلاباز کہاں سفر کرتے ہیں؟',
          optionsEn: ['To space', 'To school', 'To bed'],
          optionsUr: ['خلا میں', 'اسکول', 'بستر تک'],
          correctIndex: 0,
        ),
      ],
    ),
  ],
};

/// One stop on the child's learning path, remembering why it was chosen.
class LearningPathEntry {
  const LearningPathEntry({
    required this.activity,
    required this.viaInterestId,
    required this.viaTopicId,
  });

  final LearningActivity activity;
  final String viaInterestId;
  final String viaTopicId;
}

/// Pure deterministic builder: catalog-ordered interests → their topics →
/// each topic's activities, de-duplicated by activity id.
List<LearningPathEntry> buildLearningPath(Iterable<String> selectedIds) {
  final selected = selectedIds.toSet();
  final entries = <LearningPathEntry>[];
  final seen = <String>{};
  for (final interest in interestCatalog) {
    if (!selected.contains(interest.id)) continue;
    for (final topicId in interestTopicMap[interest.id] ?? const <String>[]) {
      for (final activity in topicActivities[topicId] ?? const <LearningActivity>[]) {
        if (seen.add(activity.id)) {
          entries.add(
            LearningPathEntry(
              activity: activity,
              viaInterestId: interest.id,
              viaTopicId: topicId,
            ),
          );
        }
      }
    }
  }
  return entries;
}
