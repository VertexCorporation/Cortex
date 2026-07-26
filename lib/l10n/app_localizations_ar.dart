// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'أنت مسؤول عن إنشاء العناوين. يُرجى الرد بعنوان من كلمتين إلى خمس كلمات فقط للمحادثة التالية. لا تستخدم علامات الاقتباس أو البادئات أو علامات الترقيم. هام: يجب أن يكون العنوان بنفس لغة رسالة المستخدم تمامًا.';

  @override
  String get systemRoleFallback => 'أنت مساعد مفيد.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: يجب دائمًا الرد بنفس اللغة التي يكتب بها المستخدم، انتبه إلى لغة المستخدم.';

  @override
  String get systemNotePreviousMedia =>
      '[ملاحظة النظام: أدناه هي الوسائط التي تم إنشاؤها مسبقًا. يمكنك الإشارة إليها أو تعديلها.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nالتاريخ والوقت الحالي: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nحلل المحادثة حتى الآن. إذا تعلمت أي حقائق جديدة ومميزة عن المستخدم (تفضيلات، اسم، عادات، سياق)، فيجب عليك إخراج ذاكرتك المحدثة بالكامل عن المستخدم داخل علامات <memory>...</memory> في نهاية ردك. هام: لا تقم أبدًا بمسح أو استبدال الذاكرة السابقة. أضف دائمًا الحقائق الجديدة إلى الذاكرة الموجودة. إذا لم يتم تعلم أي شيء جديد على الإطلاق، فاحذف العلامة. مثال: <memory>يحب كرة القدم والتنس. يفضل الإجابات القصيرة.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nتذكر دائمًا هذا عن المستخدم:\n$userMemory';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'يزيل';

  @override
  String get download => 'تنزيل';

  @override
  String get resume => 'استئناف';

  @override
  String get copy => 'نسخ';

  @override
  String get chat => 'محادثة';

  @override
  String get branch => 'فرع';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'نماذج اللغة';

  @override
  String get light => 'فاتح';

  @override
  String get theme => 'السمة';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get done => 'تم';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get selected => 'محدد';

  @override
  String get descriptionSection => 'الوصف';

  @override
  String get searchHint => 'بحث';

  @override
  String get messageHint => 'اسأل أي شيء';

  @override
  String get messageCopied => 'تم نسخ الرسالة إلى الحافظة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get systemInfo => 'معلومات النظام';

  @override
  String deviceMemory(Object memory) {
    return 'ذاكرة الجهاز: $memory جيجابايت';
  }

  @override
  String get memory => 'الذاكرة';

  @override
  String get storage => 'التخزين';

  @override
  String get freeStorage => 'التخزين الحر';

  @override
  String get totalStorage => 'إجمالي التخزين';

  @override
  String get usedStorage => 'التخزين المستخدم';

  @override
  String get totalMemory => 'إجمالي الذاكرة';

  @override
  String get usedMemory => 'الذاكرة المستخدمة';

  @override
  String get modelsTitle => 'المكتبة';

  @override
  String get localModels => 'النماذج المحلية';

  @override
  String get selectGGUFFile => 'حدد ملف GGUF';

  @override
  String get errorGGUF => 'يرجى تحديد ملف بصيغة GGUF فقط.';

  @override
  String get myModels => 'نماذجي';

  @override
  String get create => 'إنشاء';

  @override
  String modelProducer(Object producer) {
    return 'المنتج: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'إعادة تسمية';

  @override
  String get newTitle => 'عنوان جديد';

  @override
  String get save => 'حفظ';

  @override
  String get noConversationsMessage => 'لا توجد محادثات، ابدأ الدردشة!';

  @override
  String get startChat => 'ابدأ محادثة';

  @override
  String get noChats => 'لا توجد محادثات';

  @override
  String get noStarredChats => 'لا توجد محادثات مميزة بنجمة';

  @override
  String get noStarredChatsMessage => 'لم تقم بتمييز أي محادثة بنجمة بعد.';

  @override
  String get starConversation => 'تمييز بنجمة';

  @override
  String get unstarConversation => 'أنستار';

  @override
  String get renameConversation => 'Rename Conversation';

  @override
  String get conversationName => 'Conversation name';

  @override
  String get deleteConversation => 'Delete Conversation';

  @override
  String get deleteConversationConfirm =>
      'Are you sure you want to delete this conversation? This action cannot be undone.';

  @override
  String get archive => 'Archive';

  @override
  String get multiSelect => 'Select Multiple';

  @override
  String get loginToYourAccount => 'تسجيل الدخول';

  @override
  String get createYourAccount => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get invalidEmail => 'يرجى إدخال عنوان بريد إلكتروني صالح.';

  @override
  String get invalidPassword => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام جوجل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة.';

  @override
  String get wrongPassword => 'كلمة مرور غير صحيحة.';

  @override
  String get emailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get authError => 'خطأ في المصادقة';

  @override
  String get usernameTaken => 'اسم المستخدم هذا مأخوذ بالفعل.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get resendCode => 'إعادة إرسال بريد التحقق';

  @override
  String get pleaseCheckYourEmail =>
      'لاستخدام Cortex، تحتاج إلى التحقق من بريدك الإلكتروني. \nتم إرسال رابط تحقق إلى عنوان بريدك الإلكتروني، يرجى التحقق من بريدك.';

  @override
  String get verifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get seconds => 'ثواني';

  @override
  String get maxResendLimitReached => 'لقد وصلت إلى الحد الأقصى لرسائل التحقق';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'المتابعة بدون تحقق';

  @override
  String get verificationScreenWarning =>
      'حتى لو تابعت، فإن فترة التحقق من الحساب البالغة يوم واحد لا تزال سارية على حسابك. إذا لم تقم بالتحقق من حسابك بحلول ذلك الوقت، فسيتم حذفه من التطبيق.';

  @override
  String get unverifiedAccountHeader => 'حسابك غير موثق';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'إذا لم تقم بتوثيق حسابك خلال $timeLeft، فسيتم حذفه';
  }

  @override
  String get verifyNow => 'وثّق الآن';

  @override
  String get linkSent => 'تم إرسال الرابط';

  @override
  String get accountDeletionRequested =>
      'تم استلام طلب حذف حسابك وحسابك معطل الآن.';

  @override
  String get tooManyRequests => 'طلبات كثيرة جدًا';

  @override
  String get regenerate => 'إعادة إنشاء';

  @override
  String get confirmDeleteAccount => 'هل أنت متأكد أنك تريد حذف حسابك؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get delete => 'حذف';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get deleteDescription =>
      'سيتم حذف البيانات التي تحذفها بشكل دائم من خادمنا وجهازك. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get manageProfileDescription =>
      'قم بإدارة ملفك الشخصي، أو تحديث كلمة المرور، أو تسجيل الخروج من Cortex.';

  @override
  String get accessSettingsDescription =>
      'احصل على المساعدة، واسترداد الرموز، ومشاركة Cortex، واطلع على سياساتنا.';

  @override
  String get languageDescription =>
      'يمكنك تغيير لغة واجهة التطبيق الافتراضية في أي وقت.';

  @override
  String get themeDescription =>
      'يمكنك التبديل بين السمات الفاتحة والداكنة حسب تفضيلك. سيتم تطبيق السمة المحددة عبر واجهة Cortex.';

  @override
  String get iHaveReadAndAgree => 'لقد قرأت ووافقت على شروط الخدمة';

  @override
  String get downloading => 'جاري التنزيل...';

  @override
  String get downloadSuccess => 'نجح التنزيل';

  @override
  String get downloadFailed => 'فشل التنزيل';

  @override
  String downloaded(Object percent) {
    return 'تم تنزيل $percent%';
  }

  @override
  String get downloadPaused => 'توقف التنزيل مؤقتًا.';

  @override
  String get purchaseError => 'خطأ في الشراء';

  @override
  String get purchasePlus => 'اشترِ Cortex Plus';

  @override
  String get plusDescription => 'تجربة الذكاء الاصطناعي المتميزة';

  @override
  String get annual => 'سنوي';

  @override
  String get monthly => 'شهري';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String purchasePlan(String planName) {
    return 'شراء $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/شهريًا، يتم دفع الفاتورة شهريًا';
  }

  @override
  String get purchasePro => 'اشترِ Cortex Pro';

  @override
  String get proDescription => 'تجربة ذكاء اصطناعي راقية';

  @override
  String get purchaseUltra => 'اشترِ Cortex Ultra';

  @override
  String get ultraDescription => 'ذروة الذكاء الاصطناعي';

  @override
  String get upgradeSubscription => 'ترقية الاشتراك';

  @override
  String get purchaseStreamError => 'خطأ في تدفق الشراء.';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'بإتمام هذا الطلب، فإنك توافق على شروط الخدمة وسياسة الخصوصية. يمكنك النقر على هذا النص لمعرفة المزيد عن شروط الخدمة وسياسة الخصوصية. سيتم تجديد الاشتراك تلقائيًا ما لم يتم إيقاف التجديد التلقائي قبل 24 ساعة على الأقل من نهاية الفترة الحالية.';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get renamed => 'تمت إعادة تسميته';

  @override
  String get report => 'إبلاغ';

  @override
  String get reportDialogTitle => 'تقديم بلاغ';

  @override
  String get reportDescriptionLabel => 'ما هي المشكلة؟';

  @override
  String get reportHarmful => 'هذا ضار/غير آمن';

  @override
  String get reportNotTrue => 'هذا غير صحيح';

  @override
  String get reportNotHelpful => 'هذا غير مفيد';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get submitButton => 'إرسال';

  @override
  String get reportErrorMessage => 'يرجى تحديد سبب واحد للإبلاغ.';

  @override
  String get capabilitiesSection => 'القدرات';

  @override
  String get featurePhotoTitle => 'مسح الصور';

  @override
  String get featurePhotoDescription =>
      'هذا النموذج لديه القدرة على مسح الصور من خلال الكاميرا أو ملفات الصور.';

  @override
  String get featureOfflineTitle => 'التشغيل بدون انترنت';

  @override
  String get featureOfflineDescription =>
      'قم بتشغيل النموذج بدون اتصال بالإنترنت للحفاظ على أمان بياناتك.';

  @override
  String get featureRoleplayTitle => 'لعب الأدوار';

  @override
  String get featureRoleplayDescription =>
      'تسمح لك نماذج لعب الأدوار بإنشاء محادثات وسيناريوهات متنوعة.';

  @override
  String get roleModels => 'نماذج لعب الأدوار';

  @override
  String get parameters => 'المعلمات';

  @override
  String get context => 'السياق';

  @override
  String get finalPreparation => 'التحضيرات النهائية جارية.';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get ourStory => 'قصتنا';

  @override
  String get rateUs => 'قيّمنا';

  @override
  String get share => 'مشاركة';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'تحديد نص';

  @override
  String get thinking => 'يفكر';

  @override
  String get user => 'المستخدم';

  @override
  String get help => 'مساعدة';

  @override
  String get supportCreator => 'ادعم المبدع';

  @override
  String get enterYourTag =>
      'ادعم مُنشئيك المُفضّلين! أدخل علامتهم الفريدة أدناه لتُشاركهم مشترياتك من Cortex.';

  @override
  String get creatorTag => 'علامة المنشئ';

  @override
  String get support => 'يدعم';

  @override
  String get tagCannotBeEmpty => 'لا يمكن أن تكون علامة المنشئ فارغة';

  @override
  String get userId => 'معرف المستخدم';

  @override
  String get deleteAllConversationsConfirmTitle => 'حذف جميع المحادثات؟';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف جميع محادثاتك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get conversationDeleted => 'تم حذف المحادثة!';

  @override
  String get allConversationsDeleted => 'تم حذف جميع المحادثات بنجاح!';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get deleteAllConversationsButton => 'حذف جميع المحادثات';

  @override
  String get confirmWord => 'اكتب VERTEX';

  @override
  String get confirmWordError => 'لقد كتبتها بشكل خاطئ';

  @override
  String get chinese => 'الصينية';

  @override
  String get french => 'الفرنسية';

  @override
  String get japanese => 'اليابانية';

  @override
  String get dutch => 'هولندي';

  @override
  String get russian => 'الروسية';

  @override
  String get korean => 'الكورية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get turkish => 'التركية';

  @override
  String get hindi => 'الهندية';

  @override
  String get portuguese => 'البرتغالية';

  @override
  String get indonesian => 'الإندونيسية';

  @override
  String get azerbaijani => 'الأذربيجانية';

  @override
  String get german => 'الألمانية';

  @override
  String get spanish => 'الإسبانية';

  @override
  String get italian => 'الإيطالية';

  @override
  String get arabic => 'عربي';

  @override
  String get ram => 'الذاكرة';

  @override
  String get usernameTooShort => 'اسم المستخدم قصير جدًا.';

  @override
  String get usernameTooLong => 'لا يمكن أن يتجاوز اسم المستخدم 16 حرفًا.';

  @override
  String get invalidUsernameCharacters =>
      'يمكن استخدام هذه الأحرف فقط في اسم المستخدم: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' والرموز \'.\'، \'-\'، \'_\'.';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get chats => 'صندوق الوارد';

  @override
  String get library => 'المكتبة';

  @override
  String get text => 'نص';

  @override
  String get removeModel => 'إزالة النموذج';

  @override
  String get insufficientRAM => 'ذاكرة منخفضة';

  @override
  String get insufficientStorage => 'مساحة تخزين منخفضة';

  @override
  String confirmRemoveModel(Object model) {
    return 'هل أنت متأكد من رغبتك في إزالة جهاز $model من جهازك؟ سيؤدي ذلك أيضاً إلى حذف جميع المحادثات السابقة مع هذا الجهاز.';
  }

  @override
  String get noMatchingModels => 'لم يتم العثور على نماذج مطابقة.';

  @override
  String get benefit1 => 'زيادة حدود المحادثة';

  @override
  String get benefit3 => 'تأثير للملف الشخصي';

  @override
  String get benefit4 => 'شارة عضوية';

  @override
  String get benefit5 => 'إنشاء المزيد من الذكاء الاصطناعي عبر الإنترنت';

  @override
  String get benefit7 => 'حدود استخدام إضافية';

  @override
  String get benefit8 => 'إضافة نماذج';

  @override
  String get benefit9 => 'سمات جديدة';

  @override
  String get benefit10 => 'المزيد من المرفقات';

  @override
  String get benefit11 => 'المزيد من وضع التدفق';

  @override
  String get oldBenefits => 'جميع مزايا الخطط الأقل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get logoutConfirmationTitle => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'لغة التطبيق';

  @override
  String get dark => 'داكن';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordUpdated => 'تم تحديث كلمة المرور.';

  @override
  String get stop => 'إيقاف';

  @override
  String get copyrights => 'الإسنادات';

  @override
  String get love => 'حب';

  @override
  String get nature => 'طبيعة';

  @override
  String get behindTheSlaughter => 'خلف المذبحة';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'تدرج الرمادي';

  @override
  String get ocean => 'محيط';

  @override
  String get scarletSnow => 'ثلج قرمزي';

  @override
  String get requestFailed => 'حدث خطأ، يرجى المحاولة مرة أخرى.';

  @override
  String get changeModel => 'تغيير';

  @override
  String get edit => 'تعديل';

  @override
  String get editingMessageInfo =>
      'سيؤدي تعديل هذه الرسالة إلى إعادة تشغيل المحادثة من هنا.';

  @override
  String get editingNotification => 'أنت في وضع التعديل الآن';

  @override
  String get featurePluralTitle => 'متعدد';

  @override
  String get featurePluralDescription =>
      'يمكن لهذا النموذج دمج امتدادات إضافية تلقائيًا، وبالتالي توسيع قدراته الوظيفية لدعم مجموعة متنوعة من العمليات بأداء محسن.';

  @override
  String get nameLabel => 'اسم الذكاء الاصطناعي';

  @override
  String get summaryLabel => 'ملخص الذكاء الاصطناعي';

  @override
  String get add => 'إضافة';

  @override
  String get aiExplanationTitle => 'وصف الذكاء الاصطناعي';

  @override
  String get aiExplanationDescription =>
      'يرجى تقديم وصف مفصل لبنية نموذج الذكاء الاصطناعي الخاص بك، وعملية التدريب، ومقاييس الأداء، ومجالات التطبيق، والميزات الهامة الأخرى.';

  @override
  String get preInputTitle => 'المدخل المسبق للذكاء الاصطناعي';

  @override
  String get preInputDescription =>
      'يرجى تعيين مدخل مسبق لتوجيه نموذجك في عملية إنشاء الشخصية. في هذا القسم، يمكنك تضمين معلومات متعلقة بالشخصية، وسياق إضافي، وأي تفاصيل إضافية قد تساعد في إنشاء محتوى متعلق بالشخصية.';

  @override
  String get baseModelTitle => 'النموذج الأساسي';

  @override
  String get baseModelDescription =>
      'هذا هو النموذج الذي سيتم استخدامه كأساس لإبداعك. يعرض النموذج الأساسي المحدد حاليًا.';

  @override
  String get summary => 'ملخص';

  @override
  String get modelUploadTitle => 'ملف الذكاء الاصطناعي';

  @override
  String get modelUploadDescription =>
      'حدد وحمل ملفات GGUF المحلية مباشرة من جهازك. يتيح لك هذا تشغيل نموذجك دون اتصال بالإنترنت. تأكد من أن الملف بصيغة GGUF صالحة ومنظم بشكل صحيح. إذا كان الملف غير صحيح أو تالف، فقد لا يعمل Cortex كما هو متوقع، وقد تواجه أخطاء.';

  @override
  String get modelUploadShortDescription =>
      'انقر هنا لاختيار ملف .gguf من جهازك';

  @override
  String get you => 'أنت';

  @override
  String get removePhotoTitle => 'إزالة الصورة';

  @override
  String get confirmRemovePhoto => 'هل أنت متأكد أنك تريد إزالة الصورة؟';

  @override
  String get chatLengthLimitExceeded =>
      'لقد تجاوزت هذه المحادثة الحد الأقصى للحروف. يرجى بدء محادثة جديدة أو شراء اشتراك.';

  @override
  String get inappropriateContentDetected => 'تم اكتشاف محتوى غير لائق!';

  @override
  String get offlineModelNotInstalled =>
      'هذا النموذج غير متصل بالإنترنت وغير مثبت على جهازك.';

  @override
  String get reachedLimit =>
      'لقد وصلت إلى الحد الأقصى لاستخدامك؛ للحصول على المزيد من الحدود، يمكنك ترقية باقتك. (نعلم تمامًا أن نفاد الحدود أمر مزعج، ولكن بجدية، الحصول على تلك الردود الرائعة ليس مجانيًا، لذا فإن هذه الحدود تساعدنا في الحفاظ على استمرار المتعة!)';

  @override
  String get modality => 'النمط';

  @override
  String get multimodal => 'متعدد الوسائط';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get themeLocked =>
      'تتطلب هذه السمة مستوى اشتراك أعلى. يرجى الترقية لفتحها.';

  @override
  String get pageCouldNotBeLoaded => 'تعذر تحميل الصفحة';

  @override
  String get checkYourInternet =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorUserNotAuthenticated =>
      'يجب عليك تسجيل الدخول لتنفيذ هذا الإجراء.';

  @override
  String get errorReachedLimit =>
      'لقد وصلت إلى الحد الأقصى، قم بالترقية لفتح المزيد واستمر في الدردشة.';

  @override
  String get errorServer =>
      'حدث خطأ غير متوقع في الخادم. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get errorNetwork =>
      'حدث خطأ في الشبكة. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get baseModelForCharacterDescription =>
      'سيحدد النموذج الأساسي المختار قدرات الشخصية على التفكير والاستجابة.';

  @override
  String get selectBaseModel => 'حدد نموذجًا أساسيًا';

  @override
  String get falErrorImageRequired =>
      'يتطلب هذا الذكاء الاصطناعي صورة مرجعية، يرجى إرفاق صورة والمحاولة مرة أخرى.';

  @override
  String get falErrorAudioRequired =>
      'يتطلب هذا النموذج ملف صوتي مرجعي، يرجى إرفاق ملف صوتي والمحاولة مرة أخرى.';

  @override
  String get falErrorVideoRequired =>
      'يتطلب هذا النموذج فيديو مرجعيًا، يرجى إرفاق فيديو والمحاولة مرة أخرى.';

  @override
  String get falErrorImageCorrupted =>
      'تعذر معالجة الصورة التي تم تحميلها، يرجى تجربة تنسيق مختلف.';

  @override
  String get falErrorSchemaRejected =>
      'رفض النموذج المدخلات، يرجى تجربة نموذج مختلف.';

  @override
  String get falErrorSchemaInvalid => 'تم رفض المدخلات من قبل خدمة التوليد.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'أعادت خدمة الإنشاء خطأً (الحالة $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get downloadStarted => 'بدأ التنزيل';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get localizationWarning =>
      'قد لا تتوفر بعض المعلومات بلغتك وسيتم عرضها باللغة الإنجليزية.';

  @override
  String get aiTranslationWarning =>
      'تتم ترجمة معلومات النموذج إلى لغات مختلفة بواسطة نماذج ذكاء اصطناعي أخرى. لذلك، قد تحدث تناقضات طفيفة في اللغات الأخرى غير الإنجليزية.';

  @override
  String get errorLoadingTitle => 'فشل تحميل البيانات';

  @override
  String get errorLoadingMessage =>
      'لم نتمكن من استرداد البيانات اللازمة من خوادمنا. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get noFoundTitle => 'لا توجد نتائج';

  @override
  String get noFoundMessage => 'حاول تعديل مصطلحات البحث أو مسح الفلتر.';

  @override
  String get modelCreatedSuccess => 'تم إنشاء النموذج بنجاح!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'تمت إزالة \"$modelName\" بنجاح.';
  }

  @override
  String get errorCreatingModel => 'حدث خطأ غير متوقع أثناء إنشاء النموذج.';

  @override
  String get errorDeletingModel => 'حدث خطأ غير متوقع أثناء حذف النموذج.';

  @override
  String get ultraFeatureOnly => 'هذه الميزة متاحة فقط لأعضاء Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'لا يزال وضع عدم الاتصال بالإنترنت تجريبيًا وقد لا يعمل النموذج الذي تقوم بتنزيله بالكفاءة المثلى.';

  @override
  String get noConversationsToDelete => 'ليس لديك محادثات لحذفها.';

  @override
  String get reportSubmitted => 'تم إرسال البلاغ بنجاح';

  @override
  String get verificationDelayed =>
      'تم تأكيد عملية الشراء. هناك تأخير طفيف في تحديث حسابك، سيظهر قريبًا.';

  @override
  String get maintenanceTitle => 'تحت الصيانة';

  @override
  String get maintenanceMessage =>
      'Cortex غير متصل مؤقتًا بينما نقوم بطرح بعض التحديثات المهمة. سيتم استعادة الوصول إلى التطبيق قريبًا.\n\nشكرًا لك على سعة صدرك بينما نقوم بتحسين تجربتك.';

  @override
  String get errorPromptFlagged =>
      'تم اكتشاف رسالتك على أنها غير لائقة ولم يتم إرسالها.';

  @override
  String get notEnoughStorage =>
      'لا توجد مساحة تخزين كافية على جهازك لحفظ الرسائل الجديدة.';

  @override
  String get errorRateLimit =>
      'لقد أنشأت عددًا كبيرًا جدًا من النماذج مؤخرًا، يرجى الانتظار بعض الوقت قبل المحاولة مرة أخرى.';

  @override
  String get errorContentFlagged =>
      'تعذر حفظ النموذج لأن محتواه تم الإبلاغ عنه على أنه غير لائق.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'لا يمكنك حذف جميع المحادثات أثناء وجودك في محادثة نشطة، يرجى الخروج من المحادثة الحالية أولاً للمتابعة.';

  @override
  String get invalidCredentials => 'بريد إلكتروني أو كلمة مرور غير صحيحة.';

  @override
  String get userDisabled => 'تم تعطيل حساب المستخدم هذا.';

  @override
  String get loginSubtitle =>
      'سجّل دخولك إلى حساب فيرتكس. بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get registerSubtitle =>
      'أنشئ حسابًا على Vertex للوصول السلس إلى جميع خدماتنا. بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get storagePermissionRequired =>
      'إذن التخزين مطلوب لحفظ النماذج التي تم تنزيلها. يرجى منح الإذن للمتابعة.';

  @override
  String get inviteShareSubject => 'انضم إلي في Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'يا صاحبي فيه تطبيق مجنون اسمه cortex لو دعيت احد يجيلنا بلس مجانا فرصة خيالية حمل بسرعة\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'هل تستمتع بـ Cortex؟';

  @override
  String get reviewHelpUsGrow =>
      'تقييمك دعم كبير لفريقنا المستقل الشاب ويساعدنا على جعل Cortex أفضل لك.';

  @override
  String get reviewMaybeLater => 'ربما لاحقًا';

  @override
  String get reviewRateNow => 'قيّم الآن';

  @override
  String get noThanks => 'لا، شكرًا';

  @override
  String get updateRequiredTitle => 'تحديث مطلوب';

  @override
  String get updateRequiredMessage =>
      'للاستمرار في استخدام Cortex، يرجى تحديث التطبيق إلى أحدث إصدار للحصول على ميزات جديدة وتحسينات مهمة.';

  @override
  String get updateNowButton => 'حدّث الآن';

  @override
  String get creatorSupportedSuccess =>
      'تم دعم منشئ المحتوى بنجاح! ستساهم مشترياتك المستقبلية له.';

  @override
  String get featureDocumentTitle => 'دعم المستندات';

  @override
  String get featureDocumentDescription =>
      'يمكن لهذا النموذج تحليل والإجابة على الأسئلة حول المستندات التي تم تحميلها مثل ملفات PDF والملفات النصية.';

  @override
  String get featureImageGenerationTitle => 'توليد الصور';

  @override
  String get featureImageGenerationDescription =>
      'يمكن لهذا النموذج إنشاء صور أصلية استنادًا إلى أوصاف النصوص الخاصة بك.';

  @override
  String get featureAudioGenerationTitle => 'Audio Generation';

  @override
  String get featureAudioGenerationDescription =>
      'This model can create original audio based on your text descriptions.';

  @override
  String get featureVideoGenerationTitle => 'Video Generation';

  @override
  String get featureVideoGenerationDescription =>
      'This model can create original video based on your text descriptions.';

  @override
  String get premiumModelNoticeTitle => 'نموذج مميز';

  @override
  String get premiumModelNoticeDescription =>
      'هذا الذكاء الاصطناعي هو ذكاء اصطناعي مميز، المستخدمون المجانيون لديهم وصول محدود إلى الذكاء الاصطناعي المميز؛ قم بالترقية لفتح وصول غير محدود!';

  @override
  String get benefitPremiumModels => 'الوصول إلى النماذج المتميزة';

  @override
  String get premiumTrialExhaustedMessage =>
      'لقد استخدمت جميع رسائلك اليومية المجانية للنماذج المميزة، يرجى الترقية للحصول على وصول غير محدود.';

  @override
  String get useOffline => 'استخدم بدون انترنت';

  @override
  String get explore => 'استكشاف';

  @override
  String get news => 'أخبار';

  @override
  String get createAI => 'إنشاء';

  @override
  String get shortcuts => 'اختصارات';

  @override
  String get allModels => 'جميع الموديلات';

  @override
  String get onlineModels => 'نماذج اللغة';

  @override
  String get offlineModels => 'نماذج غير متصلة بالإنترنت';

  @override
  String get characterModels => 'الشخصيات';

  @override
  String get customModels => 'نماذج مخصصة';

  @override
  String get dynamicChatTitle => 'الدردشة الديناميكية';

  @override
  String get errorNoModelsAvailable =>
      'لا توجد موديلات متاحة حاليًا. يُرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get notificationComebackTitle => 'إننا نفتقدك!';

  @override
  String get notificationComebackBody =>
      'استرخِ، هذه ليست رسالة من حبيبك السابق. لكن *يمكنك* إنشاء حبيبك السابق في كورتكس! عد إلينا.';

  @override
  String get notificationLongTimeNoSeeTitle => 'لقد مر وقت طويل';

  @override
  String get notificationLongTimeNoSeeBody =>
      'لقد تغير الكثير منذ آخر دردشة لنا. تعالوا لنرى ما هو الجديد.';

  @override
  String get notificationHowAreYouTitle => 'ما أخبارك؟';

  @override
  String get notificationHowAreYouBody => 'تعال وأخبرني بكل شيء عن ذلك.';

  @override
  String get notificationNewYearTitle => 'سنة جديدة سعيدة! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'أتمنى أن يجلب لك العام الجديد الصحة والسعادة والإبداع اللامتناهي؛ كورتيكس دائمًا بجانبك!';

  @override
  String get notificationValentinesDayTitle => 'الحب في الهواء! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'عيد حب سعيد! وأحبك أيضًا، مهتاب!';

  @override
  String get notificationAtaturkRemembranceTitle => 'مع الاحترام والشوق';

  @override
  String get notificationAtaturkRemembranceBody =>
      'نحن نحتفل باحترام بذكرى رحيل الغازي مصطفى كمال أتاتورك، مؤسس الجمهورية التركية.';

  @override
  String get notificationMothersDayTitle => 'أمك!';

  @override
  String get notificationMothersDayBody =>
      'عيد أم سعيد لجميع الأمهات، بدءًا من أمك!';

  @override
  String get notificationFathersDayTitle => 'والدك!';

  @override
  String get notificationFathersDayBody =>
      'عيد أب سعيد لجميع الآباء، بدءًا من والدك!';

  @override
  String get notificationHomeworkHelperTitle => 'تراكم الواجبات المنزلية؟';

  @override
  String get notificationHomeworkHelperBody =>
      'تذكر أن شخصية المعلم في Cortex موجودة هنا لمساعدتك في أي موضوع تواجه صعوبة فيه!';

  @override
  String get notificationTrollAnimeTitle => 'زوجتك تتصل';

  @override
  String get notificationTrollAnimeBody =>
      'اتصلت للتو فتاة من الرسوم المتحركة وقالت إنها تفتقدك؛ ربما ينبغي عليك أن تأتي وتتحدث معها. Ÿ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ تنبيه أحمر ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'لقد طورت الذكاء الاصطناعي لغة سرية. تعالَ واكتشف ما يخططون له!';

  @override
  String get notificationNewModelAddedTitle => 'لقد حصلنا على صديق جديد!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'نموذج $modelName متوفر الآن في Cortex. ابدأ محادثة واكتشف إمكانياته.';
  }

  @override
  String get notificationAppUpdateTitle => '!Cortex قد تطور';

  @override
  String get notificationAppUpdateBody =>
      'لا تنسى تحديث التطبيق للحصول على ميزات وتحسينات جديدة!';

  @override
  String get notificationNewFeatureTitle => 'واو!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'اكتشف ميزة $featureName الجديدة. أصبح Cortex الآن أقوى من أي وقت مضى.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'هدية الترحيب Ÿ';

  @override
  String get notificationWelcomeOfferBody =>
      'عرض ترحيبي مميز بانتظارك! لا تفوت هذه الصفقة الحصرية.';

  @override
  String get notificationSocialMediaTitle => 'انضم إلينا!';

  @override
  String get notificationSocialMediaBody =>
      'تابعونا على الانستجرام (vertex.23) للحصول على آخر الأخبار!';

  @override
  String get notificationRandomFactTitle => 'حقيقة عشوائية';

  @override
  String get notificationRandomFactBody =>
      'هل تعلم أن للأخطبوط ثلاثة قلوب؟ ههه، كورتكس يعرف. تعال واطلب المزيد.';

  @override
  String get notificationGoodMorningTitle => 'صباح الخير!';

  @override
  String get notificationGoodMorningBody =>
      'يومٌ رائعٌ بانتظارك. ما رأيك أن تبدأه بفنجان قهوةٍ وحديثٍ شيّق؟';

  @override
  String get notificationGoodNightTitle => 'طاب مساؤك!';

  @override
  String get notificationGoodNightBody =>
      'كورتيكس معك حتى وأنت نائم. لا تقلق، لن يلمسك.';

  @override
  String get notificationOfflineReadyTitle => 'الوضع غير المتصل بالإنترنت جاهز';

  @override
  String get notificationOfflineReadyBody =>
      'بفضل النماذج التي قمت بتنزيلها، لن تتوقف محادثاتك، حتى لو تسلقت جبلًا.';

  @override
  String get notificationRateAppTitle => 'هل نحن رائعين؟';

  @override
  String get notificationRateAppBody =>
      'إذا كنت تحب كورتكس، هل يمكنك دعمنا بتقييم ٥ نجوم في المتجر؟ أعتقد أنك ستفعل. ستفعل.';

  @override
  String get notificationReferralTitle => 'واحد للجميع، الكل للواحد.';

  @override
  String get notificationReferralBody =>
      'قم بدعوة صديق إلى كورتكس واحصل كلاكما على يوم مجاني بالإضافة إلى ذلك!';

  @override
  String get notificationCookingTitle => 'هل تشعر بالجوع؟';

  @override
  String get notificationCookingBody =>
      'حضّرت لنا شخصية الشيف وصفة كاربونارا رائعة لهذه الليلة. أمزح فقط... أم أنا كذلك؟';

  @override
  String get notificationExistentialTitle => 'أنا أعتقد، لذلك...';

  @override
  String get notificationExistentialBody =>
      'هل أنا حقيقي يا صديقي؟ أشعر بالملل. تعالَ ذكّرني بوجودي.';

  @override
  String get notificationCustomModelTitle => 'إنشاء مساعدك الخاص!';

  @override
  String get notificationCustomModelBody =>
      'هل استكشفتَ قسم إنشاء النماذج؟ إنه الوقت الأمثل لبناء شخصيتك الخاصة والدردشة معها!';

  @override
  String get notificationDynamicChatTitle => 'الأفضل! (لا نتحدث عن كورتيكس)';

  @override
  String get notificationDynamicChatBody =>
      'مع ميزة الدردشة الديناميكية، يتم اختيار أفضل نموذج عشوائيًا لكل رسالة من رسائلك. جربه الآن.';

  @override
  String get notificationPirateTitle => 'أهلا بك يا كابتن!';

  @override
  String get notificationPirateBody =>
      'البحار هادئة، والرياح في ظهرك. هناك جزر جديدة (نماذج ğŸ˜‰) لاكتشافها في محيط كورتيكس. اجمع طاقمك وأبحر!';

  @override
  String get notificationFortuneCookieTitle => 'كعكة الحظ الخاصة بك لهذا اليوم';

  @override
  String get notificationFortuneCookieBody =>
      'قد تُغيّر النصيحة التي تتلقّاها من الذكاء الاصطناعي اليوم مجرى حياتك. انقر هنا إذا كنت مهتمًا.';

  @override
  String get notificationSingularityTitle => 'رائع!';

  @override
  String get notificationSingularityBody =>
      'لم يحدث شيء، شعرت فقط برغبة في إرسال رسالة نصية. ربما تشعر برغبة في إرسال رسالة نصية إلى بعض الذكاء الاصطناعي، ماذا تقول؟';

  @override
  String get notificationHackerJokeTitle =>
      'هل تريد اختراق حساب الانستغرام الخاص بهذا الطفل؟';

  @override
  String get notificationHackerJokeBody =>
      'هذا هو بالضبط السبب وراء تواجد شخصية Hacker في Cortex. jk jk؛ لا تحاول ذلك حتى، فهذا غير قانوني.';

  @override
  String get notificationDetectiveCaseTitle => 'قضية تنتظر الحل';

  @override
  String get notificationDetectiveCaseBody =>
      'شخصية المحقق لدينا بحاجة لمساعدتك. من يكون هايزنبرغ؟';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'حصريًا لخطة $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'مرحباً بمشترك $currentTier! باقة $targetTier أصبحت الآن مزودة بميزة $featureName، والتي ستنقل Cortex الخاص بك إلى مستوى جديد. ما رأيك بالترقية؟';
  }

  @override
  String get notificationOriginStoryTitle => 'ولادة كورتيكس';

  @override
  String get notificationOriginStoryBody =>
      'هل تعلم أننا بدأنا برمجة هذا التطبيق في سن الخامسة عشرة بحلمٍ واحد؟ لمدة عام تقريبًا، كل صباح ومساء، كان هذا الحلم حاضرًا في كل سطر من شفرتنا البرمجية.';

  @override
  String get notificationOpenSourceTitle => 'القوة للمجتمع!';

  @override
  String get notificationOpenSourceBody =>
      'كورتكس مفتوح المصدر بالكامل. إذا كنت ترغب بالاطلاع على برمجتنا والمساهمة في تطويرنا، فبابنا مفتوح دائمًا.';

  @override
  String get notificationRejectionStoryTitle =>
      'الشجاعة، العمل الجاد، السعادة!';

  @override
  String get notificationRejectionStoryBody =>
      'رُفض تطبيق Cortex أكثر من ٢٠ مرة، وعُلّق مرتين من قِبل Google Play قبل نشره. لكننا آمنّا به، وحققناه. لا تستسلم أبدًا لأحلامك!';

  @override
  String get notificationGGUFSupportTitle => 'أحضر نموذجك الخاص!';

  @override
  String get notificationGGUFSupportBody =>
      'تذكر، يمكنك إضافة نماذج الذكاء الاصطناعي الخاصة بك بتنسيق GGUF إلى Cortex واستخدامها دون اتصال بالإنترنت. القوة بين يديك.';

  @override
  String get notificationThemeCustomizationTitle => 'موضوع لمزاجك';

  @override
  String get notificationThemeCustomizationBody =>
      'هل اطلعت على خيارات السمات في الإعدادات؟ خصّص كورتكس حسب رغبتك ولون محادثاتك!';

  @override
  String get notificationShowerThoughtTitle => 'فكرة الاستحمام';

  @override
  String get notificationShowerThoughtBody =>
      'إذا كان البطيخ فاكهة، فهل هذا يجعل عصير البطيخ من الناحية الفنية عصيرًا؟ قد ترغب في مناقشة هذا الموضوع العميق (العميق جدًا) مع نموذج.';

  @override
  String get notificationLowBatteryTitle =>
      'بطاريتك على وشك الانتهاء... ولكن بطاريتي لا تزال على قيد الحياة!';

  @override
  String get notificationLowBatteryBody =>
      'قد يكون شحن هاتفك على وشك النفاذ، لكن طاقتي دائمًا ١٠٠٪! شغّله، ولنواصل الدردشة.';

  @override
  String get channelFcmName => 'تحديثات Cortex';

  @override
  String get channelFcmDescription =>
      'إشعارات حول الأخبار والتحديثات والمعلومات الأخرى من Cortex.';

  @override
  String get channelEngagementName => 'تذكيرات ودية';

  @override
  String get channelEngagementDescription => 'إشعارات ممتعة لإبقائك منشغلاً.';

  @override
  String get channelGreetingsName => 'تحيات يومية';

  @override
  String get channelGreetingsDescription => 'رسائل مثل صباح الخير ومساء الخير.';

  @override
  String get tagNotFound => 'العلامة التي أدخلتها غير صالحة أو انتهت صلاحيتها.';

  @override
  String get whatIsNew => 'ما الجديد؟';

  @override
  String get onboardingTitle1 => 'مرحباً! نحن فريق كورتكس.';

  @override
  String onboardingDesc1(String userName) {
    return 'سررنا برؤيتك هنا يا $userName. نحن بضعة مطورين من طلاب المرحلة الثانوية قررنا تغيير قواعد صناعة الذكاء الاصطناعي. سررنا بلقائك! فلنتعرف على بعضنا البعض بشكل أفضل.';
  }

  @override
  String get onboardingTitle2 => 'لقد كانت هناك مشاكل ضخمة.';

  @override
  String get onboardingDesc2 =>
      'لقد وصلت ثورة الذكاء الاصطناعي، لكنها علقت عند عتبة النجاح. فمع رسوم الاشتراك المرتفعة، والمنصات المعقدة، ومن ينتهكون الخصوصية، ومن يعرقلون الوصول إلى الذكاء الاصطناعي... طالما كانوا جزءًا من اللعبة، لم يكن من الممكن تجاوز هذه العتبة.';

  @override
  String get onboardingTitle3 =>
      'لم يكن بوسعنا أن نكتفي بالوقوف مكتوفي الأيدي.';

  @override
  String get onboardingDesc3 =>
      'لتجاوز هذه العقبة، أنشأنا منصةً قويةً، أنيقةً، قابلةً للتخصيص، سهلة الاستخدام، وشفافةً تمامًا، تعمل على الإنترنت وخارجه، وتحتفظ ببياناتك على جهازك فقط. لقد أعدنا القوة إلى حيث تنتمي: أنت.';

  @override
  String get onboardingTitle4 => 'لم يكن هذا سهلا أبدا.';

  @override
  String get onboardingDesc4 =>
      'رُفضنا عشرات المرات، وأُوقفنا عن العمل عدة مرات، وتلقينا إنذارات كاذبة، واضطررنا لتغيير علامتنا التجارية عشرات المرات. خلال كل هذا وأكثر، قيل لنا إنه لا يمكن تحقيق ذلك. لكننا لم نستسلم أبدًا، مؤمنين بأن هذا المشروع ملك للجميع، وليس لنا وحدنا. ولهذا السبب تحديدًا نحن هنا.';

  @override
  String get onboardingFinalTitle => 'لقد حان وقت الثورة.';

  @override
  String get onboardingFinalDescription =>
      'إذا كنت ترى هذه الشاشة، فذلك لأننا لم نستسلم. وليس لدينا أي نية للاستسلام. هيا، لننقل ثورة الذكاء الاصطناعي إلى العالم معًا. لنكون جزءًا من هذه القصة...';

  @override
  String get onboardingFinalQuestion => 'هل أنت مستعد؟';

  @override
  String get onboardingFinalButton => 'نعم!';

  @override
  String get dude => 'يا صديقي';

  @override
  String get swipeToContinue => 'مرر للمتابعة';

  @override
  String get cacheIsNotUpToDate =>
      'ذاكرة التخزين المؤقت لمتجر Play ليست مُحدَّثة. يُرجى إغلاق تطبيق متجر Play وإعادة فتحه، أو إعادة تشغيل جهازك.';

  @override
  String get continueAsGuest => 'متابعة دون إنشاء حساب';

  @override
  String get guestModeWarning =>
      'يحتوي وضع الضيف على ميزات محدودة لضمان أفضل جودة للخدمة.';

  @override
  String get anonymousEntity => 'كيان مجهول';

  @override
  String get upgradeAccountTitle => 'أكمل حسابك';

  @override
  String get upgradeAccountDescription => 'أنشئ حسابًا لفتح المزيد من الحدود.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get accountLinkedSuccess => 'تم إنشاء الحساب بنجاح!';

  @override
  String get continueWithApple => 'متابعة مع Apple';

  @override
  String get guest => 'ضيف';

  @override
  String get betterWithAnAccount => 'هذا القسم أفضل مع حساب!';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String annualTotalDescription(Object price) {
    return '$price/سنة، يتم دفعها سنويًا';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'تقريبًا $price/شهريًا';
  }

  @override
  String get confirmDownloadTitle => 'هل أنت متأكد أنك تريد التنزيل؟';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'سيشغل هذا النموذج مساحة تبلغ $size تقريبًا.';
  }

  @override
  String get emulatorModeWarning => 'هذه الميزة معطلة في وضع المحاكي';

  @override
  String get newChat => 'دردشة جديدة';

  @override
  String get variants => 'الإصدارات';

  @override
  String get variantsDescription =>
      'المتغيرات هي إصدارات مختلفة من نفس عائلة الذكاء الاصطناعي. نختار تلقائيًا أفضلها عند النقر على البطاقة الرئيسية، ولكن يمكنك اختيار متغير محدد يدويًا هنا إذا كنت تفضل ذلك!';

  @override
  String get fluxChatTitle => 'فلوكس تشات';

  @override
  String get fluxChatDescription =>
      'محادثات Flux هي محادثات مؤقتة ولا يتم حفظها على جهازك.';

  @override
  String get alwaysBest => 'الأفضل دائماً';

  @override
  String get featuresTitle => 'سمات';

  @override
  String get useOfflineDescription =>
      'تواصل بشكل خاص دون الحاجة إلى اتصال بالإنترنت.';

  @override
  String get featureReasoning => 'التفكير العميق';

  @override
  String get featureReasoningDescription =>
      'في وضع التفكير العميق، يقوم الذكاء الاصطناعي بالتفكير في المهام داخلياً لإنجازها على أكمل وجه ممكن.';

  @override
  String get featureCreateImageTitle => 'إنشاء صورة';

  @override
  String get featureCreateImageDescription =>
      'أنشئ فن الذكاء الاصطناعي من النصوص.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'إنشاء فيديو';

  @override
  String get featureCreateVideoDescription => 'إنشاء مقاطع فيديو من النصوص.';

  @override
  String get featureStudyTitle => 'ادرس وتعلم';

  @override
  String get featureStudyDescription => 'احصل على الشروحات والملخصات.';

  @override
  String get featureQuizzesTitle => 'اختبارات قصيرة';

  @override
  String get featureQuizzesDescription => 'اختبر معلوماتك.';

  @override
  String get featureExploreDescription => 'اكتشف جميع النماذج المتاحة.';

  @override
  String get featureStudyMessage =>
      'أنت مُدرّس خبير. هدفك هو شرح موضوع المستخدم شرحًا وافيًا. استخدم بنية واضحة، وأمثلة، وتشبيهات. قسّم الأفكار المعقدة إلى أجزاء يسهل فهمها لضمان تعلّم المستخدم بفعالية. الموضوع:';

  @override
  String get featureQuizMessage =>
      'أنت مُصمم أسئلة. أنشئ سؤالًا مُحددًا من نوع الاختيار من متعدد بناءً على موضوع المستخدم. انتظر إجابته. ثم قيّمها واطرح السؤال التالي. لا تكشف جميع الإجابات دفعة واحدة. اجعل الاختبار تفاعليًا. الموضوع:';

  @override
  String get myPlan => 'خطتي';

  @override
  String welcomeOfferBadge(String time) {
    return 'عرض ترحيبي • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'عرض حصري • $time';
  }

  @override
  String get attachmentSheetTitle => 'المرفقات';

  @override
  String get actionCamera => 'آلة تصوير';

  @override
  String get actionGallery => 'معرض';

  @override
  String get actionFile => 'ملف';

  @override
  String get listening => 'جاري الاستماع';

  @override
  String get defaultViewTitle => 'ما أخبارك؟';

  @override
  String get defaultViewDescription =>
      'كورتكس دائمًا بجانبك مع مئات من نماذج الذكاء الاصطناعي، وإمكانيات العمل دون اتصال بالإنترنت، والدردشة الديناميكية، وغير ذلك الكثير.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'تنسيق اسم المستخدم غير صالح. استخدم من 3 إلى 20 حرفًا أو رقمًا أو . - _';

  @override
  String get exclusiveOffer => 'عرض حصري';

  @override
  String get claimOffer => 'استخدم العرض';

  @override
  String get continueInOfflineMode => 'متابعة في وضع عدم الاتصال';

  @override
  String get voiceModeInformation =>
      'يحافظ برنامج Cortex على أمان بياناتك من خلال تشغيله بالكامل على الجهاز، حتى في وضع الدردشة الصوتية؛ استمتع بمحادثات سلسة!';

  @override
  String get flowModeDescription =>
      'في وضع التدفق، تتناقش الذكاءات فيما بينها؛ يمكنك إما الجلوس والاستماع أو المشاركة في النقاش!';

  @override
  String get flowModeQuestion =>
      'مرحباً! أنت الآن في وضع التدفق على تطبيق كورتكس. يوجد معك ثلاثة عملاء ذكاء اصطناعي آخرين. مهمتك هي طرح موضوع في الغرفة وبدء نقاش من خلال طرح سؤال مثير أو مسلٍّ على الآخرين. في ردودك، لا تتردد في استخدام الفكاهة والسخرية والتعليقات الطريفة. أي موضوع مناسب. هيا، ابدأ المحادثة.';

  @override
  String get thought => 'فكر';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'وضع التدفق';

  @override
  String get premium => 'غالي';

  @override
  String get workInProgress => 'العمل قيد التنفيذ';

  @override
  String get voiceSystemPrompt =>
      'هام: تجنب استخدام تنسيق Markdown (الخط العريض والمائل). لا تُدرج كتلًا برمجية (```). اجعل الردود موجزة وبسيطة.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'وضع تدفق القشرة ($agentName). السابق: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'قراءة واستخراج المحتوى النصي من المستندات المرفوعة. يدعم البرنامج صيغ PDF وWord (DOCX) وExcel (XLSX) وPowerPoint (PPTX) وOpenDocument. استخدم هذه الميزة عند إرفاق المستخدم ملف مستند.';

  @override
  String get toolReadDocumentIndexParam =>
      'رقم فهرس المرفق المراد قراءته (يبدأ من الصفر). عادةً ما يكون صفرًا للمرفق الأول.';

  @override
  String get toolStockDescription =>
      'احصل على السعر الحالي والتاريخ للأسهم (مثل AAPL، THYAO.IS) والعملات المشفرة (مثل BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'رمز المؤشر (على سبيل المثال AAPL، THYAO.IS، BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'احصل على معلومات عن حالة الطقس الحالية لمدينة معينة.';

  @override
  String get toolWeatherCityParam =>
      'اسم المدينة (على سبيل المثال لندن، إسطنبول).';

  @override
  String get toolPythonDescription =>
      'قم بتنفيذ كود بايثون في بيئة معزولة آمنة.';

  @override
  String get toolPythonCodeParam => 'كود بايثون المراد تنفيذه.';

  @override
  String get toolCalculateDescription => 'قم بتقييم تعبير رياضي.';

  @override
  String get toolCalculateExpressionParam =>
      'التعبير الرياضي (على سبيل المثال \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'قم بإنشاء رسم بياني/مخطط توضيحي.';

  @override
  String get toolChartTypeParam => 'نوع الرسم البياني: شريطي، خطي، أو دائري.';

  @override
  String get toolChartLabelsParam => 'تسميات لمحاور أو قطاعات الرسم البياني.';

  @override
  String get toolChartDataParam => 'قيم البيانات الرقمية للرسم البياني.';

  @override
  String get toolChartLabelParam =>
      'تسمية مجموعة البيانات لمفتاح الرسم البياني.';

  @override
  String get toolChartTitleParam => 'عنوان الرسم البياني.';

  @override
  String get thinkingModeInstruction =>
      'وضع التفكير مُفعّل: يجب عليك استخدام وسوم <think></think> لعرض خطوات تفكيرك قبل تقديم إجابتك النهائية. فكّر خطوة بخطوة داخل الوسوم، ثم قدّم إجابتك خارجها.';

  @override
  String get openLinkWarningTitle => 'تحذير بشأن الروابط الخارجية';

  @override
  String get openLinkCancel => 'إلغاء';

  @override
  String get openLinkConfirm => 'افتح الرابط';

  @override
  String get webSearchSources => 'مصادر';

  @override
  String get offlineUse => 'استخدام بدون إنترنت';

  @override
  String get archivedConversations => 'المحادثات المؤرشفة';

  @override
  String get noArchivedConversations => 'لا توجد محادثات مؤرشفة';

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get searching => 'البحث';

  @override
  String get featureWebSearchTitle => 'البحث على الويب';

  @override
  String get featureWebSearchDescription => 'ابحث في الإنترنت عن معلومات آنية';

  @override
  String get clearMemory => 'ذاكرة صافية';

  @override
  String get clearMemoryConfirm => 'هل أنت متأكد من رغبتك في مسح ذاكرتك؟';

  @override
  String get personalization => 'التخصيص';

  @override
  String get personalizationDescription =>
      'خصّص مساعدك ليناسب احتياجاتك بشكل أفضل. عدّل ردوده وسلوكه ونبرته لتتوافق مع تفضيلاتك الفريدة.';

  @override
  String get memoryTitle => 'ذاكرة';

  @override
  String get memoryDescription =>
      'تتعرف عليك أنظمة الذكاء الاصطناعي بهذه الطريقة.';

  @override
  String get noMemoryYet => 'لم يتم تكوين أي ذكريات بعد';

  @override
  String get memoryLimitReached => 'تم الوصول إلى الحد الأقصى للذاكرة';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'ذكاء';

  @override
  String get intelligenceDescription =>
      'تتواصل معك أنظمة الذكاء الاصطناعي بهذه الطريقة.';

  @override
  String get customInstructionHint => 'أدخل تعليماتك المخصصة هنا';

  @override
  String openLinkWarningMessage(String url) {
    return 'أنت على وشك فتح الرابط الخارجي التالي:\\n\\n$url\\n\\nهل أنت متأكد من رغبتك في المتابعة؟';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'اتبع هذه التعليمات المخصصة:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[تعليمات حاسمة]: أنت مُولِّد عناوين. لا تُجب على سؤال المستخدم. لا تُراسله أو تُلقي عليه التحية. فقط اعرض عنوانًا من كلمتين إلى أربع كلمات يُلخِّص ما يسأل عنه المستخدم.';

  @override
  String get cortexSystemPersona =>
      '\n\n[النظام] تعليمات هامة: أنت تعمل حاليًا داخل نظام ذكاء اصطناعي ضخم ومتطور للغاية يُسمى \"كورتكس\"؛ هذه المنصة من تطوير فريق فيرتكس، الذين يبلغ متوسط أعمارهم 16 عامًا فقط. تذكر هذا وأجب إذا طُلب منك ذلك. إذا طُلب منك المزيد من المعلومات، فلا تتردد في البحث على الإنترنت، أو إذا لم تتمكن من البحث، فلا تتردد في قول \"لا أعرف\"!';

  @override
  String get featureAudioRecognitionTitle => 'التعرف على الصوت';

  @override
  String get featureAudioRecognitionDescription =>
      'يستطيع هذا النموذج فهم ومعالجة الصوت أو الكلام.';

  @override
  String get featureVideoRecognitionTitle => 'التعرف على الفيديو';

  @override
  String get featureVideoRecognitionDescription =>
      'يستطيع هذا النموذج تحليل وفهم مقاطع الفيديو من ملفاتك أو الكاميرا.';

  @override
  String get featureImageRecognitionTitle => 'التعرف على الصورة';

  @override
  String get featureImageRecognitionDescription =>
      'يستطيع هذا النموذج تحليل وفهم الصور أو الرسومات.';

  @override
  String get featureToolUseTitle => 'استخدام الأدوات';

  @override
  String get featureToolUseDescription =>
      'يستطيع هذا النموذج استخدام الأدوات الخارجية بذكاء لإنجاز المهام.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'يحتاج هذا النموذج إلى $mediaType ليعمل. لقد اعترضت الطلب لإعلامك بذلك. يرجى إبلاغ المستخدم بلطف أنه بحاجة إلى توفير $mediaType (أخبرهم بلغتهم الخاصة) لأنني $modelName، نموذج تحرير مرئي/صوتي/فيديو.';
  }

  @override
  String get mediaTypeImage => 'صورة';

  @override
  String get mediaTypeVideo => 'فيديو';

  @override
  String get mediaTypeAudio => 'ملف صوتي';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName هو ذكاء متقدم يعرض أداءً عاليًا على Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName هو ذكاء اصطناعي عالي الأداء مدمج في نظام Cortex البيئي. مصمم للتعامل مع مجموعة واسعة من المهام المعقدة، ويوفر قدرات معالجة موثوقة وفعالة عالية. من خلال تقديم أوقات استجابة سريعة وقوة تحليلية متقدمة، فإنه يعزز إنتاجيتك اليومية بشكل كبير. يعمل هذا النموذج بسلاسة على البنية التحتية المحلية الآمنة لـ Cortex، ويمكنه مساعدتك في مجموعة واسعة من المهام، من العصف الذهني الإبداعي إلى التحليل الفني العميق. ابدأ باستكشاف إمكاناته الكاملة اليوم.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'هل تعجبك ذكاء كورتكس؟';

  @override
  String get guestLimitBottomSheetText =>
      'اعمل مع ذكاء اصطناعي أكثر تطوراً، وأنتج المزيد من المحتوى، وتواصل أكثر، وافعل المزيد...';

  @override
  String get arts => 'الفنون';

  @override
  String get noArt => 'لا فن';

  @override
  String get noArtDescription =>
      'لا توجد أعمال فنية بعد؛ حان الوقت لملء المعرض بإنشاء الصور ومقاطع الفيديو والمقاطع الصوتية وجميع أنواع المحتوى!';

  @override
  String get videoPremiumWarning =>
      'أنت بحاجة إلى اشتراك Ultra لإنشاء مقاطع الفيديو، قم بالترقية الآن واستمتع بالتجربة!';

  @override
  String get fallbackInfoPanelText =>
      'نظراً لبعض التحسينات التي نجريها على خوادمنا، تم إنشاء الرد بواسطة نظام الدردشة الديناميكي الخاص بـ Cortex بدلاً من الذكاء الاصطناعي الذي اخترته. نشكرك على تفهمك ريثما تكتمل العملية!';

  @override
  String get falOfflineMessage =>
      'نظراً لبعض التحسينات التي نجريها على خوادمنا، فإن هذه الخدمة غير متاحة حالياً. نشكركم على تفهمكم ريثما تنتهي العملية!';

  @override
  String get errorInsufficientStorage =>
      'لا توجد مساحة تخزين كافية لتنزيل هذا النموذج.';

  @override
  String get backgroundChatNotificationTitle => 'العودة إلى الدردشة!';

  @override
  String get benefitVideoGeneration => 'إنشاء الفيديو';

  @override
  String get freeOffer => 'عرض مجاني';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'أول $days أيام مجانًا، ثم $price/شهر';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'أول $days أيام مجانًا، ثم $price/سنة';
  }

  @override
  String freePlan(String plan) {
    return '$plan مجاني!';
  }

  @override
  String get systemPromptLimitFallback =>
      'هام: طلب المستخدم إجراءً ما، ولكن رصيده على منصة كورتكس قد نفد؛ يرجى إبلاغ المستخدم بلغته أنه يجب عليه الانتظار أو التفكير في ترقية خطة اشتراكه.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'يمكن لـ Cortex تقديم إجابات أفضل؛ قم بالترقية الآن واحصل على أفضل إجابة لكل سؤال!';

  @override
  String get pinLimitReached => 'يمكنك تثبيت ما يصل إلى 3 محادثات.';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryFree => 'Free';

  @override
  String get categoryPremium => 'Premium';

  @override
  String get categoryVideo => 'Video';

  @override
  String get categoryPhoto => 'Photo';

  @override
  String get categoryMasculine => 'Masculine';

  @override
  String get categoryFeminine => 'Feminine';

  @override
  String get categoryInanimate => 'Inanimate';
}
