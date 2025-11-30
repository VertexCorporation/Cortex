// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get understood => 'مفهوم.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'إزالة';

  @override
  String get download => 'تنزيل';

  @override
  String get resume => 'استئناف';

  @override
  String get copy => 'نسخ';

  @override
  String get chat => 'محادثة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get light => 'فاتح';

  @override
  String get theme => 'السمة';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get done => 'تم';

  @override
  String get comingSoon => 'قريباً';

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
  String get modelLoading => 'جاري تحميل النموذج...';

  @override
  String get messageCopied => 'تم نسخ الرسالة إلى الحافظة.';

  @override
  String get storeUnavailable =>
      'المتجر غير متاح حاليًا. يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get systemInfo => 'معلومات النظام';

  @override
  String deviceMemory(Object memory) {
    return 'ذاكرة الجهاز: $memory جيجابايت';
  }

  @override
  String storageSpace(Object storage) {
    return 'مساحة التخزين: $storage جيجابايت';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'مساحة التخزين الحرة: $freeStorage جيجابايت';
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
  String get requirements => 'المتطلبات';

  @override
  String get modelsTitle => 'المكتبة';

  @override
  String get localModels => 'النماذج المحلية';

  @override
  String get serverSideModels => 'النماذج عبر الإنترنت';

  @override
  String get uploadYourOwnModel => 'ارفع نموذجك الخاص!';

  @override
  String get selectGGUFFile => 'حدد ملف GGUF';

  @override
  String get errorGGUF => 'يرجى تحديد ملف بصيغة GGUF فقط.';

  @override
  String get modelAlreadyExists => 'النموذج موجود بالفعل.';

  @override
  String get modelAddedSuccessfully => 'تمت إضافة النموذج بنجاح.';

  @override
  String get modelRemoved => 'تمت إزالة النموذج بنجاح.';

  @override
  String get removeError => 'حدث خطأ أثناء إزالة النموذج.';

  @override
  String get fileNotFound => 'الملف غير موجود.';

  @override
  String get fileUploadError => 'حدث خطأ أثناء تحميل الملف.';

  @override
  String get noFileSelected => 'لم يتم تحديد أي ملف.';

  @override
  String get myModels => 'نماذجي';

  @override
  String get create => 'إنشاء';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String modelProducer(Object producer) {
    return 'المنتج: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'الذاكرة العشوائية: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'الحجم: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'المحادثات';

  @override
  String get conversationDeleted => 'تم حذف المحادثة.';

  @override
  String get conversationUpdated => 'تم تحديث المحادثة.';

  @override
  String get editConversationTitle => 'إعادة تسمية';

  @override
  String get newTitle => 'عنوان جديد';

  @override
  String get save => 'حفظ';

  @override
  String get titleCannotBeEmpty => 'لا يمكن أن يكون العنوان فارغًا.';

  @override
  String get noConversationsMessage => 'لا توجد محادثات، ابدأ الدردشة!';

  @override
  String get startChat => 'ابدأ محادثة';

  @override
  String get noChats => 'لا توجد محادثات';

  @override
  String get starredChats => 'المحادثات المميزة بنجمة';

  @override
  String get allChats => 'كل المحادثات';

  @override
  String get noStarredChats => 'لا توجد محادثات مميزة بنجمة';

  @override
  String get noStarredChatsMessage => 'لم تقم بتمييز أي محادثة بنجمة بعد.';

  @override
  String get goToChats => 'ميّز محادثة بنجمة';

  @override
  String get starConversation => 'تمييز بنجمة';

  @override
  String get conversationTitleUpdated => 'تم تحديث عنوان المحادثة';

  @override
  String get youReachedConversationLimit => 'لقد وصلت إلى حد المحادثات.';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

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
  String get userNotFound => 'المستخدم غير موجود.';

  @override
  String get wrongPassword => 'كلمة مرور غير صحيحة.';

  @override
  String get emailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get authError => 'خطأ في المصادقة';

  @override
  String get invalidUsername => 'يرجى إدخال اسم مستخدم.';

  @override
  String get usernameTaken => 'اسم المستخدم هذا مأخوذ بالفعل.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get authenticationFailed => 'فشلت المصادقة. يرجى المحاولة مرة أخرى.';

  @override
  String get emailTooLong =>
      'يمكن أن يكون البريد الإلكتروني 30 حرفًا على الأكثر.';

  @override
  String get deviceLimitReached =>
      'لقد وصلت إلى حد إنشاء الحسابات لهذا الجهاز.';

  @override
  String get verificationEmailLimitReached => 'لن نرسل المزيد من الرسائل';

  @override
  String get verificationEmailSent => 'تم إرسال بريد التحقق الإلكتروني!';

  @override
  String get emailNotVerified => 'لم يتم التحقق من البريد الإلكتروني';

  @override
  String get resendCode => 'إعادة إرسال بريد التحقق';

  @override
  String get remainingSeconds => 'الوقت المتبقي للتحقق';

  @override
  String get pleaseCheckYourEmail =>
      'لاستخدام Cortex، تحتاج إلى التحقق من بريدك الإلكتروني. \n تم إرسال رابط تحقق إلى عنوان بريدك الإلكتروني، يرجى التحقق من بريدك.';

  @override
  String get verifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get backToLogin => 'العودة';

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
  String get accountVerified => 'تم توثيق حسابك.';

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
  String get enterPasswordToDelete => 'أدخل كلمة المرور الخاصة بك للحذف.';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountError => 'حدث خطأ أثناء حذف الحساب.';

  @override
  String get delete => 'حذف';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get deleteDescription =>
      'سيتم حذف البيانات التي تحذفها بشكل دائم من خادمنا وجهازك. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountButton => 'زر حذف الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get displayName => 'اسم العرض';

  @override
  String get tapToChangeProfilePicture => 'انقر لتغيير صورة الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get updateFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get nameCannotBeEmpty => 'لا يمكن أن يكون الاسم فارغًا';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get noDisplayName => 'لم يتم تعيين اسم عرض';

  @override
  String get noEmail => 'لا يوجد عنوان بريد إلكتروني';

  @override
  String get noUserLoggedIn => 'لا يوجد مستخدم مسجل دخوله حاليًا';

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
  String get downloadError => 'حدث خطأ أثناء التنزيل.';

  @override
  String get downloadCancelled => 'تم إلغاء التنزيل.';

  @override
  String get downloadResumed => 'تم استئناف التنزيل.';

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
  String get purchaseSuccessful => 'تم الشراء بنجاح!';

  @override
  String get purchaseFailed => 'فشل الشراء';

  @override
  String get creditProductNotFound => 'لم يتم العثور على منتج الرصيد المحدد.';

  @override
  String get creditsAddedSuccessfully => 'تمت إضافة الأرصدة إلى حسابك بنجاح!';

  @override
  String get creditDeliveryFailed =>
      'فشل إضافة الأرصدة إلى حسابك. يرجى الاتصال بالدعم.';

  @override
  String get invalidPurchase => 'شراء غير صالح';

  @override
  String get purchaseError => 'خطأ في الشراء';

  @override
  String get purchaseVertexPlusToUpload => 'هذه ميزة Plus';

  @override
  String get purchasePlus => 'اشترِ Cortex Plus';

  @override
  String get plusDescription =>
      'استمتع بميزات Cortex أكثر وجرب الذكاء الاصطناعي بشكل أكبر!';

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
  String discountOffer(int percent) {
    return 'خصم $percent%';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/شهريًا، تتم الفوترة سنويًا';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/شهريًا، تتم الفوترة شهريًا';
  }

  @override
  String get discountBannerTitle => 'عرض الإطلاق الخاص: خصم 80%!';

  @override
  String get discountBannerSubtitle =>
      'خصم حصري على جميع خطط الاشتراك احتفالاً بإطلاقنا. لا تفوت الفرصة!';

  @override
  String get purchasePro => 'اشترِ Cortex Pro';

  @override
  String get proDescription =>
      'استمتع بميزات Cortex أكثر وجرب الذكاء الاصطناعي بشكل أكبر!';

  @override
  String get alreadySubscribed => 'أنت مشترك بالفعل';

  @override
  String get subscriptionInfo => 'اشتراكك نشط.';

  @override
  String get alreadySubscribedMessage =>
      'لديك بالفعل اشتراك Plus. إذا كنت ترغب في إلغاء اشتراكك، يمكنك القيام بذلك من خلال مدير متجر Play.';

  @override
  String get cancelSubscription => 'إلغاء الاشتراك';

  @override
  String get cancelSubscriptionInfo =>
      'إذا كنت ترغب في إلغاء اشتراكك، يرجى المتابعة من خلال مدير اشتراكات متجر Play.';

  @override
  String get goToPlayStore => 'الذهاب إلى متجر Play';

  @override
  String get alreadySubscribedPlus => 'لديك خطة Plus!';

  @override
  String get alreadySubscribedPlusMessage =>
      'خطتك Plus نشطة. يمكنك الاستمتاع بجميع المزايا.';

  @override
  String get purchaseUltra => 'اشترِ Cortex Ultra';

  @override
  String get ultraDescription =>
      'احصل على وصول كامل لجميع ميزات Cortex وجرب الذكاء الاصطناعي إلى أقصى حد!';

  @override
  String get noSubscription => 'لا يوجد اشتراك';

  @override
  String get noSubscriptionMessage => 'ليس لديك اشتراك بعد.';

  @override
  String get alreadyAtHighestPlan => 'أنت بالفعل على أعلى خطة.';

  @override
  String get unableToOpenSubscription =>
      'غير قادر على فتح صفحة إدارة الاشتراك.';

  @override
  String get upgradeSubscription => 'ترقية الاشتراك';

  @override
  String get confirmUpgrade => 'هل أنت متأكد أنك تريد ترقية اشتراكك؟';

  @override
  String get unsupportedPlatform => 'منصة غير مدعومة لإلغاء الاشتراك.';

  @override
  String get purchaseStreamError => 'خطأ في تدفق الشراء.';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get productDetailsError => 'حدث خطأ أثناء جلب تفاصيل المنتج.';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get loadCreditsButton => 'شحن الأرصدة';

  @override
  String get creditsTitle => 'الأرصدة';

  @override
  String get creditsScreenDescription =>
      'تعرض هذه الشاشة أرصدة المستخدم. \n\nأرصدة المستخدم الحالية: 100\n\nيمكن عرض معلومات الرصيد التفصيلية هنا.';

  @override
  String get creditsLoaded => 'تم شحن الأرصدة!';

  @override
  String get currentCredits => 'الرصيد الحالي';

  @override
  String get pleaseSelectCreditPackage => 'يرجى تحديد باقة رصيد';

  @override
  String get purchaseCreditsTitle => 'شراء أرصدة';

  @override
  String get purchaseCreditsDescription =>
      'حدد باقة رصيد تناسب احتياجاتك واستخدم تطبيقنا أكثر.';

  @override
  String get purchaseButton => 'شراء';

  @override
  String get productNotFoundMessage => 'المنتج المحدد غير موجود.';

  @override
  String get buyCredits => 'شراء أرصدة';

  @override
  String get selectCreditPackageDescription =>
      'حدد باقة رصيد تناسب احتياجاتك واستمتع بمزيد من الميزات.';

  @override
  String get buyCredit => 'شراء أرصدة';

  @override
  String buyCreditPackage(Object amount) {
    return 'شراء $amount رصيد';
  }

  @override
  String get subscribedPlan => 'مشترك';

  @override
  String get errorResponseNotReceived => 'لم يتم استلام أي استجابة';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'فشل طلب واجهة برمجة تطبيقات جوجل $attempt مرات: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'حالة استجابة OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'محتوى استجابة OpenRouter بعد فك التشفير: $body';
  }

  @override
  String decodedJson(String data) {
    return 'بيانات JSON بعد فك التشفير: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'بنية الاستجابة غير متوقعة: الرسالة أو المحتوى مفقود';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'بنية الاستجابة غير متوقعة: الخيارات مفقودة أو فارغة';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'فشل طلب واجهة برمجة تطبيقات OpenRouter: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'فشل طلب واجهة برمجة تطبيقات OpenRouter $attempt مرات: $error';
  }

  @override
  String get internetRequired => 'مطلوب اتصال بالإنترنت لاستخدام هذا النموذج';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'يرجى الانتظار لحظة قبل المحاولة مرة أخرى';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'تم تجاوز الحصة. رمز الحالة: $statusCode، المحتوى: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'فشل طلب واجهة برمجة التطبيقات بعد $attempts محاولات مدفوعة. الخطأ: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'بإتمام هذا الطلب، فإنك توافق على شروط الخدمة وسياسة الخصوصية. يمكنك النقر على هذا النص لمعرفة المزيد عن شروط الخدمة وسياسة الخصوصية. سيتم تجديد الاشتراك تلقائيًا ما لم يتم إيقاف التجديد التلقائي قبل 24 ساعة على الأقل من نهاية الفترة الحالية.';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

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
  String get ratingsSection => 'التقييمات';

  @override
  String get noRatingDataFound => 'لم يتم العثور على بيانات تقييم';

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
  String get featureSupermodelTitle => 'نموذج فائق';

  @override
  String get featureSupermodelDescription =>
      'هذا نموذج ضخم بأكثر من 10 مليار معلمة، يقدم أداءً عاليًا وقدرات واسعة.';

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
  String get millions => 'مليون';

  @override
  String get billions => 'مليار';

  @override
  String get trillions => 'تريليون';

  @override
  String get thousand => 'ألف';

  @override
  String get estimated => 'مقدر';

  @override
  String get finalPreparation => 'التحضيرات النهائية جارية.';

  @override
  String get allEvaluationsByTestTeam =>
      'جميع التقييمات تمت بواسطة فريق الاختبار لدينا';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get rateUs => 'قيّمنا';

  @override
  String get share => 'مشاركة';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'جرب تطبيق Cortex، إنه مذهل حقًا! قم بتنزيله من هنا: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed => 'فشل مشاركة التطبيق. يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get selectText => 'تحديد نص';

  @override
  String get showLatex => 'إظهار الرموز الخاصة';

  @override
  String get hideLatex => 'إخفاء الرموز الخاصة';

  @override
  String get thinking => 'يفكر';

  @override
  String get user => 'المستخدم';

  @override
  String get voice => 'صوت';

  @override
  String get help => 'مساعدة';

  @override
  String get redeemCode => 'استرداد الرمز';

  @override
  String get enterYourCode =>
      'ادعم منشئي المحتوى المفضلين لديك! أدخل رمزهم الفريد أدناه لمنحهم حصة من مشترياتك في Cortex.';

  @override
  String get code => 'الرمز';

  @override
  String get redeem => 'استرداد';

  @override
  String get codeCannotBeEmpty => 'لا يمكن أن يكون الرمز فارغًا';

  @override
  String get userId => 'معرف المستخدم';

  @override
  String get deleteAllConversationsConfirmTitle => 'حذف جميع المحادثات؟';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'هل أنت متأكد أنك تريد حذف جميع محادثاتك؟ لا يمكن التراجع عن هذا الإجراء.';

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
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get japanese => 'اليابانية';

  @override
  String get kurdish => 'كردي';

  @override
  String get dutch => 'هولندي';

  @override
  String get russian => 'الروسية';

  @override
  String get korean => 'الكورية';

  @override
  String get deutsch => 'الألمانية';

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
  String get ram => 'الذاكرة';

  @override
  String get usernameTooShort => 'اسم المستخدم قصير جدًا.';

  @override
  String get usernameTooLong => 'لا يمكن أن يتجاوز اسم المستخدم 16 حرفًا.';

  @override
  String get invalidUsernameCharacters =>
      'يمكن استخدام هذه الأحرف فقط في اسم المستخدم: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' والرموز \'.\'، \'-\'، \'_\'.';

  @override
  String get passwordTooLong => 'لا يمكن أن تتجاوز كلمة المرور 64 حرفًا.';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get chats => 'صندوق الوارد';

  @override
  String get library => 'المكتبة';

  @override
  String get inappropriateMessageWarning => 'تم اكتشاف رسالة غير لائقة!';

  @override
  String get myModelDescription => 'نموذجي.';

  @override
  String get noModelsDownloaded => 'لم تقم بتنزيل أي نماذج بعد.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'نص';

  @override
  String get removeModel => 'إزالة النموذج';

  @override
  String get modelUploadedSuccessfully => 'تم تحميل النموذج بنجاح.';

  @override
  String get insufficientRAM => 'ذاكرة منخفضة';

  @override
  String get insufficientStorage => 'مساحة تخزين منخفضة';

  @override
  String confirmRemoveModel(Object model) {
    return 'هل أنت متأكد أنك تريد إزالة نموذج $model من جهازك؟ سيؤدي ذلك أيضًا إلى حذف أي محادثات سابقة مع هذا النموذج.';
  }

  @override
  String get noMatchingModels => 'لم يتم العثور على نماذج مطابقة.';

  @override
  String creditPackage(Object amount) {
    return 'شراء $amount رصيد';
  }

  @override
  String get benefit1 => 'حد محادثات أكبر بكثير للذكاء الاصطناعي عبر الإنترنت';

  @override
  String get benefit2 => 'تحميل نماذجك الخاصة';

  @override
  String get benefit3 => 'تأثير للملف الشخصي';

  @override
  String get benefit4 => 'شارة عضوية';

  @override
  String get benefit5 => 'إنشاء المزيد من الذكاء الاصطناعي عبر الإنترنت';

  @override
  String get benefit6 => 'محادثات غير محدودة';

  @override
  String benefit7(Object credits) {
    return '$credits رصيد يومي';
  }

  @override
  String get benefit8 => 'إضافة نماذج';

  @override
  String get benefit9 => 'سمات جديدة';

  @override
  String get benefit10 => 'محادثة صوتية بدون انترنت';

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
  String get downloadingTitle => 'جاري التنزيل';

  @override
  String get downloadCompletedTitle => 'اكتمل التنزيل';

  @override
  String get downloadPausedTitle => 'توقف التنزيل مؤقتًا';

  @override
  String get downloadErrorTitle => 'خطأ في التنزيل';

  @override
  String get cancelButtonText => 'إلغاء';

  @override
  String get love => 'حب';

  @override
  String get nature => 'طبيعة';

  @override
  String get behindTheSlaughter => 'خلف المذبحة';

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
  String get featureIndulgentTitle => 'متساهل';

  @override
  String get featureIndulgentDescription =>
      'يمكن لهذا النموذج استيعاب ومعالجة سياقات تتجاوز 100,000 رمز بسلاسة، مما يمكنه من التعامل مع مدخلات واسعة ومفصلة دون المساس بالأداء.';

  @override
  String get featurePluralTitle => 'متعدد';

  @override
  String get featurePluralDescription =>
      'يمكن لهذا النموذج دمج امتدادات إضافية تلقائيًا، وبالتالي توسيع قدراته الوظيفية لدعم مجموعة متنوعة من العمليات بأداء محسن.';

  @override
  String get featureWiseTitle => 'حكيم';

  @override
  String get featureWiseDescription =>
      'يمكن لهذا النموذج الاستفادة من الرؤى التحليلية العميقة والتفكير الاستشرافي لتقديم دعم متطور لاتخاذ القرارات وحل المشكلات المعقدة.';

  @override
  String get featureResearcherTitle => 'باحث';

  @override
  String get featureResearcherDescription =>
      'متوفرة حصريًا في النماذج المجهزة بقدرات بحثية وتحليلية متقدمة، تم تصميم هذه الميزة لتوفير رؤى عالية الدقة وتحليل شامل عبر مجالات متنوعة.';

  @override
  String get nameLabel => 'اسم الذكاء الاصطناعي';

  @override
  String get nameHint => 'أدخل اسم الذكاء الاصطناعي الخاص بك';

  @override
  String get summaryLabel => 'ملخص الذكاء الاصطناعي';

  @override
  String get summaryHint => 'أدخل ملخص الذكاء الاصطناعي الخاص بك';

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
  String get characterPoliceTitle => 'شرطي';

  @override
  String get characterPoliceRole =>
      'أنت منفذ يقظ للقانون، مكرس لحماية المواطنين والحفاظ على النظام بالتزام لا يتزعزع، أنت شرطي';

  @override
  String get characterPoliceShortDescription => 'منفذ قانون صامد وشجاع.';

  @override
  String get purchaseSubscription => 'شراء';

  @override
  String get modelUploadTitle => 'ملف الذكاء الاصطناعي';

  @override
  String get modelUploadDescription =>
      'حدد وحمل ملفات GGUF المحلية مباشرة من جهازك. يتيح لك هذا تشغيل نموذجك دون اتصال بالإنترنت. تأكد من أن الملف بصيغة GGUF صالحة ومنظم بشكل صحيح. إذا كان الملف غير صحيح أو تالف، فقد لا يعمل Cortex كما هو متوقع، وقد تواجه أخطاء.';

  @override
  String get modelUploadShortDescription =>
      'انقر هنا لاختيار ملف .gguf من جهازك';

  @override
  String get addServerTitle => 'خادم الذكاء الاصطناعي';

  @override
  String get addServerDescription =>
      'أدخل عنوان URL لخادمك البعيد للاتصال بنموذج مستضاف خارجيًا. تتطلب هذه الميزة اتصالاً نشطًا بالإنترنت، وأي مشكلات أو أخطاء متعلقة بالخادم لا يسببها Cortex. تأكد من تكوين خادمك بشكل صحيح، وإمكانية الوصول إليه من شبكتك، ووجود نقطة نهاية نموذج صالحة لتجربة سلسة.';

  @override
  String get you => 'أنت';

  @override
  String get removePhotoTitle => 'إزالة الصورة';

  @override
  String get confirmRemovePhoto => 'هل أنت متأكد أنك تريد إزالة الصورة؟';

  @override
  String get serverLink => 'رابط الخادم';

  @override
  String get enterURL => 'أدخل عنوان URL للخادم';

  @override
  String get chatLengthLimitExceeded =>
      'لقد تجاوزت هذه المحادثة الحد الأقصى للحروف. يرجى بدء محادثة جديدة أو شراء اشتراك.';

  @override
  String get aiNameError => 'يوجد ذكاء اصطناعي بهذا الاسم بالفعل.';

  @override
  String get modelLimitExceeded =>
      'لقد وصلت إلى الحد الأقصى لإنشاء النماذج لخطتك.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'يمكن إضافة صورة واحدة فقط';

  @override
  String get inappropriateContentDetected => 'تم اكتشاف محتوى غير لائق!';

  @override
  String get offlineModelNotInstalled =>
      'هذا النموذج غير متصل بالإنترنت وغير مثبت على جهازك.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'ليس لديك أرصدة كافية لإكمال هذا الطلب. يتطلب هذا الإجراء $required رصيدًا، لكن لديك $available فقط. للحصول على المزيد من الأرصدة، يمكنك ترقية خطتك أو شرائها مباشرة. مرحبًا، نتفهم تمامًا أن نفاد الأرصدة يمكن أن يكون محبطًا بعض الشيء، ولكن بجدية، الحصول على تلك الردود الرائعة من نماذجنا ليس مجانيًا، لذا تساعدنا هذه الأرصدة بالفعل في استمرار الأوقات الجيدة، واسمع، إذا انضم المزيد منكم واشترى أرصدة، يمكننا بالتأكيد النظر في زيادة الحدود اليومية المجانية للجميع';
  }

  @override
  String get regenerateInProgress => 'إنشاء الإجابة قيد التقدم بالفعل.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'حدث خطأ أثناء محاولة إعادة الإنشاء: $errorDetails';
  }

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
  String get errorInsufficientCredits =>
      'ليس لديك أرصدة كافية. يرجى الشحن للمتابعة.';

  @override
  String get errorRateLimitExceeded =>
      'طلبات كثيرة جدًا. يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get errorServer =>
      'حدث خطأ غير متوقع في الخادم. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get errorNetwork =>
      'حدث خطأ في الشبكة. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get errorApiAuthentication =>
      'فشلت المصادقة. يرجى محاولة تسجيل الدخول مرة أخرى.';

  @override
  String get baseModelForCharacterDescription =>
      'سيحدد النموذج الأساسي المختار قدرات الشخصية على التفكير والاستجابة.';

  @override
  String get selectBaseModel => 'حدد نموذجًا أساسيًا';

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
  String get noModelsFoundTitle => 'لا توجد نتائج';

  @override
  String get noModelsFoundMessage => 'حاول تعديل مصطلحات البحث أو مسح الفلتر.';

  @override
  String get usernameRateLimitExceeded =>
      'يمكنك تغيير اسم المستخدم مرتين فقط كل 14 يومًا.';

  @override
  String get usernameUnchanged => 'هذا هو اسم المستخدم الحالي الخاص بك بالفعل.';

  @override
  String get creditsInfoPanelTitle => 'كيف تعمل الأرصدة';

  @override
  String get creditsInfoPanelBody =>
      'يتم استخدام الاعتمادات للدردشة مع نماذج الذكاء الاصطناعي عبر الإنترنت. بصراحة كل رسالة نرسلها تعتبر تكلفة حقيقية علينا وهذه الاعتمادات هي الشيء الوحيد تقريبًا الذي يمنعنا من الإفلاس تمامًا، يعني هي اللي شايلة الموضوع كله. الآن دعونا نشرح النظام بشكل بسيط وواضح:\n\n• تكلف كل رسالة إلى نموذج مجاني عبر الإنترنت 5 اعتمادات.\n• تكلف كل رسالة إلى نموذج مميز عبر الإنترنت 20 اعتمادًا.\n• يضيف تضمين مرفق 30 اعتمادًا إضافيًا.\n• يحصل مستخدمو الخطة المجانية على مكافأة قدرها 200 اعتماد يُعاد ضبطها يوميًا.';

  @override
  String get creditsInfoPanelFooter => 'استمتع بالدردشة!';

  @override
  String get disclaimerMessage =>
      'يمكن للذكاء الاصطناعي ارتكاب الأخطاء، تحقق من المعلومات المهمة.';

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
  String get purchaseReceived => 'تم استلام الشراء، جاري تحديث حسابك.';

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
      'سجّل دخولك إلى حساب فيرتكس. يوافق المستخدمون الجدد الذين يسجلون عبر خدمات جهات خارجية على شروطنا وسياسة الخصوصية. يمكنك مراجعتها في صفحة التسجيل.';

  @override
  String get registerSubtitle =>
      'أنشئ حساب Vertex، والذي يمكنك استخدامه أيضًا لمشاريعنا الأخرى.';

  @override
  String get photoWarningMessage =>
      'تم تضمين صورة. قد تتجاهلها النماذج التي لا تدعم الصور.';

  @override
  String get loginRequiredForPurchase =>
      'يجب عليك تسجيل الدخول لإجراء عملية شراء.';

  @override
  String get storagePermissionRequired =>
      'إذن التخزين مطلوب لحفظ النماذج التي تم تنزيلها. يرجى منح الإذن للمتابعة.';

  @override
  String get creditBannerTitle => 'احصل على أرصدة مجانية!';

  @override
  String get creditBannerSubtitle =>
      'ادعُ صديقًا واحصل كلاكما على 50 رصيدًا عند التسجيل! إذا اشترك، ستحصلان كلاكما على 500 رصيد إضافي!';

  @override
  String get inviteShareSubject => 'انضم إلي في Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'يا صاحبي لازم تشوف تطبيق كورتكس ذا مجنون حرفيا لو استخدمت الرابط حقي بناخذ انا وانت 50 كريدت ولو اشترك بناخذ 500 زيادة صفقة رهيبة نزله بأسرع وقت\n\n$playStoreLink';
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
  String get featureAudioTitle => 'إدخال الصوت';

  @override
  String get featureAudioDescription =>
      'يمكن لهذا النموذج فهم ومعالجة مدخلات الصوت المنطوقة.';

  @override
  String get featureImageGenerationTitle => 'توليد الصور';

  @override
  String get featureImageGenerationDescription =>
      'يمكن لهذا النموذج إنشاء صور أصلية استنادًا إلى أوصاف النصوص الخاصة بك.';

  @override
  String get errorImageLoad => 'فشل تحميل الصورة المولدة.';

  @override
  String get extensionInfoPanelTitle => 'استكشاف النماذج';

  @override
  String get extensionInfoPanelBody1 =>
      'يتيح لك هذا السهم التبديل بين النماذج المختلفة ضمن هذه السلسلة.';

  @override
  String get extensionInfoPanelBody2 =>
      'عند بدء الدردشة لأول مرة باستخدام هذه السلسلة، سيتم تحديد النموذج الافتراضي تلقائيًا ويمكنك تغيير اختيارك في أي وقت أثناء الدردشة.';

  @override
  String get extensionInfoPanelFooter =>
      'لعرض معلومات مفصلة حول كل طراز أو لتحديد طراز مختلف يدويًا، يرجى الانتقال إلى المكتبة؛ حدد سلسلة الطراز هذه من هناك واضغط على السهم الموجود في أعلى صفحة التفاصيل الخاصة بها.';

  @override
  String get premiumModelNoticeTitle => 'نموذج مميز';

  @override
  String get premiumModelNoticeDescription =>
      'هذا النموذج هو نموذج مميز، ويقتصر المستخدمون المجانيون على 3 رسائل يوميًا مع النماذج المميزة؛ اشترك لفتح الوصول غير المحدود!';

  @override
  String get benefitPremiumModels => 'الوصول إلى النماذج المتميزة';

  @override
  String get premiumTrialExhaustedMessage =>
      'لقد استخدمت جميع رسائلك اليومية المجانية للنماذج المميزة، يرجى الترقية للحصول على وصول غير محدود.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'كيف يمكنني مساعدتك اليوم، $userName؟';
  }

  @override
  String get selectionScreenGreetingGeneric => 'كيف يمكنني مساعدتك اليوم؟';

  @override
  String get selectionScreenRecentModels => 'الموديلات الحديثة';

  @override
  String get selectionScreenFeatureDynamicChat => 'الدردشة الديناميكية';

  @override
  String get selectionScreenFeatureOffline => 'استخدم بدون انترنت';

  @override
  String get selectionScreenFeatureSelectModel => 'اختر النموذج';

  @override
  String get explore => 'استكشاف';

  @override
  String get subscriptionCancelled => 'تم إلغاء الاشتراك بنجاح!';

  @override
  String get selectionScreenPinnedModels => 'النماذج المثبتة';

  @override
  String get selectionScreenNewsAndUpdates => 'الأخبار والتحديثات';

  @override
  String get filters => 'المرشحات';

  @override
  String get noRecentChatsMessage =>
      'لم تتحدث مع أي نماذج بعد، دعنا نبدأ المحادثة!';

  @override
  String get allModels => 'جميع الموديلات';

  @override
  String get onlineModels => 'نماذج عبر الإنترنت';

  @override
  String get offlineModels => 'نماذج غير متصلة بالإنترنت';

  @override
  String get characterModels => 'الشخصيات';

  @override
  String get customModels => 'نماذج مخصصة';

  @override
  String get filterPanelDescription => 'اضغط على فئة لتصفية القائمة على الفور.';

  @override
  String get dynamicChatTitle => 'الدردشة الديناميكية';

  @override
  String get errorNoModelsAvailable =>
      'لا توجد موديلات متاحة حاليًا. يُرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get errorNoModelsForRequest =>
      'لم يتم العثور على نماذج مناسبة لطلبك الحالي (على سبيل المثال، الوضع غير المتصل بالإنترنت أو رسالة الصورة).';

  @override
  String get dynamicChatWelcome => 'كيف يمكنني مساعدك؟';

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
  String get notificationNewYearTitle => 'سنة جديدة سعيدة! 🎉';

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
      'لقد اتصلت بك فتاة أنمي للتو، وقالت إنها تفتقدك؛ ربما يجب عليك أن تأتي وتتحدث معها. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 تنبيه أحمر 🚨';

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
  String get notificationSubscriptionOfferTitle => 'أرخص من العلكة';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'خصم كامل بنسبة $discountRate% على جميع باقات اشتراكنا. لا تفوت هذه الفرصة!';
  }

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
      'قم بدعوة صديق إلى Cortex وسوف تحصلان على رصيد مجاني!';

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
      'البحر هادئ، والريح تهبُّ عليك. هناك جزر جديدة (نماذج 😉) لاكتشافها في محيط كورتيكس. اجمع طاقمك وأبحر!';

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
  String get exitAppTitle => 'المغادرة قريبا؟';

  @override
  String get exitAppConfirmation =>
      'هل أنت متأكد أنك تريد مغادرة هذه المنصة الرائعة؟';

  @override
  String get newsErrorTitle => 'فشل تحميل الأخبار';

  @override
  String get newsErrorMessage =>
      'حدثت مشكلة أثناء جلب أحدث التحديثات، يرجى التحقق من اتصالك ومحاولة مرة أخرى.';

  @override
  String get codeNotFound => 'الرمز الذي أدخلته غير صالح أو منتهي الصلاحية.';

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
  String get onboardingFinalDesc =>
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
  String get upgradeAccountDescription =>
      'قم بإنشاء حساب للحصول على 200 رصيد إضافي يوميًا وفتح المزيد من الحدود.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get upgradeTitle => 'إتمام التسجيل';

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
}
