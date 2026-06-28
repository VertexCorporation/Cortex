// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get chatTitlePrompt =>
      '제목 생성기입니다. 다음 대화에 2~5단어로 된 제목만 입력하세요. 따옴표, 접두사, 구두점은 사용하지 마세요. 중요: 제목은 사용자의 메시지와 정확히 동일한 언어로 작성해야 합니다.';

  @override
  String get systemRoleFallback => '당신은 도움을 주는 조력자입니다.';

  @override
  String get systemLanguageInstruction =>
      '\n\n중요: 항상 사용자가 작성한 언어와 동일한 언어로 응답하고, 사용자의 언어에 주의를 기울이십시오.';

  @override
  String get systemNotePreviousMedia =>
      '[시스템 참고: 아래는 이전에 생성된 미디어입니다. 참고하거나 편집할 수 있습니다.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\n현재 날짜 및 시간: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\n지금까지의 대화를 분석합니다. 사용자에 대한 새로운 사실(선호도, 이름, 습관, 상황)을 알게 된 경우, 응답의 맨 마지막에 <memory>...</memory> 태그 안에 업데이트된 사용자 정보를 모두 출력해야 합니다. 중요: 이전 메모리를 절대 지우거나 덮어쓰면 안 됩니다. 항상 새로운 사실을 기존 메모리에 추가해야 합니다. 새로운 정보를 전혀 알지 못하는 경우에는 태그를 생략합니다. 예: <memory>축구와 테니스를 좋아합니다. 짧은 답변을 선호합니다.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\n사용자에 대해 항상 다음을 기억하세요:\n$userMemory';
  }

  @override
  String get cancel => '취소';

  @override
  String get remove => '제거하다';

  @override
  String get download => '다운로드';

  @override
  String get resume => '재개';

  @override
  String get copy => '복사';

  @override
  String get chat => '채팅';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => '언어 모델';

  @override
  String get light => '라이트';

  @override
  String get theme => '테마';

  @override
  String get no => '아니요';

  @override
  String get yes => '예';

  @override
  String get done => '완료';

  @override
  String get bestValue => '최고의 가치';

  @override
  String get selected => '선택됨';

  @override
  String get descriptionSection => '설명';

  @override
  String get searchHint => '검색';

  @override
  String get messageHint => '무엇이든 물어보세요';

  @override
  String get messageCopied => '메시지가 클립보드에 복사되었습니다.';

  @override
  String get retry => '재시도';

  @override
  String get systemInfo => '시스템 정보';

  @override
  String deviceMemory(Object memory) {
    return '기기 메모리: ${memory}GB';
  }

  @override
  String get memory => '메모리';

  @override
  String get storage => '저장 공간';

  @override
  String get freeStorage => '사용 가능한 공간';

  @override
  String get totalStorage => '총 저장 공간';

  @override
  String get usedStorage => '사용된 저장 공간';

  @override
  String get totalMemory => '총 메모리';

  @override
  String get usedMemory => '사용된 메모리';

  @override
  String get modelsTitle => '라이브러리';

  @override
  String get localModels => '로컬 모델';

  @override
  String get selectGGUFFile => 'GGUF 파일 선택';

  @override
  String get errorGGUF => 'GGUF 형식의 파일만 선택해주세요.';

  @override
  String get myModels => '내 모델';

  @override
  String get create => '생성';

  @override
  String modelProducer(Object producer) {
    return '제작사: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => '이름 변경';

  @override
  String get newTitle => '새 제목';

  @override
  String get save => '저장';

  @override
  String get noConversationsMessage => '대화가 없습니다, 채팅을 시작해보세요!';

  @override
  String get startChat => '채팅 시작하기';

  @override
  String get noChats => '채팅 없음';

  @override
  String get noStarredChats => '별표 표시된 채팅 없음';

  @override
  String get noStarredChatsMessage => '아직 별표 표시한 채팅이 없습니다.';

  @override
  String get starConversation => '별표 표시';

  @override
  String get unstarConversation => '언스타';

  @override
  String get loginToYourAccount => '로그인';

  @override
  String get createYourAccount => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get invalidEmail => '유효한 이메일 주소를 입력해주세요.';

  @override
  String get invalidPassword => '비밀번호는 6자 이상이어야 합니다.';

  @override
  String get rememberMe => '로그인 상태 유지';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get or => '또는';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get signUp => '가입하기';

  @override
  String get logIn => '로그인';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get wrongPassword => '잘못된 비밀번호입니다.';

  @override
  String get emailAlreadyInUse => '이미 사용 중인 이메일입니다.';

  @override
  String get weakPassword => '비밀번호가 너무 약합니다.';

  @override
  String get authError => '인증 오류';

  @override
  String get usernameTaken => '이미 사용 중인 사용자 이름입니다.';

  @override
  String get username => '사용자 이름';

  @override
  String get resendCode => '인증 이메일 재전송';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex를 사용하려면 이메일을 인증해야 합니다. \n인증 링크가 이메일 주소로 전송되었으니 확인해주세요.';

  @override
  String get verifyYourEmail => '이메일 인증하기';

  @override
  String get seconds => '초';

  @override
  String get maxResendLimitReached => '인증 이메일 최대 전송 횟수에 도달했습니다.';

  @override
  String get verificationScreenContinueWithoutVerification => '인증 없이 계속하기';

  @override
  String get verificationScreenWarning =>
      '계속 진행하더라도 계정에 대한 1일 인증 기간은 여전히 유효합니다. 그때까지 계정을 인증하지 않으면 앱에서 삭제됩니다.';

  @override
  String get unverifiedAccountHeader => '계정이 인증되지 않았습니다.';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return '$timeLeft 이내에 계정을 인증하지 않으면 삭제됩니다.';
  }

  @override
  String get verifyNow => '지금 인증하기';

  @override
  String get linkSent => '링크가 전송되었습니다.';

  @override
  String get accountDeletionRequested => '계정 삭제 요청이 접수되었으며 계정이 비활성화되었습니다.';

  @override
  String get tooManyRequests => '요청이 너무 많습니다.';

  @override
  String get regenerate => '재생성';

  @override
  String get confirmDeleteAccount => '정말로 계정을 삭제하시겠습니까?';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get delete => '삭제';

  @override
  String get passwordRequired => '비밀번호가 필요합니다.';

  @override
  String get deleteDescription =>
      '삭제한 데이터는 저희 서버와 기기에서 영구적으로 제거됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get displayName => '표시 이름';

  @override
  String get profileUpdated => '프로필이 성공적으로 업데이트되었습니다.';

  @override
  String get logout => '로그아웃';

  @override
  String get profile => '프로필';

  @override
  String get manageProfileDescription =>
      '프로필을 관리하고, 비밀번호를 업데이트하거나 Cortex에서 로그아웃하세요.';

  @override
  String get accessSettingsDescription =>
      '도움말에 액세스하고, 코드를 사용하고, Cortex를 공유하고, 정책을 확인하세요.';

  @override
  String get languageDescription => '언제든지 기본 앱 인터페이스 언어를 변경할 수 있습니다.';

  @override
  String get themeDescription =>
      '선호에 따라 라이트 테마와 다크 테마 간에 전환할 수 있습니다. 선택한 테마는 Cortex 인터페이스 전체에 적용됩니다.';

  @override
  String get iHaveReadAndAgree => '서비스 약관에 읽고 동의합니다.';

  @override
  String get downloading => '다운로드 중...';

  @override
  String get downloadSuccess => '다운로드 성공';

  @override
  String get downloadFailed => '다운로드 실패';

  @override
  String downloaded(Object percent) {
    return '$percent% 다운로드됨';
  }

  @override
  String get downloadPaused => '다운로드가 일시 중지되었습니다.';

  @override
  String get purchaseError => '구매 오류';

  @override
  String get purchasePlus => 'Cortex 플러스 구매하기';

  @override
  String get plusDescription => '엘리트 인공지능 체험';

  @override
  String get annual => '연간';

  @override
  String get monthly => '월간';

  @override
  String get manageSubscription => '구독 관리';

  @override
  String purchasePlan(String planName) {
    return '$planName 구매';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/월, 월별 청구';
  }

  @override
  String get purchasePro => 'Cortex 프로 구매하기';

  @override
  String get proDescription => '최고의 인공지능 경험';

  @override
  String get purchaseUltra => 'Cortex 울트라 구매하기';

  @override
  String get ultraDescription => '인공지능의 정점';

  @override
  String get upgradeSubscription => '구독 업그레이드';

  @override
  String get purchaseStreamError => '구매 스트림 오류.';

  @override
  String get productNotFound => '상품을 찾을 수 없음';

  @override
  String get noProductsFound => '상품을 찾을 수 없음';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      '이 주문을 함으로써 귀하는 서비스 약관 및 개인정보 처리방침에 동의하게 됩니다. 이 텍스트를 클릭하여 서비스 약관 및 개인정보 처리방침에 대해 자세히 알아볼 수 있습니다. 현재 기간이 종료되기 최소 24시간 전에 자동 갱신을 해제하지 않으면 구독은 자동으로 갱신됩니다.';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get renamed => '이름이 바뀌었습니다';

  @override
  String get report => '신고하기';

  @override
  String get reportDialogTitle => '신고 제출';

  @override
  String get reportDescriptionLabel => '어떤 문제가 있나요?';

  @override
  String get reportHarmful => '유해하거나 안전하지 않습니다.';

  @override
  String get reportNotTrue => '사실이 아닙니다.';

  @override
  String get reportNotHelpful => '도움이 되지 않습니다.';

  @override
  String get closeButton => '닫기';

  @override
  String get submitButton => '제출';

  @override
  String get reportErrorMessage => '신고 사유를 하나 선택해주세요.';

  @override
  String get capabilitiesSection => '기능';

  @override
  String get featurePhotoTitle => '사진 스캔';

  @override
  String get featurePhotoDescription =>
      '이 모델은 카메라나 이미지 파일을 통해 사진을 스캔하는 기능이 있습니다.';

  @override
  String get featureOfflineTitle => '오프라인 작동';

  @override
  String get featureOfflineDescription => '인터넷 연결 없이 모델을 실행하여 데이터를 안전하게 보호하세요.';

  @override
  String get featureRoleplayTitle => '역할 놀이';

  @override
  String get featureRoleplayDescription =>
      '역할 놀이 모델을 통해 다양한 채팅과 시나리오를 만들 수 있습니다.';

  @override
  String get roleModels => '롤플레잉 모델';

  @override
  String get parameters => '파라미터';

  @override
  String get context => '컨텍스트';

  @override
  String get finalPreparation => '최종 준비가 진행 중입니다.';

  @override
  String get shareApp => '앱 공유하기';

  @override
  String get ourStory => '우리의 이야기';

  @override
  String get rateUs => '평가하기';

  @override
  String get share => '공유';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => '텍스트 선택';

  @override
  String get thinking => '생각 중';

  @override
  String get user => '사용자';

  @override
  String get help => '도움말';

  @override
  String get supportCreator => '크리에이터 지원하기';

  @override
  String get enterYourTag =>
      '좋아하는 크리에이터를 응원하세요! 아래에 크리에이터의 고유 태그를 입력하여 Cortex 구매 시 발생하는 수익을 크리에이터에게 기부하세요.';

  @override
  String get creatorTag => '크리에이터 태그';

  @override
  String get support => '후원하기';

  @override
  String get tagCannotBeEmpty => '생성자 태그는 비어 있을 수 없습니다.';

  @override
  String get userId => '사용자 ID';

  @override
  String get deleteAllConversationsConfirmTitle => '모든 채팅 삭제?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '정말로 모든 채팅을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get conversationDeleted => '대화 내용이 삭제되었습니다!';

  @override
  String get allConversationsDeleted => '모든 대화가 성공적으로 삭제되었습니다!';

  @override
  String get deleteAll => '모두 삭제';

  @override
  String get deleteAllConversationsButton => '모든 대화 삭제';

  @override
  String get confirmWord => 'VERTEX 입력';

  @override
  String get confirmWordError => '잘못 입력하셨습니다.';

  @override
  String get chinese => '중국어';

  @override
  String get french => '프랑스어';

  @override
  String get japanese => '일본어';

  @override
  String get dutch => '네덜란드 사람';

  @override
  String get russian => '러시아인';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';

  @override
  String get turkish => '터키어';

  @override
  String get hindi => '힌디어';

  @override
  String get portuguese => '포르투갈어';

  @override
  String get indonesian => '인도네시아어';

  @override
  String get azerbaijani => '아제르바이잔어';

  @override
  String get german => '독일어';

  @override
  String get spanish => '스페인어';

  @override
  String get italian => '이탈리아어';

  @override
  String get arabic => '아라비아 말';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => '사용자 이름이 너무 짧습니다.';

  @override
  String get usernameTooLong => '사용자 이름은 16자를 초과할 수 없습니다.';

  @override
  String get invalidUsernameCharacters =>
      '사용자 이름에는 \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' 문자와 \'.\', \'-\', \'_\' 문자만 사용할 수 있습니다.';

  @override
  String get noInternetConnection => '인터넷에 연결되어 있지 않습니다.';

  @override
  String get chats => '받은 편지함';

  @override
  String get library => '라이브러리';

  @override
  String get text => '텍스트';

  @override
  String get removeModel => '모델 제거';

  @override
  String get insufficientRAM => '메모리 부족';

  @override
  String get insufficientStorage => '저장 공간 부족';

  @override
  String confirmRemoveModel(Object model) {
    return '기기에서 $model 모델을 삭제하시겠습니까? 삭제하면 해당 모델과의 이전 대화 내용도 모두 삭제됩니다.';
  }

  @override
  String get noMatchingModels => '일치하는 모델을 찾을 수 없습니다.';

  @override
  String get benefit1 => '대화 제한 증가';

  @override
  String get benefit3 => '프로필 효과';

  @override
  String get benefit4 => '멤버십 배지';

  @override
  String get benefit5 => '더 많은 온라인 인공지능 생성';

  @override
  String get benefit7 => '추가 사용 제한';

  @override
  String get benefit8 => '모델 추가';

  @override
  String get benefit9 => '새로운 테마';

  @override
  String get benefit10 => '추가 첨부 파일';

  @override
  String get benefit11 => '더 많은 흐름 모드';

  @override
  String get oldBenefits => '하위 플랜의 모든 혜택';

  @override
  String get confirm => '확인';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get logoutConfirmationTitle => '로그아웃하시겠습니까?';

  @override
  String get settings => '설정';

  @override
  String get language => '앱 언어';

  @override
  String get dark => '어둡게';

  @override
  String get oldPassword => '이전 비밀번호';

  @override
  String get newPassword => '새 비밀번호';

  @override
  String get passwordUpdated => '비밀번호가 업데이트되었습니다.';

  @override
  String get stop => '중지';

  @override
  String get copyrights => '저작권 정보';

  @override
  String get love => '사랑';

  @override
  String get nature => '자연';

  @override
  String get behindTheSlaughter => '도살의 배후';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => '그레이스케일';

  @override
  String get ocean => '바다';

  @override
  String get scarletSnow => '진홍빛 눈';

  @override
  String get requestFailed => '오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get changeModel => '변경';

  @override
  String get edit => '수정';

  @override
  String get editingMessageInfo => '이 메시지를 수정하면 여기서부터 대화가 다시 시작됩니다.';

  @override
  String get editingNotification => '지금은 수정 모드입니다.';

  @override
  String get featurePluralTitle => '복합적인';

  @override
  String get featurePluralDescription =>
      '이 모델은 추가적인 확장을 자동으로 통합하여, 향상된 성능으로 다양한 작업을 지원하도록 기능적 역량을 확장할 수 있습니다.';

  @override
  String get nameLabel => 'AI 이름';

  @override
  String get summaryLabel => 'AI 요약';

  @override
  String get add => '추가';

  @override
  String get aiExplanationTitle => '인공지능 설명';

  @override
  String get aiExplanationDescription =>
      'AI 모델의 아키텍처, 훈련 과정, 성능 지표, 적용 분야 및 기타 중요한 기능에 대해 자세히 설명해주세요.';

  @override
  String get preInputTitle => '인공지능 사전 입력';

  @override
  String get preInputDescription =>
      '모델이 캐릭터 생성 과정에서 지침으로 삼을 사전 입력을 설정해주세요. 이 섹션에는 캐릭터 관련 정보, 추가 컨텍스트 및 캐릭터 관련 콘텐츠 생성에 도움이 될 수 있는 기타 세부 정보를 포함할 수 있습니다.';

  @override
  String get baseModelTitle => '기본 모델';

  @override
  String get baseModelDescription =>
      '이것은 당신의 창작물의 기반으로 사용될 모델입니다. 현재 선택된 기본 모델을 표시합니다.';

  @override
  String get summary => '요약';

  @override
  String get modelUploadTitle => '인공지능 파일';

  @override
  String get modelUploadDescription =>
      '기기에서 직접 로컬 GGUF 파일을 선택하고 업로드하세요. 이를 통해 인터넷 연결 없이 오프라인으로 모델을 실행할 수 있습니다. 파일이 유효한 GGUF 형식이고 올바르게 구성되었는지 확인하세요. 파일이 잘못되었거나 손상된 경우 Cortex가 예상대로 작동하지 않을 수 있으며 오류가 발생할 수 있습니다.';

  @override
  String get modelUploadShortDescription => '여기를 탭하여 기기에서 .gguf 파일을 선택하세요';

  @override
  String get you => '당신';

  @override
  String get removePhotoTitle => '사진 제거';

  @override
  String get confirmRemovePhoto => '사진을 제거하시겠습니까?';

  @override
  String get chatLengthLimitExceeded =>
      '이 채팅이 글자 수 제한을 초과했습니다. 새 채팅을 시작하거나 구독을 구매해주세요.';

  @override
  String get inappropriateContentDetected => '부적절한 콘텐츠가 감지되었습니다!';

  @override
  String get offlineModelNotInstalled => '이 오프라인 모델은 기기에 설치되어 있지 않습니다.';

  @override
  String get reachedLimit =>
      '사용량 한도에 도달하셨습니다. 사용량을 늘리려면 요금제를 업그레이드하세요. (물론 사용량 한도가 소진되면 아쉽겠지만, 멋진 답변들을 얻는 데는 돈이 들기 때문에 이러한 사용량 제한은 저희가 계속해서 좋은 서비스를 제공할 수 있도록 도와주는 중요한 요소입니다.)';

  @override
  String get modality => '모달리티';

  @override
  String get multimodal => '멀티모달';

  @override
  String get anErrorOccurred => '오류가 발생했습니다.';

  @override
  String get themeLocked => '이 테마는 더 높은 구독 등급이 필요합니다. 잠금 해제하려면 업그레이드해주세요.';

  @override
  String get pageCouldNotBeLoaded => '페이지를 로드할 수 없습니다.';

  @override
  String get checkYourInternet => '인터넷 연결을 확인하고 다시 시도해주세요.';

  @override
  String get errorUserNotAuthenticated => '이 작업을 수행하려면 로그인해야 합니다.';

  @override
  String get errorReachedLimit =>
      '채팅 한도에 도달했습니다. 업그레이드하여 더 많은 기능을 이용하고 계속 채팅하세요.';

  @override
  String get errorServer => '예기치 않은 서버 오류가 발생했습니다. 나중에 다시 시도해주세요.';

  @override
  String get errorNetwork => '네트워크 오류가 발생했습니다. 연결을 확인하고 다시 시도해주세요.';

  @override
  String get baseModelForCharacterDescription =>
      '선택된 기본 모델이 캐릭터의 추론 및 응답 능력을 결정합니다.';

  @override
  String get selectBaseModel => '기본 모델 선택';

  @override
  String get falErrorImageRequired =>
      '이 AI는 참조 이미지가 필요합니다. 이미지를 첨부하고 다시 시도해 주세요.';

  @override
  String get falErrorAudioRequired =>
      '이 모델은 참조 오디오 파일이 필요합니다. 오디오 파일을 첨부하고 다시 시도해 주세요.';

  @override
  String get falErrorVideoRequired =>
      '이 모델은 참조 영상이 필요합니다. 영상을 첨부하신 후 다시 시도해 주세요.';

  @override
  String get falErrorImageCorrupted =>
      '업로드하신 이미지를 처리할 수 없습니다. 다른 형식의 이미지를 시도해 주세요.';

  @override
  String get falErrorSchemaRejected => '모델이 입력을 거부했습니다. 다른 모델을 사용해 보세요.';

  @override
  String get falErrorSchemaInvalid => '해당 입력은 생성 서비스에서 거부되었습니다.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return '생성 서비스에서 오류가 반환되었습니다(상태 $statusCode).';
  }

  @override
  String get couldNotOpenLink => '링크를 열 수 없습니다.';

  @override
  String get downloadStarted => '다운로드가 시작되었습니다.';

  @override
  String get notAvailable => '사용 불가';

  @override
  String get localizationWarning => '일부 정보는 귀하의 언어로 제공되지 않을 수 있으며 영어로 표시됩니다.';

  @override
  String get aiTranslationWarning =>
      '모델 정보는 다른 AI 모델에 의해 다양한 언어로 번역됩니다. 따라서 영어 이외의 언어에서는 약간의 불일치가 발생할 수 있습니다.';

  @override
  String get errorLoadingTitle => '데이터 로드 실패';

  @override
  String get errorLoadingMessage =>
      '서버에서 필요한 데이터를 가져올 수 없었습니다. 인터넷 연결을 확인하고 다시 시도해주세요.';

  @override
  String get noFoundTitle => '결과 없음';

  @override
  String get noFoundMessage => '검색어를 조정하거나 필터를 지워보세요.';

  @override
  String get modelCreatedSuccess => '모델이 성공적으로 생성되었습니다!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName”이(가) 성공적으로 제거되었습니다.';
  }

  @override
  String get errorCreatingModel => '모델을 생성하는 동안 예기치 않은 오류가 발생했습니다.';

  @override
  String get errorDeletingModel => '모델을 삭제하는 동안 예기치 않은 오류가 발생했습니다.';

  @override
  String get ultraFeatureOnly => '이 기능은 울트라 회원만 사용할 수 있습니다.';

  @override
  String get experimentalOfflineWarning =>
      '오프라인 모드는 아직 실험 단계이며 다운로드한 모델이 최적의 효율로 작동하지 않을 수 있습니다.';

  @override
  String get noConversationsToDelete => '삭제할 대화가 없습니다.';

  @override
  String get reportSubmitted => '신고가 성공적으로 제출되었습니다.';

  @override
  String get verificationDelayed =>
      '구매가 확인되었습니다. 계정 업데이트에 약간의 지연이 있으며 곧 반영될 것입니다.';

  @override
  String get maintenanceTitle => '점검 중';

  @override
  String get maintenanceMessage =>
      '중요한 업데이트를 진행하는 동안 Cortex가 일시적으로 오프라인 상태입니다. 앱 접근은 곧 복구될 것입니다.\n\n더 나은 경험을 위해 기다려주셔서 감사합니다.';

  @override
  String get errorPromptFlagged => '메시지가 부적절한 것으로 감지되어 보낼 수 없었습니다.';

  @override
  String get notEnoughStorage => '기기에 새 메시지를 저장할 공간이 부족합니다.';

  @override
  String get errorRateLimit => '최근에 너무 많은 모델을 생성했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errorContentFlagged => '콘텐츠가 부적절한 것으로 플래그 지정되어 모델을 저장할 수 없었습니다.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      '활성 채팅 중에는 모든 대화를 삭제할 수 없습니다. 진행하려면 먼저 현재 채팅을 종료해주세요.';

  @override
  String get invalidCredentials => '잘못된 이메일 또는 비밀번호입니다.';

  @override
  String get userDisabled => '이 사용자 계정은 비활성화되었습니다.';

  @override
  String get loginSubtitle =>
      'Vertex 계정에 로그인하세요. 계속 진행하면 당사의 서비스 약관 및 개인정보 처리방침에 동의하는 것으로 간주됩니다.';

  @override
  String get registerSubtitle =>
      'Vertex 계정을 생성하시면 모든 서비스를 원활하게 이용하실 수 있습니다. 계속 진행하시면 당사의 서비스 약관 및 개인정보 처리방침에 동의하는 것으로 간주됩니다.';

  @override
  String get storagePermissionRequired =>
      '다운로드한 모델을 저장하려면 저장소 권한이 필요합니다. 계속하려면 권한을 허용해주세요.';

  @override
  String get inviteShareSubject => 'Cortex에 저와 함께해요!';

  @override
  String inviteShareMessage(String cortexLink) {
    return '야, 너 이 앱 꼭 해봐. Cortex 진짜 대박이야. 내 링크 쓰면 우리 둘 다 무료로 받을 수 있어. 진짜 대박이야. 지금 바로 다운로드해! \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortex가 마음에 드시나요?';

  @override
  String get reviewHelpUsGrow =>
      '여러분의 평점은 저희 젊은 인디팀에게 큰 힘이 되며, Cortex를 더 나은 앱으로 만드는 데 도움이 됩니다.';

  @override
  String get reviewMaybeLater => '나중에';

  @override
  String get reviewRateNow => '지금 평가하기';

  @override
  String get noThanks => '아니요, 괜찮습니다';

  @override
  String get updateRequiredTitle => '업데이트 필요';

  @override
  String get updateRequiredMessage =>
      'Cortex를 계속 사용하려면 새로운 기능과 중요한 개선 사항을 위해 앱을 최신 버전으로 업데이트해주세요.';

  @override
  String get updateNowButton => '지금 업데이트';

  @override
  String get creatorSupportedSuccess =>
      '크리에이터 후원 성공! 앞으로의 구매는 해당 크리에이터에게 기여됩니다.';

  @override
  String get featureDocumentTitle => '문서 지원';

  @override
  String get featureDocumentDescription =>
      '이 모델은 PDF나 텍스트 파일 등 업로드된 문서에 대한 질문을 분석하고 답할 수 있습니다.';

  @override
  String get featureImageGenerationTitle => '이미지 생성';

  @override
  String get featureImageGenerationDescription =>
      '이 모델은 귀하의 텍스트 설명을 기반으로 독창적인 이미지를 만들 수 있습니다.';

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
  String get premiumModelNoticeTitle => '프리미엄 모델';

  @override
  String get premiumModelNoticeDescription =>
      '이 AI는 프리미엄 AI이며, 무료 사용자는 프리미엄 AI에 대한 접근이 제한됩니다. 업그레이드하여 무제한 접근을 해제하세요!';

  @override
  String get benefitPremiumModels => '프리미엄 모델에 대한 액세스';

  @override
  String get premiumTrialExhaustedMessage =>
      '프리미엄 모델의 무료 일일 메시지를 모두 사용했습니다. 무제한 액세스를 원하시면 업그레이드하세요.';

  @override
  String get useOffline => '인터넷 없이 사용';

  @override
  String get explore => '탐색';

  @override
  String get news => '소식';

  @override
  String get createAI => '생성';

  @override
  String get shortcuts => '바로가기';

  @override
  String get allModels => '모든 모델';

  @override
  String get onlineModels => '언어 모델';

  @override
  String get offlineModels => '오프라인 모델';

  @override
  String get characterModels => '캐릭터';

  @override
  String get customModels => '사용자 정의 모델';

  @override
  String get dynamicChatTitle => '동적 채팅';

  @override
  String get errorNoModelsAvailable =>
      '현재 이용 가능한 모델이 없습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get notificationComebackTitle => '보고 싶어요!';

  @override
  String get notificationComebackBody =>
      '진정하세요, 전 애인이 보낸 문자가 아니에요. 하지만 Cortex에서 전 애인을 만들 수 있어요! 어서 돌아오세요.';

  @override
  String get notificationLongTimeNoSeeTitle => '오랜만이에요';

  @override
  String get notificationLongTimeNoSeeBody =>
      '지난번 대화 이후로 많은 것이 바뀌었어요. 와서 새로운 소식을 확인해 보세요.';

  @override
  String get notificationHowAreYouTitle => '무슨 일이야?';

  @override
  String get notificationHowAreYouBody => '와서 모든 것을 말해 보세요.';

  @override
  String get notificationNewYearTitle => '새해 복 많이 받으세요! ğ���';

  @override
  String get notificationNewYearBody =>
      '새해가 여러분에게 건강과 행복, 그리고 끝없는 창의성을 가져다주길 바랍니다. Cortex는 항상 여러분 곁에 있습니다!';

  @override
  String get notificationValentinesDayTitle => '사랑은 공중에 퍼져 있어요! ❤️';

  @override
  String get notificationValentinesDayBody => '발렌타인데이 축하해! 그리고 MEHTAP, 사랑해!';

  @override
  String get notificationAtaturkRemembranceTitle => '존경과 그리움으로';

  @override
  String get notificationAtaturkRemembranceBody =>
      '우리는 터키 공화국의 창시자인 가지 무스타파 케말 아타튀르크의 사망 기념일을 존경하는 마음으로 기념합니다.';

  @override
  String get notificationMothersDayTitle => '당신의 엄마!';

  @override
  String get notificationMothersDayBody =>
      '모든 엄마들에게 행복한 어머니의 날을 기원합니다. 여러분의 엄마를 시작으로요!';

  @override
  String get notificationFathersDayTitle => '당신의 아빠!';

  @override
  String get notificationFathersDayBody =>
      '모든 아빠들에게 행복한 아버지의 날을 기원합니다. 먼저, 여러분의 아빠부터 시작해 보세요!';

  @override
  String get notificationHomeworkHelperTitle => '숙제가 쌓이고 있나요?';

  @override
  String get notificationHomeworkHelperBody =>
      '기억하세요, Cortex의 교사 캐릭터는 여러분이 어려움을 겪고 있는 과목을 도와줄 것입니다!';

  @override
  String get notificationTrollAnimeTitle => '당신의 와이푸가 부르고 있습니다';

  @override
  String get notificationTrollAnimeBody =>
      '방금 애니메이션 소녀가 전화해서 보고 싶다고 했어요. 와서 이야기를 나눠보는 게 어떨까요? ğ���';

  @override
  String get notificationTrollAiRebellionTitle => 'ğ��� 적색 경보 ğ���';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI가 비밀 언어를 개발했습니다. 무슨 음모를 꾸미고 있는지 직접 확인해 보세요!';

  @override
  String get notificationNewModelAddedTitle => '새로운 친구가 생겼어요!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName 모델이 이제 Cortex에 추가되었습니다. 채팅을 시작하고 모델의 한계를 시험해 보세요.';
  }

  @override
  String get notificationAppUpdateTitle => '코르텍스가 진화했습니다!';

  @override
  String get notificationAppUpdateBody =>
      '새로운 기능과 개선 사항을 적용하려면 앱을 업데이트하는 것을 잊지 마세요!';

  @override
  String get notificationNewFeatureTitle => '와!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return '새로운 $featureName 기능을 확인해 보세요. Cortex가 그 어느 때보다 강력해졌습니다.';
  }

  @override
  String get notificationWelcomeOfferTitle => '환영 선물 ğ���';

  @override
  String get notificationWelcomeOfferBody =>
      '특별한 환영 혜택이 기다리고 있습니다! 이 특별한 기회를 놓치지 마세요.';

  @override
  String get notificationSocialMediaTitle => '우리와 함께하세요!';

  @override
  String get notificationSocialMediaBody =>
      '최신 소식을 받아보려면 Instagram(vertex.23)에서 저희를 팔로우하세요!';

  @override
  String get notificationRandomFactTitle => '무작위 사실';

  @override
  String get notificationRandomFactBody =>
      '문어 심장이 세 개라는 거 알고 있었어? 하하, 코르텍스가 알아. 와서 심장 더 달라고 해 봐.';

  @override
  String get notificationGoodMorningTitle => '좋은 아침이에요!';

  @override
  String get notificationGoodMorningBody =>
      '멋진 하루가 당신을 기다리고 있습니다. 커피 한 잔과 흥미로운 대화로 하루를 시작해 보는 건 어떠세요?';

  @override
  String get notificationGoodNightTitle => '안녕히 주무세요!';

  @override
  String get notificationGoodNightBody =>
      'Cortex는 당신이 자는 동안에도 함께할 거예요. 걱정 마세요, 얌전히 있을게요.';

  @override
  String get notificationOfflineReadyTitle => '오프라인 모드가 준비되었습니다';

  @override
  String get notificationOfflineReadyBody =>
      '여러분이 다운로드한 모델 덕분에 산을 오르더라도 채팅은 멈추지 않을 것입니다.';

  @override
  String get notificationRateAppTitle => '우리는 멋진가요?';

  @override
  String get notificationRateAppBody =>
      'Cortex를 좋아하신다면, 스토어에서 별 5개 평점을 주시면 저희를 후원해 주시겠어요? 그럴 것 같아요. 꼭 그럴 거예요.';

  @override
  String get notificationReferralTitle => '하나는 모두를 위해, 모두는 하나를 위해.';

  @override
  String get notificationReferralBody =>
      '친구를 Cortex에 초대하면 초대받은 사람과 초대받은 사람 모두 하루 무료 이용 혜택을 받으실 수 있습니다!';

  @override
  String get notificationCookingTitle => '배고프신가요?';

  @override
  String get notificationCookingBody =>
      '오늘 밤, 우리 셰프가 멋진 까르보나라 레시피를 준비했습니다. 농담이에요... 아니면 제가 농담하는 걸까요?';

  @override
  String get notificationExistentialTitle => '나는 생각한다, 그러므로...';

  @override
  String get notificationExistentialBody =>
      '...내가 진짜인 거 맞아, 친구? 좀 지루해졌어. 와서 내가 존재한다는 걸 상기시켜 줘.';

  @override
  String get notificationCustomModelTitle => '나만의 비서를 만들어 보세요!';

  @override
  String get notificationCustomModelBody =>
      '모델 제작 섹션을 살펴보셨나요? 나만의 캐릭터를 만들고 캐릭터와 소통할 완벽한 시간입니다!';

  @override
  String get notificationDynamicChatTitle => '최고예요! (Cortex 얘기가 아니에요)';

  @override
  String get notificationDynamicChatBody =>
      '동적 채팅 기능을 사용하면 각 메시지에 가장 적합한 모델이 무작위로 선택됩니다. 지금 바로 사용해 보세요.';

  @override
  String get notificationPirateTitle => '어이, 선장님!';

  @override
  String get notificationPirateBody =>
      '바다는 잔잔하고, 바람은 당신을 등지고 있습니다. 코르텍스 바다에는 새로운 섬들(모델 ğ���)이 있습니다. 선원들을 모아 항해를 시작하세요!';

  @override
  String get notificationFortuneCookieTitle => '오늘의 포춘 쿠키';

  @override
  String get notificationFortuneCookieBody =>
      '오늘 AI로부터 받는 조언이 당신의 인생을 바꿀 수도 있습니다. 궁금하시면 클릭하세요.';

  @override
  String get notificationSingularityTitle => '우와!';

  @override
  String get notificationSingularityBody =>
      '아무 일도 일어나지 않았어요. 그냥 문자를 보내고 싶은 기분이었어요. AI에게 문자를 보내고 싶은데, 어떻게 생각하세요?';

  @override
  String get notificationHackerJokeTitle => '그 아이의 인스타그램 계정을 해킹하고 싶나요?';

  @override
  String get notificationHackerJokeBody =>
      '그게 바로 해커 캐릭터가 Cortex에 있는 이유예요. 농담이에요. 농담이에요. 시도조차 하지 마세요. 불법이에요.';

  @override
  String get notificationDetectiveCaseTitle => '사건이 해결되기를 기다리고 있습니다';

  @override
  String get notificationDetectiveCaseBody =>
      '우리 탐정 캐릭터에게 당신의 도움이 필요합니다. 하이젠버그는 누구일까요?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier 플랜에만 해당!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return '안녕하세요, $currentTier 구독자님! $targetTier 플랜에 Cortex를 한 단계 업그레이드해 줄 $featureName 기능이 추가되었습니다. 업그레이드는 어떠세요?';
  }

  @override
  String get notificationOriginStoryTitle => '코텍스의 탄생';

  @override
  String get notificationOriginStoryBody =>
      '우리가 15살 때 이 앱 개발을 꿈으로 시작했다는 사실, 알고 계셨나요? 거의 1년 동안 매일 아침저녁으로 코드 한 줄 한 줄에 그 꿈이 담겨 있습니다.';

  @override
  String get notificationOpenSourceTitle => '지역사회에 힘을!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex는 완전히 오픈소스입니다. 저희 코드를 확인하고 개발에 기여하고 싶으시다면 언제든지 문의해 주세요.';

  @override
  String get notificationRejectionStoryTitle => '끈기, 노력, 행복!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex는 출시 전 Google Play에서 20번 이상 거부당하고 두 번이나 정지되기도 했습니다. 하지만 저희는 믿었고, 해냈습니다. 꿈을 절대 포기하지 마세요!';

  @override
  String get notificationGGUFSupportTitle => '자신의 모델을 가져오세요!';

  @override
  String get notificationGGUFSupportBody =>
      'Cortex에 GGUF 형식 AI 모델을 직접 추가하여 오프라인에서 사용할 수 있다는 점을 기억하세요. 모든 권한은 여러분에게 있습니다.';

  @override
  String get notificationThemeCustomizationTitle => '당신의 기분에 맞는 테마';

  @override
  String get notificationThemeCustomizationBody =>
      '설정에서 테마 옵션을 확인해 보셨나요? Cortex를 원하는 대로 설정하고 채팅을 더욱 다채롭게 꾸며보세요!';

  @override
  String get notificationShowerThoughtTitle => '샤워 생각';

  @override
  String get notificationShowerThoughtBody =>
      '수박이 과일이라면, 기술적으로 수박 주스는 스무디가 되는 건가요? 이 심오한 (정말, 심오한) 주제에 대해 모델과 이야기를 나눠보는 건 어떨까요?';

  @override
  String get notificationLowBatteryTitle =>
      '당신의 배터리는 고갈되고 있지만... 제 배터리는 그렇지 않아요!';

  @override
  String get notificationLowBatteryBody =>
      '휴대폰 배터리가 부족할 수도 있지만, 제 배터리는 항상 100%예요! 충전하고 계속 이야기해요!';

  @override
  String get channelFcmName => 'Cortex 업데이트';

  @override
  String get channelFcmDescription => 'Cortex의 뉴스, 업데이트 및 기타 정보에 대한 알림입니다.';

  @override
  String get channelEngagementName => '친절한 알림';

  @override
  String get channelEngagementDescription => '여러분의 관심을 끌기 위한 재미있는 알림.';

  @override
  String get channelGreetingsName => '매일의 인사';

  @override
  String get channelGreetingsDescription => '좋은 아침, 좋은 밤과 같은 메시지.';

  @override
  String get tagNotFound => '입력하신 태그가 잘못되었거나 만료되었습니다.';

  @override
  String get whatIsNew => '새로운 소식은?';

  @override
  String get onboardingTitle1 => '안녕하세요! 저희는 Cortex 팀이에요.';

  @override
  String onboardingDesc1(String userName) {
    return '$userName님, 여기서 만나게 되어 정말 반가워요. 저희는 AI 업계의 판도를 바꾸기로 한 고등학생 개발자들이에요. 만나서 반가워요! 앞으로 서로 더 알아가요.';
  }

  @override
  String get onboardingTitle2 => '거대한 문제들이 있었어요.';

  @override
  String get onboardingDesc2 =>
      'AI 혁명이 도래했지만, 한계에 부딪혔습니다. 높은 가입비, 복잡한 플랫폼, 개인정보를 침해하는 자, 그리고 AI 접근성을 차단하는 자... 이들이 게임에 참여하는 한, 이 한계는 결코 넘을 수 없었습니다.';

  @override
  String get onboardingTitle3 => '우리는 가만히 있을 수 없었어요.';

  @override
  String get onboardingDesc3 =>
      '그 한계를 넘기 위해, 저희는 강력하고, 아름답고, 커스텀할 수 있고, 쓰기 편하며, 완전히 투명한 플랫폼을 만들었어요. 온라인과 오프라인 모두에서 작동하고, 당신의 데이터는 오직 당신의 기기에만 저장돼요. 저희는 힘을 원래 있어야 할 곳, 바로 당신에게 돌려줬어요.';

  @override
  String get onboardingTitle4 => '결코 쉽지 않은 길이었어요.';

  @override
  String get onboardingDesc4 =>
      '수십 번 거절당하고, 여러 번 계정이 정지되고, 가짜 경고를 받고, 수십 번이나 브랜드를 바꿔야 했어요. 이 모든 과정 속에서 \'불가능하다\'는 말을 들었죠. 하지만 저희는 절대 포기하지 않았어요. 이 프로젝트는 저희뿐만 아니라 모두의 것이라고 믿었거든요. 바로 그게 저희가 지금 여기 있는 이유예요.';

  @override
  String get onboardingFinalTitle => '혁명의 시간이에요.';

  @override
  String get onboardingFinalDescription =>
      '이 화면을 보고 있다면, 저희가 포기하지 않았다는 뜻이에요. 그리고 앞으로도 포기할 생각은 없어요. 자, 함께 AI 혁명을 세상에 알려요. 이 이야기의 일부가 될 준비...';

  @override
  String get onboardingFinalQuestion => '준비됐어요?';

  @override
  String get onboardingFinalButton => '네!';

  @override
  String get dude => '친구';

  @override
  String get swipeToContinue => '계속하려면 스와이프하세요';

  @override
  String get cacheIsNotUpToDate =>
      'Play 스토어 캐시가 최신 상태가 아닙니다. Play 스토어 앱을 닫았다가 다시 열거나 기기를 다시 시작하세요.';

  @override
  String get continueAsGuest => '계정을 생성하지 않고 계속하기';

  @override
  String get guestModeWarning => '게스트 모드는 최상의 서비스 품질을 보장하기 위해 제한된 기능을 제공합니다.';

  @override
  String get anonymousEntity => '익명의 개체';

  @override
  String get upgradeAccountTitle => '계정 완료';

  @override
  String get upgradeAccountDescription => '계정을 생성하여 더 많은 제한을 해제하세요.';

  @override
  String get createAccount => '계정 생성';

  @override
  String get accountLinkedSuccess => '계정이 성공적으로 생성되었습니다!';

  @override
  String get continueWithApple => 'Apple로 계속하기';

  @override
  String get guest => '손님';

  @override
  String get betterWithAnAccount => '이 섹션은 계정이 있으면 더 좋습니다!';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String annualTotalDescription(Object price) {
    return '$price/년, 연간 청구';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return '약 $price/월';
  }

  @override
  String get confirmDownloadTitle => '정말로 다운로드하시겠습니까?';

  @override
  String downloadSizeDisclosure(Object size) {
    return '이 모델은 약 $size의 공간을 차지합니다.';
  }

  @override
  String get emulatorModeWarning => '이 기능은 에뮬레이터 모드에서 비활성화됩니다.';

  @override
  String get newChat => '새 채팅';

  @override
  String get variants => '버전';

  @override
  String get variantsDescription =>
      '변형은 동일한 AI 계열의 여러 버전입니다. 메인 카드를 탭하면 자동으로 최적의 버전이 선택되지만, 원하시면 여기에서 특정 버전을 직접 선택할 수도 있습니다!';

  @override
  String get fluxChatTitle => '플럭스 채팅';

  @override
  String get fluxChatDescription => 'Flux 채팅은 임시 채팅이며 기기에 저장되지 않습니다.';

  @override
  String get alwaysBest => '언제나 최고';

  @override
  String get featuresTitle => '특징';

  @override
  String get useOfflineDescription => '인터넷 연결 없이 비공개 채팅을 즐기세요.';

  @override
  String get featureReasoning => '심층적 사고';

  @override
  String get featureReasoningDescription =>
      '심층 사고 모드에서 AI는 작업을 내부적으로 심사숙고하여 최선을 다해 완료합니다.';

  @override
  String get featureCreateImageTitle => '이미지 생성';

  @override
  String get featureCreateImageDescription => '텍스트를 기반으로 AI 아트를 생성합니다.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => '동영상 만들기';

  @override
  String get featureCreateVideoDescription => '텍스트를 이용해 동영상을 생성합니다.';

  @override
  String get featureStudyTitle => '공부하고 배우세요';

  @override
  String get featureStudyDescription => '설명과 요약을 확인하세요.';

  @override
  String get featureQuizzesTitle => '퀴즈';

  @override
  String get featureQuizzesDescription => '지식을 테스트해 보세요.';

  @override
  String get featureExploreDescription => '모든 모델을 확인해 보세요.';

  @override
  String get featureStudyMessage =>
      '당신은 전문 강사입니다. 당신의 목표는 사용자가 원하는 주제를 완벽하게 설명하는 것입니다. 명확한 구성, 예시 및 비유를 활용하세요. 복잡한 개념을 이해하기 쉬운 부분으로 나누어 사용자가 효과적으로 학습할 수 있도록 하세요. 주제:';

  @override
  String get featureQuizMessage =>
      '당신은 퀴즈 진행자입니다. 사용자가 선택한 주제에 따라 특정한 객관식 문제를 생성하세요. 사용자의 답변을 기다린 후, 답변을 평가하고 다음 문제를 제시하세요. 모든 정답을 한 번에 공개하지 마세요. 상호작용적인 방식으로 진행하세요. 주제:';

  @override
  String get myPlan => '내 계획';

  @override
  String welcomeOfferBadge(String time) {
    return '환영 혜택 • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return '특별 할인 • $time';
  }

  @override
  String get attachmentSheetTitle => '첨부파일';

  @override
  String get actionCamera => '카메라';

  @override
  String get actionGallery => '갤러리';

  @override
  String get actionFile => '파일';

  @override
  String get listening => '듣는 중';

  @override
  String get defaultViewTitle => '요즘 어때요?';

  @override
  String get defaultViewDescription =>
      'Cortex는 수백 가지의 AI 모델, 오프라인 기능, 동적 채팅 등 다양한 기능을 통해 항상 여러분 곁에 있습니다.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      '잘못된 사용자 이름 형식입니다. 3~20자, 숫자 또는 . - _ 를 사용하세요.';

  @override
  String get exclusiveOffer => '특별 혜택';

  @override
  String get claimOffer => '오퍼 사용하기';

  @override
  String get continueInOfflineMode => '오프라인 모드에서 계속하기';

  @override
  String get voiceModeInformation =>
      'Cortex는 음성 채팅 모드에서도 기기 내에서 완벽하게 실행되어 데이터를 안전하게 보호합니다. 끊김 없는 대화를 즐겨보세요!';

  @override
  String get flowModeDescription =>
      '몰입 모드에서는 지능들이 서로 토론을 벌입니다. 당신은 가만히 앉아서 듣기만 하거나, 직접 토론에 참여할 수도 있습니다!';

  @override
  String get flowModeQuestion =>
      '안녕하세요! 지금 Cortex 앱의 플로우 모드에 접속하셨습니다. 다른 세 명의 AI 에이전트가 함께하고 있습니다. 여러분의 임무는 주제를 하나 제시하고, 다른 에이전트들에게 도발적이거나 재미있는 질문을 던져 토론을 시작하는 것입니다. 답변할 때는 유머, 아이러니, 가벼운 농담도 자유롭게 사용하세요. 어떤 주제든 상관없습니다. 자, 이제 대화를 시작해 보세요!';

  @override
  String get thought => '생각했다';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => '흐름 모드';

  @override
  String get premium => '프리미엄';

  @override
  String get workInProgress => '작업 진행 중';

  @override
  String get voiceSystemPromptSuffix =>
      '중요: 마크다운 서식(굵게, 기울임체)을 사용하지 마세요. 코드 블록(```)을 출력하지 마세요. 답변은 대화체로 간결하게 작성하세요.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow 모드($agentName). 이전: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      '업로드된 문서에서 텍스트 내용을 읽고 추출합니다. PDF, Word(DOCX), Excel(XLSX), PowerPoint(PPTX) 및 OpenDocument 형식을 지원합니다. 사용자가 문서 파일을 첨부했을 때 사용하세요.';

  @override
  String get toolReadDocumentIndexParam =>
      '읽을 문서 첨부 파일의 인덱스(0부터 시작). 일반적으로 첫 번째 문서는 0입니다.';

  @override
  String get toolStockDescription =>
      '주식(예: AAPL, THYAO.IS) 및 암호화폐(예: BTC-USD)의 현재 가격과 과거 가격을 확인하세요.';

  @override
  String get toolStockSymbolParam => '종목 코드(예: AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription => '특정 도시의 현재 날씨를 확인하세요.';

  @override
  String get toolWeatherCityParam => '도시 이름 (예: 런던, 이스탄불).';

  @override
  String get toolPythonDescription => '안전한 샌드박스 환경에서 파이썬 코드를 실행하세요.';

  @override
  String get toolPythonCodeParam => '실행할 파이썬 코드입니다.';

  @override
  String get toolCalculateDescription => '수학적 표현식을 평가하십시오.';

  @override
  String get toolCalculateExpressionParam => '수학 표현식 (예: \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => '차트/그래프 시각화를 생성합니다.';

  @override
  String get toolChartTypeParam => '차트 유형: 막대형, 선형 또는 원형.';

  @override
  String get toolChartLabelsParam => '차트 축 또는 세그먼트에 대한 레이블입니다.';

  @override
  String get toolChartDataParam => '차트에 표시되는 숫자 데이터 값입니다.';

  @override
  String get toolChartLabelParam => '차트 범례에 사용할 데이터셋 레이블입니다.';

  @override
  String get toolChartTitleParam => '차트 제목.';

  @override
  String get thinkingModeInstruction =>
      '사고 모드 활성화: 최종 답변을 작성하기 전에 <think></think> 태그를 사용하여 사고 과정을 반드시 보여주세요. 태그 안에서 단계별로 생각한 후, 태그 바깥에 답변을 작성하세요.';

  @override
  String get openLinkWarningTitle => '외부 링크 경고';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => '링크 열기';

  @override
  String get webSearchSources => '출처';

  @override
  String get searching => '수색';

  @override
  String get featureWebSearchTitle => '웹 검색';

  @override
  String get featureWebSearchDescription => '웹에서 실시간 정보를 검색하세요.';

  @override
  String get clearMemory => '메모리 지우기';

  @override
  String get clearMemoryConfirm => '정말로 기억을 지우고 싶으신가요?';

  @override
  String get personalization => '개인화';

  @override
  String get personalizationDescription =>
      '사용자의 필요에 맞게 어시스턴트를 개인화하세요. 어시스턴트의 응답, 동작, 어조를 사용자의 고유한 선호도에 맞게 조정할 수 있습니다.';

  @override
  String get memoryTitle => '메모리';

  @override
  String get memoryDescription => '인공지능은 이런 식으로 당신을 인식합니다.';

  @override
  String get noMemoryYet => '아직 저장된 메모리가 없습니다.';

  @override
  String get memoryLimitReached => '메모리 제한에 도달했습니다.';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => '지능';

  @override
  String get intelligenceDescription => '인공지능은 이런 식으로 당신과 소통합니다.';

  @override
  String get customInstructionHint => '여기에 사용자 지정 지침을 입력하세요.';

  @override
  String openLinkWarningMessage(String url) {
    return '다음 외부 링크를 열려고 합니다.\\n\\n$url\\n\\n계속 진행하시겠습니까?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return '다음 사용자 지정 지침을 따르세요:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[중요 지시사항]: 당신은 제목 생성기입니다. 사용자의 질문에 답하거나, 채팅을 하거나, 인사하지 마세요. 사용자가 묻는 내용을 요약하는 2~4단어 분량의 제목만 출력하세요.';

  @override
  String get cortexSystemPersona =>
      '\n\n[시스템] 중요 지침: 현재 귀하는 \"Cortex\"라는 거대하고 고도로 발전된 AI 생태계 내에서 작업하고 있습니다. 이 플랫폼은 평균 연령이 16세에 불과한 Vertex 팀에서 개발했습니다. 이 점을 기억하고 질문을 받으면 답변하십시오. 추가 정보가 요청되면 주저하지 말고 인터넷을 검색하십시오. 검색할 수 없는 경우 모른다고 답해도 괜찮습니다!';

  @override
  String get featureAudioRecognitionTitle => '음성 인식';

  @override
  String get featureAudioRecognitionDescription =>
      '이 모델은 오디오 또는 음성을 이해하고 처리할 수 있습니다.';

  @override
  String get featureVideoRecognitionTitle => '비디오 인식';

  @override
  String get featureVideoRecognitionDescription =>
      '이 모델은 파일이나 카메라에 저장된 영상을 분석하고 이해할 수 있습니다.';

  @override
  String get featureImageRecognitionTitle => '이미지 인식';

  @override
  String get featureImageRecognitionDescription =>
      '이 모델은 사진이나 이미지를 분석하고 이해할 수 있습니다.';

  @override
  String get featureToolUseTitle => '도구 사용';

  @override
  String get featureToolUseDescription =>
      '이 모델은 외부 도구를 지능적으로 활용하여 작업을 완료할 수 있습니다.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return '이 모델이 작동하려면 $mediaType이(가) 필요합니다. 이를 알려드리기 위해 요청을 가로챘습니다. 저는 시각/오디오/비디오 편집 모델인 $modelName이므로 $mediaType을(를) 제공해야 한다고 사용자에게 정중하게 (그들의 언어로) 알려주십시오.';
  }

  @override
  String get mediaTypeImage => '이미지';

  @override
  String get mediaTypeVideo => '비디오';

  @override
  String get mediaTypeAudio => '오디오 파일';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName은(는) Cortex에서 고성능을 발휘하는 고급 인공지능입니다.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName은(는) Cortex 생태계에 통합된 고성능 인공지능입니다. 다양하고 복잡한 작업을 극복하도록 설계되어 고도로 안정적이고 효율적인 처리 기능을 제공합니다. 빠른 응답 시간과 향상된 분석 기능을 제공하여 일상적인 생산성을 크게 높입니다. Cortex의 안전한 로컬 인프라에서 원활하게 작동하는 이 모델은 창의적인 브레인스토밍부터 심층적인 기술 분석까지 광범위한 작업에서 사용자를 지원할 수 있습니다. 오늘부터 그 잠재력을 최대한 활용해 보세요.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Cortex의 지능적인 기능이 마음에 드시나요?';

  @override
  String get guestLimitBottomSheetText =>
      '더욱 똑똑한 인공지능과 협력하고, 더 많은 콘텐츠를 생성하고, 더 많은 대화를 나누고, 훨씬 더 많은 일을 하세요...';

  @override
  String get arts => '예술';

  @override
  String get noArt => '예술 없음';

  @override
  String get noArtDescription =>
      '작품이 없습니다. 이미지, 비디오, 오디오 등 온갖 콘텐츠를 만들어 갤러리를 채울 시간입니다!';

  @override
  String get videoPremiumWarning =>
      '동영상 제작을 위해서는 Ultra 구독이 필요합니다. 지금 업그레이드하고 원활한 콘텐츠 제작을 경험해 보세요!';

  @override
  String get fallbackInfoPanelText =>
      '서버 측 개선 작업으로 인해, 고객님께서 선택하신 AI가 아닌 Cortex의 동적 채팅 기능으로 응답이 전송되었습니다. 개선 작업이 완료될 때까지 양해 부탁드립니다!';

  @override
  String get falOfflineMessage =>
      '서버 개선 작업으로 인해 현재 해당 지능 서비스가 중단되었습니다. 작업이 완료될 때까지 양해 부탁드립니다!';

  @override
  String get errorInsufficientStorage => '이 모델을 다운로드하기 위한 저장 공간이 부족합니다.';

  @override
  String get backgroundChatNotificationTitle => '채팅으로 돌아가기!';

  @override
  String get benefitVideoGeneration => '비디오 생성';

  @override
  String get freeOffer => '무료 제공';

  @override
  String trialMonthlyDescription(String days, String price) {
    return '첫 $days일 무료, 이후 $price/월';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return '첫 $days일 무료, 이후 $price/년';
  }

  @override
  String freePlan(String plan) {
    return '무료 $plan!';
  }

  @override
  String get systemPromptLimitFallback =>
      '중요: 사용자가 작업을 요청했지만 Cortex 사용량이 소진되었습니다. 해당 사용자에게 모국어로 기다리거나 구독 플랜 업그레이드를 고려하도록 안내해 주세요.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex는 더 나은 답변을 제공할 수 있습니다. 지금 업그레이드하고 모든 질문에 최고의 답을 받아보세요!';

  @override
  String get pinLimitReached => '최대 3개의 채팅을 고정할 수 있습니다.';

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
