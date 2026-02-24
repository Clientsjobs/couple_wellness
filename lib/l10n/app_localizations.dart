import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
    Locale('fr', ''),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home Screen
      'welcome_back': 'Welcome\nBack',
      'welcome': 'Welcome',
      'explore_features': 'Explore our features designed for couples',
      'premium_feature': 'Premium Feature',
      'premium_message':
          'This feature requires a premium subscription. Start your free trial to access all features!',
      'cancel': 'Cancel',
      'start_free_trial': 'Start Free Trial',
      'trial_started': 'Your 48-hour free trial has started!',
      'failed_to_start_trial': 'Failed to start trial',
      'premium_active': 'Premium Active',
      'trial_active': 'Trial Active',
      'start_trial': 'Start your 48-hour free trial',
      'full_access': 'Full access to all features',
      'hours_remaining': 'hours remaining',
      'couples_games': 'Couples Games',
      'couples_games_subtitle': 'Fun activities to deepen your connection',
      'kegel_exercises': 'Kegel Exercises',
      'kegel_exercises_subtitle': 'Guided routines for intimate wellness',
      'ai_chat': 'AI Chat',
      'ai_chat_subtitle': 'Get personalized relationship guidance',
      'sign_out': 'Sign Out',

      // Games Screen
      'play_together': 'Play together, grow together',
      'game_not_found': 'Game not found!',
      'game_coming_soon': 'Game coming soon!',
      'error_starting_game': 'Error starting game',
      'premium_game_message': 'This game requires a premium subscription. Upgrade to access all games!',
      'upgrade': 'Upgrade',
      'not_started': 'Not Started',
      'in_progress': 'In Progress',
      'completed': 'Completed',
      'played': 'Played',
      'time': 'time',
      'times': 'times',
      'play_now': 'Play Now',
      'play_again': 'Play Again',
      'retry': 'Retry',

      // Kegel Screen
      'kegel': 'Kegel',
      'intimate_wellness_journey': 'Your intimate wellness journey',
      'your_progress': 'Your Progress',
      'week_streak': 'Week Streak',
      'completed_label': 'Completed',
      'daily_goal': 'Daily Goal',
      'exercise_routines': 'Exercise Routines',
      'beginner_routine': 'Beginner Routine',
      'intermediate_routine': 'Intermediate Routine',
      'advanced_routine': 'Advanced Routine',
      'minutes': 'minutes',
      'sets': 'sets',
      'about_kegel': 'About Kegel Exercises',
      'about_kegel_content': 'Kegel exercises strengthen the pelvic floor muscles, which support the bladder, uterus, and bowel. These exercises can improve intimate wellness, bladder control, and enhance physical connection with your partner.',
      'target_muscle': 'Target Muscle',
      'target_muscle_content': 'Pelvic floor muscles - the muscles you use to stop urination midstream.',
      'how_to_perform': 'How to Perform',
      'step_1_title': 'Identify the Right Muscles',
      'step_1_desc': 'Imagine stopping urination or holding gas. Those are your pelvic floor muscles.',
      'step_2_title': 'Contract & Hold',
      'step_2_desc': 'Tighten these muscles and hold for the specified time. Don\'t hold your breath.',
      'step_3_title': 'Relax Completely',
      'step_3_desc': 'Release the muscles fully and rest between repetitions.',
      'step_4_title': 'Stay Consistent',
      'step_4_desc': 'Practice daily for best results. You should notice improvements within weeks.',
      'important_tips': 'Important Tips',
      'tip_1': 'Don\'t tighten your stomach, thighs, or buttocks',
      'tip_2': 'Breathe normally throughout the exercise',
      'tip_3': 'Start with beginner level and progress gradually',
      'tip_4': 'Practice on an empty bladder for comfort',
      'medical_disclaimer': 'Medical Disclaimer',
      'medical_disclaimer_content': 'This app is for informational and educational purposes only. Please consult a healthcare professional for any medical advice or concerns.',

      // Chat Screen
      'chat': 'Chat',
      'ai_companion': 'Your AI relationship companion',
      'ai_greeting': 'Hello! I\'m here to support your relationship journey. How can I help you today?',
      'type_message': 'Type your message...',
      'chat_disclaimer': 'For informational purposes only. Consult a doctor for medical advice.',
    },
    'ar': {
      // Home Screen
      'welcome_back': 'مرحباً بعودتك',
      'welcome': 'مرحباً',
      'explore_features': 'استكشف ميزاتنا المصممة للأزواج',
      'premium_feature': 'ميزة مميزة',
      'premium_message':
          'تتطلب هذه الميزة اشتراكاً مميزاً. ابدأ تجربتك المجانية للوصول إلى جميع الميزات!',
      'cancel': 'إلغاء',
      'start_free_trial': 'ابدأ التجربة المجانية',
      'trial_started': 'بدأت تجربتك المجانية لمدة 48 ساعة!',
      'failed_to_start_trial': 'فشل بدء التجربة',
      'premium_active': 'الاشتراك المميز نشط',
      'trial_active': 'التجربة نشطة',
      'start_trial': 'ابدأ تجربتك المجانية لمدة 48 ساعة',
      'full_access': 'وصول كامل لجميع الميزات',
      'hours_remaining': 'ساعات متبقية',
      'couples_games': 'ألعاب الأزواج',
      'couples_games_subtitle': 'أنشطة ممتعة لتعميق علاقتك',
      'kegel_exercises': 'تمارين كيجل',
      'kegel_exercises_subtitle': 'روتينات موجهة للصحة الحميمة',
      'ai_chat': 'الدردشة الذكية',
      'ai_chat_subtitle': 'احصل على إرشادات شخصية للعلاقات',
      'sign_out': 'تسجيل الخروج',

      // Games Screen
      'play_together': 'العبوا معاً، انموا معاً',
      'game_not_found': 'اللعبة غير موجودة!',
      'game_coming_soon': 'اللعبة قريباً!',
      'error_starting_game': 'خطأ في بدء اللعبة',
      'premium_game_message': 'تتطلب هذه اللعبة اشتراكاً مميزاً. قم بالترقية للوصول إلى جميع الألعاب!',
      'upgrade': 'ترقية',
      'not_started': 'لم تبدأ',
      'in_progress': 'قيد التقدم',
      'completed': 'مكتملة',
      'played': 'لعبت',
      'time': 'مرة',
      'times': 'مرات',
      'play_now': 'العب الآن',
      'play_again': 'العب مرة أخرى',
      'retry': 'إعادة المحاولة',

      // Kegel Screen
      'kegel': 'كيجل',
      'intimate_wellness_journey': 'رحلة صحتك الحميمة',
      'your_progress': 'تقدمك',
      'week_streak': 'سلسلة الأسبوع',
      'completed_label': 'مكتمل',
      'daily_goal': 'الهدف اليومي',
      'exercise_routines': 'روتينات التمارين',
      'beginner_routine': 'روتين المبتدئين',
      'intermediate_routine': 'روتين متوسط',
      'advanced_routine': 'روتين متقدم',
      'minutes': 'دقائق',
      'sets': 'مجموعات',
      'about_kegel': 'حول تمارين كيجل',
      'about_kegel_content': 'تمارين كيجل تقوي عضلات قاع الحوض التي تدعم المثانة والرحم والأمعاء. يمكن لهذه التمارين تحسين الصحة الحميمة والتحكم في المثانة وتعزيز الاتصال الجسدي مع شريكك.',
      'target_muscle': 'العضلة المستهدفة',
      'target_muscle_content': 'عضلات قاع الحوض - العضلات التي تستخدمها لإيقاف التبول في منتصف الطريق.',
      'how_to_perform': 'كيفية الأداء',
      'step_1_title': 'حدد العضلات الصحيحة',
      'step_1_desc': 'تخيل إيقاف التبول أو حبس الغازات. هذه هي عضلات قاع الحوض.',
      'step_2_title': 'انقبض واحتفظ',
      'step_2_desc': 'شد هذه العضلات واحتفظ بها للوقت المحدد. لا تحبس أنفاسك.',
      'step_3_title': 'استرخ تماماً',
      'step_3_desc': 'أطلق العضلات بالكامل واسترح بين التكرارات.',
      'step_4_title': 'كن متسقاً',
      'step_4_desc': 'مارس يومياً للحصول على أفضل النتائج. يجب أن تلاحظ تحسينات في غضون أسابيع.',
      'important_tips': 'نصائح مهمة',
      'tip_1': 'لا تشد معدتك أو فخذيك أو أردافك',
      'tip_2': 'تنفس بشكل طبيعي طوال التمرين',
      'tip_3': 'ابدأ بمستوى المبتدئين وتقدم تدريجياً',
      'tip_4': 'مارس على مثانة فارغة للراحة',
      'medical_disclaimer': 'إخلاء المسؤولية الطبية',
      'medical_disclaimer_content': 'هذا التطبيق لأغراض إعلامية وتعليمية فقط. يرجى استشارة أخصائي رعاية صحية للحصول على أي نصيحة أو مخاوف طبية.',

      // Chat Screen
      'chat': 'دردشة',
      'ai_companion': 'رفيقك الذكي للعلاقات',
      'ai_greeting': 'مرحباً! أنا هنا لدعم رحلة علاقتك. كيف يمكنني مساعدتك اليوم؟',
      'type_message': 'اكتب رسالتك...',
      'chat_disclaimer': 'لأغراض إعلامية فقط. استشر طبيباً للحصول على نصيحة طبية.',
    },
    'fr': {
      // Home Screen
      'welcome_back': 'Bienvenue\nde retour',
      'welcome': 'Bienvenue',
      'explore_features': 'Explorez nos fonctionnalités conçues pour les couples',
      'premium_feature': 'Fonctionnalité Premium',
      'premium_message':
          'Cette fonctionnalité nécessite un abonnement premium. Commencez votre essai gratuit pour accéder à toutes les fonctionnalités!',
      'cancel': 'Annuler',
      'start_free_trial': 'Commencer l\'essai gratuit',
      'trial_started': 'Votre essai gratuit de 48 heures a commencé!',
      'failed_to_start_trial': 'Échec du démarrage de l\'essai',
      'premium_active': 'Premium Actif',
      'trial_active': 'Essai Actif',
      'start_trial': 'Commencez votre essai gratuit de 48 heures',
      'full_access': 'Accès complet à toutes les fonctionnalités',
      'hours_remaining': 'heures restantes',
      'couples_games': 'Jeux de Couple',
      'couples_games_subtitle': 'Activités amusantes pour approfondir votre connexion',
      'kegel_exercises': 'Exercices de Kegel',
      'kegel_exercises_subtitle': 'Routines guidées pour le bien-être intime',
      'ai_chat': 'Chat IA',
      'ai_chat_subtitle': 'Obtenez des conseils personnalisés sur les relations',
      'sign_out': 'Se déconnecter',

      // Games Screen
      'play_together': 'Jouez ensemble, grandissez ensemble',
      'game_not_found': 'Jeu introuvable!',
      'game_coming_soon': 'Jeu bientôt disponible!',
      'error_starting_game': 'Erreur lors du démarrage du jeu',
      'premium_game_message': 'Ce jeu nécessite un abonnement premium. Mettez à niveau pour accéder à tous les jeux!',
      'upgrade': 'Mettre à niveau',
      'not_started': 'Non commencé',
      'in_progress': 'En cours',
      'completed': 'Terminé',
      'played': 'Joué',
      'time': 'fois',
      'times': 'fois',
      'play_now': 'Jouer maintenant',
      'play_again': 'Rejouer',
      'retry': 'Réessayer',

      // Kegel Screen
      'kegel': 'Kegel',
      'intimate_wellness_journey': 'Votre parcours de bien-être intime',
      'your_progress': 'Votre progression',
      'week_streak': 'Série hebdomadaire',
      'completed_label': 'Terminé',
      'daily_goal': 'Objectif quotidien',
      'exercise_routines': 'Routines d\'exercices',
      'beginner_routine': 'Routine débutant',
      'intermediate_routine': 'Routine intermédiaire',
      'advanced_routine': 'Routine avancée',
      'minutes': 'minutes',
      'sets': 'séries',
      'about_kegel': 'À propos des exercices de Kegel',
      'about_kegel_content': 'Les exercices de Kegel renforcent les muscles du plancher pelvien qui soutiennent la vessie, l\'utérus et l\'intestin. Ces exercices peuvent améliorer le bien-être intime, le contrôle de la vessie et renforcer la connexion physique avec votre partenaire.',
      'target_muscle': 'Muscle ciblé',
      'target_muscle_content': 'Muscles du plancher pelvien - les muscles que vous utilisez pour arrêter la miction en cours.',
      'how_to_perform': 'Comment effectuer',
      'step_1_title': 'Identifiez les bons muscles',
      'step_1_desc': 'Imaginez arrêter la miction ou retenir des gaz. Ce sont vos muscles du plancher pelvien.',
      'step_2_title': 'Contractez et maintenez',
      'step_2_desc': 'Serrez ces muscles et maintenez pendant le temps spécifié. Ne retenez pas votre respiration.',
      'step_3_title': 'Détendez-vous complètement',
      'step_3_desc': 'Relâchez complètement les muscles et reposez-vous entre les répétitions.',
      'step_4_title': 'Restez cohérent',
      'step_4_desc': 'Pratiquez quotidiennement pour de meilleurs résultats. Vous devriez remarquer des améliorations en quelques semaines.',
      'important_tips': 'Conseils importants',
      'tip_1': 'Ne serrez pas votre estomac, vos cuisses ou vos fesses',
      'tip_2': 'Respirez normalement pendant l\'exercice',
      'tip_3': 'Commencez au niveau débutant et progressez graduellement',
      'tip_4': 'Pratiquez avec une vessie vide pour plus de confort',
      'medical_disclaimer': 'Avertissement médical',
      'medical_disclaimer_content': 'Cette application est à des fins informatives et éducatives uniquement. Veuillez consulter un professionnel de la santé pour tout conseil ou préoccupation médicale.',

      // Chat Screen
      'chat': 'Chat',
      'ai_companion': 'Votre compagnon IA pour les relations',
      'ai_greeting': 'Bonjour! Je suis là pour soutenir votre parcours relationnel. Comment puis-je vous aider aujourd\'hui?',
      'type_message': 'Tapez votre message...',
      'chat_disclaimer': 'À des fins informatives uniquement. Consultez un médecin pour des conseils médicaux.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Home Screen
  String get welcomeBack => translate('welcome_back');
  String get welcome => translate('welcome');
  String get exploreFeatures => translate('explore_features');
  String get premiumFeature => translate('premium_feature');
  String get premiumMessage => translate('premium_message');
  String get cancel => translate('cancel');
  String get startFreeTrial => translate('start_free_trial');
  String get trialStarted => translate('trial_started');
  String get failedToStartTrial => translate('failed_to_start_trial');
  String get premiumActive => translate('premium_active');
  String get trialActive => translate('trial_active');
  String get startTrial => translate('start_trial');
  String get fullAccess => translate('full_access');
  String get hoursRemaining => translate('hours_remaining');
  String get couplesGames => translate('couples_games');
  String get couplesGamesSubtitle => translate('couples_games_subtitle');
  String get kegelExercises => translate('kegel_exercises');
  String get kegelExercisesSubtitle => translate('kegel_exercises_subtitle');
  String get aiChat => translate('ai_chat');
  String get aiChatSubtitle => translate('ai_chat_subtitle');
  String get signOut => translate('sign_out');

  // Games Screen
  String get playTogether => translate('play_together');
  String get gameNotFound => translate('game_not_found');
  String get gameComingSoon => translate('game_coming_soon');
  String get errorStartingGame => translate('error_starting_game');
  String get premiumGameMessage => translate('premium_game_message');
  String get upgrade => translate('upgrade');
  String get notStarted => translate('not_started');
  String get inProgress => translate('in_progress');
  String get completed => translate('completed');
  String get played => translate('played');
  String get time => translate('time');
  String get times => translate('times');
  String get playNow => translate('play_now');
  String get playAgain => translate('play_again');
  String get retry => translate('retry');

  // Kegel Screen
  String get kegel => translate('kegel');
  String get intimateWellnessJourney => translate('intimate_wellness_journey');
  String get yourProgress => translate('your_progress');
  String get weekStreak => translate('week_streak');
  String get completedLabel => translate('completed_label');
  String get dailyGoal => translate('daily_goal');
  String get exerciseRoutines => translate('exercise_routines');
  String get beginnerRoutine => translate('beginner_routine');
  String get intermediateRoutine => translate('intermediate_routine');
  String get advancedRoutine => translate('advanced_routine');
  String get minutes => translate('minutes');
  String get sets => translate('sets');
  String get aboutKegel => translate('about_kegel');
  String get aboutKegelContent => translate('about_kegel_content');
  String get targetMuscle => translate('target_muscle');
  String get targetMuscleContent => translate('target_muscle_content');
  String get howToPerform => translate('how_to_perform');
  String get step1Title => translate('step_1_title');
  String get step1Desc => translate('step_1_desc');
  String get step2Title => translate('step_2_title');
  String get step2Desc => translate('step_2_desc');
  String get step3Title => translate('step_3_title');
  String get step3Desc => translate('step_3_desc');
  String get step4Title => translate('step_4_title');
  String get step4Desc => translate('step_4_desc');
  String get importantTips => translate('important_tips');
  String get tip1 => translate('tip_1');
  String get tip2 => translate('tip_2');
  String get tip3 => translate('tip_3');
  String get tip4 => translate('tip_4');
  String get medicalDisclaimer => translate('medical_disclaimer');
  String get medicalDisclaimerContent => translate('medical_disclaimer_content');

  // Chat Screen
  String get chat => translate('chat');
  String get aiCompanion => translate('ai_companion');
  String get aiGreeting => translate('ai_greeting');
  String get typeMessage => translate('type_message');
  String get chatDisclaimer => translate('chat_disclaimer');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
