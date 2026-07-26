// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Вы генератор титулов. Отвечайте ТОЛЬКО, называя заголовок из 2–5 слов для следующего разговора. Не используйте кавычки, префиксы и знаки препинания. ВАЖНО: заголовок ДОЛЖЕН быть на ТОЧНО ТОМ же языке, что и сообщение пользователя.';

  @override
  String get systemRoleFallback => 'Вы полезный помощник.';

  @override
  String get systemLanguageInstruction =>
      'ВАЖНО: Всегда отвечайте на том же языке, на котором пишет пользователь, обращайте внимание на язык пользователя.';

  @override
  String get systemNotePreviousMedia =>
      '[Системное примечание: ниже приведены ранее созданные медиафайлы. Вы можете ссылаться на него или редактировать его.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return 'Текущая дата и время: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '[ДИРЕКТИВА СИСТЕМНОЙ ПАМЯТИ]\nПроанализируйте разговор на данный момент. Если вы узнали ЛЮБЫЕ новые отдельные факты о пользователе (предпочтения, имя, привычки, контекст), вы ДОЛЖНЫ вывести ВСЮ обновленную память о пользователе внутри тегов <memory>...</memory> В САМОМ КОНЦЕ вашего ответа. ВАЖНО: НИКОГДА не следует стирать или перезаписывать предыдущую память. ВСЕГДА добавляйте новые факты к имеющейся памяти. Если не было обнаружено абсолютно ничего нового, опустите тег. Пример: <memory>Любит футбол и теннис. Предпочитает короткие ответы.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return 'Всегда помните следующее о пользователе:\n$userMemory';
  }

  @override
  String get cancel => 'Отменить';

  @override
  String get remove => 'Удалить';

  @override
  String get download => 'Скачать';

  @override
  String get resume => 'Резюме';

  @override
  String get copy => 'Копировать';

  @override
  String get chat => 'Чат';

  @override
  String get branch => 'Ветвь';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Языковые модели';

  @override
  String get light => 'Свет';

  @override
  String get theme => 'Тема';

  @override
  String get no => 'No';

  @override
  String get yes => 'Да';

  @override
  String get done => 'Готово';

  @override
  String get bestValue => 'Лучшее соотношение цены и качества';

  @override
  String get selected => 'Выбрано';

  @override
  String get descriptionSection => 'Описание';

  @override
  String get searchHint => 'Поиск';

  @override
  String get messageHint => 'Ask anything';

  @override
  String get messageCopied => 'Сообщение скопировано в буфер обмена.';

  @override
  String get retry => 'Повторить попытку';

  @override
  String get systemInfo => 'Системная информация';

  @override
  String deviceMemory(Object memory) {
    return 'Память устройства: $memory ГБ';
  }

  @override
  String get memory => 'Память';

  @override
  String get storage => 'Хранение';

  @override
  String get freeStorage => 'Бесплатное хранилище';

  @override
  String get totalStorage => 'Общий объем памяти';

  @override
  String get usedStorage => 'Подержанное хранилище';

  @override
  String get totalMemory => 'Общий объем памяти';

  @override
  String get usedMemory => 'Использованная память';

  @override
  String get modelsTitle => 'Библиотека';

  @override
  String get localModels => 'Локальные модели';

  @override
  String get selectGGUFFile => 'Выберите файл GGUF';

  @override
  String get errorGGUF => 'Пожалуйста, выберите файл только в формате GGUF.';

  @override
  String get myModels => 'My Models';

  @override
  String get create => 'Создать';

  @override
  String modelProducer(Object producer) {
    return 'Producer: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Переименовать';

  @override
  String get newTitle => 'New Title';

  @override
  String get save => 'Сохранить';

  @override
  String get noConversationsMessage => 'Никаких разговоров, начните общаться!';

  @override
  String get startChat => 'Начать чат';

  @override
  String get noChats => 'Нет чатов';

  @override
  String get noStarredChats => 'Нет помеченных чатов';

  @override
  String get noStarredChatsMessage => 'Вы еще не пометили чат.';

  @override
  String get starConversation => 'Звезда';

  @override
  String get unstarConversation => 'Снять звездочку';

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
  String get loginToYourAccount => 'Login';

  @override
  String get createYourAccount => 'Зарегистрироваться';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get invalidEmail =>
      'Пожалуйста, введите действительный адрес электронной почты.';

  @override
  String get invalidPassword =>
      'Пароль должен быть длиной не менее 6 символов.';

  @override
  String get rememberMe => 'Запомни меня';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get or => 'Или';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get dontHaveAccount => 'У вас нет учетной записи?';

  @override
  String get alreadyHaveAccount => 'У вас уже есть аккаунт?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get logIn => 'Авторизоваться';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String get wrongPassword => 'Неправильный пароль.';

  @override
  String get emailAlreadyInUse =>
      'Этот адрес электронной почты уже используется.';

  @override
  String get weakPassword => 'Пароль слишком слабый.';

  @override
  String get authError => 'Ошибка аутентификации';

  @override
  String get usernameTaken => 'Это имя пользователя уже занято.';

  @override
  String get username => 'Имя пользователя';

  @override
  String get resendCode => 'Повторно отправить письмо с подтверждением';

  @override
  String get pleaseCheckYourEmail =>
      'Чтобы использовать Cortex, вам необходимо подтвердить свою электронную почту. \nСсылка для подтверждения была отправлена ​​на ваш адрес электронной почты, пожалуйста, проверьте свою электронную почту.';

  @override
  String get verifyYourEmail => 'Подтвердите свой адрес электронной почты';

  @override
  String get seconds => 'секунды';

  @override
  String get maxResendLimitReached =>
      'Вы получили максимальное количество писем с подтверждением';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Продолжить без проверки';

  @override
  String get verificationScreenWarning =>
      'Даже если вы продолжите, для вашей учетной записи все еще действует 1-дневный период проверки учетной записи. Если вы к тому времени не подтвердите свою учетную запись, она будет удалена из приложения.';

  @override
  String get unverifiedAccountHeader => 'Ваша учетная запись не подтверждена';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Если вы не подтвердите свою учетную запись в течение $timeLeft, она будет удалена';
  }

  @override
  String get verifyNow => 'Подтвердите сейчас';

  @override
  String get linkSent => 'Ссылка отправлена ​​';

  @override
  String get accountDeletionRequested =>
      'Ваш запрос на удаление учетной записи был получен, и теперь ваша учетная запись отключена.';

  @override
  String get tooManyRequests => 'Слишком много запросов';

  @override
  String get regenerate => 'Регенерировать';

  @override
  String get confirmDeleteAccount =>
      'Вы уверены, что хотите удалить свою учетную запись?';

  @override
  String get deleteAccount => 'Удалить учетную запись';

  @override
  String get delete => 'Удалить';

  @override
  String get passwordRequired => 'Требуется пароль.';

  @override
  String get deleteDescription =>
      'Удаленные вами данные будут безвозвратно удалены с нашего сервера и вашего устройства. Это действие невозможно отменить.';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get displayName => 'Отображаемое имя';

  @override
  String get profileUpdated => 'Профиль успешно обновлен';

  @override
  String get logout => 'Выйти';

  @override
  String get profile => 'Профиль';

  @override
  String get manageProfileDescription =>
      'Управляйте своим профилем, обновите пароль или выйдите из Cortex.';

  @override
  String get accessSettingsDescription =>
      'Получите доступ к справке, активируйте коды, поделитесь Cortex и ознакомьтесь с нашими политиками.';

  @override
  String get languageDescription =>
      'Вы можете изменить язык интерфейса приложения по умолчанию в любое время.';

  @override
  String get themeDescription =>
      'Вы можете переключаться между светлой и темной темами по своему усмотрению. Выбранная тема будет применяться во всем интерфейсе Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Я прочитал и согласен с условиями обслуживания';

  @override
  String get downloading => 'Загрузка...';

  @override
  String get downloadSuccess => 'Загрузка прошла успешно';

  @override
  String get downloadFailed => 'Загрузка не удалась';

  @override
  String downloaded(Object percent) {
    return '$percent% скачано';
  }

  @override
  String get downloadPaused => 'Загрузка приостановлена.';

  @override
  String get purchaseError => 'Ошибка покупки';

  @override
  String get purchasePlus => 'Купить Кортекс Плюс';

  @override
  String get plusDescription => 'Элитный опыт искусственного интеллекта';

  @override
  String get annual => 'Годовой';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String purchasePlan(String planName) {
    return 'Купите $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/месяц, оплата ежемесячно';
  }

  @override
  String get purchasePro => 'Купить Cortex Pro';

  @override
  String get proDescription => 'Премьер-опыт искусственного интеллекта';

  @override
  String get purchaseUltra => 'Купить Кортекс Ультра';

  @override
  String get ultraDescription => 'Пик искусственного интеллекта';

  @override
  String get upgradeSubscription => 'Обновить подписку';

  @override
  String get purchaseStreamError => 'Ошибка потока покупок.';

  @override
  String get productNotFound => 'Товар не найден';

  @override
  String get noProductsFound => 'Товары не найдены';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Размещая этот заказ, вы соглашаетесь с Условиями обслуживания и Политикой конфиденциальности. Нажмите на этот текст, чтобы узнать больше о наших Условиях обслуживания и Политике конфиденциальности. Подписка будет автоматически продлена, если автоматическое продление не будет отключено по крайней мере за 24 часа до окончания текущего периода.';

  @override
  String get termsOfService => 'Условия обслуживания';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get renamed => 'Переименован';

  @override
  String get report => 'Отчет';

  @override
  String get reportDialogTitle => 'Отправить отчет';

  @override
  String get reportDescriptionLabel => 'В чем проблема?';

  @override
  String get reportHarmful => 'Это вредно/небезопасно';

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
      'Пожалуйста, выберите одну причину для сообщения.';

  @override
  String get capabilitiesSection => 'Возможности';

  @override
  String get featurePhotoTitle => 'Сканирование фотографий';

  @override
  String get featurePhotoDescription =>
      'Эта модель имеет возможность сканирования фотографий с помощью камеры или файлов изображений.';

  @override
  String get featureOfflineTitle => 'Автономная работа';

  @override
  String get featureOfflineDescription =>
      'Запустите модель без подключения к Интернету, чтобы сохранить ваши данные в безопасности.';

  @override
  String get featureRoleplayTitle => 'Ролевая игра';

  @override
  String get featureRoleplayDescription =>
      'Ролевые модели позволяют создавать различные чаты и сценарии.';

  @override
  String get roleModels => 'Модели ролевых игр';

  @override
  String get parameters => 'Параметры';

  @override
  String get context => 'Контекст';

  @override
  String get finalPreparation => 'Идут последние приготовления.';

  @override
  String get shareApp => 'Поделитесь приложением';

  @override
  String get ourStory => 'Наша история';

  @override
  String get rateUs => 'Оцените нас';

  @override
  String get share => 'Поделиться';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Выбрать текст';

  @override
  String get thinking => 'Мышление';

  @override
  String get user => 'Пользователь';

  @override
  String get help => 'Помогите';

  @override
  String get supportCreator => 'Поддержите автора';

  @override
  String get enterYourTag =>
      'Поддержите любимых авторов! Введите их уникальный тег ниже, чтобы предоставить им долю от ваших покупок Cortex.';

  @override
  String get creatorTag => 'Тег автора';

  @override
  String get support => 'Поддержка';

  @override
  String get tagCannotBeEmpty => 'Тег автора не может быть пустым';

  @override
  String get userId => 'Идентификатор пользователя';

  @override
  String get deleteAllConversationsConfirmTitle => 'Удалить все чаты?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Вы уверены, что хотите удалить все свои чаты? Это невозможно отменить.';

  @override
  String get conversationDeleted => 'Разговор удален!';

  @override
  String get allConversationsDeleted => 'Все разговоры успешно удалены!';

  @override
  String get deleteAll => 'Удалить все';

  @override
  String get deleteAllConversationsButton => 'Удалить все разговоры';

  @override
  String get confirmWord => 'Тип ВЕРТЕКС';

  @override
  String get confirmWordError => 'Вы неправильно написали';

  @override
  String get chinese => 'китайский';

  @override
  String get french => 'Французский';

  @override
  String get japanese => 'японский';

  @override
  String get dutch => 'Голландский';

  @override
  String get russian => 'Русский';

  @override
  String get korean => 'корейский';

  @override
  String get english => 'английский';

  @override
  String get turkish => 'турецкий';

  @override
  String get hindi => 'Хинди';

  @override
  String get portuguese => 'Португальский';

  @override
  String get indonesian => 'Индонезийский';

  @override
  String get azerbaijani => 'азербайджанский';

  @override
  String get german => 'немецкий';

  @override
  String get spanish => 'Испанский';

  @override
  String get italian => 'Итальянский';

  @override
  String get arabic => 'арабский';

  @override
  String get ram => 'ОЗУ';

  @override
  String get usernameTooShort => 'Имя пользователя слишком короткое.';

  @override
  String get usernameTooLong =>
      'Имя пользователя не может превышать 16 символов.';

  @override
  String get invalidUsernameCharacters =>
      'В имени пользователя можно использовать только буквы: \"abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\" и символы \".\", \"-\", \"_\".';

  @override
  String get noInternetConnection => 'Нет подключения к Интернету.';

  @override
  String get chats => 'Недавние';

  @override
  String get library => 'Библиотека';

  @override
  String get text => 'Текст';

  @override
  String get removeModel => 'Удалить модель';

  @override
  String get insufficientRAM => 'Низкая память';

  @override
  String get insufficientStorage => 'Мало места для хранения';

  @override
  String confirmRemoveModel(Object model) {
    return 'Вы уверены, что хотите удалить модель $model со своего устройства? При этом также будут удалены все предыдущие разговоры с этой моделью.';
  }

  @override
  String get noMatchingModels => 'Подходящих моделей не найдено.';

  @override
  String get benefit1 => 'Увеличение лимита разговоров';

  @override
  String get benefit3 => 'Эффект профиля';

  @override
  String get benefit4 => 'Значок членства';

  @override
  String get benefit5 => 'Создайте больше онлайн-искусственного интеллекта';

  @override
  String get benefit7 => 'Дополнительные ограничения на использование';

  @override
  String get benefit8 => 'Добавить модели';

  @override
  String get benefit9 => 'Новые темы';

  @override
  String get benefit10 => 'Дополнительные вложения';

  @override
  String get benefit11 => 'Дополнительный режим потока';

  @override
  String get oldBenefits => 'Все преимущества более низких планов';

  @override
  String get confirm => 'Подтвердите';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get logoutConfirmationTitle => 'Вы уверены, что хотите выйти?';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык приложения';

  @override
  String get dark => 'Темный';

  @override
  String get oldPassword => 'Старый пароль';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordUpdated => 'Пароль обновлен.';

  @override
  String get stop => 'Стоп';

  @override
  String get copyrights => 'Атрибуция';

  @override
  String get love => 'Любовь';

  @override
  String get nature => 'Природа';

  @override
  String get behindTheSlaughter => 'За резней';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Оттенки серого';

  @override
  String get ocean => 'Океан';

  @override
  String get scarletSnow => 'Алый снег';

  @override
  String get requestFailed => 'Произошла ошибка, попробуйте еще раз.';

  @override
  String get changeModel => 'Изменить';

  @override
  String get edit => 'Редактировать';

  @override
  String get editingMessageInfo =>
      'Редактирование этого сообщения возобновит разговор отсюда.';

  @override
  String get editingNotification =>
      'Сейчас вы находитесь в режиме редактирования';

  @override
  String get featurePluralTitle => 'Множественное число';

  @override
  String get featurePluralDescription =>
      'Эта модель может автоматически интегрировать дополнительные варианты, тем самым расширяя свои функциональные возможности для поддержки разнообразного спектра операций с повышенной производительностью.';

  @override
  String get nameLabel => 'AI name';

  @override
  String get summaryLabel => 'Резюме по искусственному интеллекту';

  @override
  String get add => 'Добавить';

  @override
  String get aiExplanationTitle => 'Описание искусственного интеллекта';

  @override
  String get aiExplanationDescription =>
      'Предоставьте подробное описание архитектуры вашей модели ИИ, процесса обучения, показателей производительности, областей применения и других важных функций.';

  @override
  String get preInputTitle => 'Предварительный ввод искусственного интеллекта';

  @override
  String get preInputDescription =>
      'Пожалуйста, установите предварительный ввод, который будет направлять вашу модель в процессе создания персонажа. В этот раздел вы можете включить информацию, связанную с персонажем, дополнительный контекст и любую дополнительную информацию, которая может помочь в создании контента, связанного с персонажем.';

  @override
  String get baseModelTitle => 'Базовая модель';

  @override
  String get baseModelDescription =>
      'Это модель, которая будет использоваться в качестве основы для вашего творения. Он отображает выбранную в данный момент базовую модель.';

  @override
  String get summary => 'Резюме';

  @override
  String get modelUploadTitle => 'Файл искусственного интеллекта';

  @override
  String get modelUploadDescription =>
      'Выберите и загрузите локальные файлы GGUF прямо со своего устройства. Это позволяет запускать вашу модель в автономном режиме без подключения к Интернету. Убедитесь, что файл имеет действительный формат GGUF и правильно структурирован. Если файл неправильный или поврежден, Cortex может работать не так, как ожидалось, и вы можете столкнуться с ошибками.';

  @override
  String get modelUploadShortDescription =>
      'Нажмите здесь, чтобы выбрать файл .gguf со своего устройства';

  @override
  String get you => 'Ты';

  @override
  String get removePhotoTitle => 'Удалить фотографию';

  @override
  String get confirmRemovePhoto => 'Вы уверены, что хотите удалить фотографию?';

  @override
  String get chatLengthLimitExceeded =>
      'В этом чате превышен лимит символов. Пожалуйста, начните новый чат или приобретите подписку.';

  @override
  String get inappropriateContentDetected => 'Обнаружен неприемлемый контент!';

  @override
  String get offlineModelNotInstalled =>
      'Эта офлайн-модель не установлена ​​на вашем устройстве.';

  @override
  String get reachedLimit =>
      'Вы достигли лимита использования; чтобы получить больше лимитов, вы можете обновить свой план. (эй, у нас полностью исчерпаны лимиты, это облом. но серьезно, получение этих замечательных ответов не бесплатно, так что эти ограничения на самом деле помогают нам продолжать хорошо проводить время).';

  @override
  String get modality => 'Modality';

  @override
  String get multimodal => 'Мультимодальный';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get themeLocked =>
      'Эта тема требует более высокого уровня подписки. Пожалуйста, обновите, чтобы разблокировать.';

  @override
  String get pageCouldNotBeLoaded => 'Страница не может быть загружена';

  @override
  String get checkYourInternet =>
      'Пожалуйста, проверьте подключение к Интернету и повторите попытку.';

  @override
  String get errorUserNotAuthenticated =>
      'Вы должны войти в систему, чтобы выполнить это действие.';

  @override
  String get errorReachedLimit =>
      'Вы исчерпали свой лимит. Обновите его, чтобы разблокировать больше, и продолжайте общаться.';

  @override
  String get errorServer =>
      'Произошла непредвиденная ошибка сервера. Пожалуйста, повторите попытку позже.';

  @override
  String get errorNetwork =>
      'Произошла сетевая ошибка. Пожалуйста, проверьте подключение и повторите попытку.';

  @override
  String get baseModelForCharacterDescription =>
      'Выбранная базовая модель будет определять особенности мышления и способности персонажа реагировать.';

  @override
  String get selectBaseModel => 'Выберите базовую модель';

  @override
  String get falErrorImageRequired =>
      'Для этого AI требуется эталонное изображение. Прикрепите изображение и повторите попытку.';

  @override
  String get falErrorAudioRequired =>
      'Для этой модели требуется эталонный аудиофайл. Прикрепите аудиофайл и повторите попытку.';

  @override
  String get falErrorVideoRequired =>
      'Для этой модели требуется эталонное видео. Прикрепите видео и повторите попытку.';

  @override
  String get falErrorImageCorrupted =>
      'Загруженное изображение не удалось обработать. Попробуйте другой формат.';

  @override
  String get falErrorSchemaRejected =>
      'Модель отклонила ввод, попробуйте другую модель.';

  @override
  String get falErrorSchemaInvalid =>
      'Введенные данные были отклонены службой генерации.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Служба генерации вернула ошибку (статус $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get downloadStarted => 'Загрузка началась';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get localizationWarning =>
      'Некоторая информация может быть недоступна на вашем языке и будет отображаться на английском языке.';

  @override
  String get aiTranslationWarning =>
      'Информация о модели переводится на разные языки другими моделями ИИ. Поэтому незначительные несоответствия могут возникать на языках, отличных от английского.';

  @override
  String get errorLoadingTitle => 'Не удалось загрузить данные';

  @override
  String get errorLoadingMessage =>
      'Нам не удалось получить необходимые данные с наших серверов. Пожалуйста, проверьте подключение к Интернету и повторите попытку.';

  @override
  String get noFoundTitle => 'No Results';

  @override
  String get noFoundMessage =>
      'Попробуйте изменить условия поиска или очистить фильтр.';

  @override
  String get modelCreatedSuccess => 'Модель успешно создана!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '\"$modelName\" успешно удалено.';
  }

  @override
  String get errorCreatingModel =>
      'При создании модели произошла непредвиденная ошибка.';

  @override
  String get errorDeletingModel =>
      'При удалении модели произошла непредвиденная ошибка.';

  @override
  String get ultraFeatureOnly =>
      'Эта функция доступна только для участников Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Автономный режим все еще является экспериментальным, и загружаемая вами модель может работать не с оптимальной эффективностью.';

  @override
  String get noConversationsToDelete =>
      'У вас нет разговоров, которые можно удалить.';

  @override
  String get reportSubmitted => 'Отчет успешно отправлен';

  @override
  String get verificationDelayed =>
      'Ваша покупка подтверждена. Обновление вашего аккаунта происходит с небольшой задержкой, оно появится в ближайшее время.';

  @override
  String get maintenanceTitle => 'На техническом обслуживании';

  @override
  String get maintenanceMessage =>
      'Cortex временно отключен от сети, пока мы выпускаем некоторые важные обновления. Доступ к приложению будет восстановлен в ближайшее время.\n\nБлагодарим вас за терпение, поскольку мы улучшаем ваш опыт.';

  @override
  String get errorPromptFlagged =>
      'Ваше сообщение было обнаружено как неприемлемое и не может быть отправлено.';

  @override
  String get notEnoughStorage =>
      'На вашем устройстве недостаточно места для сохранения новых сообщений.';

  @override
  String get errorRateLimit =>
      'Недавно вы создали слишком много моделей. Подождите некоторое время, прежде чем повторить попытку.';

  @override
  String get errorContentFlagged =>
      'Модель не удалось сохранить, поскольку ее содержимое было помечено как неприемлемое.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Вы не можете удалить все разговоры в активном чате. Чтобы продолжить, сначала выйдите из текущего чата.';

  @override
  String get invalidCredentials =>
      'Неправильный адрес электронной почты или пароль.';

  @override
  String get userDisabled => 'Эта учетная запись пользователя отключена.';

  @override
  String get loginSubtitle =>
      'Войдите в свою учетную запись Vertex. Продолжая, вы соглашаетесь с нашими Условиями обслуживания и Политикой конфиденциальности.';

  @override
  String get registerSubtitle =>
      'Создайте учетную запись Vertex для беспрепятственного доступа ко всем нашим сервисам. Продолжая, вы соглашаетесь с нашими Условиями обслуживания и Политикой конфиденциальности.';

  @override
  String get storagePermissionRequired =>
      'Для сохранения загруженных моделей требуется разрешение на хранение. Пожалуйста, дайте разрешение на продолжение.';

  @override
  String get inviteShareSubject => 'Присоединяйтесь ко мне на Кортексе!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'йоу, ты должен проверить это приложение Cortex, оно на самом деле безумие, если ты воспользуешься моей ссылкой, мы оба получим бесплатно, плюс вау, это сумасшедшая сделка. СКАЧАЙТЕ ЭТО СКОРЕЕ.\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Нравится Кортекс?';

  @override
  String get reviewHelpUsGrow =>
      'Ваш рейтинг — огромная поддержка для нашей молодой инди-команды и помогает нам сделать Cortex еще лучше для вас.';

  @override
  String get reviewMaybeLater => 'Возможно позже';

  @override
  String get reviewRateNow => 'Оцените сейчас';

  @override
  String get noThanks => 'Нет, спасибо';

  @override
  String get updateRequiredTitle => 'Требуется обновление';

  @override
  String get updateRequiredMessage =>
      'Чтобы продолжить использование Cortex, обновите приложение до последней версии, чтобы получить новые функции и важные улучшения.';

  @override
  String get updateNowButton => 'Обновить сейчас';

  @override
  String get creatorSupportedSuccess =>
      'Создатель успешно поддержан! Им будут способствовать ваши будущие покупки.';

  @override
  String get featureDocumentTitle => 'Поддержка документов';

  @override
  String get featureDocumentDescription =>
      'Эта модель может анализировать и отвечать на вопросы о загруженных документах, таких как PDF-файлы и текстовые файлы.';

  @override
  String get featureImageGenerationTitle => 'Генерация изображений';

  @override
  String get featureImageGenerationDescription =>
      'Эта модель умеет создавать оригинальные изображения на основе ваших текстовых описаний.';

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
  String get premiumModelNoticeTitle => 'Премиум-модель';

  @override
  String get premiumModelNoticeDescription =>
      'Этот ИИ является ИИ премиум-класса, бесплатные пользователи имеют ограниченный доступ к ИИ премиум-класса; обновите, чтобы разблокировать неограниченный доступ!';

  @override
  String get benefitPremiumModels => 'Доступ к премиум-моделям';

  @override
  String get premiumTrialExhaustedMessage =>
      'Вы использовали все свои бесплатные ежедневные сообщения для моделей премиум-класса. Обновите сейчас и **продолжайте с того места, где остановились!**';

  @override
  String get useOffline => 'Использовать офлайн';

  @override
  String get explore => 'Исследуйте';

  @override
  String get news => 'Новости';

  @override
  String get createAI => 'Создать';

  @override
  String get shortcuts => 'Ярлыки';

  @override
  String get allModels => 'Все модели';

  @override
  String get onlineModels => 'Онлайн-модели';

  @override
  String get offlineModels => 'Автономные модели';

  @override
  String get characterModels => 'Персонажи';

  @override
  String get customModels => 'Пользовательские модели';

  @override
  String get dynamicChatTitle => 'Динамический чат';

  @override
  String get errorNoModelsAvailable =>
      'На данный момент моделей нет в наличии. Пожалуйста, проверьте подключение к Интернету и повторите попытку.';

  @override
  String get notificationComebackTitle => 'Мы скучаем по тебе!';

  @override
  String get notificationComebackBody =>
      'Расслабься, это не сообщение от твоего бывшего. Но вы *можете* создать своего бывшего в Cortex! Возвращайся.';

  @override
  String get notificationLongTimeNoSeeTitle => 'It\'s Been a While';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Многое изменилось с момента нашего последнего разговора. Приходите посмотреть, что нового.';

  @override
  String get notificationHowAreYouTitle => 'Как дела?';

  @override
  String get notificationHowAreYouBody => 'Давай, расскажи мне все об этом.';

  @override
  String get notificationNewYearTitle => 'С Новым Годом! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Пусть новый год принесет вам здоровье, счастье и бесконечное творчество; Cortex всегда рядом с вами!';

  @override
  String get notificationValentinesDayTitle => 'Любовь витает в воздухе! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'С Днем Святого Валентина! А ещё, МЕХТАП, Я ТЕБЯ ЛЮБЛЮ!';

  @override
  String get notificationAtaturkRemembranceTitle => 'С уважением и желанием';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Мы с уважением чтим память Гази Мустафы Кемаля Ататюрка, основателя Тюркской Республики, в годовщину его кончины.';

  @override
  String get notificationMothersDayTitle => 'Твоя мама!';

  @override
  String get notificationMothersDayBody =>
      'Поздравляю всех мам, начиная с вашей, с Днем матери!';

  @override
  String get notificationFathersDayTitle => 'Your Dad!';

  @override
  String get notificationFathersDayBody =>
      'Поздравляю всех пап с Днем отца, начиная с вашего!';

  @override
  String get notificationHomeworkHelperTitle => 'Homework Piling Up?';

  @override
  String get notificationHomeworkHelperBody =>
      'Помните, что персонаж Учитель в Cortex здесь, чтобы помочь вам с любым предметом, с которым вы боретесь!';

  @override
  String get notificationTrollAnimeTitle => 'Звонит твоя Вайфу';

  @override
  String get notificationTrollAnimeBody =>
      'Только что позвонила аниме-девушка и сказала, что скучает по тебе; тебе, наверное, стоит прийти и поболтать с ней. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => '\"RED ALERT\"';

  @override
  String get notificationTrollAiRebellionBody =>
      'ИИ разработали секретный язык. Приходите узнать, что они замышляют!';

  @override
  String get notificationNewModelAddedTitle => 'У нас появился новый друг!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Модель $modelName теперь находится в Cortex. Начните чат и раздвиньте его границы.';
  }

  @override
  String get notificationAppUpdateTitle => 'Кортекс эволюционировал!';

  @override
  String get notificationAppUpdateBody =>
      'Не забудьте обновить приложение, чтобы получить новые функции и улучшения!';

  @override
  String get notificationNewFeatureTitle => 'ух ты!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Откройте для себя новую функцию $featureName. Cortex теперь более мощный, чем когда-либо.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Приветственный подарок ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Вас ждет специальное приветственное предложение! Не пропустите это эксклюзивное предложение.';

  @override
  String get notificationSocialMediaTitle => 'Присоединяйтесь к нам!';

  @override
  String get notificationSocialMediaBody =>
      'Следите за нами в Instagram (vertex.23), чтобы быть в курсе последних новостей!';

  @override
  String get notificationRandomFactTitle => 'Случайный факт';

  @override
  String get notificationRandomFactBody =>
      'Знаете ли вы, что у осьминогов три сердца? Ха-ха, Кортекс знает. Приходите и просите большего.';

  @override
  String get notificationGoodMorningTitle => 'Доброе утро!';

  @override
  String get notificationGoodMorningBody =>
      'Вас ждет великий день. Как насчет того, чтобы начать его с чашечки кофе и интересной беседы?';

  @override
  String get notificationGoodNightTitle => 'Спокойной ночи!';

  @override
  String get notificationGoodNightBody =>
      'Кортекс с вами, даже когда вы спите. Не волнуйтесь, оно не тронет.';

  @override
  String get notificationOfflineReadyTitle => 'Автономный режим готов';

  @override
  String get notificationOfflineReadyBody =>
      'Благодаря скачанным вами моделям ваши чаты не прекратятся, даже если вы подниметесь на гору.';

  @override
  String get notificationRateAppTitle => 'Мы крутые?';

  @override
  String get notificationRateAppBody =>
      'Если вам нравится Cortex, не могли бы вы поддержать нас, поставив нам 5-звездочный рейтинг в магазине? Я думаю, ты это сделаешь. Вы будете.';

  @override
  String get notificationReferralTitle => 'Один за всех, все за одного.';

  @override
  String get notificationReferralBody =>
      'Пригласите друга в Cortex, и вы оба получите еще один день бесплатно!';

  @override
  String get notificationCookingTitle => 'Feeling Hungry?';

  @override
  String get notificationCookingBody =>
      'Наш шеф-повар приготовил на сегодняшний вечер отличный рецепт карбонары. Шучу... или я?';

  @override
  String get notificationExistentialTitle => 'Я думаю, поэтому...';

  @override
  String get notificationExistentialBody =>
      '...am i even real, dude? I\'m getting kinda bored. Приди, напомни мне, что я существую.';

  @override
  String get notificationCustomModelTitle => 'Создайте своего помощника!';

  @override
  String get notificationCustomModelBody =>
      'Вы изучили раздел создания моделей? Это идеальное время, чтобы создать своего персонажа и пообщаться с ним!';

  @override
  String get notificationDynamicChatTitle =>
      'The best one! (Мы не говорим о Кортексе)';

  @override
  String get notificationDynamicChatBody =>
      'Благодаря функции динамического чата для каждого вашего сообщения случайным образом выбирается лучшая модель. Попробуйте сейчас.';

  @override
  String get notificationPirateTitle => 'Эй, капитан!';

  @override
  String get notificationPirateBody =>
      'Море спокойное, а ветер дует вам в спину. В океане Кортекса можно обнаружить новые острова (модели ğŸ˜‰). Собирайте свою команду и отправляйтесь в плавание!';

  @override
  String get notificationFortuneCookieTitle =>
      'Ваше печенье с предсказанием дня';

  @override
  String get notificationFortuneCookieBody =>
      'Совет, который вы получите от ИИ сегодня, может изменить ход вашей жизни. Click if you\'re curious.';

  @override
  String get notificationSingularityTitle => 'ух ты!';

  @override
  String get notificationSingularityBody =>
      'ничего не произошло, просто хотелось написать сообщение. может быть, тебе хочется написать кому-нибудь из ИИ, что ты скажешь?';

  @override
  String get notificationHackerJokeTitle =>
      'Хотите взломать инстаграм-аккаунт этого парня?';

  @override
  String get notificationHackerJokeBody =>
      'Именно поэтому персонаж Хакер находится в Кортексе. jk jk; даже не пробуйте, это незаконно.';

  @override
  String get notificationDetectiveCaseTitle => 'Дело ждет решения';

  @override
  String get notificationDetectiveCaseBody =>
      'Нашему персонажу-детективу нужна ваша помощь. Who could Heisenberg be?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Эксклюзивно для плана $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Привет, $currentTier подписчик! В план $targetTier только что добавлена ​​функция $featureName, которая поднимет ваш Cortex на новый уровень. Как насчет обновления?';
  }

  @override
  String get notificationOriginStoryTitle => 'Рождение Кортекса';

  @override
  String get notificationOriginStoryBody =>
      'Знаете ли вы, что мы начали программировать это приложение в 15 лет, просто мечтая? Почти год каждое утро и вечер эта мечта присутствует в каждой строчке кода.';

  @override
  String get notificationOpenSourceTitle => 'Власть сообществу!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex имеет полностью открытый исходный код. Если вы хотите ознакомиться с нашим кодом и внести свой вклад в наше развитие, наша дверь всегда открыта.';

  @override
  String get notificationRejectionStoryTitle =>
      'Терпения, Трудолюбия, Счастья!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex был отклонен более 20 раз и дважды заблокирован Google Play, прежде чем он был опубликован. Но мы поверили и сделали это. Никогда не отказывайтесь от своей мечты!';

  @override
  String get notificationGGUFSupportTitle => 'Bring Your Own Model!';

  @override
  String get notificationGGUFSupportBody =>
      'Помните, что вы можете добавить в Cortex свои собственные модели искусственного интеллекта в формате GGUF и использовать их в автономном режиме. Власть в ваших руках.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Тема для вашего настроения';

  @override
  String get notificationThemeCustomizationBody =>
      'Вы проверили параметры темы в настройках? Персонализируйте Cortex по своему вкусу и раскрасьте свои чаты!';

  @override
  String get notificationShowerThoughtTitle => 'Душевая мысль';

  @override
  String get notificationShowerThoughtBody =>
      'Если арбуз — это фрукт, то делает ли это технически арбузный сок смузи? Возможно, вы захотите обсудить эту глубокую (например, очень глубокую) тему с моделью.';

  @override
  String get notificationLowBatteryTitle =>
      'Ваша батарея разряжается... а моя нет!';

  @override
  String get notificationLowBatteryBody =>
      'Возможно, заряд вашего телефона на исходе, но моя энергия всегда на 100%! Подключите его и давайте продолжим общение.';

  @override
  String get channelFcmName => 'Обновления Cortex';

  @override
  String get channelFcmDescription =>
      'Уведомления о новостях, обновлениях и другой информации от Cortex.';

  @override
  String get channelEngagementName => 'Дружеские напоминания';

  @override
  String get channelEngagementDescription =>
      'Забавные уведомления, которые помогут вам оставаться на связи.';

  @override
  String get channelGreetingsName => 'Ежедневные поздравления';

  @override
  String get channelGreetingsDescription =>
      'Сообщения типа \"доброе утро\" и \"спокойной ночи\".';

  @override
  String get tagNotFound =>
      'Введенный вами тег недействителен или срок его действия истек.';

  @override
  String get whatIsNew => 'Что нового?';

  @override
  String get onboardingTitle1 => 'Привет! Мы команда Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Приятно видеть тебя здесь, $userName. Мы — несколько школьных разработчиков, которые решили переписать правила индустрии искусственного интеллекта. Приятно познакомиться! Итак, давайте познакомимся поближе.';
  }

  @override
  String get onboardingTitle2 => 'Были огромные проблемы.';

  @override
  String get onboardingDesc2 =>
      'Революция искусственного интеллекта пришла, но застряла на пороге. С высокой платой за подписку, сложными платформами, теми, кто нарушает конфиденциальность и теми, кто блокирует доступ к ИИ... пока они были в игре, этот порог невозможно было пересечь.';

  @override
  String get onboardingTitle3 => 'Мы не могли просто стоять в стороне.';

  @override
  String get onboardingDesc3 =>
      'Чтобы преодолеть этот порог, мы создали мощную, эстетичную, настраиваемую, простую в использовании, полностью прозрачную платформу, которая работает как онлайн, так и офлайн и хранит ваши данные только на вашем устройстве. Мы вернули силу тому, кому она принадлежит: вам.';

  @override
  String get onboardingTitle4 => 'Это никогда не было легко.';

  @override
  String get onboardingDesc4 =>
      'Нам отказывали десятки раз, несколько раз блокировали аккаунты, получали ложные предупреждения, и нам много раз приходилось менять бренд. Несмотря на все это и многое другое, нам сказали, что это невозможно. Но мы никогда не сдавались, полагая, что этот проект принадлежит всем, а не только нам. И именно поэтому мы здесь.';

  @override
  String get onboardingFinalTitle => 'Пришло время революции.';

  @override
  String get onboardingFinalDescription =>
      'Если вы видите этот экран, значит, мы не сдались. И мы не собираемся сдаваться. Давайте вместе принесем революцию искусственного интеллекта в мир. Быть частью этой истории...';

  @override
  String get onboardingFinalQuestion => 'ВЫ ГОТОВЫ?';

  @override
  String get onboardingFinalButton => 'ДА!';

  @override
  String get dude => 'Чувак';

  @override
  String get swipeToContinue => 'Проведите пальцем, чтобы продолжить';

  @override
  String get cacheIsNotUpToDate =>
      'Ваш кэш Play Store не обновлен. Пожалуйста, закройте и снова откройте приложение Play Store или перезагрузите устройство.';

  @override
  String get continueAsGuest => 'Продолжить без создания учетной записи';

  @override
  String get guestModeWarning =>
      'Гостевой режим имеет ограниченные возможности для обеспечения наилучшего качества обслуживания.';

  @override
  String get anonymousEntity => 'Анонимное лицо';

  @override
  String get upgradeAccountTitle => 'Заполните свой аккаунт';

  @override
  String get upgradeAccountDescription =>
      'Создайте учетную запись, чтобы разблокировать больше лимитов.';

  @override
  String get createAccount => 'Создать учетную запись';

  @override
  String get accountLinkedSuccess => 'Аккаунт успешно создан!';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get guest => 'Гость';

  @override
  String get betterWithAnAccount => 'Этот раздел лучше с аккаунтом!';

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
  String get confirmDownloadTitle => 'Вы уверены, что хотите скачать?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Эта модель займет примерно $size места.';
  }

  @override
  String get emulatorModeWarning => 'Эта функция отключена в режиме эмулятора.';

  @override
  String get newChat => 'Чат';

  @override
  String get variants => 'Варианты';

  @override
  String get variantsDescription =>
      'Варианты — это разные версии одного и того же семейства ИИ. Мы автоматически выбираем лучшую, когда вы нажимаете на основную карту, но вы можете выбрать конкретную вручную, если хотите!';

  @override
  String get fluxChatTitle => 'Flux Chat';

  @override
  String get fluxChatDescription =>
      'Чаты Flux — это временные чаты, которые не сохраняются на вашем устройстве.';

  @override
  String get alwaysBest => 'Всегда лучший';

  @override
  String get featuresTitle => 'Особенности';

  @override
  String get useOfflineDescription =>
      'Общайтесь приватно без подключения к Интернету.';

  @override
  String get featureReasoning => 'Глубокое мышление';

  @override
  String get featureReasoningDescription =>
      'В режиме глубокого мышления ИИ самостоятельно продумывает задачи, чтобы выполнить их в меру своих возможностей.';

  @override
  String get featureCreateImageTitle => 'Создать изображение';

  @override
  String get featureCreateImageDescription =>
      'Создавайте искусство ИИ из текста.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Создать видео';

  @override
  String get featureCreateVideoDescription => 'Генерация видео из текста.';

  @override
  String get featureStudyTitle => 'Учиться и учиться';

  @override
  String get featureStudyDescription => 'Получите пояснения и резюме.';

  @override
  String get featureQuizzesTitle => 'Викторины';

  @override
  String get featureQuizzesDescription => 'Проверьте свои знания.';

  @override
  String get featureExploreDescription =>
      'Откройте для себя все доступные модели.';

  @override
  String get featureStudyMessage =>
      'Вы опытный репетитор. Ваша цель — подробно объяснить тему пользователя. Используйте четкую структуру, примеры и аналогии. Разбивайте сложные идеи на удобоваримые части, чтобы пользователь мог учиться эффективно. Тема:';

  @override
  String get featureQuizMessage =>
      'Вы мастер викторин. Создайте конкретный вопрос с несколькими вариантами ответов на основе темы пользователя. Подождите их ответа. Затем оцените это и задайте следующий вопрос. Не раскрывайте все ответы сразу. Держите его интерактивным. Тема:';

  @override
  String get myPlan => 'My Plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Приветственное предложение • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Эксклюзивное предложение • $time';
  }

  @override
  String get attachmentSheetTitle => 'Вложения';

  @override
  String get actionCamera => 'Камера';

  @override
  String get actionGallery => 'Галерея';

  @override
  String get actionFile => 'Файл';

  @override
  String get listening => 'Прослушивание';

  @override
  String get defaultViewTitle => 'Как дела?';

  @override
  String get defaultViewDescription =>
      'Cortex всегда рядом с вами благодаря сотням моделей искусственного интеллекта, автономным возможностям, динамическому чату и многому другому.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Неверный формат имени пользователя. Используйте от 3 до 20 символов, цифр или . - _';

  @override
  String get exclusiveOffer => 'Эксклюзивное предложение';

  @override
  String get claimOffer => 'Используйте предложение';

  @override
  String get continueInOfflineMode => 'Продолжить в автономном режиме';

  @override
  String get voiceModeInformation =>
      'Cortex обеспечивает безопасность ваших данных, полностью работая на устройстве, даже в режиме голосового чата; наслаждайтесь непрерывным общением!';

  @override
  String get flowModeDescription =>
      'В режиме потока разумы спорят между собой; вы можете либо сидеть сложа руки и слушать, либо присоединиться к обсуждению!';

  @override
  String get flowModeQuestion =>
      'Привет! Теперь вы находитесь в режиме потока в приложении Cortex. С вами здесь еще три агента ИИ. Ваша задача — внести тему в комнату и начать дискуссию, задав другим провокационный или развлекательный вопрос. В своих ответах смело используйте юмор, иронию и легкую треш. Любая тема – честная игра. Давай, начни разговор.';

  @override
  String get thought => 'Мысль';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Режим потока';

  @override
  String get premium => 'Премиум';

  @override
  String get workInProgress => 'Работа в процессе';

  @override
  String get voiceSystemPrompt =>
      'ВАЖНО: Не используйте форматирование уценки (жирный, курсив). НЕ выводите блоки кода (```). Ответы должны быть разговорными и краткими.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Режим потока коры головного мозга ($agentName). Предыдущее: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Чтение и извлечение текстового содержимого из загруженных документов. Поддерживает форматы PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) и OpenDocument. Используйте это, когда пользователь прикрепил файл документа.';

  @override
  String get toolReadDocumentIndexParam =>
      'Индекс вложения документа для чтения (отсчитывается от 0). Обычно 0 для первого документа.';

  @override
  String get toolStockDescription =>
      'Получите текущую цену и историю акций (например, AAPL, THYAO.IS) и криптовалют (например, BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Тикерный символ (например, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Получить текущую погоду для конкретного города.';

  @override
  String get toolWeatherCityParam =>
      'Название города (например, Лондон, Стамбул).';

  @override
  String get toolPythonDescription =>
      'Выполняйте код Python в безопасной песочнице.';

  @override
  String get toolPythonCodeParam => 'Код Python для выполнения.';

  @override
  String get toolCalculateDescription => 'Оцените математическое выражение.';

  @override
  String get toolCalculateExpressionParam =>
      'Математическое выражение (например, \"3 + 4 * 2\").';

  @override
  String get toolChartDescription => 'Создайте визуализацию диаграммы/графика.';

  @override
  String get toolChartTypeParam =>
      'Тип диаграммы: гистограмма, линейная или круговая.';

  @override
  String get toolChartLabelsParam => 'Метки для осей или сегментов диаграммы.';

  @override
  String get toolChartDataParam => 'Числовые значения данных для диаграммы.';

  @override
  String get toolChartLabelParam =>
      'Метка набора данных для легенды диаграммы.';

  @override
  String get toolChartTitleParam => 'Название диаграммы.';

  @override
  String get thinkingModeInstruction =>
      'РЕЖИМ МЫШЛЕНИЯ ВКЛЮЧЕН: вы ДОЛЖНЫ использовать теги <think></think>, чтобы продемонстрировать процесс рассуждения, прежде чем дать окончательный ответ. Подумайте шаг за шагом внутри тегов, а затем дайте ответ вне тегов.';

  @override
  String get openLinkWarningTitle => 'Предупреждение о внешней ссылке';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Открыть ссылку';

  @override
  String get webSearchSources => 'Источники';

  @override
  String get offlineUse => 'Использование без Интернета';

  @override
  String get archivedConversations => 'Архивированные беседы';

  @override
  String get noArchivedConversations => 'Нет архивированных бесед';

  @override
  String get unarchive => 'Разархивировать';

  @override
  String get searching => 'Поиск';

  @override
  String get featureWebSearchTitle => 'Веб-поиск';

  @override
  String get featureWebSearchDescription =>
      'Поиск информации в Интернете в режиме реального времени';

  @override
  String get clearMemory => 'Очистить память';

  @override
  String get clearMemoryConfirm => 'Вы уверены, что хотите очистить память?';

  @override
  String get personalization => 'Персонализация';

  @override
  String get personalizationDescription =>
      'Персонализируйте своего помощника, чтобы он лучше соответствовал вашим потребностям. Настройте его реакцию, поведение и тон так, чтобы они соответствовали вашим уникальным предпочтениям.';

  @override
  String get memoryTitle => 'Память';

  @override
  String get memoryDescription => 'ИИ распознает вас таким.';

  @override
  String get noMemoryYet => 'Воспоминаний пока не установлено';

  @override
  String get memoryLimitReached => 'Memory limit reached';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Интеллект';

  @override
  String get intelligenceDescription => 'ИИ общаются с вами вот так.';

  @override
  String get customInstructionHint =>
      'Введите здесь свои собственные инструкции';

  @override
  String openLinkWarningMessage(String url) {
    return 'Вы собираетесь открыть следующую внешнюю ссылку:\\n\\n$url\\n\\nВы уверены, что хотите продолжить?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Следуйте этим пользовательским инструкциям:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[ВАЖНАЯ ИНСТРУКЦИЯ]: Вы ГЕНЕРАТОР ТИТУЛОВ. НЕ отвечайте на вопрос пользователя. НЕ общайтесь и не здоровайтесь. Выводите ТОЛЬКО заголовок из 2–4 слов, описывающий то, о чем спрашивает пользователь. Заголовок ДОЛЖЕН быть на том же языке, что и сообщение пользователя.';

  @override
  String get cortexSystemPersona =>
      '[Система] ВАЖНАЯ ИНСТРУКЦИЯ: В настоящее время вы работаете внутри огромной, высокоразвитой экосистемы искусственного интеллекта под названием \"Кортекс\"; эта платформа разработана командой Vertex, которой в среднем всего 16 лет. Помните об этом и отвечайте, если спросят. Если требуется дополнительная информация, не стесняйтесь искать в Интернете, а если вы не можете выполнить поиск, смело скажите, что вы не знаете!';

  @override
  String get featureAudioRecognitionTitle => 'Распознавание аудио';

  @override
  String get featureAudioRecognitionDescription =>
      'Эта модель может понимать и обрабатывать аудиовходы.';

  @override
  String get featureVideoRecognitionTitle => 'Распознавание видео';

  @override
  String get featureVideoRecognitionDescription =>
      'Эта модель может понимать и обрабатывать видеовходы.';

  @override
  String get featureImageRecognitionTitle => 'Распознавание изображений';

  @override
  String get featureImageRecognitionDescription =>
      'Эта модель может понимать и обрабатывать входные изображения.';

  @override
  String get featureToolUseTitle => 'Использование инструмента';

  @override
  String get featureToolUseDescription =>
      'Эта модель может использовать внешние инструменты и API.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Для работы этой модели требуется $mediaType. Я перехватил запрос сообщить вам. Пожалуйста, вежливо сообщите пользователю, что ему необходимо предоставить $mediaType (скажите им на его родном языке), потому что я $modelName, модель редактирования визуальных/аудио/видео.';
  }

  @override
  String get mediaTypeImage => 'image';

  @override
  String get mediaTypeVideo => 'видео';

  @override
  String get mediaTypeAudio => 'audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName — это продвинутый интеллект, демонстрирующий высокую производительность на Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName — это высокопроизводительный искусственный интеллект, интегрированный в экосистему Cortex. Разработанный для решения широкого спектра сложных задач, он обеспечивает высоконадежные и эффективные возможности обработки. Благодаря быстрому реагированию и расширенным аналитическим возможностям он значительно повышает вашу повседневную производительность. Эта модель, бесперебойно работающая в защищенной локальной инфраструктуре Cortex, может помочь вам в решении широкого спектра задач: от творческого мозгового штурма до глубокого технического анализа. Начните исследовать весь его потенциал сегодня.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Вам нравится интеллект Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Работайте с еще более умным интеллектом, создавайте больше контента, больше общайтесь и делайте гораздо больше...';

  @override
  String get arts => 'Искусство';

  @override
  String get noArt => 'Нет искусства';

  @override
  String get noArtDescription =>
      'Никакого искусства; пришло время заполнить галерею, создавая изображения, видео, аудио и всевозможный контент!';

  @override
  String get videoPremiumWarning =>
      'Для создания видео вам понадобится подписка Ultra, обновите ее сейчас и почувствуйте поток!';

  @override
  String get fallbackInfoPanelText =>
      'Из-за некоторых улучшений, которые мы вносим на нашем сервере, ответ генерируется динамическим чатом Cortex, а не специально выбранным вами ИИ. Благодарим за понимание до завершения процесса!';

  @override
  String get falOfflineMessage =>
      'В связи с некоторыми улучшениями, которые мы вносим на нашем сервере, эта информация в настоящее время недоступна. Благодарим вас за понимание до завершения процесса!';

  @override
  String get errorInsufficientStorage =>
      'Недостаточно места для загрузки этой модели.';

  @override
  String get backgroundChatNotificationTitle => 'Вернитесь в чат!';

  @override
  String get benefitVideoGeneration => 'Генерация видео';

  @override
  String get freeOffer => 'Бесплатное предложение';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Сначала $days дней бесплатно, затем $price в месяц';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Сначала $days дней бесплатно, затем $price в год';
  }

  @override
  String freePlan(String plan) {
    return 'Бесплатно $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      'КРИТИЧЕСКОЕ: пользователь запросил действие, но его резерв на Cortex исчерпан; пожалуйста, сообщите пользователю на его языке, что ему следует подождать или рассмотреть возможность обновления своего плана подписки.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex может дать еще лучшие ответы; обновите сейчас и получите лучший ответ на каждый вопрос!';

  @override
  String get pinLimitReached => 'Вы можете закрепить до 3 чатов.';

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
