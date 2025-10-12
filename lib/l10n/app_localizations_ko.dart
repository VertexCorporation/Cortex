// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get understood => '알겠습니다.';

  @override
  String get cancel => '취소';

  @override
  String get remove => '제거';

  @override
  String get download => '다운로드';

  @override
  String get resume => '재개';

  @override
  String get copy => '복사';

  @override
  String get chat => '채팅';

  @override
  String get darkMode => '다크 모드';

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
  String get comingSoon => '출시 예정';

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
  String get modelLoading => '모델 로딩 중...';

  @override
  String get messageCopied => '메시지가 클립보드에 복사되었습니다.';

  @override
  String get storeUnavailable => '스토어를 현재 이용할 수 없습니다. 나중에 다시 시도해주세요.';

  @override
  String get retry => '재시도';

  @override
  String get systemInfo => '시스템 정보';

  @override
  String deviceMemory(Object memory) {
    return '기기 메모리: ${memory}GB';
  }

  @override
  String storageSpace(Object storage) {
    return '저장 공간: ${storage}GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return '사용 가능한 저장 공간: ${freeStorage}GB';
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
  String get requirements => '요구 사항';

  @override
  String get modelsTitle => '라이브러리';

  @override
  String get localModels => '로컬 모델';

  @override
  String get serverSideModels => '온라인 모델';

  @override
  String get uploadYourOwnModel => '나만의 모델 업로드하기!';

  @override
  String get selectGGUFFile => 'GGUF 파일 선택';

  @override
  String get errorGGUF => 'GGUF 형식의 파일만 선택해주세요.';

  @override
  String get modelAlreadyExists => '모델이 이미 존재합니다.';

  @override
  String get modelAddedSuccessfully => '모델이 성공적으로 추가되었습니다.';

  @override
  String get modelRemoved => '모델이 성공적으로 제거되었습니다.';

  @override
  String get removeError => '모델을 제거하는 동안 오류가 발생했습니다.';

  @override
  String get fileNotFound => '파일을 찾을 수 없습니다.';

  @override
  String get fileUploadError => '파일을 업로드하는 동안 오류가 발생했습니다.';

  @override
  String get noFileSelected => '선택된 파일이 없습니다.';

  @override
  String get myModels => '내 모델';

  @override
  String get create => '생성';

  @override
  String get seeAll => '모두 보기';

  @override
  String modelProducer(Object producer) {
    return '제작사: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return '크기: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => '대화';

  @override
  String get conversationDeleted => '대화가 삭제되었습니다.';

  @override
  String get conversationUpdated => '대화가 업데이트되었습니다.';

  @override
  String get editConversationTitle => '이름 변경';

  @override
  String get newTitle => '새 제목';

  @override
  String get save => '저장';

  @override
  String get titleCannotBeEmpty => '제목은 비워둘 수 없습니다.';

  @override
  String get noConversationsMessage => '대화가 없습니다, 채팅을 시작해보세요!';

  @override
  String get startChat => '채팅 시작하기';

  @override
  String get noChats => '채팅 없음';

  @override
  String get starredChats => '별표 표시된 채팅';

  @override
  String get allChats => '모든 채팅';

  @override
  String get noStarredChats => '별표 표시된 채팅 없음';

  @override
  String get noStarredChatsMessage => '아직 별표 표시한 채팅이 없습니다.';

  @override
  String get goToChats => '채팅에 별표 표시하기';

  @override
  String get starConversation => '별표 표시';

  @override
  String get conversationTitleUpdated => '대화 제목이 업데이트되었습니다.';

  @override
  String get youReachedConversationLimit => '대화 한도에 도달했습니다.';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

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
  String get userNotFound => '사용자를 찾을 수 없습니다.';

  @override
  String get wrongPassword => '잘못된 비밀번호입니다.';

  @override
  String get emailAlreadyInUse => '이미 사용 중인 이메일입니다.';

  @override
  String get weakPassword => '비밀번호가 너무 약합니다.';

  @override
  String get authError => '인증 오류';

  @override
  String get invalidUsername => '사용자 이름을 입력해주세요.';

  @override
  String get usernameTaken => '이미 사용 중인 사용자 이름입니다.';

  @override
  String get username => '사용자 이름';

  @override
  String get authenticationFailed => '인증에 실패했습니다. 다시 시도해주세요.';

  @override
  String get emailTooLong => '이메일은 최대 30자까지 가능합니다.';

  @override
  String get deviceLimitReached => '이 기기에서 계정 생성 한도에 도달했습니다.';

  @override
  String get verificationEmailLimitReached => '더 이상 인증 이메일을 보내지 않습니다.';

  @override
  String get verificationEmailSent => '인증 이메일이 발송되었습니다!';

  @override
  String get emailNotVerified => '이메일이 인증되지 않았습니다.';

  @override
  String get resendCode => '인증 이메일 재전송';

  @override
  String get remainingSeconds => '인증까지 남은 시간';

  @override
  String get pleaseCheckYourEmail =>
      'Cortex를 사용하려면 이메일을 인증해야 합니다. \n 인증 링크가 이메일 주소로 전송되었으니 확인해주세요.';

  @override
  String get verifyYourEmail => '이메일 인증하기';

  @override
  String get backToLogin => '뒤로 가기';

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
  String get accountVerified => '계정이 인증되었습니다.';

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
  String get enterPasswordToDelete => '삭제하려면 비밀번호를 입력하세요.';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountError => '계정을 삭제하는 동안 오류가 발생했습니다.';

  @override
  String get delete => '삭제';

  @override
  String get passwordRequired => '비밀번호가 필요합니다.';

  @override
  String get deleteDescription =>
      '삭제한 데이터는 저희 서버와 기기에서 영구적으로 제거됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get deleteAccountButton => '계정 삭제 버튼';

  @override
  String get editProfile => '프로필 수정';

  @override
  String get displayName => '표시 이름';

  @override
  String get tapToChangeProfilePicture => '프로필 사진을 변경하려면 탭하세요';

  @override
  String get profileUpdated => '프로필이 성공적으로 업데이트되었습니다.';

  @override
  String get updateFailed => '프로필 업데이트에 실패했습니다.';

  @override
  String get nameCannotBeEmpty => '이름은 비워둘 수 없습니다.';

  @override
  String get logout => '로그아웃';

  @override
  String get noDisplayName => '설정된 표시 이름 없음';

  @override
  String get noEmail => '이메일 주소 없음';

  @override
  String get noUserLoggedIn => '현재 로그인된 사용자가 없습니다.';

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
  String get downloadError => '다운로드 중 오류가 발생했습니다.';

  @override
  String get downloadCancelled => '다운로드가 취소되었습니다.';

  @override
  String get downloadResumed => '다운로드가 재개되었습니다.';

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
  String get purchaseSuccessful => '구매 성공!';

  @override
  String get purchaseFailed => '구매 실패';

  @override
  String get creditProductNotFound => '선택한 크레딧 상품을 찾을 수 없습니다.';

  @override
  String get creditsAddedSuccessfully => '크레딧이 계정에 성공적으로 추가되었습니다!';

  @override
  String get creditDeliveryFailed => '계정에 크레딧을 추가하지 못했습니다. 지원팀에 문의해주세요.';

  @override
  String get invalidPurchase => '유효하지 않은 구매';

  @override
  String get purchaseError => '구매 오류';

  @override
  String get purchaseVertexPlusToUpload => '이 기능은 플러스 기능입니다.';

  @override
  String get purchasePlus => 'Cortex 플러스 구매하기';

  @override
  String get plusDescription => 'Cortex의 더 많은 기능에 액세스하고 AI를 훨씬 더 많이 경험해보세요!';

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
  String discountOffer(int percent) {
    return '$percent% 할인';
  }

  @override
  String annualPlanDescription(String price) {
    return '월 $price, 연간 청구';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '월 $price, 월간 청구';
  }

  @override
  String get discountBannerTitle => '출시 기념 특가: 80% 할인!';

  @override
  String get discountBannerSubtitle => '출시를 기념하여 모든 구독 플랜에 대한 독점 할인. 놓치지 마세요!';

  @override
  String get purchasePro => 'Cortex 프로 구매하기';

  @override
  String get proDescription => 'Cortex의 더 많은 기능에 액세스하고 AI를 더욱 경험해보세요!';

  @override
  String get alreadySubscribed => '이미 구독 중입니다.';

  @override
  String get subscriptionInfo => '구독이 활성화되어 있습니다.';

  @override
  String get alreadySubscribedMessage =>
      '이미 플러스 구독을 하고 있습니다. 구독을 취소하려면 Play 스토어 관리자를 통해 할 수 있습니다.';

  @override
  String get cancelSubscription => '구독 취소';

  @override
  String get cancelSubscriptionInfo => '구독을 취소하려면 Play 스토어 구독 관리자를 통해 진행해주세요.';

  @override
  String get goToPlayStore => 'Play 스토어로 이동';

  @override
  String get alreadySubscribedPlus => '플러스 플랜을 사용 중입니다!';

  @override
  String get alreadySubscribedPlusMessage =>
      '플러스 플랜이 활성화되어 있습니다. 모든 혜택을 누릴 수 있습니다.';

  @override
  String get purchaseUltra => 'Cortex 울트라 구매하기';

  @override
  String get ultraDescription =>
      'Cortex의 모든 기능에 대한 전체 액세스 권한을 얻고 AI를 최대한 경험해보세요!';

  @override
  String get noSubscription => '구독 없음';

  @override
  String get noSubscriptionMessage => '아직 구독이 없습니다.';

  @override
  String get alreadyAtHighestPlan => '이미 가장 높은 플랜을 사용 중입니다.';

  @override
  String get unableToOpenSubscription => '구독 관리 페이지를 열 수 없습니다.';

  @override
  String get upgradeSubscription => '구독 업그레이드';

  @override
  String get confirmUpgrade => '구독을 업그레이드하시겠습니까?';

  @override
  String get unsupportedPlatform => '구독 취소를 지원하지 않는 플랫폼입니다.';

  @override
  String get purchaseStreamError => '구매 스트림 오류.';

  @override
  String get productNotFound => '상품을 찾을 수 없음';

  @override
  String get productDetailsError => '상품 세부 정보를 가져오는 동안 오류가 발생했습니다.';

  @override
  String get noProductsFound => '상품을 찾을 수 없음';

  @override
  String get loadCreditsButton => '크레딧 충전';

  @override
  String get creditsTitle => '크레딧';

  @override
  String get creditsScreenDescription =>
      '이 화면은 사용자의 크레딧을 보여줍니다. \n\n사용자의 현재 크레딧: 100\n\n자세한 크레딧 정보가 여기에 표시될 수 있습니다.';

  @override
  String get creditsLoaded => '크레딧이 충전되었습니다!';

  @override
  String get currentCredits => '현재 크레딧';

  @override
  String get pleaseSelectCreditPackage => '크레딧 패키지를 선택해주세요.';

  @override
  String get purchaseCreditsTitle => '크레딧 구매';

  @override
  String get purchaseCreditsDescription =>
      '필요에 맞는 크레딧 패키지를 선택하고 앱을 더 많이 사용하세요.';

  @override
  String get purchaseButton => '구매';

  @override
  String get productNotFoundMessage => '선택한 상품이 존재하지 않습니다.';

  @override
  String get buyCredits => '크레딧 구매';

  @override
  String get selectCreditPackageDescription =>
      '필요에 맞는 크레딧 패키지를 선택하고 더 많은 기능을 즐기세요.';

  @override
  String get buyCredit => '크레딧 구매';

  @override
  String buyCreditPackage(Object amount) {
    return '$amount 크레딧 구매';
  }

  @override
  String get subscribedPlan => '구독 중';

  @override
  String get errorResponseNotReceived => '응답을 받지 못했습니다.';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API 요청이 $attempt번 실패했습니다: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter 응답 상태: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouter 디코딩된 응답 본문: $body';
  }

  @override
  String decodedJson(String data) {
    return '디코딩된 JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      '응답 구조가 예상과 다릅니다: 메시지 또는 콘텐츠가 없습니다.';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      '응답 구조가 예상과 다릅니다: 선택지가 없거나 비어 있습니다.';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API 요청 실패: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API 요청이 $attempt번 실패했습니다: $error';
  }

  @override
  String get internetRequired => '이 모델을 사용하려면 인터넷 연결이 필요합니다.';

  @override
  String get pleaseWaitBeforeTryingAgain => '잠시 후 다시 시도해주세요.';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return '할당량 초과. 상태 코드: $statusCode, 본문: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return '유료 시도 $attempts번 후 API 요청 실패. 오류: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      '이 주문을 함으로써 귀하는 서비스 약관 및 개인정보 처리방침에 동의하게 됩니다. 이 텍스트를 클릭하여 서비스 약관 및 개인정보 처리방침에 대해 자세히 알아볼 수 있습니다. 현재 기간이 종료되기 최소 24시간 전에 자동 갱신을 해제하지 않으면 구독은 자동으로 갱신됩니다.';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

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
  String get ratingsSection => '평가';

  @override
  String get noRatingDataFound => '평가 데이터를 찾을 수 없습니다.';

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
  String get featureSupermodelTitle => '슈퍼 모델';

  @override
  String get featureSupermodelDescription =>
      '이 모델은 100억 개 이상의 파라미터를 가진 거대 모델로, 높은 성능과 광범위한 기능을 제공합니다.';

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
  String get millions => '백만';

  @override
  String get billions => '십억';

  @override
  String get trillions => '조';

  @override
  String get thousand => '천';

  @override
  String get estimated => '추정';

  @override
  String get finalPreparation => '최종 준비가 진행 중입니다.';

  @override
  String get allEvaluationsByTestTeam => '모든 평가는 저희 테스트 팀에 의해 이루어졌습니다.';

  @override
  String get shareApp => '앱 공유하기';

  @override
  String get rateUs => '평가하기';

  @override
  String get share => '공유';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Cortex 앱을 확인해보세요, 정말 놀랍습니다! 여기서 다운로드하세요: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed => '앱 공유에 실패했습니다. 나중에 다시 시도해주세요.';

  @override
  String get selectText => '텍스트 선택';

  @override
  String get showLatex => '특수 기호 표시';

  @override
  String get hideLatex => '특수 기호 숨기기';

  @override
  String get thinking => '생각 중';

  @override
  String get user => '사용자';

  @override
  String get voice => '음성';

  @override
  String get help => '도움말';

  @override
  String get redeemCode => '코드 사용';

  @override
  String get enterYourCode =>
      '좋아하는 크리에이터를 후원하세요! 아래에 고유 코드를 입력하여 Cortex 구매 금액의 일부를 그들에게 전달하세요.';

  @override
  String get code => '코드';

  @override
  String get redeem => '사용하기';

  @override
  String get codeCannotBeEmpty => '코드는 비워둘 수 없습니다.';

  @override
  String get userId => '사용자 ID';

  @override
  String get deleteAllConversationsConfirmTitle => '모든 채팅 삭제?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '정말로 모든 채팅을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

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
  String get arabic => '아랍어';

  @override
  String get french => '프랑스어';

  @override
  String get japanese => '일본어';

  @override
  String get kurdish => '쿠르드어';

  @override
  String get dutch => '네덜란드 사람';

  @override
  String get russian => '러시아인';

  @override
  String get korean => '한국어';

  @override
  String get deutsch => '독일어';

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
  String get ram => 'RAM';

  @override
  String get usernameTooShort => '사용자 이름이 너무 짧습니다.';

  @override
  String get usernameTooLong => '사용자 이름은 16자를 초과할 수 없습니다.';

  @override
  String get invalidUsernameCharacters =>
      '사용자 이름에는 \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' 문자와 \'.\', \'-\', \'_\' 문자만 사용할 수 있습니다.';

  @override
  String get passwordTooLong => '비밀번호는 64자를 초과할 수 없습니다.';

  @override
  String get noInternetConnection => '인터넷에 연결되어 있지 않습니다.';

  @override
  String get chats => '받은 편지함';

  @override
  String get library => '라이브러리';

  @override
  String get inappropriateMessageWarning => '부적절한 메시지가 감지되었습니다!';

  @override
  String get myModelDescription => '내 모델.';

  @override
  String get noModelsDownloaded => '아직 다운로드한 모델이 없습니다.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => '텍스트';

  @override
  String get removeModel => '모델 제거';

  @override
  String get modelUploadedSuccessfully => '모델이 성공적으로 업로드되었습니다.';

  @override
  String get insufficientRAM => '메모리 부족';

  @override
  String get insufficientStorage => '저장 공간 부족';

  @override
  String confirmRemoveModel(Object model) {
    return '정말로 $model 모델을 기기에서 제거하시겠습니까? 이 작업을 수행하면 해당 모델과의 이전 대화도 모두 삭제됩니다.';
  }

  @override
  String get noMatchingModels => '일치하는 모델을 찾을 수 없습니다.';

  @override
  String creditPackage(Object amount) {
    return '$amount 크레딧 구매';
  }

  @override
  String get benefit1 => '온라인 AI를 위한 훨씬 더 많은 대화 한도';

  @override
  String get benefit2 => '자신만의 모델 업로드';

  @override
  String get benefit3 => '프로필 효과';

  @override
  String get benefit4 => '멤버십 배지';

  @override
  String get benefit5 => '더 많은 온라인 인공지능 생성';

  @override
  String get benefit6 => '무제한 채팅';

  @override
  String benefit7(Object credits) {
    return '매일 $credits 크레딧';
  }

  @override
  String get benefit8 => '모델 추가';

  @override
  String get benefit9 => '새로운 테마';

  @override
  String get benefit10 => '오프라인 음성 채팅';

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
  String get downloadingTitle => '다운로드 중';

  @override
  String get downloadCompletedTitle => '다운로드 완료';

  @override
  String get downloadPausedTitle => '다운로드 일시 중지됨';

  @override
  String get downloadErrorTitle => '다운로드 오류';

  @override
  String get cancelButtonText => '취소';

  @override
  String get love => '사랑';

  @override
  String get nature => '자연';

  @override
  String get behindTheSlaughter => '도살의 배후';

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
  String get featureIndulgentTitle => '관대한';

  @override
  String get featureIndulgentDescription =>
      '이 모델은 100,000 토큰을 초과하는 컨텍스트를 원활하게 수용하고 처리할 수 있어, 성능 저하 없이 방대하고 상세한 입력을 처리할 수 있습니다.';

  @override
  String get featurePluralTitle => '복합적인';

  @override
  String get featurePluralDescription =>
      '이 모델은 추가적인 확장을 자동으로 통합하여, 향상된 성능으로 다양한 작업을 지원하도록 기능적 역량을 확장할 수 있습니다.';

  @override
  String get featureWiseTitle => '현명한';

  @override
  String get featureWiseDescription =>
      '이 모델은 깊은 분석적 통찰력과 미래 지향적 추론을 활용하여 의사 결정 및 복잡한 문제 해결을 위한 정교한 지원을 제공할 수 있습니다.';

  @override
  String get featureResearcherTitle => '연구원';

  @override
  String get featureResearcherDescription =>
      '고급 연구 및 분석 능력을 갖춘 모델에서만 사용할 수 있는 이 기능은 다양한 영역에 걸쳐 고정밀도의 통찰력과 포괄적인 분석을 제공하도록 설계되었습니다.';

  @override
  String get nameLabel => 'AI 이름';

  @override
  String get nameHint => 'AI의 이름을 입력하세요';

  @override
  String get summaryLabel => 'AI 요약';

  @override
  String get summaryHint => 'AI의 요약을 입력하세요';

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
  String get characterPoliceTitle => '경찰';

  @override
  String get characterPoliceRole =>
      '당신은 법의 집행자로서, 흔들림 없는 헌신으로 시민을 보호하고 질서를 유지하는 데 전념하는 경찰입니다.';

  @override
  String get characterPoliceShortDescription => '꿋꿋하고 용감한 법 집행관.';

  @override
  String get purchaseSubscription => '구매';

  @override
  String get modelUploadTitle => '인공지능 파일';

  @override
  String get modelUploadDescription =>
      '기기에서 직접 로컬 GGUF 파일을 선택하고 업로드하세요. 이를 통해 인터넷 연결 없이 오프라인으로 모델을 실행할 수 있습니다. 파일이 유효한 GGUF 형식이고 올바르게 구성되었는지 확인하세요. 파일이 잘못되었거나 손상된 경우 Cortex가 예상대로 작동하지 않을 수 있으며 오류가 발생할 수 있습니다.';

  @override
  String get modelUploadShortDescription => '여기를 탭하여 기기에서 .gguf 파일을 선택하세요';

  @override
  String get addServerTitle => '인공지능 서버';

  @override
  String get addServerDescription =>
      '원격 서버의 URL을 입력하여 외부에서 호스팅되는 모델과 연결하세요. 이 기능은 활성 인터넷 연결이 필요하며, 서버 관련 문제나 오류는 Cortex로 인해 발생한 것이 아닙니다. 원활한 경험을 위해 서버가 올바르게 구성되고, 네트워크에서 액세스할 수 있으며, 유효한 모델 엔드포인트가 있는지 확인하세요.';

  @override
  String get you => '당신';

  @override
  String get removePhotoTitle => '사진 제거';

  @override
  String get confirmRemovePhoto => '사진을 제거하시겠습니까?';

  @override
  String get serverLink => '서버 링크';

  @override
  String get enterURL => '서버 URL 입력';

  @override
  String get chatLengthLimitExceeded =>
      '이 채팅이 글자 수 제한을 초과했습니다. 새 채팅을 시작하거나 구독을 구매해주세요.';

  @override
  String get aiNameError => '이 이름을 가진 AI가 이미 존재합니다.';

  @override
  String get modelLimitExceeded => '플랜의 최대 모델 생성 한도에 도달했습니다.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => '사진은 한 장만 추가할 수 있습니다.';

  @override
  String get inappropriateContentDetected => '부적절한 콘텐츠가 감지되었습니다!';

  @override
  String get offlineModelNotInstalled => '이 오프라인 모델은 기기에 설치되어 있지 않습니다.';

  @override
  String insufficientCredits(Object available, Object required) {
    return '이 요청을 완료하기에 크레딧이 부족합니다. 이 작업에는 $required 크레딧이 필요하지만, 현재 $available 크레딧만 보유하고 있습니다. 더 많은 크레딧을 얻으려면 플랜을 업그레이드하거나 직접 구매할 수 있습니다. 크레딧이 부족하면 좀 실망스러울 수 있다는 거 저희도 잘 알아요. 하지만 저희 모델들로부터 멋진 답변을 받는 건 공짜가 아니거든요. 그래서 이 크레딧은 저희가 좋은 서비스를 계속 운영하는 데 실제로 도움이 됩니다. 그리고 더 많은 분들이 참여해서 크레딧을 구매해주시면, 모두를 위한 무료 일일 한도를 상향 조정하는 것도 충분히 고려해볼 수 있습니다.';
  }

  @override
  String get regenerateInProgress => '답변 생성이 이미 진행 중입니다.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return '재생성 중 오류가 발생했습니다: $errorDetails';
  }

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
  String get errorInsufficientCredits => '크레딧이 부족합니다. 계속하려면 충전해주세요.';

  @override
  String get errorRateLimitExceeded => '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errorServer => '예기치 않은 서버 오류가 발생했습니다. 나중에 다시 시도해주세요.';

  @override
  String get errorNetwork => '네트워크 오류가 발생했습니다. 연결을 확인하고 다시 시도해주세요.';

  @override
  String get errorApiAuthentication => '인증에 실패했습니다. 다시 로그인해주세요.';

  @override
  String get baseModelForCharacterDescription =>
      '선택된 기본 모델이 캐릭터의 추론 및 응답 능력을 결정합니다.';

  @override
  String get selectBaseModel => '기본 모델 선택';

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
  String get noModelsFoundTitle => '결과 없음';

  @override
  String get noModelsFoundMessage => '검색어를 조정하거나 필터를 지워보세요.';

  @override
  String get usernameRateLimitExceeded => '사용자 이름은 14일마다 두 번만 변경할 수 있습니다.';

  @override
  String get usernameUnchanged => '이미 현재 사용 중인 사용자 이름입니다.';

  @override
  String get creditsInfoPanelTitle => '크레딧 작동 방식';

  @override
  String get creditsInfoPanelBody =>
      '크레딧은 온라인 모델과 채팅하는 데 사용됩니다. 메시지 하나하나가 다 돈이야 이 크레딧 때문에 우리가 안 망하는 거라고 자 이제 시스템을 설명해줄게\n\n• 무료 온라인 모델에게 보내는 각 메시지는 10크레딧입니다.\n• 온라인 프리미엄 모델에게 보내는 각 메시지는 20크레딧입니다.\n• 첨부 파일을 포함하면 30크레딧이 추가됩니다.\n• 무료 플랜 사용자는 매일 초기화되는 200크레딧 보너스를 받습니다.';

  @override
  String get creditsInfoPanelFooter => '즐거운 채팅 되세요!';

  @override
  String get disclaimerMessage => '인공지능은 실수를 할 수 있으니 중요한 정보는 확인하세요.';

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
  String get purchaseReceived => '구매가 접수되었으며 계정을 업데이트 중입니다.';

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
      'Vertex 계정에 로그인하세요. Google을 통해 가입하는 신규 사용자는 저희의 약관 및 개인정보 처리방침에 동의하는 것입니다. 가입 화면에서 검토할 수 있습니다.';

  @override
  String get registerSubtitle => 'Vertex 계정을 생성하면 다른 프로젝트에서도 사용할 수 있습니다.';

  @override
  String get photoWarningMessage =>
      '사진이 포함되어 있습니다. 이미지를 지원하지 않는 모델은 이를 무시할 수 있습니다.';

  @override
  String get loginRequiredForPurchase => '구매하려면 로그인해야 합니다.';

  @override
  String get storagePermissionRequired =>
      '다운로드한 모델을 저장하려면 저장소 권한이 필요합니다. 계속하려면 권한을 허용해주세요.';

  @override
  String get creditBannerTitle => '무료 크레딧 받기!';

  @override
  String get creditBannerSubtitle =>
      '친구를 초대하면 가입 시 두 분 모두 50 크레딧을 받습니다! 친구가 구독하면 두 분 모두 추가로 500 크레딧을 더 받습니다!';

  @override
  String get inviteShareSubject => 'Cortex에 저와 함께해요!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return '야 너 이 앱 코텍스 꼭 써봐 진짜 미쳤어 내 링크로 가입하면 우리 둘 다 50크레딧 받고 너가 구독하면 추가로 500크레딧씩 더 받아 완전 대박이니까 빨리 다운받아\n\n$playStoreLink';
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
  String get featureAudioTitle => '음성 입력';

  @override
  String get featureAudioDescription => '이 모델은 음성 오디오 입력을 이해하고 처리할 수 있습니다.';

  @override
  String get featureImageGenerationTitle => '이미지 생성';

  @override
  String get featureImageGenerationDescription =>
      '이 모델은 귀하의 텍스트 설명을 기반으로 독창적인 이미지를 만들 수 있습니다.';

  @override
  String get errorImageLoad => '생성된 이미지를 로드하는 데 실패했습니다.';

  @override
  String get extensionInfoPanelTitle => '모델 탐색';

  @override
  String get extensionInfoPanelBody1 =>
      '이 화살표를 사용하면 이 시리즈 내의 다른 모델로 전환할 수 있습니다.';

  @override
  String get extensionInfoPanelBody2 =>
      '이 시리즈에서 처음 채팅을 시작하면 기본 모델이 자동으로 선택되며, 채팅 중 언제든지 선택 항목을 변경할 수 있습니다.';

  @override
  String get extensionInfoPanelFooter =>
      '각 모델에 대한 자세한 정보를 보거나 다른 모델을 수동으로 선택하려면 라이브러리로 이동하세요. 거기에서 해당 모델 시리즈를 선택하고 세부 정보 페이지 상단에 있는 화살표를 탭하세요.';

  @override
  String get premiumModelNoticeTitle => '프리미엄 모델';

  @override
  String get premiumModelNoticeDescription =>
      '이 모델은 프리미엄 모델이며, 무료 사용자는 프리미엄 모델을 사용하여 하루에 3개의 메시지로 제한됩니다. 무제한 액세스를 잠금 해제하려면 구독하세요!';

  @override
  String get benefitPremiumModels => '프리미엄 모델에 대한 액세스';

  @override
  String get premiumTrialExhaustedMessage =>
      '프리미엄 모델의 무료 일일 메시지를 모두 사용했습니다. 무제한 액세스를 원하시면 업그레이드하세요.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return '$userName 님, 오늘은 무엇을 도와드릴까요?';
  }

  @override
  String get selectionScreenGreetingGeneric => '오늘은 어떻게 도와드릴까요?';

  @override
  String get selectionScreenRecentModels => '최근 모델';

  @override
  String get selectionScreenFeatureDynamicChat => '동적 채팅';

  @override
  String get selectionScreenFeatureOffline => '인터넷 없이 사용';

  @override
  String get selectionScreenFeatureSelectModel => '모델 선택';

  @override
  String get explore => '탐색';

  @override
  String get subscriptionCancelled => '구독이 성공적으로 취소되었습니다!';

  @override
  String get selectionScreenPinnedModels => '고정된 모델';

  @override
  String get selectionScreenNewsAndUpdates => '뉴스 및 업데이트';

  @override
  String get filters => '필터';

  @override
  String get noRecentChatsMessage => '아직 모델과 대화를 나누지 않으셨나요? 대화를 시작해 보세요!';

  @override
  String get allModels => '모든 모델';

  @override
  String get onlineModels => '온라인 모델';

  @override
  String get offlineModels => '오프라인 모델';

  @override
  String get characterModels => '캐릭터';

  @override
  String get customModels => '사용자 정의 모델';

  @override
  String get filterPanelDescription => '카테고리를 탭하면 목록이 즉시 필터링됩니다.';

  @override
  String get dynamicChatTitle => '동적 채팅';

  @override
  String get errorNoModelsAvailable =>
      '현재 이용 가능한 모델이 없습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get errorNoModelsForRequest =>
      '현재 요청(예: 오프라인 모드 또는 이미지 메시지)에 적합한 모델을 찾을 수 없습니다.';

  @override
  String get dynamicChatWelcome => '어떻게 도와드릴까요?';

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
  String get notificationNewYearTitle => '새해 복 많이 받으세요! 🎉';

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
      '방금 애니메이션 소녀가 전화해서 보고 싶다고 했어요. 와서 이야기를 나눠보는 게 어떨까요? 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 적색 경보 🚨';

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
  String get notificationSubscriptionOfferTitle => '껌보다 저렴하다';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return '모든 구독 플랜에 $discountRate% 할인 혜택이 제공됩니다. 놓치지 마세요!';
  }

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
      '친구를 Cortex에 초대하면 두 분 모두 무료 크레딧을 받으세요!';

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
      '바다는 잔잔하고, 바람은 당신을 등지고 있습니다. 코르텍스 바다에는 새로운 섬들(모델 😉)이 있습니다. 선원들을 모아 항해를 시작하세요!';

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
}
