import 'package:flutter/material.dart';

import 'social_models.dart';

/// The four scoped social stories, fully bilingual and fixed.
const socialStories = <SocialStory>[
  SocialStory(
    id: 'meeting-someone',
    titleEn: 'Meeting Someone New',
    titleUr: 'کسی سے ملیں',
    pages: [
      StoryPage(
        textEn: 'Sometimes I meet new people. A new person might be a '
            'teacher, a helper, or another child.',
        textUr: 'کبھی کبھی میں نئے لوگوں سے ملتا ہوں۔ نیا شخص کوئی استاد، '
            'مددگار یا کوئی اور بچہ ہو سکتا ہے۔',
        icon: Icons.person_add_alt_1_outlined,
      ),
      StoryPage(
        textEn: 'I can say hello and tell them my name. Saying hello helps '
            'people feel friendly.',
        textUr: 'میں سلام کہہ سکتا ہوں اور اپنا نام بتا سکتا ہوں۔ سلام لوگوں '
            'کو دوستانہ محسوس کراتا ہے۔',
        icon: Icons.waving_hand_outlined,
      ),
      StoryPage(
        textEn: 'The other person may ask me a question. It is okay if I '
            'need a moment to think before I answer.',
        textUr: 'دوسرا شخص مجھ سے سوال پوچھ سکتا ہے۔ اگر مجھے جواب سے پہلے '
            'سوچنے کے لیے وقت چاہیے تو یہ ٹھیک ہے۔',
        icon: Icons.help_outline,
      ),
      StoryPage(
        textEn: 'When we finish talking, I can say goodbye. Meeting new '
            'people can be calm and safe.',
        textUr: 'جب باتیں ختم ہو جائیں تو میں الوداع کہہ سکتا ہوں۔ نئے لوگوں '
            'سے ملنا پُرسکون اور محفوظ ہو سکتا ہے۔',
        icon: Icons.handshake_outlined,
      ),
    ],
    questions: [
      ComprehensionQuestion(
        promptEn: 'What can I say when I meet someone new?',
        promptUr: 'کسی نئے شخص سے ملتے ہوئے میں کیا کہہ سکتا ہوں؟',
        optionsEn: ['Hello, my name is…', 'Nothing at all', 'Run away'],
        optionsUr: ['سلام، میرا نام ہے…', 'کچھ نہیں', 'بھاگ جانا'],
        correctIndex: 0,
      ),
      ComprehensionQuestion(
        promptEn: 'Is it okay to take time before answering?',
        promptUr: 'کیا جواب دینے سے پہلے وقت لینا ٹھیک ہے؟',
        optionsEn: ['Yes, it is okay', 'No, never'],
        optionsUr: ['ہاں، یہ ٹھیک ہے', 'نہیں، کبھی نہیں'],
        correctIndex: 0,
      ),
    ],
  ),
  SocialStory(
    id: 'asking-for-help',
    titleEn: 'Asking for Help',
    titleUr: 'مدد مانگنا',
    pages: [
      StoryPage(
        textEn: 'Sometimes something feels hard. Maybe my shoelace is '
            'stuck or I cannot find my book.',
        textUr: 'کبھی کبھی کوئی کام مشکل لگتا ہے۔ شاید میری جوتے کا فیتہ '
            'پھنس گیا ہو یا کتاب نہ مل رہی ہو۔',
        icon: Icons.pan_tool_outlined,
      ),
      StoryPage(
        textEn: 'Asking for help is a strong thing to do. I can go to an '
            'adult I trust.',
        textUr: 'مدد مانگنا بہادرانہ کام ہے۔ میں کسی قابلِ اعتماد بڑے کے پاس '
            'جا سکتا ہوں۔',
        icon: Icons.volunteer_activism_outlined,
      ),
      StoryPage(
        textEn: 'I can say: "Please help me." Then I can show what the '
            'problem is.',
        textUr: 'میں کہہ سکتا ہوں: «مہربانی کر کے میری مدد کریں۔» پھر میں دکھا '
            'سکتا ہوں کیا مسئلہ ہے۔',
        icon: Icons.record_voice_over_outlined,
      ),
      StoryPage(
        textEn: 'After the problem is solved, I can say thank you. Adults '
            'are happy when I ask for help politely.',
        textUr: 'مسئلہ حل ہونے کے بعد میں شکریہ ادا کر سکتا ہوں۔ جب میں ادب سے '
            'مدد مانگتا ہوں تو بڑے خوش ہوتے ہیں۔',
        icon: Icons.favorite_outline,
      ),
    ],
    questions: [
      ComprehensionQuestion(
        promptEn: 'What can I say when I need help?',
        promptUr: 'مدد درکار ہونے پر میں کیا کہہ سکتا ہوں؟',
        optionsEn: ['"Please help me."', 'Stay silent all day', 'Cry only'],
        optionsUr: ['«مہربانی کر کے میری مدد کریں۔»', 'سارا دن خاموش رہنا', 'صرف رونا'],
        correctIndex: 0,
      ),
      ComprehensionQuestion(
        promptEn: 'Who can I ask for help?',
        promptUr: 'میں کس سے مدد مانگ سکتا ہوں؟',
        optionsEn: ['An adult I trust', 'A stranger only', 'Nobody ever'],
        optionsUr: ['کوئی قابلِ اعتماد بڑا', 'صرف اجنبی', 'کبھی کسی سے نہیں'],
        correctIndex: 0,
      ),
    ],
  ),
  SocialStory(
    id: 'waiting-my-turn',
    titleEn: 'Waiting for My Turn',
    titleUr: 'اپنی باری کا انتظار',
    pages: [
      StoryPage(
        textEn: 'At school and at home there are times to wait. Waiting '
            'for my turn happens in games and in lines.',
        textUr: 'اسکول اور گھر میں انتظار کے لمحے آتے ہیں۔ کھیلوں اور قطار '
            'میں اپنی باری کا انتظار کرنا پڑتا ہے۔',
        icon: Icons.hourglass_empty_outlined,
      ),
      StoryPage(
        textEn: 'Waiting means my turn will come later. It does not mean '
            'my turn will never come.',
        textUr: 'انتظار کا مطلب ہے کہ میری باری بعد میں آئے گی۔ اس کا مطلب '
            'یہ نہیں کہ میری باری کبھی نہیں آئے گی۔',
        icon: Icons.schedule_outlined,
      ),
      StoryPage(
        textEn: 'While I wait, I can take a slow breath or count quietly '
            'in my head. This helps my body stay calm.',
        textUr: 'انتظار کے دوران میں آہستہ سانس لے سکتا ہوں یا دل ہی دل میں '
            'گنی سکتا ہوں۔ اس سے میرا جسم پُرسکون رہتا ہے۔',
        icon: Icons.self_improvement_outlined,
      ),
      StoryPage(
        textEn: 'When my turn comes, it is my time to play or speak. '
            'Waiting makes taking turns fair for everyone.',
        textUr: 'جب میری باری آئے تو یہ میرا کھیلنے یا بولنے کا وقت ہے۔ '
            'انتظار سب کے لیے باریاں منصفانہ بناتا ہے۔',
        icon: Icons.emoji_events_outlined,
      ),
    ],
    questions: [
      ComprehensionQuestion(
        promptEn: 'What can waiting for my turn mean?',
        promptUr: 'اپنی باری کے انتظار کا کیا مطلب ہو سکتا ہے؟',
        optionsEn: ['My turn comes later', 'My turn never comes'],
        optionsUr: ['میری باری بعد میں آتی ہے', 'میری باری کبھی نہیں آتی'],
        correctIndex: 0,
      ),
      ComprehensionQuestion(
        promptEn: 'What helps while I wait?',
        promptUr: 'انتظار کے دوران کیا مدد دیتا ہے؟',
        optionsEn: ['Slow breathing or counting', 'Pushing others'],
        optionsUr: ['آہستہ سانس یا گنتی', 'دوسروں کو دھکا دینا'],
        correctIndex: 0,
      ),
    ],
  ),
  SocialStory(
    id: 'going-to-a-shop',
    titleEn: 'Going to a Shop',
    titleUr: 'دکان جانا',
    pages: [
      StoryPage(
        textEn: 'Sometimes my family goes to a shop. Shops can be bright '
            'and noisy. I can bring my calm tools with me.',
        textUr: 'کبھی کبھی میرا خاندان دکان جاتا ہے۔ دکانیں روشن اور شور والی '
            'ہو سکتی ہیں۔ میں اپنے پُرسکون آلات ساتھ لے جا سکتا ہوں۔',
        icon: Icons.storefront_outlined,
      ),
      StoryPage(
        textEn: 'I can stay close to my grown-up and walk slowly inside '
            'the shop.',
        textUr: 'میں اپنے بڑے کے قریب رہ سکتا ہوں اور دکان کے اندر آہستہ چل '
            'سکتا ہوں۔',
        icon: Icons.family_restroom_outlined,
      ),
      StoryPage(
        textEn: 'At the counter I can give the money or the card to the '
            'shopkeeper. The shopkeeper may say hello to me.',
        textUr: 'کاؤنٹر پر میں دکاندار کو پیسے یا کارڈ دے سکتا ہوں۔ دکاندار '
            'مجھے سلام کہہ سکتا ہے۔',
        icon: Icons.payments_outlined,
      ),
      StoryPage(
        textEn: 'After shopping we go home. Going to a shop has steps, '
            'and now I know them.',
        textUr: 'خریداری کے بعد ہم گھر جاتے ہیں۔ دکان جانے کے مراحل ہوتے '
            'ہیں اور اب میں انہیں جانتا ہوں۔',
        icon: Icons.home_outlined,
      ),
    ],
    questions: [
      ComprehensionQuestion(
        promptEn: 'What can I do if the shop feels too loud?',
        promptUr: 'اگر دکان زیادہ شور والی لگے تو میں کیا کر سکتا ہوں؟',
        optionsEn: [
          'Use my calm tools and stay near my grown-up',
          'Scream and run',
        ],
        optionsUr: [
          'اپنے پُرسکون آلات استعمال کروں اور بڑے کے قریب رہوں',
          'چیخنا اور بھاگنا',
        ],
        correctIndex: 0,
      ),
      ComprehensionQuestion(
        promptEn: 'What do we do at the counter?',
        promptUr: 'کاؤنٹر پر ہم کیا کرتے ہیں؟',
        optionsEn: ['Pay the shopkeeper', 'Take things without asking'],
        optionsUr: ['دکاندار کو ادائیگی کرتے ہیں', 'بغیر پوچھے چیزیں لے جاتے ہیں'],
        correctIndex: 0,
      ),
    ],
  ),
];

