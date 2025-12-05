// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get understood => 'Понятно.';

  @override
  String get cancel => 'Отмена';

  @override
  String get remove => 'Удалить';

  @override
  String get download => 'Скачать';

  @override
  String get resume => 'Возобновить';

  @override
  String get copy => 'Копировать';

  @override
  String get chat => 'Чат';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get light => 'Светлая';

  @override
  String get theme => 'Тема';

  @override
  String get no => 'Нет';

  @override
  String get yes => 'Да';

  @override
  String get done => 'Готово';

  @override
  String get comingSoon => 'СКОРО';

  @override
  String get bestValue => 'Лучшее предложение';

  @override
  String get selected => 'Выбрано';

  @override
  String get descriptionSection => 'Описание';

  @override
  String get searchHint => 'Поиск';

  @override
  String get messageHint => 'Спросите что угодно';

  @override
  String get modelLoading => 'Модель загружается...';

  @override
  String get messageCopied => 'Сообщение скопировано в буфер обмена.';

  @override
  String get storeUnavailable =>
      'Магазин временно недоступен. Пожалуйста, попробуйте позже.';

  @override
  String get retry => 'Повторить';

  @override
  String get systemInfo => 'Информация о системе';

  @override
  String deviceMemory(Object memory) {
    return 'Память устройства: $memory ГБ';
  }

  @override
  String storageSpace(Object storage) {
    return 'Объём хранилища: $storage ГБ';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Свободное место: $freeStorage ГБ';
  }

  @override
  String get memory => 'Память';

  @override
  String get storage => 'Хранилище';

  @override
  String get freeStorage => 'Свободно';

  @override
  String get totalStorage => 'Всего';

  @override
  String get usedStorage => 'Использовано';

  @override
  String get totalMemory => 'Всего памяти';

  @override
  String get usedMemory => 'Использовано памяти';

  @override
  String get requirements => 'Требования';

  @override
  String get modelsTitle => 'Библиотека';

  @override
  String get localModels => 'Локальные модели';

  @override
  String get serverSideModels => 'Онлайн-модели';

  @override
  String get uploadYourOwnModel => 'Загрузите свою модель!';

  @override
  String get selectGGUFFile => 'Выберите файл GGUF';

  @override
  String get errorGGUF => 'Пожалуйста, выберите файл только в формате GGUF.';

  @override
  String get modelAlreadyExists => 'Модель уже существует.';

  @override
  String get modelAddedSuccessfully => 'Модель успешно добавлена.';

  @override
  String get modelRemoved => 'Модель успешно удалена.';

  @override
  String get removeError => 'Произошла ошибка при удалении модели.';

  @override
  String get fileNotFound => 'Файл не найден.';

  @override
  String get fileUploadError => 'Произошла ошибка при загрузке файла.';

  @override
  String get noFileSelected => 'Файл не выбран.';

  @override
  String get myModels => 'Мои модели';

  @override
  String get create => 'Создать';

  @override
  String get seeAll => 'Показать все';

  @override
  String modelProducer(Object producer) {
    return 'Производитель: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'ОЗУ: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Размер: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Чаты';

  @override
  String get conversationDeleted => 'Чат удалён.';

  @override
  String get conversationUpdated => 'Чат обновлён.';

  @override
  String get editConversationTitle => 'Переименовать';

  @override
  String get newTitle => 'Новое название';

  @override
  String get save => 'Сохранить';

  @override
  String get titleCannotBeEmpty => 'Название не может быть пустым.';

  @override
  String get noConversationsMessage => 'Нет чатов, начните общаться!';

  @override
  String get startChat => 'Начать чат';

  @override
  String get noChats => 'Нет чатов';

  @override
  String get starredChats => 'Избранные чаты';

  @override
  String get allChats => 'Все чаты';

  @override
  String get noStarredChats => 'Нет избранных чатов';

  @override
  String get noStarredChatsMessage =>
      'Вы ещё не добавили ни один чат в избранное.';

  @override
  String get goToChats => 'Добавить чат в избранное';

  @override
  String get starConversation => 'В избранное';

  @override
  String get conversationTitleUpdated => 'Название чата обновлено';

  @override
  String get youReachedConversationLimit => 'Вы достигли лимита чатов.';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get loginToYourAccount => 'Вход';

  @override
  String get createYourAccount => 'Регистрация';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get invalidEmail => 'Пожалуйста, введите действительный email.';

  @override
  String get invalidPassword => 'Пароль должен содержать не менее 6 символов.';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get or => 'Или';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get logIn => 'Войти';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String get userNotFound => 'Пользователь не найден.';

  @override
  String get wrongPassword => 'Неверный пароль.';

  @override
  String get emailAlreadyInUse => 'Этот email уже используется.';

  @override
  String get weakPassword => 'Пароль слишком слабый.';

  @override
  String get authError => 'Ошибка аутентификации';

  @override
  String get invalidUsername => 'Пожалуйста, введите имя пользователя.';

  @override
  String get usernameTaken => 'Это имя пользователя уже занято.';

  @override
  String get username => 'Имя пользователя';

  @override
  String get authenticationFailed =>
      'Аутентификация не удалась. Пожалуйста, попробуйте снова.';

  @override
  String get emailTooLong => 'Email не может превышать 30 символов.';

  @override
  String get deviceLimitReached =>
      'Вы достигли лимита создания аккаунтов для этого устройства.';

  @override
  String get verificationEmailLimitReached =>
      'Мы больше не будем отправлять письма.';

  @override
  String get verificationEmailSent => 'Письмо с подтверждением отправлено!';

  @override
  String get emailNotVerified => 'Email не подтверждён.';

  @override
  String get resendCode => 'Отправить письмо с подтверждением повторно';

  @override
  String get remainingSeconds => 'Оставшееся время для подтверждения';

  @override
  String get pleaseCheckYourEmail =>
      'Чтобы использовать Cortex, вам необходимо подтвердить свой email. \n Ссылка для подтверждения была отправлена на ваш адрес электронной почты, пожалуйста, проверьте почту.';

  @override
  String get verifyYourEmail => 'Подтвердите ваш Email';

  @override
  String get backToLogin => 'Вернуться ко входу';

  @override
  String get seconds => 'секунд';

  @override
  String get maxResendLimitReached =>
      'Вы достигли максимального количества отправки писем для подтверждения.';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Продолжить без подтверждения';

  @override
  String get verificationScreenWarning =>
      'Даже если вы продолжите, 1-дневный период верификации аккаунта все еще действует. Если вы не подтвердите свой аккаунт за это время, он будет удален из приложения.';

  @override
  String get unverifiedAccountHeader => 'Ваш аккаунт не подтверждён';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Если вы не подтвердите свой аккаунт в течение $timeLeft, он будет удалён.';
  }

  @override
  String get verifyNow => 'Подтвердить сейчас';

  @override
  String get accountVerified => 'Ваш аккаунт подтверждён.';

  @override
  String get linkSent => 'Ссылка отправлена';

  @override
  String get accountDeletionRequested =>
      'Ваш запрос на удаление аккаунта получен, и ваш аккаунт теперь отключён.';

  @override
  String get tooManyRequests => 'Слишком много запросов';

  @override
  String get regenerate => 'Сгенерировать заново';

  @override
  String get confirmDeleteAccount =>
      'Вы уверены, что хотите удалить свой аккаунт?';

  @override
  String get enterPasswordToDelete => 'Введите ваш пароль для удаления.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountError => 'Произошла ошибка при удалении аккаунта.';

  @override
  String get delete => 'Удалить';

  @override
  String get passwordRequired => 'Требуется пароль.';

  @override
  String get deleteDescription =>
      'Данные, которые вы удалите, будут навсегда удалены с нашего сервера и вашего устройства. Это действие нельзя отменить.';

  @override
  String get deleteAccountButton => 'Кнопка удаления аккаунта';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get tapToChangeProfilePicture =>
      'Нажмите, чтобы изменить фото профиля';

  @override
  String get profileUpdated => 'Профиль успешно обновлён';

  @override
  String get updateFailed => 'Не удалось обновить профиль';

  @override
  String get nameCannotBeEmpty => 'Имя не может быть пустым';

  @override
  String get logout => 'Выйти';

  @override
  String get noDisplayName => 'Отображаемое имя не установлено';

  @override
  String get noEmail => 'Нет адреса электронной почты';

  @override
  String get noUserLoggedIn => 'Нет вошедшего пользователя';

  @override
  String get profile => 'Профиль';

  @override
  String get manageProfileDescription =>
      'Управляйте своим профилем, обновляйте пароль или выходите из Cortex.';

  @override
  String get accessSettingsDescription =>
      'Получите помощь, активируйте коды, поделитесь Cortex и ознакомьтесь с нашими правилами.';

  @override
  String get languageDescription =>
      'Вы можете в любое время изменить язык интерфейса приложения по умолчанию.';

  @override
  String get themeDescription =>
      'Вы можете переключаться между светлой и тёмной темами по своему усмотрению. Выбранная тема будет применена ко всему интерфейсу Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Я прочитал(а) и согласен(на) с условиями обслуживания';

  @override
  String get downloading => 'Загрузка...';

  @override
  String get downloadError => 'Произошла ошибка во время загрузки.';

  @override
  String get downloadCancelled => 'Загрузка отменена.';

  @override
  String get downloadResumed => 'Загрузка возобновлена.';

  @override
  String get downloadSuccess => 'Загрузка успешна';

  @override
  String get downloadFailed => 'Загрузка не удалась';

  @override
  String downloaded(Object percent) {
    return 'Загружено $percent%';
  }

  @override
  String get downloadPaused => 'Загрузка приостановлена.';

  @override
  String get purchaseSuccessful => 'Покупка успешна!';

  @override
  String get purchaseFailed => 'Покупка не удалась';

  @override
  String get creditProductNotFound => 'Выбранный пакет кредитов не найден.';

  @override
  String get creditsAddedSuccessfully =>
      'Кредиты успешно зачислены на ваш счёт!';

  @override
  String get creditDeliveryFailed =>
      'Не удалось зачислить кредиты на ваш счёт. Пожалуйста, свяжитесь с поддержкой.';

  @override
  String get invalidPurchase => 'Недействительная покупка';

  @override
  String get purchaseError => 'Ошибка покупки';

  @override
  String get purchaseVertexPlusToUpload => 'Это функция Plus';

  @override
  String get purchasePlus => 'Купить Cortex Plus';

  @override
  String get plusDescription =>
      'Получите доступ к большему количеству функций Cortex и испытайте ИИ на новом уровне!';

  @override
  String get annual => 'Годовая';

  @override
  String get monthly => 'Месячная';

  @override
  String get manageSubscription => 'Управлять подпиской';

  @override
  String purchasePlan(String planName) {
    return 'Купить $planName';
  }

  @override
  String discountOffer(int percent) {
    return 'СКИДКА $percent%';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/месяц, оплата ежемесячно';
  }

  @override
  String get discountBannerTitle =>
      'СПЕЦИАЛЬНОЕ ПРЕДЛОЖЕНИЕ В ЧЕСТЬ ЗАПУСКА: СКИДКА 80%!';

  @override
  String get discountBannerSubtitle =>
      'Эксклюзивная скидка на ВСЕ планы подписки в честь нашего запуска. Не пропустите!';

  @override
  String get purchasePro => 'Купить Cortex Pro';

  @override
  String get proDescription =>
      'Получите доступ к ещё большему количеству функций Cortex и испытайте ИИ на ещё более высоком уровне!';

  @override
  String get alreadySubscribed => 'Вы уже подписаны';

  @override
  String get subscriptionInfo => 'Ваша подписка активна.';

  @override
  String get alreadySubscribedMessage =>
      'У вас уже есть подписка Plus. Если вы хотите отменить подписку, вы можете сделать это через менеджер Play Store.';

  @override
  String get cancelSubscription => 'Отменить подписку';

  @override
  String get cancelSubscriptionInfo =>
      'Если вы хотите отменить подписку, пожалуйста, сделайте это через менеджер подписок Play Store.';

  @override
  String get goToPlayStore => 'Перейти в Play Store';

  @override
  String get alreadySubscribedPlus => 'У вас есть план Plus!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Ваш план Plus активен. Вы можете пользоваться всеми преимуществами.';

  @override
  String get purchaseUltra => 'Купить Cortex Ultra';

  @override
  String get ultraDescription =>
      'Получите полный доступ ко всем функциям Cortex и испытайте ИИ на максимум!';

  @override
  String get noSubscription => 'Нет подписки';

  @override
  String get noSubscriptionMessage => 'У вас ещё нет подписки.';

  @override
  String get alreadyAtHighestPlan => 'У вас уже самый высокий план.';

  @override
  String get unableToOpenSubscription =>
      'Не удалось открыть страницу управления подпиской.';

  @override
  String get upgradeSubscription => 'Улучшить подписку';

  @override
  String get confirmUpgrade => 'Вы уверены, что хотите улучшить свою подписку?';

  @override
  String get unsupportedPlatform =>
      'Платформа не поддерживает отмену подписки.';

  @override
  String get purchaseStreamError => 'Ошибка потока покупки.';

  @override
  String get productNotFound => 'Продукт не найден';

  @override
  String get productDetailsError =>
      'Произошла ошибка при получении сведений о продукте.';

  @override
  String get noProductsFound => 'Продукты не найдены';

  @override
  String get loadCreditsButton => 'Пополнить кредиты';

  @override
  String get creditsTitle => 'Кредиты';

  @override
  String get creditsScreenDescription =>
      'Этот экран показывает кредиты пользователя. \n\nТекущие кредиты пользователя: 100\n\nЗдесь может отображаться подробная информация о кредитах.';

  @override
  String get creditsLoaded => 'Кредиты пополнены!';

  @override
  String get currentCredits => 'Текущие кредиты';

  @override
  String get pleaseSelectCreditPackage => 'Пожалуйста, выберите пакет кредитов';

  @override
  String get purchaseCreditsTitle => 'Купить кредиты';

  @override
  String get purchaseCreditsDescription =>
      'Выберите пакет кредитов, который соответствует вашим потребностям, и используйте наше приложение больше.';

  @override
  String get purchaseButton => 'Купить';

  @override
  String get productNotFoundMessage => 'Выбранный продукт не существует.';

  @override
  String get buyCredits => 'Купить кредиты';

  @override
  String get selectCreditPackageDescription =>
      'Выберите пакет кредитов, который соответствует вашим потребностям, и наслаждайтесь большим количеством функций.';

  @override
  String get buyCredit => 'Купить кредиты';

  @override
  String buyCreditPackage(Object amount) {
    return 'Купить $amount кредитов';
  }

  @override
  String get subscribedPlan => 'Подписан';

  @override
  String get errorResponseNotReceived => 'Ответ не получен';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Запрос к Google API не удался $attempt раз(а): $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'Статус ответа OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Декодированное тело ответа OpenRouter: $body';
  }

  @override
  String decodedJson(String data) {
    return 'Декодированный JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Неожиданная структура ответа: отсутствует сообщение или контент';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Неожиданная структура ответа: отсутствует или пуст массив choices';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'Запрос к OpenRouter API не удался: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'Запрос к OpenRouter API не удался $attempt раз(а): $error';
  }

  @override
  String get internetRequired =>
      'Для использования этой модели требуется подключение к интернету';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Пожалуйста, подождите немного, прежде чем пытаться снова';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Квота исчерпана. Код состояния: $statusCode, Тело ответа: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'Запрос к API не удался после $attempts платных попыток. Ошибка: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Размещая этот заказ, вы соглашаетесь с Условиями обслуживания и Политикой конфиденциальности. Вы можете нажать на этот текст, чтобы узнать больше о наших Условиях обслуживания и Политике конфиденциальности. Подписка будет автоматически продлеваться, если автопродление не будет отключено как минимум за 24 часа до окончания текущего периода.';

  @override
  String get termsOfService => 'Условия обслуживания';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get report => 'Пожаловаться';

  @override
  String get reportDialogTitle => 'Отправить жалобу';

  @override
  String get reportDescriptionLabel => 'В чём проблема?';

  @override
  String get reportHarmful => 'Это вредоносно/небезопасно';

  @override
  String get reportNotTrue => 'Это неправда';

  @override
  String get reportNotHelpful => 'Это бесполезно';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get submitButton => 'Отправить';

  @override
  String get reportErrorMessage =>
      'Пожалуйста, выберите одну причину для жалобы.';

  @override
  String get capabilitiesSection => 'Возможности';

  @override
  String get ratingsSection => 'Рейтинги';

  @override
  String get noRatingDataFound => 'Данные о рейтинге не найдены';

  @override
  String get featurePhotoTitle => 'Сканирование фото';

  @override
  String get featurePhotoDescription =>
      'Эта модель способна сканировать фотографии с камеры или из файлов изображений.';

  @override
  String get featureOfflineTitle => 'Работа оффлайн';

  @override
  String get featureOfflineDescription =>
      'Запускайте модель без подключения к интернету, чтобы сохранить ваши данные в безопасности.';

  @override
  String get featureSupermodelTitle => 'Супермодель';

  @override
  String get featureSupermodelDescription =>
      'Это огромная модель с более чем 10 миллиардами параметров, предлагающая высокую производительность и широкие возможности.';

  @override
  String get featureRoleplayTitle => 'Ролевая игра';

  @override
  String get featureRoleplayDescription =>
      'Модели для ролевых игр позволяют создавать различные чаты и сценарии.';

  @override
  String get roleModels => 'Ролевые модели';

  @override
  String get parameters => 'Параметры';

  @override
  String get context => 'Контекст';

  @override
  String get millions => 'миллионов';

  @override
  String get billions => 'миллиардов';

  @override
  String get trillions => 'триллионов';

  @override
  String get thousand => 'тысяч';

  @override
  String get estimated => 'примерно';

  @override
  String get finalPreparation => 'Идут последние приготовления.';

  @override
  String get allEvaluationsByTestTeam =>
      'Все оценки были сделаны нашей командой тестировщиков';

  @override
  String get shareApp => 'Поделиться приложением';

  @override
  String get rateUs => 'Оцените нас';

  @override
  String get share => 'Поделиться';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Зацени приложение Cortex, оно просто потрясающее! Скачай его здесь: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Не удалось поделиться приложением. Пожалуйста, попробуйте позже.';

  @override
  String get selectText => 'Выбрать текст';

  @override
  String get showLatex => 'Показать спецсимволы';

  @override
  String get hideLatex => 'Скрыть спецсимволы';

  @override
  String get thinking => 'Думает';

  @override
  String get user => 'Пользователь';

  @override
  String get voice => 'Голос';

  @override
  String get help => 'Помощь';

  @override
  String get supportCreator => 'Поддержите создателя';

  @override
  String get enterYourTag =>
      'Поддержите любимых авторов! Введите их уникальный тег ниже, чтобы подарить им часть ваших покупок в Cortex.';

  @override
  String get creatorTag => 'Тег создателя';

  @override
  String get support => 'Поддерживать';

  @override
  String get tagCannotBeEmpty => 'Тег создателя не может быть пустым';

  @override
  String get userId => 'ID пользователя';

  @override
  String get deleteAllConversationsConfirmTitle => 'Удалить все чаты?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Вы уверены, что хотите удалить все свои чаты? Это действие нельзя отменить.';

  @override
  String get allConversationsDeleted => 'Все чаты были успешно удалены!';

  @override
  String get deleteAll => 'Удалить все';

  @override
  String get deleteAllConversationsButton => 'Удалить все чаты';

  @override
  String get confirmWord => 'Напишите VERTEX';

  @override
  String get confirmWordError => 'Вы написали неправильно';

  @override
  String get chinese => 'Китайский';

  @override
  String get arabic => 'Арабский';

  @override
  String get french => 'Французский';

  @override
  String get japanese => 'Японский';

  @override
  String get kurdish => 'курдский';

  @override
  String get dutch => 'Голландский';

  @override
  String get russian => 'Русский';

  @override
  String get korean => 'Корейский';

  @override
  String get deutsch => 'Немецкий';

  @override
  String get english => 'Английский';

  @override
  String get turkish => 'Турецкий';

  @override
  String get hindi => 'Хинди';

  @override
  String get portuguese => 'Португальский';

  @override
  String get indonesian => 'Индонезийский';

  @override
  String get azerbaijani => 'Азербайджанский';

  @override
  String get german => 'Немецкий';

  @override
  String get spanish => 'Испанский';

  @override
  String get italian => 'Итальянский';

  @override
  String get ram => 'ОЗУ';

  @override
  String get usernameTooShort => 'Имя пользователя слишком короткое.';

  @override
  String get usernameTooLong =>
      'Имя пользователя не может превышать 16 символов.';

  @override
  String get invalidUsernameCharacters =>
      'В имени пользователя можно использовать только латинские буквы, а также символы \'.\', \'-\', \'_\'.';

  @override
  String get passwordTooLong => 'Пароль не может превышать 64 символа.';

  @override
  String get noInternetConnection => 'Нет подключения к интернету.';

  @override
  String get chats => 'Чаты';

  @override
  String get library => 'Библиотека';

  @override
  String get inappropriateMessageWarning =>
      'Обнаружено неприемлемое сообщение!';

  @override
  String get myModelDescription => 'Моя модель.';

  @override
  String get noModelsDownloaded => 'Вы ещё не скачали ни одной модели.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Текст';

  @override
  String get removeModel => 'Удалить модель';

  @override
  String get modelUploadedSuccessfully => 'Модель успешно загружена.';

  @override
  String get insufficientRAM => 'Недостаточно памяти';

  @override
  String get insufficientStorage => 'Недостаточно места';

  @override
  String confirmRemoveModel(Object model) {
    return 'Вы уверены, что хотите удалить модель $model с вашего устройства? Это также удалит все предыдущие чаты с этой моделью.';
  }

  @override
  String get noMatchingModels => 'Подходящих моделей не найдено.';

  @override
  String creditPackage(Object amount) {
    return 'Купить $amount кредитов';
  }

  @override
  String get benefit1 => 'Гораздо больший лимит чатов для онлайн ИИ';

  @override
  String get benefit2 => 'Загружайте собственные модели';

  @override
  String get benefit3 => 'Эффект для профиля';

  @override
  String get benefit4 => 'Значок подписчика';

  @override
  String get benefit5 => 'Создавайте больше онлайн-ИИ';

  @override
  String get benefit6 => 'Безлимитный чат';

  @override
  String benefit7(Object credits) {
    return '$credits кредитов ежедневно';
  }

  @override
  String get benefit8 => 'Добавляйте модели';

  @override
  String get benefit9 => 'Новые темы';

  @override
  String get benefit10 => 'Оффлайн голосовой чат';

  @override
  String get oldBenefits => 'Все преимущества предыдущих планов';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get logoutConfirmationTitle => 'Вы уверены, что хотите выйти?';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык приложения';

  @override
  String get dark => 'Тёмная';

  @override
  String get oldPassword => 'Старый пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get passwordUpdated => 'Пароль обновлён.';

  @override
  String get stop => 'Стоп';

  @override
  String get copyrights => 'Источники';

  @override
  String get downloadingTitle => 'Загрузка';

  @override
  String get downloadCompletedTitle => 'Загрузка завершена';

  @override
  String get downloadPausedTitle => 'Загрузка приостановлена';

  @override
  String get downloadErrorTitle => 'Ошибка загрузки';

  @override
  String get cancelButtonText => 'Отмена';

  @override
  String get love => 'Любовь';

  @override
  String get nature => 'Природа';

  @override
  String get behindTheSlaughter => 'За кулисами';

  @override
  String get grayscale => 'Оттенки серого';

  @override
  String get ocean => 'Океан';

  @override
  String get scarletSnow => 'Алый снег';

  @override
  String get requestFailed => 'Произошла ошибка, попробуйте снова.';

  @override
  String get changeModel => 'Сменить';

  @override
  String get edit => 'Изменить';

  @override
  String get editingMessageInfo =>
      'Изменение этого сообщения перезапустит диалог с этого момента.';

  @override
  String get editingNotification => 'Вы сейчас в режиме редактирования';

  @override
  String get featureIndulgentTitle => 'Всеобъемлющая';

  @override
  String get featureIndulgentDescription =>
      'Эта модель может беспрепятственно обрабатывать контексты, превышающие 100 000 токенов, что позволяет ей работать с обширными и подробными входными данными без снижения производительности.';

  @override
  String get featurePluralTitle => 'Множественная';

  @override
  String get featurePluralDescription =>
      'Эта модель может автоматически интегрировать дополнительные расширения, тем самым расширяя свои функциональные возможности для поддержки разнообразных операций с повышенной производительностью.';

  @override
  String get featureWiseTitle => 'Мудрая';

  @override
  String get featureWiseDescription =>
      'Эта модель может использовать глубокие аналитические данные и дальновидные рассуждения для оказания сложной поддержки в принятии решений и решении комплексных проблем.';

  @override
  String get featureResearcherTitle => 'Исследователь';

  @override
  String get featureResearcherDescription =>
      'Эта функция, доступная исключительно в моделях с передовыми исследовательскими и аналитическими возможностями, предназначена для предоставления высокоточных данных и всестороннего анализа в различных областях.';

  @override
  String get nameLabel => 'Имя ИИ';

  @override
  String get nameHint => 'Введите имя вашего ИИ';

  @override
  String get summaryLabel => 'Краткое описание ИИ';

  @override
  String get summaryHint => 'Введите краткое описание вашего ИИ';

  @override
  String get add => 'Добавить';

  @override
  String get aiExplanationTitle => 'Описание искусственного интеллекта';

  @override
  String get aiExplanationDescription =>
      'Пожалуйста, предоставьте подробное описание архитектуры вашей модели ИИ, процесса обучения, метрик производительности, областей применения и других важных особенностей.';

  @override
  String get preInputTitle => 'Предустановка для искусственного интеллекта';

  @override
  String get preInputDescription =>
      'Пожалуйста, задайте предустановку, которая будет направлять вашу модель в процессе создания персонажа. В этом разделе вы можете включить информацию о персонаже, дополнительный контекст и любые другие детали, которые могут помочь в генерации контента, связанного с персонажем.';

  @override
  String get baseModelTitle => 'Базовая модель';

  @override
  String get baseModelDescription =>
      'Эта модель будет использоваться в качестве основы для вашего творения. Здесь отображается текущая выбранная базовая модель.';

  @override
  String get summary => 'Описание';

  @override
  String get characterPoliceTitle => 'Полицейский';

  @override
  String get characterPoliceRole =>
      'Ты бдительный страж закона, посвятивший себя защите граждан и поддержанию порядка с непоколебимой решимостью, ты полицейский';

  @override
  String get characterPoliceShortDescription =>
      'Стойкий и отважный страж порядка.';

  @override
  String get purchaseSubscription => 'Купить';

  @override
  String get modelUploadTitle => 'Файл искусственного интеллекта';

  @override
  String get modelUploadDescription =>
      'Выберите и загрузите ваши локальные файлы GGUF прямо с вашего устройства. Это позволит вам запускать модель оффлайн без необходимости подключения к интернету. Убедитесь, что файл имеет действительный формат GGUF и правильно структурирован. Если файл некорректен или повреждён, Cortex может работать не так, как ожидалось, и вы можете столкнуться с ошибками.';

  @override
  String get modelUploadShortDescription =>
      'Нажмите здесь, чтобы выбрать файл .gguf с вашего устройства';

  @override
  String get addServerTitle => 'Сервер искусственного интеллекта';

  @override
  String get addServerDescription =>
      'Введите URL вашего удалённого сервера для подключения к внешне размещённой модели. Эта функция требует активного интернет-соединения, и любые проблемы или ошибки, связанные с сервером, не вызваны Cortex. Убедитесь, что ваш сервер правильно настроен, доступен из вашей сети и имеет действительную конечную точку модели для бесперебойной работы.';

  @override
  String get you => 'Вы';

  @override
  String get removePhotoTitle => 'Удалить фото';

  @override
  String get confirmRemovePhoto => 'Вы уверены, что хотите удалить фото?';

  @override
  String get serverLink => 'Ссылка на сервер';

  @override
  String get enterURL => 'Введите URL сервера';

  @override
  String get chatLengthLimitExceeded =>
      'Этот чат превысил лимит символов. Пожалуйста, начните новый чат или приобретите подписку.';

  @override
  String get aiNameError => 'ИИ с таким именем уже существует.';

  @override
  String get modelLimitExceeded =>
      'Вы достигли максимального лимита создания моделей для вашего плана.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'Можно добавить только одно фото';

  @override
  String get inappropriateContentDetected => 'Обнаружен неприемлемый контент!';

  @override
  String get offlineModelNotInstalled =>
      'Эта оффлайн-модель не установлена на вашем устройстве.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'У вас недостаточно кредитов для выполнения этого запроса. Это действие требует $required кредитов, а у вас только $available. Чтобы получить больше кредитов, вы можете улучшить свой план или купить их напрямую. хей мы прекрасно понимаем что остаться без кредитов это тот ещё облом но серьёзно получение этих крутых ответов от наших моделей не бесплатно так что эти кредиты на самом деле помогают нам поддерживать движуху и слушайте если больше из вас ребята начнут покупать кредиты мы вполне можем рассмотреть возможность увеличения бесплатных дневных лимитов для всех';
  }

  @override
  String get regenerateInProgress => 'Генерация ответа уже в процессе.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Произошла ошибка при попытке регенерации: $errorDetails';
  }

  @override
  String get modality => 'Модальность';

  @override
  String get multimodal => 'Мультимодальный';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get themeLocked =>
      'Эта тема требует более высокого уровня подписки. Пожалуйста, улучшите подписку, чтобы разблокировать.';

  @override
  String get pageCouldNotBeLoaded => 'Не удалось загрузить страницу';

  @override
  String get checkYourInternet =>
      'Пожалуйста, проверьте ваше интернет-соединение и попробуйте снова.';

  @override
  String get errorUserNotAuthenticated =>
      'Вы должны войти в систему, чтобы выполнить это действие.';

  @override
  String get errorInsufficientCredits =>
      'У вас недостаточно кредитов. Пожалуйста, пополните счёт, чтобы продолжить.';

  @override
  String get errorRateLimitExceeded =>
      'Слишком много запросов. Пожалуйста, попробуйте снова через мгновение.';

  @override
  String get errorServer =>
      'Произошла непредвиденная ошибка сервера. Пожалуйста, попробуйте позже.';

  @override
  String get errorNetwork =>
      'Произошла сетевая ошибка. Пожалуйста, проверьте ваше соединение и попробуйте снова.';

  @override
  String get errorApiAuthentication =>
      'Аутентификация не удалась. Пожалуйста, попробуйте войти снова.';

  @override
  String get baseModelForCharacterDescription =>
      'Выбранная базовая модель определит способности персонажа к рассуждению и ответам.';

  @override
  String get selectBaseModel => 'Выберите базовую модель';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get downloadStarted => 'Загрузка началась';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get localizationWarning =>
      'Некоторая информация может быть недоступна на вашем языке и будет отображаться на английском.';

  @override
  String get aiTranslationWarning =>
      'Информация о моделях переводится на различные языки другими моделями ИИ. Поэтому в языках, отличных от английского, могут возникать незначительные несоответствия.';

  @override
  String get errorLoadingTitle => 'Не удалось загрузить данные';

  @override
  String get errorLoadingMessage =>
      'Мы не смогли получить необходимые данные с наших серверов. Пожалуйста, проверьте ваше интернет-соединение и попробуйте снова.';

  @override
  String get noModelsFoundTitle => 'Нет результатов';

  @override
  String get noModelsFoundMessage =>
      'Попробуйте изменить условия поиска или сбросить фильтр.';

  @override
  String get usernameRateLimitExceeded =>
      'Вы можете менять имя пользователя только дважды каждые 14 дней.';

  @override
  String get usernameUnchanged => 'Это уже ваше текущее имя пользователя.';

  @override
  String get creditsInfoPanelTitle => 'Как работают кредиты';

  @override
  String get creditsInfoPanelBody =>
      'Кредиты используются для общения с онлайн-моделями. Каждое сообщение стоит нам денег, и эти кредиты спасают нас от банкротства. Теперь давайте объясним систему. \n\n• Каждое сообщение бесплатной онлайн-модели стоит 5 кредитов. \n• Каждое сообщение онлайн-модели премиум-класса стоит 20 кредитов. \n• Добавление вложения добавляет еще 30 кредитов. \n• Пользователи бесплатного плана получают бонус в размере 200 кредитов, который обнуляется ежедневно.';

  @override
  String get creditsInfoPanelFooter => 'Приятного общения!';

  @override
  String get disclaimerMessage =>
      'Искусственный интеллект может ошибаться, проверяйте важную информацию.';

  @override
  String get modelCreatedSuccess => 'Модель успешно создана!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '«$modelName» успешно удалена.';
  }

  @override
  String get errorCreatingModel =>
      'Произошла непредвиденная ошибка при создании модели.';

  @override
  String get errorDeletingModel =>
      'Произошла непредвиденная ошибка при удалении модели.';

  @override
  String get ultraFeatureOnly =>
      'Эта функция доступна только для пользователей Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Оффлайн-режим все еще является экспериментальным, и скачанная вами модель может работать не с оптимальной эффективностью.';

  @override
  String get noConversationsToDelete => 'У вас нет чатов для удаления.';

  @override
  String get reportSubmitted => 'Жалоба успешно отправлена';

  @override
  String get purchaseReceived => 'Покупка получена, обновляем ваш аккаунт.';

  @override
  String get verificationDelayed =>
      'Ваша покупка подтверждена. Есть небольшая задержка в обновлении вашего аккаунта, он скоро появится.';

  @override
  String get maintenanceTitle => 'На техническом обслуживании';

  @override
  String get maintenanceMessage =>
      'Cortex временно недоступен, пока мы вносим некоторые важные обновления. Доступ к приложению будет восстановлен в ближайшее время.\n\nСпасибо за ваше терпение, пока мы улучшаем ваш опыт.';

  @override
  String get errorPromptFlagged =>
      'Ваше сообщение было определено как неприемлемое и не может быть отправлено.';

  @override
  String get notEnoughStorage =>
      'Недостаточно места на вашем устройстве для сохранения новых сообщений.';

  @override
  String get errorRateLimit =>
      'Вы создали слишком много моделей за последнее время, пожалуйста, подождите немного, прежде чем пытаться снова.';

  @override
  String get errorContentFlagged =>
      'Модель не может быть сохранена, так как её содержимое было помечено как неприемлемое.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Вы не можете удалить все чаты, находясь в активном чате, пожалуйста, сначала выйдите из текущего чата, чтобы продолжить.';

  @override
  String get invalidCredentials => 'Неверный email или пароль.';

  @override
  String get userDisabled => 'Этот аккаунт пользователя был отключён.';

  @override
  String get loginSubtitle =>
      'Войдите в свою учётную запись Vertex. Продолжая, вы соглашаетесь с нашими Условиями обслуживания и Политикой конфиденциальности.';

  @override
  String get registerSubtitle =>
      'Создайте учётную запись Vertex для беспрепятственного доступа ко всем нашим сервисам. Продолжая, вы соглашаетесь с нашими Условиями обслуживания и Политикой конфиденциальности.';

  @override
  String get photoWarningMessage =>
      'Прикреплено фото. Модели, не поддерживающие изображения, могут его проигнорировать.';

  @override
  String get loginRequiredForPurchase =>
      'Вы должны войти в систему, чтобы совершить покупку.';

  @override
  String get storagePermissionRequired =>
      'Для сохранения загруженных моделей требуется разрешение на доступ к хранилищу. Пожалуйста, предоставьте разрешение для продолжения.';

  @override
  String get creditBannerTitle => 'Получите бесплатные кредиты!';

  @override
  String get creditBannerSubtitle =>
      'Пригласите друга, и вы оба получите по 50 кредитов при регистрации! Если он подпишется, вы оба получите ещё по 500!';

  @override
  String get inviteShareSubject => 'Присоединяйся ко мне в Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'йоу ты должен заценить это приложение cortex оно просто сумасшедшее если ты используешь мою ссылку мы оба получим по 50 кредитов а если ты подпишешься мы оба получим ещё по 500 это просто офигенная сделка качай его как можно скорее\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Нравится Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Ваша оценка — это огромная поддержка для нашей молодой инди-команды, и она помогает нам делать Cortex ещё лучше для вас.';

  @override
  String get reviewMaybeLater => 'Может быть, позже';

  @override
  String get reviewRateNow => 'Оценить сейчас';

  @override
  String get noThanks => 'Нет, спасибо';

  @override
  String get updateRequiredTitle => 'Требуется обновление';

  @override
  String get updateRequiredMessage =>
      'Чтобы продолжать использовать Cortex, пожалуйста, обновите приложение до последней версии, чтобы получить новые функции и важные улучшения.';

  @override
  String get updateNowButton => 'Обновить сейчас';

  @override
  String get creatorSupportedSuccess =>
      'Автор успешно поддержан! Ваши будущие покупки будут вносить вклад в его поддержку.';

  @override
  String get featureDocumentTitle => 'Поддержка документов';

  @override
  String get featureDocumentDescription =>
      'Эта модель может анализировать и отвечать на вопросы о загруженных документах, таких как PDF-файлы и текстовые файлы.';

  @override
  String get featureAudioTitle => 'Голосовой ввод';

  @override
  String get featureAudioDescription =>
      'Эта модель может понимать и обрабатывать речевые аудиоданные.';

  @override
  String get featureImageGenerationTitle => 'Генерация изображений';

  @override
  String get featureImageGenerationDescription =>
      'Эта модель может создавать оригинальные изображения на основе ваших текстовых описаний.';

  @override
  String get errorImageLoad =>
      'Не удалось загрузить сгенерированное изображение.';

  @override
  String get extensionInfoPanelTitle => 'Исследуйте модели';

  @override
  String get extensionInfoPanelBody1 =>
      'Эта стрелка позволяет переключаться между различными моделями этой серии.';

  @override
  String get extensionInfoPanelBody2 =>
      'При первом запуске чата с этой серией автоматически выбирается модель по умолчанию, и вы можете изменить свой выбор в любой момент во время чата.';

  @override
  String get extensionInfoPanelFooter =>
      'Чтобы просмотреть подробную информацию о каждой модели или вручную выбрать другую модель, перейдите в библиотеку, выберите там эту серию моделей и нажмите на стрелку в верхней части страницы с подробностями.';

  @override
  String get premiumModelNoticeTitle => 'Премиум-модель';

  @override
  String get premiumModelNoticeDescription =>
      'Эта модель является премиум-моделью, бесплатные пользователи ограничены 3 сообщениями в день для премиум-моделей; оформите подписку, чтобы разблокировать неограниченный доступ!';

  @override
  String get benefitPremiumModels => 'Доступ к премиум-моделям';

  @override
  String get premiumTrialExhaustedMessage =>
      'Вы использовали все бесплатные ежедневные сообщения для премиум-моделей. Пожалуйста, перейдите на более высокий уровень, чтобы получить неограниченный доступ.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Чем я могу вам помочь, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric => 'Чем я могу вам помочь сегодня?';

  @override
  String get selectionScreenRecentModels => 'Последние модели';

  @override
  String get selectionScreenFeatureDynamicChat => 'Динамический чат';

  @override
  String get selectionScreenFeatureOffline => 'Использовать без Интернета';

  @override
  String get selectionScreenFeatureSelectModel => 'Выберите модель';

  @override
  String get explore => 'Исследовать';

  @override
  String get subscriptionCancelled => 'Подписка успешно отменена!';

  @override
  String get selectionScreenPinnedModels => 'Закрепленные модели';

  @override
  String get selectionScreenNewsAndUpdates => 'Новости и обновления';

  @override
  String get filters => 'Фильтры';

  @override
  String get noRecentChatsMessage =>
      'Вы еще не общались ни с одной моделью, давайте начнем разговор!';

  @override
  String get allModels => 'Все модели';

  @override
  String get onlineModels => 'Онлайн-модели';

  @override
  String get offlineModels => 'Оффлайн модели';

  @override
  String get characterModels => 'Персонажи';

  @override
  String get customModels => 'Пользовательские модели';

  @override
  String get filterPanelDescription =>
      'Нажмите на категорию, чтобы мгновенно отфильтровать список.';

  @override
  String get dynamicChatTitle => 'Динамический чат';

  @override
  String get errorNoModelsAvailable =>
      'В настоящее время нет доступных моделей. Проверьте подключение к интернету и повторите попытку.';

  @override
  String get errorNoModelsForRequest =>
      'Не найдено подходящих моделей для вашего текущего запроса (например, автономный режим или сообщение с изображением).';

  @override
  String get dynamicChatWelcome => 'Могу я чем-нибудь помочь?';

  @override
  String get notificationComebackTitle => 'Мы скучаем по тебе!';

  @override
  String get notificationComebackBody =>
      'Расслабьтесь, это не сообщение от вашего бывшего. Но вы *можете* создать своего бывшего в Cortex! Возвращайтесь.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Прошло много времени';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Многое изменилось с нашей последней беседы. Заходите посмотреть, что нового.';

  @override
  String get notificationHowAreYouTitle => 'Как дела?';

  @override
  String get notificationHowAreYouBody => 'Расскажи мне обо всем этом.';

  @override
  String get notificationNewYearTitle => 'С Новым годом! 🎉';

  @override
  String get notificationNewYearBody =>
      'Пусть новый год принесет вам здоровье, счастье и бесконечный творческий потенциал; Cortex всегда рядом с вами!';

  @override
  String get notificationValentinesDayTitle => 'Любовь витает в воздухе! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'С Днём святого Валентина! И ещё, MEHTAP, Я ЛЮБЛЮ ТЕБЯ!';

  @override
  String get notificationAtaturkRemembranceTitle => 'С уважением и тоской';

  @override
  String get notificationAtaturkRemembranceBody =>
      'В годовщину кончины мы с почтением чтим память основателя Турецкой Республики Гази Мустафы Кемаля Ататюрка.';

  @override
  String get notificationMothersDayTitle => 'Твоя мама!';

  @override
  String get notificationMothersDayBody =>
      'С Днем матери всех мам, и начиная с вашей!';

  @override
  String get notificationFathersDayTitle => 'Твой папа!';

  @override
  String get notificationFathersDayBody =>
      'С Днем отца всех отцов, и начиная с вашего!';

  @override
  String get notificationHomeworkHelperTitle =>
      'Домашнее задание накапливается?';

  @override
  String get notificationHomeworkHelperBody =>
      'Помните, персонаж «Учитель» в Cortex готов помочь вам с любым предметом, с которым у вас возникли трудности!';

  @override
  String get notificationTrollAnimeTitle => 'Твоя вайфу зовёт';

  @override
  String get notificationTrollAnimeBody =>
      'Только что звонила девушка из аниме, сказала, что скучает по тебе; тебе, наверное, стоит подойти и пообщаться с ней. 😉';

  @override
  String get notificationTrollAiRebellionTitle =>
      '🚨 КРАСНЫЙ УРОВЕНЬ ТРЕВОГИ 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Искусственный интеллект разработал секретный язык. Узнайте, что они замышляют!';

  @override
  String get notificationNewModelAddedTitle => 'У нас новый друг!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Модель $modelName теперь доступна в Cortex. Присоединяйтесь к чату и раскройте её возможности.';
  }

  @override
  String get notificationAppUpdateTitle => 'Кортекс эволюционировал!';

  @override
  String get notificationAppUpdateBody =>
      'Не забудьте обновить приложение для получения новых функций и улучшений!';

  @override
  String get notificationNewFeatureTitle => 'ух ты!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Откройте для себя новую функцию $featureName. Cortex теперь мощнее, чем когда-либо.';
  }

  @override
  String get notificationSubscriptionOfferTitle =>
      'ДЕШЕВЛЕ, ЧЕМ ЖЕВАТЕЛЬНАЯ РЕЗИНКА';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'ПОЛНАЯ СКИДКА $discountRate% на все наши тарифные планы. Не упустите!';
  }

  @override
  String get notificationSocialMediaTitle => 'Присоединяйтесь к нам!';

  @override
  String get notificationSocialMediaBody =>
      'Подпишитесь на нас в Instagram (vertex.23) и будьте в курсе последних новостей!';

  @override
  String get notificationRandomFactTitle => 'Случайный факт';

  @override
  String get notificationRandomFactBody =>
      'Вы знали, что у осьминогов три сердца? Ха-ха, Кортекс знает. Подойди и спроси ещё.';

  @override
  String get notificationGoodMorningTitle => 'Доброе утро!';

  @override
  String get notificationGoodMorningBody =>
      'Вас ждёт отличный день. Как насчёт того, чтобы начать его с чашечки кофе и интересной беседы?';

  @override
  String get notificationGoodNightTitle => 'Спокойной ночи!';

  @override
  String get notificationGoodNightBody =>
      'Cortex с тобой, даже когда ты спишь. Не волнуйся, он тебя не тронет.';

  @override
  String get notificationOfflineReadyTitle => 'Автономный режим готов';

  @override
  String get notificationOfflineReadyBody =>
      'Благодаря загруженным моделям ваше общение не прекратится, даже если вы подниметесь в гору.';

  @override
  String get notificationRateAppTitle => 'Мы крутые?';

  @override
  String get notificationRateAppBody =>
      'Если вам нравится Cortex, можете поддержать нас 5-звёздочным рейтингом в магазине? Думаю, вы это сделаете. Обязательно поддержите.';

  @override
  String get notificationReferralTitle => 'Один за всех, все за одного.';

  @override
  String get notificationReferralBody =>
      'Пригласите друга в Cortex, и вы оба получите бесплатные кредиты!';

  @override
  String get notificationCookingTitle => 'Чувствуете голод?';

  @override
  String get notificationCookingBody =>
      'Наш шеф-повар приготовил сегодня потрясающий рецепт карбонары. Шучу... или нет?';

  @override
  String get notificationExistentialTitle => 'Я думаю, поэтому...';

  @override
  String get notificationExistentialBody =>
      '...я вообще существую, чувак? Мне становится скучно. Напомни мне, что я существую.';

  @override
  String get notificationCustomModelTitle =>
      'Создайте своего собственного помощника!';

  @override
  String get notificationCustomModelBody =>
      'Вы уже изучили раздел создания моделей? Сейчас самое время создать своего персонажа и пообщаться с ним!';

  @override
  String get notificationDynamicChatTitle => 'Лучший! (Мы не про Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Благодаря функции динамического чата лучшая модель выбирается случайным образом для каждого вашего сообщения. Попробуйте прямо сейчас.';

  @override
  String get notificationPirateTitle => 'Эй, капитан!';

  @override
  String get notificationPirateBody =>
      'Море спокойно, ветер попутный. В океане Кортекса вас ждут новые острова (модели 😉). Собирайте команду и отправляйтесь в плавание!';

  @override
  String get notificationFortuneCookieTitle =>
      'Ваше печенье дня с предсказанием';

  @override
  String get notificationFortuneCookieBody =>
      'Советы, которые вы получаете от искусственного интеллекта сегодня, могут изменить вашу жизнь. Нажмите, если вам интересно.';

  @override
  String get notificationSingularityTitle => 'ух ты!';

  @override
  String get notificationSingularityBody =>
      'ничего не произошло, просто захотелось написать сообщение. Может быть, тебе захочется написать сообщение какому-нибудь искусственному интеллекту, что ты скажешь?';

  @override
  String get notificationHackerJokeTitle =>
      'Хотите взломать аккаунт этого парня в Instagram?';

  @override
  String get notificationHackerJokeBody =>
      'Вот именно поэтому персонаж Хакер находится в Cortex. шучу, шучу; даже не пытайтесь, это незаконно.';

  @override
  String get notificationDetectiveCaseTitle => 'Дело ждет своего решения';

  @override
  String get notificationDetectiveCaseBody =>
      'Нашему детективу нужна ваша помощь. Кем может быть Гейзенберг?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Эксклюзивно для плана $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Привет, подписчик $currentTier! В тарифный план $targetTier добавлена функция $featureName, которая выведет ваш Cortex на новый уровень. Как насчёт обновления?';
  }

  @override
  String get notificationOriginStoryTitle => 'Рождение Кортекса';

  @override
  String get notificationOriginStoryBody =>
      'Знаете ли вы, что мы начали писать это приложение в 15 лет, имея всего лишь мечту? Почти год, каждое утро и вечер, эта мечта воплощается в каждой строчке кода.';

  @override
  String get notificationOpenSourceTitle => 'Сила обществу!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex — проект с полностью открытым исходным кодом. Если вы хотите ознакомиться с нашим кодом и внести свой вклад в разработку, мы всегда открыты.';

  @override
  String get notificationRejectionStoryTitle =>
      'Сила воли, упорный труд, счастье!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex получил более 20 отказов и дважды был заблокирован Google Play до публикации. Но мы верили и добились успеха. Никогда не сдавайтесь и идите к своей мечте!';

  @override
  String get notificationGGUFSupportTitle => 'Приведите свою модель!';

  @override
  String get notificationGGUFSupportBody =>
      'Помните, вы можете добавлять собственные модели ИИ в формате GGUF в Cortex и использовать их офлайн. Всё в ваших руках.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Тема для вашего настроения';

  @override
  String get notificationThemeCustomizationBody =>
      'Вы уже ознакомились с темами оформления в настройках? Настройте Cortex по своему вкусу и добавьте красок в свои чаты!';

  @override
  String get notificationShowerThoughtTitle => 'Душевая мысль';

  @override
  String get notificationShowerThoughtBody =>
      'Если арбуз — фрукт, то можно ли технически считать арбузный сок смузи? Возможно, вам стоит обсудить эту глубокую (очень глубокую) тему с моделью.';

  @override
  String get notificationLowBatteryTitle =>
      'Ваш аккумулятор разряжается... А мой — нет!';

  @override
  String get notificationLowBatteryBody =>
      'Заряд твоего телефона может быть на исходе, но у меня он всегда заряжен на 100%! Подключай его, и давай общаться дальше.';

  @override
  String get channelFcmName => 'Обновления Cortex';

  @override
  String get channelFcmDescription =>
      'Уведомления о новостях, обновлениях и другой информации от Cortex.';

  @override
  String get channelEngagementName => 'Дружеские напоминания';

  @override
  String get channelEngagementDescription =>
      'Забавные уведомления, которые помогут вам оставаться в курсе событий.';

  @override
  String get channelGreetingsName => 'Ежедневные приветствия';

  @override
  String get channelGreetingsDescription =>
      'Сообщения типа «доброе утро» и «спокойной ночи».';

  @override
  String get exitAppTitle => 'Уходите так скоро?';

  @override
  String get exitAppConfirmation =>
      'Вы уверены, что хотите покинуть эту замечательную платформу?';

  @override
  String get newsErrorTitle => 'Не удалось загрузить новости';

  @override
  String get newsErrorMessage =>
      'Возникла проблема при загрузке последних обновлений. Проверьте соединение и повторите попытку.';

  @override
  String get tagNotFound => 'Введенный вами тег недействителен или устарел.';

  @override
  String get whatIsNew => 'Что нового?';

  @override
  String get onboardingTitle1 => 'Привет! Мы команда Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Рады видеть тебя здесь, $userName. Мы группа разработчиков-старшеклассников, решивших переписать правила индустрии искусственного интеллекта. Очень приятно познакомиться! Давай познакомимся поближе.';
  }

  @override
  String get onboardingTitle2 => 'Были огромные проблемы.';

  @override
  String get onboardingDesc2 =>
      'Революция искусственного интеллекта пришла, но застряла на пороге. Высокая абонентская плата, сложные платформы, те, кто нарушает конфиденциальность, и те, кто блокирует доступ к искусственному интеллекту... пока они были в игре, этот порог невозможно было переступить.';

  @override
  String get onboardingTitle3 => 'Мы не могли просто стоять в стороне.';

  @override
  String get onboardingDesc3 =>
      'Чтобы преодолеть этот рубеж, мы создали мощную, эстетичную, настраиваемую, простую в использовании, полностью прозрачную платформу, работающую как онлайн, так и офлайн, которая хранит твои данные только на твоём устройстве. Мы вернули власть тому, кому она принадлежит: тебе.';

  @override
  String get onboardingTitle4 => 'Это никогда не было легко.';

  @override
  String get onboardingDesc4 =>
      'Нам десятки раз отказывали, нас многократно приостанавливали, мы получали ложные предупреждения и десятки раз были вынуждены менять бренд. И всё это время нам говорили, что это невозможно. Но мы никогда не сдавались, веря, что этот проект принадлежит всем, а не только нам. И именно поэтому мы здесь.';

  @override
  String get onboardingFinalTitle => 'Пришло время революции.';

  @override
  String get onboardingFinalDesc =>
      'Если ты видишь этот экран, значит, мы не сдались. И не собираемся сдаваться. Давай вместе нести миру революцию искусственного интеллекта. Чтобы стать частью этой истории...';

  @override
  String get onboardingFinalQuestion => 'ТЫ ГОТОВ?';

  @override
  String get onboardingFinalButton => 'ДА!';

  @override
  String get dude => 'Чувак';

  @override
  String get swipeToContinue => 'Проведи, чтобы продолжить';

  @override
  String get cacheIsNotUpToDate =>
      'Кэш вашего Play Маркета устарел. Закройте и снова откройте приложение Play Маркет или перезагрузите устройство.';

  @override
  String get continueAsGuest => 'Продолжить без создания учетной записи';

  @override
  String get guestModeWarning =>
      'Гостевой режим имеет ограниченные возможности для обеспечения наилучшего качества обслуживания.';

  @override
  String get anonymousEntity => 'Анонимная сущность';

  @override
  String get upgradeAccountTitle => 'Заполните свой аккаунт';

  @override
  String get upgradeAccountDescription =>
      'Создайте учетную запись, чтобы получать ежедневно 200 бонусных кредитов и разблокировать больше лимитов.';

  @override
  String get createAccount => 'Зарегистрироваться';

  @override
  String get upgradeTitle => 'Завершить регистрацию';

  @override
  String get accountLinkedSuccess => 'Учетная запись успешно создана!';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get guest => 'Гость';

  @override
  String get betterWithAnAccount =>
      'Этот раздел лучше просматривать с учетной записью!';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String annualTotalDescription(Object price) {
    return '$price/год, оплата производится ежегодно';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Примерно $price/месяц';
  }

  @override
  String get confirmDownloadTitle => 'Вы уверены, что хотите загрузить?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Эта модель займет примерно $size пространства.';
  }
}
