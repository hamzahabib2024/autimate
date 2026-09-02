// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get navHome => 'ہوم';

  @override
  String get navCommunicate => 'بات کریں';

  @override
  String get navRoutine => 'روٹین';

  @override
  String get navProgress => 'پیش رفت';

  @override
  String get settingsTooltip => 'ترتیبات';

  @override
  String get homeGreeting => 'صبح بخیر، نگہبان';

  @override
  String get homeTagline => 'بات چیت، سیکھنے اور مشق کے لیے ایک پُرسکون جگہ۔';

  @override
  String get homeToday => 'آج';

  @override
  String get emotionPracticeTileTitle => 'جذبات کی مشق';

  @override
  String get emotionPracticeTileSubtitle => 'چھ روزمرہ اظہارات سیکھیں';

  @override
  String get socialStoriesTileTitle => 'سماجی کہانیاں';

  @override
  String get socialStoriesTileSubtitle => 'کہانیاں اور بات چیت کی مشق';

  @override
  String get tabStories => 'کہانیاں';

  @override
  String get tabConversations => 'بات چیت کی مشق';

  @override
  String get narrateTooltip => 'بلند آواز میں پڑھیں';

  @override
  String get nextPageTooltip => 'اگلا صفحہ';

  @override
  String get previousPageTooltip => 'پچھلا صفحہ';

  @override
  String get comprehensionTitle => 'آئیے سمجھ جانچیں';

  @override
  String get conversationComplete => 'آپ نے بات چیت مکمل کر لی! ایک ستارہ ملا۔';

  @override
  String get conversationHint => 'ایک صورتحال منتخب کریں اور موزوں جواب چنیں۔';

  @override
  String get gentleRetry => 'کوئی بات نہیں، آئیے دوسرا طریقہ آزمائیں۔';

  @override
  String storyPagesCount(int count) {
    return '$count صفحات';
  }

  @override
  String get learningPathTileTitle => 'سیکھنے کا راستہ';

  @override
  String get learningPathTileSubtitle => 'دلچسپی پر مبنی سرگرمیاں آنے والی ہیں';

  @override
  String get beginnerSupportLevel => 'ابتدائی سطح کی معاونت';

  @override
  String starsEarned(int count) {
    return '$count ستارے ملے';
  }

  @override
  String get comingNextPhase => 'اگلے مرحلے میں';

  @override
  String get safeByDesign => 'ڈیزائن سے محفوظ';

  @override
  String get safeByDesignMessage =>
      'یہ ماڈیول نگہبان کی منظور شدہ مواد استعمال کرے گا۔ بچوں کے لیے کھلی چیٹ شامل نہیں ہے۔';

  @override
  String get interestLearningDescription =>
      'دلچسپی سے موضوع کی طے شدہ نشاندہی اس راستے کو چلائے گی۔';

  @override
  String get socialStoriesDescription =>
      'مختصر مصور کہانیاں اور سمجھ جانچ یہاں ہوں گی۔';

  @override
  String get communicateTitle => 'بات کریں';

  @override
  String get speakSentenceTooltip => 'جملہ بولیں';

  @override
  String get sentenceHeader => 'جملہ';

  @override
  String get tapCardToBuild => 'جملہ بنانے کے لیے کارڈ دبائیں';

  @override
  String get clearSentenceTooltip => 'جملہ صاف کریں';

  @override
  String get frequentlyUsed => 'زیادہ استعمال ہونے والے';

  @override
  String get recentCardsHint => 'آپ کے حالیہ کارڈ یہاں نظر آئیں گے۔';

  @override
  String get coreWords => 'بنیادی الفاظ';

  @override
  String get allCategories => 'سب';

  @override
  String get aacCategoryFood => 'کھانا';

  @override
  String get aacCategoryDrinks => 'مشروبات';

  @override
  String get aacCategoryEmotions => 'جذبات';

  @override
  String get aacCategoryActivities => 'سرگرمیاں';

  @override
  String get aacCategoryPeople => 'لوگ';

  @override
  String get aacCategoryPlaces => 'جگہیں';

  @override
  String get aacCategoryNeeds => 'ضرورتیں';

  @override
  String get aacCategoryObjects => 'چیزیں';

  @override
  String get removeLastWordTooltip => 'آخری لفظ ہٹائیں';

  @override
  String get emotionPracticeTitle => 'جذبات کی مشق';

  @override
  String get sessionComplete => 'سیشن مکمل';

  @override
  String sessionSummary(int score, int total, int stars) {
    return '$total میں سے $score درست • $stars ستارے ملے';
  }

  @override
  String get practiseAgain => 'دوبارہ مشق کریں';

  @override
  String questionProgress(int index, int total) {
    return 'سوال $total میں سے $index';
  }

  @override
  String whichFaceFeels(String emotion) {
    return 'کون سا چہرہ $emotion محسوس کرتا ہے؟';
  }

  @override
  String get emotionHappy => 'خوش';

  @override
  String get emotionSad => 'اداس';

  @override
  String get emotionAngry => 'غصہ';

  @override
  String get emotionSurprised => 'حیران';

  @override
  String get emotionScared => 'خوفزدہ';

  @override
  String get emotionNeutral => 'عام';

  @override
  String get beginnerHint =>
      'اشارہ: چہرے کو دیکھیں اور ملنے والا احساس منتخب کریں۔';

  @override
  String get answerCorrect => 'یہ درست ہے۔';

  @override
  String get answerIncorrect => 'آئیے اگلا آزماتے ہیں۔';

  @override
  String get cameraPracticeTitle => 'کیمرہ اظہار مشق';

  @override
  String get cameraPracticeMessage =>
      'آلے پر مسکراہٹ کی شناخت کا منطق مکمل ہے؛ ML Kit کیمرہ ایڈاپٹر فزیکل ویریفیکیشن کے بعد آئے گا۔ ابھی سمیولیٹڈ ڈیمو دستیاب ہے۔';

  @override
  String get expressionTitle => 'اظہار کی مشق';

  @override
  String get expressionStart => 'مشق شروع کریں';

  @override
  String get expressionHoldSmile => 'ایک سیکنڈ تک بڑی مسکراہٹ رکھیں';

  @override
  String get expressionUnsupported => 'اس آلے پر اظہار کی مشق دستیاب نہیں ہے۔';

  @override
  String get expressionPermissionDenied =>
      'کیمرے کی اجازت درکار ہے۔ نگہبان آلے کی ترتیبات سے اجازت دے سکتے ہیں۔';

  @override
  String get expressionLoadingCamera => 'کیمرہ شروع ہو رہا ہے...';

  @override
  String get expressionCameraError =>
      'کیمرے میں کوئی خرابی پیش آئی۔ دوبارہ کوشش کریں۔';

  @override
  String expressionSmileProgress(int done, int total) {
    return '$total میں سے $done مسکراہٹیں مکمل';
  }

  @override
  String expressionSessionComplete(int stars) {
    return 'شاباش! $stars ستارے ملے';
  }

  @override
  String get expressionPrivacyTitle => 'ڈیزائن سے نجی';

  @override
  String get expressionPrivacyNote =>
      'فریمز اس آلے کی یادداشت میں رہتے ہیں اور کبھی محفوظ یا اپ لوڈ نہیں ہوتے۔ صرف ستاروں کا مجموعہ ریکارڈ ہوتا ہے۔';

  @override
  String get expressionRationaleTitle => 'کیمرہ کیوں؟';

  @override
  String get expressionRationaleBody =>
      'کیمرا آپ کی مسکراہٹ دیکھ کر ستارے دیتا ہے۔ فریم اسی ڈیوائس پر رہتے ہیں اور کبھی محفوظ یا اپ لوڈ نہیں کیے جاتے۔';

  @override
  String get expressionAllowCamera => 'کیمرے کی اجازت دیں';

  @override
  String get expressionNotNow => 'ابھی نہیں';

  @override
  String get expressionComeCloserHint => 'کیمرے کے قریب آئیں';

  @override
  String get expressionEyesHint => 'آنکھیں کھولنے کی کوشش کریں';

  @override
  String get expressionLookStraightHint => 'کیمرے کی طرف سیدھا دیکھیں';

  @override
  String get routineEditTooltip => 'روٹین ترتیب دیں';

  @override
  String get routineEditorTitle => 'روٹین ایڈیٹر';

  @override
  String get routineAddStep => 'نیا مرحلہ شامل کریں';

  @override
  String get stepTitleEnLabel => 'عنوان (انگریزی)';

  @override
  String get stepTitleUrLabel => 'عنوان (اردو)';

  @override
  String get stepCueEnLabel => 'بولنے کا جملہ (انگریزی، اختیاری)';

  @override
  String get stepCueUrLabel => 'بولنے کا جملہ (اردو، اختیاری)';

  @override
  String get stepTimeLabel => 'وقت';

  @override
  String get stepIconLabel => 'علامت';

  @override
  String get leadMinutesLabel => 'ہر مرحلے سے کتنے منٹ پہلے اطلاع دیں';

  @override
  String countdownWarning(int minutes, String title) {
    return '$minutes منٹ باقی ہیں: $title';
  }

  @override
  String get flexibilityTitle => 'دوستانہ تبدیلیاں';

  @override
  String get flexibilityExplanation =>
      'آج کے کسی معروف مرحلے میں ایک چھوٹی منصوبہ بند تبدیلی ڈالیں تاکہ بچہ حیرانی سنبھالنے کی مشق کرے۔';

  @override
  String get flexibilityPickStep => 'تبدیلی کا مرحلہ';

  @override
  String get flexibilityNewLabelEn => 'نیا عنوان (انگریزی، اختیاری)';

  @override
  String get flexibilityNewLabelUr => 'نیا عنوان (اردو، اختیاری)';

  @override
  String get flexibilityApply => 'آج کی تبدیلی مقرر کریں';

  @override
  String get flexibilityClear => 'منصوبہ بند تبدیلی ہٹائیں';

  @override
  String get flexibilityPlannedToday => 'آج ایک دوستانہ تبدیلی مقرر ہے۔';

  @override
  String get flexibilityBadge => 'منصوبہ بند تبدیلی';

  @override
  String get flexibilityWellDone => 'تبدیلیاں مزے دار ہو سکتی ہیں! شاباش۔';

  @override
  String get routineDeleteStepTitle => 'کیا یہ مرحلہ ہٹا دیں؟';

  @override
  String routineDeleteStepBody(String title) {
    return '«$title» روزانہ کی روٹین میں اب نہیں دکھے گا۔';
  }

  @override
  String get deleteAction => 'ہٹائیں';

  @override
  String get learningEditorTitle => 'دلچسپیاں';

  @override
  String get learningPickHint =>
      'وہ چنیں جو آپ کا بچہ پسند کرتا ہے۔ سیکھنے کا راستہ اسی مطابق بدلے گا۔';

  @override
  String learningWhy(String name, String interest) {
    return '$name کو $interest پسند ہیں';
  }

  @override
  String get learningPathEmptyHint =>
      'سرگرمیاں دکھانے کے لیے چند دلچسپیاں منتخب کریں۔';

  @override
  String learningQuestionProgress(int done, int total) {
    return 'سوال $total میں سے $done';
  }

  @override
  String get breathingTitle => 'میرے ساتھ سانس لو';

  @override
  String get breatheIn => 'سانس اندر';

  @override
  String get breatheHold => 'روکے رکھیں';

  @override
  String get breatheOut => 'سانس باہر';

  @override
  String get breathingStart => 'شروع کریں';

  @override
  String get breathingStop => 'آرام';

  @override
  String get sensoryBreathingSubtitle => 'پرسکون سانس کے لیے آہستہ گولائی۔';

  @override
  String get calmingTitle => 'پرسکون جگہ';

  @override
  String get calmingHint =>
      'نرم شکلیں آہستہ تیرتی ہیں۔ یہاں کچھ کرنا ضروری نہیں۔';

  @override
  String get calmSoundOn => 'نرم آواز آن';

  @override
  String get calmSoundOff => 'نرم آواز بند';

  @override
  String get sensoryCalmingSubtitle =>
      'آنکھوں کو ٹھیک رکھنے کے لیے آہستہ ہلکے نقشے۔';

  @override
  String get emotionTrendTitle => 'جذبات کی درستگی، گزشتہ ۷ دن';

  @override
  String emotionTrendLatest(String percent) {
    return '$percent تازہ ترین';
  }

  @override
  String get noEmotionDataYet =>
      'گزشتہ ۷ دنوں میں ابھی کوئی جذباتی سرگرمی نہیں ہوئی۔';

  @override
  String get observationTagLabel => 'قسم';

  @override
  String get tagGeneral => 'عمومی';

  @override
  String get tagMood => 'مزاج';

  @override
  String get tagBehaviour => 'رویہ';

  @override
  String get tagSensory => 'حسی';

  @override
  String get tagCommunication => 'رابطہ';

  @override
  String get editProfileTitle => 'پروفائل میں ترمیم';

  @override
  String levelPickerForChild(String name) {
    return '$name کے لیے معاونت کی سطح';
  }

  @override
  String get levelAutomaticTitle => 'پیش رفت کے مطابق خودکار';

  @override
  String get levelAutomaticSubtitle =>
      'پروفائل کی سطح سے آغاز؛ مسلسل تین درست جوابات سے سطح بڑھے گی اور دو غلط جوابات سے گھٹے گی۔';

  @override
  String get levelLockTitle => 'اس سطح کو مقفل کریں';

  @override
  String get levelLockSubtitle => 'خودکار اضافے یا کمی کو روک دیتا ہے۔';

  @override
  String levelLockedNotice(Object level) {
    return 'مقفل — $level ایک ہی رہے گی۔';
  }

  @override
  String levelChangedPrompt(String level) {
    return 'معاونت $level ہو گئی۔ نئی سطح پر دوبارہ شروع کریں؟';
  }

  @override
  String get levelRestartAction => 'نئی سطح سے شروع کریں';

  @override
  String get levelContinueAction => 'آگے جاری رکھیں';

  @override
  String get rewardCadenceEverySession => 'ہر مکمل سیشن کے بعد ایک ستارہ۔';

  @override
  String rewardCadenceEveryN(int sessions) {
    return '$sessions مکمل سیشنز کے بعد ایک ستارہ۔';
  }

  @override
  String get coopTitle => 'ہم ایک ٹیم ہیں';

  @override
  String coopSubtitle(String name) {
    return '$name اور آپ، ہر کامیابی ساتھ ملی۔';
  }

  @override
  String streakDays(int count) {
    return '$count دن مسلسل';
  }

  @override
  String get badgesSectionTitle => 'سنگِ میل';

  @override
  String progressOf(int done, int total) {
    return '$total میں سے $done';
  }

  @override
  String get allBadgesEarned => 'ہر سنگِ میل حاصل — شاندار ٹیم ورک!';

  @override
  String get routineTitle => 'روٹین';

  @override
  String get oneStepAtATime => 'ایک وقت میں ایک قدم';

  @override
  String get routineProgressLabel => 'روٹین کی پیش رفت';

  @override
  String stepsDone(int done, int total) {
    return '$total میں سے $done مراحل مکمل';
  }

  @override
  String get transitionWarnings => 'تبدیلی کی اطلاع';

  @override
  String get transitionWarningsSubtitle =>
      'اس اسکرین کے کھلے ہونے پر ہر مرحلہ اس کے وقت پر بولیں';

  @override
  String get resetToday => 'آج کو ری سیٹ کریں';

  @override
  String get progressTitle => 'پیش رفت';

  @override
  String childWeekHeader(String name) {
    return '$name کا ہفتہ';
  }

  @override
  String get metricActivities => 'سرگرمیاں';

  @override
  String get metricRoutine => 'روٹین';

  @override
  String get metricStars => 'ستارے';

  @override
  String get activitiesThisWeek => 'اس ہفتے کی سرگرمیاں';

  @override
  String get explainableProgress => 'وضاحت شدہ پیش رفت';

  @override
  String get explainableProgressMessage =>
      'چارٹ ریکارڈ شدہ سرگرمیوں پر مبنی ہیں اور کبھی طبی دعویٰ نہیں کرتے۔';

  @override
  String get caregiverNotes => 'نگہبان کے نوٹس';

  @override
  String get noObservationsYet => 'ابھی کوئی مشاہدہ درج نہیں ہوا۔';

  @override
  String get logObservation => 'مشاہدہ درج کریں';

  @override
  String get observationButton => 'مشاہدہ';

  @override
  String get observationHint => 'آج آپ نے کیا محسوس کیا؟';

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get sensoryMode => 'حسی دوستانہ موڈ';

  @override
  String get sensoryModeSubtitle => 'حرکت، گنجان پن اور آواز کی شدت کم کریں';

  @override
  String get languageLabel => 'زبان';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get supportLevel => 'معاونت کی سطح';

  @override
  String get supportLevelSubtitle => 'ابتدائی سطح، نگہبان کے کنٹرول میں';

  @override
  String get supportLevelDescription =>
      'موافقت پسند مشکل یہاں اصولوں پر مبنی کنٹرولر سے جڑے گی۔';

  @override
  String get privacySafety => 'پرائیویسی اور حفاظت';

  @override
  String get privacySafetySubtitle =>
      'کوئی تشخیص نہیں، بچوں کے لیے کھلی چیٹ نہیں، کیمرہ پروسیسنگ آلے پر رہتی ہے';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get authWelcome => 'AutiMate میں خوش آمدید';

  @override
  String get authTagline =>
      'بچوں اور نگہبانوں کے لیے بات چیت اور سیکھنے کی پُرسکون جگہ۔';

  @override
  String get parentEmail => 'والدین کا ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get signIn => 'سائن ان';

  @override
  String get signingIn => 'لوڈ ہو رہا ہے...';

  @override
  String get createParentAccount => 'والدین کا اکاؤنٹ بنائیں';

  @override
  String get authErrorRequired =>
      'جاری رکھنے کے لیے ای میل اور پاس ورڈ درج کریں۔';

  @override
  String get gamificationComingMessage =>
      'بیجز، اسٹریک اور پیش رفت کے رنگ مکمل شدہ سرگرمیوں سے جڑیں گے۔';

  @override
  String get sensorySupportTitle => 'حسی معاونت';

  @override
  String get ttsControlsTitle => 'آواز اور حرکت کے کنٹرول';

  @override
  String get ttsControlsMessage =>
      'حسی دوستانہ موڈ میں تقریر کی رفتار اور آواز خود بخود ڈھل جاتی ہے۔';

  @override
  String get gamificationTileTitle => 'ستارے اور انعامات';

  @override
  String get gamificationTileSubtitle => 'سرگرمیوں سے ملنے والے ستارے دیکھیں';

  @override
  String get sensorySupportTileTitle => 'حسی معاونت';

  @override
  String get sensorySupportTileSubtitle =>
      'پُرسکون ہونے اور آواز کے فوری کنٹرول';

  @override
  String get onboardingTitle => 'AutiMate میں خوش آمدید';

  @override
  String get onboardingSubtitle => 'اپنے بچے کے لیے ایک پُرسکون جگہ ترتیب دیں۔';

  @override
  String get childNameLabel => 'بچے کا نام';

  @override
  String get chooseLanguageLabel => 'ایپ کی زبان';

  @override
  String get createPinLabel => 'نگہبان کا PIN (4 ہندسے)';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get intermediateSupportLevel => 'درمیانی سطح کی معاونت';

  @override
  String get advancedSupportLevel => 'اعلیٰ سطح کی معاونت';

  @override
  String get parentLockTitle => 'والدین کا لاک';

  @override
  String get enterParentPin => 'نگہبان کا PIN درج کریں';

  @override
  String get pinIncorrect => 'PIN غلط ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get unlockAction => 'کھولیں';

  @override
  String get childModeLabel => 'بچوں والا موڈ';

  @override
  String get childModeSubtitle =>
      'نگہبان کے حصے والدین کے لاک کے پیچھے چھپائیں';

  @override
  String get profilesSectionTitle => 'بچے';

  @override
  String get addChildLabel => 'بچہ شامل کریں';

  @override
  String get offlineBanner =>
      'آپ آف لائن ہیں۔ کام اس آلے پر محفوظ ہے اور بعد میں سنک ہوگا۔';

  @override
  String get customCardsTitle => 'میرے کارڈ';

  @override
  String get customCardsSubtitle => 'وہ کارڈ جو آپ نے اس بچے کے لیے بنائے';

  @override
  String get addCustomCard => 'کارڈ شامل کریں';

  @override
  String get editCustomCard => 'کارڈ میں تبدیلی';

  @override
  String get deleteCustomCard => 'کارڈ حذف کریں';

  @override
  String get cardLabelEnglish => 'نام (انگریزی)';

  @override
  String get cardLabelUrdu => 'نام (اردو)';

  @override
  String get cardSpokenEnglish => 'بولے جانے والے الفاظ (انگریزی، اختیاری)';

  @override
  String get cardSpokenUrdu => 'بولے جانے والے الفاظ (اردو، اختیاری)';

  @override
  String get cardCategoryLabel => 'زمرہ';

  @override
  String get cardPictureLabel => 'تصویر';

  @override
  String get choosePhotoGallery => 'گیلری سے منتخب کریں';

  @override
  String get takePhoto => 'تصویر کھینچیں';

  @override
  String get useSymbolInstead => 'اس کے بجائے علامت استعمال کریں';

  @override
  String get cameraUnavailable =>
      'اس آلے پر کیمرہ یا گیلری دستیاب نہیں۔ آپ پھر بھی علامت کے ساتھ کارڈ بنا سکتے ہیں۔';

  @override
  String get customCardAdded => 'کارڈ شامل ہو گیا';

  @override
  String get customCardDeleted => 'کارڈ حذف ہو گیا';

  @override
  String get confirmDeleteCard => 'یہ کارڈ حذف کریں؟ یہ بورڈ سے ہٹ جائے گا۔';

  @override
  String get myCardsEmpty =>
      'ابھی کوئی کارڈ نہیں۔ ایک شامل کریں تاکہ وہ بورڈ پر آ جائے۔';

  @override
  String get longPressToEditCard =>
      'اپنا بنایا ہوا کارڈ دبا کر رکھیں تاکہ اس میں تبدیلی ہو سکے۔';

  @override
  String get reorderSentenceHint => 'لفظ کی جگہ بدلنے کے لیے اسے کھینچیں۔';

  @override
  String get removeWordTooltip => 'یہ لفظ ہٹائیں';

  @override
  String get sentenceStripEmpty => 'شروع کرنے کے لیے کارڈ چھوئیں۔';

  @override
  String get homeQuickActions => 'فوری آغاز';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مسلسل $count دن',
      one: 'مسلسل ۱ دن',
      zero: 'ابھی کوئی مسلسل دن نہیں',
    );
    return '$_temp0';
  }

  @override
  String greetingChild(String name) {
    return 'السلام علیکم، $name';
  }

  @override
  String get openSettings => 'ترتیبات';

  @override
  String get displaySectionTitle => 'شکل و صورت';

  @override
  String get themeModeLabel => 'اسکرین کی روشنی';

  @override
  String get themeModeSystem => 'میرے آلے کے مطابق';

  @override
  String get themeModeLight => 'روشن';

  @override
  String get themeModeDark => 'گہرا';

  @override
  String get themeModeSubtitle =>
      'کم روشنی والے کمرے میں گہرا رنگ آسان ہو سکتا ہے۔';

  @override
  String get chooseTheFace => 'چہرہ منتخب کریں';

  @override
  String get tryAgainGently => 'یہ نہیں۔ ایک بار پھر دیکھیں۔';

  @override
  String get wellDone => 'بہت خوب';

  @override
  String get starEarned => 'آپ نے ستارہ حاصل کیا';

  @override
  String get nextMilestone => 'اگلا سنگِ میل';

  @override
  String get earnedLabel => 'حاصل شدہ';

  @override
  String get lockedLabel => 'کوشش جاری رکھیں';

  @override
  String get ambientTrackLabel => 'آواز';

  @override
  String get ambientTrackSoftRain => 'ہلکی بارش';

  @override
  String get ambientTrackSlowOcean => 'آہستہ لہریں';

  @override
  String get ambientTrackWarmHum => 'نرم گنگناہٹ';

  @override
  String get ambientVolumeLabel => 'کتنی اونچی';

  @override
  String get ambientVolumeHint =>
      'ایپ زیادہ سے زیادہ پر بھی آواز کو ہلکا رکھتی ہے۔';
}