/// Four scripted conversation scenarios covering greetings, requesting,
/// turn-taking, and closing a conversation.
///
/// Branching rule: fitting replies advance (`nextStepId` names the next
/// step); safe-but-unexpected replies keep `encouraging` true and loop
/// back so the child can try again. Nothing here is free-form chat.
const conversationScripts = <ConversationScript>[
  ConversationScript(
    id: 'greetings',
    titleEn: 'Saying Hello',
    titleUr: 'سلام کہنا',
    startStepId: 'g1',
    steps: [
      ConversationStep(
        id: 'g1',
        partnerLineEn: 'A friend walks up and says: "Hi! How are you?"',
        partnerLineUr: 'ایک دوست آ کر کہتا ہے: «سلام! آپ کیسے ہیں؟»',
        options: [
          ConversationOption(
            replyEn: '"Hi! I am fine, thank you."',
            replyUr: '«سلام! میں ٹھیک ہوں، شکریہ۔»',
            nextStepId: 'g2',
          ),
          ConversationOption(
            replyEn: '(Say nothing and walk away)',
            replyUr: '(کچھ نہ کہیں اور چلے جائیں)',
            nextStepId: 'g1',
            encouraging: false,
          ),
        ],
      ),
      ConversationStep(
        id: 'g2',
        partnerLineEn: 'The friend asks: "Do you want to see my drawing?"',
        partnerLineUr: 'دوست پوچھتا ہے: «کیا آپ میری بنائی ہوئی تصویر دیکھنا چاہیں گے؟»',
        options: [
          ConversationOption(
            replyEn: '"Yes please!"',
            replyUr: '«جی ہاں، مہربانی!»',
            nextStepId: 'end',
          ),
          ConversationOption(
            replyEn: '"No, thank you."',
            replyUr: '«نہیں، شکریہ۔»',
            nextStepId: 'end',
          ),
        ],
      ),
    ],
  ),
  ConversationScript(
    id: 'requesting',
    titleEn: 'Asking for Something',
    titleUr: 'کوئی چیز مانگنا',
    startStepId: 'r1',
    steps: [
      ConversationStep(
        id: 'r1',
        partnerLineEn: 'You want the red crayon. Your classmate is using '
            'it. What can you say?',
        partnerLineUr: 'آپ کو سرخ رنگ چاہیے۔ آپ کا ساتھی اسے استعمال کر رہا '
            'ہے۔ آپ کیا کہہ سکتے ہیں؟',
        options: [
          ConversationOption(
            replyEn: '"May I use the red crayon next, please?"',
            replyUr: '«کیا میں اگلی بار سرخ رنگ استعمال کر سکتا ہوں؟»',
            nextStepId: 'r2',
          ),
          ConversationOption(
            replyEn: '(Grab the crayon)',
            replyUr: '(رنگ چھین لینا)',
            nextStepId: 'r1',
            encouraging: false,
          ),
        ],
      ),
      ConversationStep(
        id: 'r2',
        partnerLineEn: 'Your classmate says: "Sure, in two minutes." What '
            'can you reply?',
        partnerLineUr: 'ساتھی کہتا ہے: «ضرور، دو منٹ میں۔» آپ کیا جواب دے '
            'سکتے ہیں؟',
        options: [
          ConversationOption(
            replyEn: '"Okay! Thank you."',
            replyUr: '«ٹھیک ہے! شکریہ۔»',
            nextStepId: 'end',
          ),
          ConversationOption(
            replyEn: '"Give it NOW!"',
            replyUr: '«ابھی دیں!»',
            nextStepId: 'r1',
            encouraging: false,
          ),
        ],
      ),
    ],
  ),
  ConversationScript(
    id: 'turn-taking',
    titleEn: 'Taking Turns in a Game',
    titleUr: 'کھیل میں باری لینا',
    startStepId: 't1',
    steps: [
      ConversationStep(
        id: 't1',
        partnerLineEn: 'It is your friend\'s turn in the game right now. '
            'What do you do?',
        partnerLineUr: 'ابھی کھیل میں آپ کے دوست کی باری ہے۔ آپ کیا کریں گے؟',
        options: [
          ConversationOption(
            replyEn: 'Wait calmly and watch',
            replyUr: 'پُرسکون انتظار کریں اور دیکھیں',
            nextStepId: 't2',
          ),
          ConversationOption(
            replyEn: 'Take the dice from their hand',
            replyUr: 'ان کے ہاتھ سے پانسہ لے لیں',
            nextStepId: 't1',
            encouraging: false,
          ),
        ],
      ),
      ConversationStep(
        id: 't2',
        partnerLineEn: 'Your friend finishes. Now it IS your turn. How can '
            'you respond?',
        partnerLineUr: 'دوست نے باری ختم کی۔ اب آپ کی باری ہے۔ آپ کیسے جواب '
            'دیں گے؟',
        options: [
          ConversationOption(
            replyEn: '"My turn!" and roll happily',
            replyUr: '«میری باری!» اور خوشی سے پانسہ پھینکیں',
            nextStepId: 'end',
          ),
          ConversationOption(
            replyEn: '"I don\'t want it anymore."',
            replyUr: '«اب مجھے نہیں کھیلنا۔»',
            nextStepId: 't2',
            encouraging: false,
          ),
        ],
      ),
    ],
  ),
  ConversationScript(
    id: 'closing',
    titleEn: 'Ending a Conversation',
    titleUr: 'بات چیت ختم کرنا',
    startStepId: 'c1',
    steps: [
      ConversationStep(
        id: 'c1',
        partnerLineEn: 'You have been chatting with your cousin, but it is '
            'almost dinner time. What can you say?',
        partnerLineUr: 'آپ کزن سے باتیں کر رہے ہیں مگر کھانے کا وقت ہو گیا '
            'ہے۔ آپ کیا کہہ سکتے ہیں؟',
        options: [
          ConversationOption(
            replyEn: '"I have to go eat now. Bye!"',
            replyUr: '«مجھے اب کھانا کھانے جانا ہے۔ خدا حافظ!»',
            nextStepId: 'c2',
          ),
          ConversationOption(
            replyEn: '(Walk away in the middle without saying anything)',
            replyUr: '(بغیر کچھ کہے بیچ میں چلے جانا)',
            nextStepId: 'c1',
            encouraging: false,
          ),
        ],
      ),
      ConversationStep(
        id: 'c2',
        partnerLineEn: 'Your cousin says: "Okay, see you tomorrow!" A good '
            'last line is…',
        partnerLineUr: 'کزن کہتا ہے: «ٹھیک ہے، کل ملیں گے!» آخری اچھا جملہ ہے…',
        options: [
          ConversationOption(
            replyEn: '"See you tomorrow!"',
            replyUr: '«کل ملیں گے!»',
            nextStepId: 'end',
          ),
          ConversationOption(
            replyEn: '(Say nothing)',
            replyUr: '(کچھ نہ کہیں)',
            nextStepId: 'c2',
            encouraging: false,
          ),
        ],
      ),
    ],
  ),
];
