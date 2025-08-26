// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get understood => '了解';

  @override
  String get cancel => 'キャンセル';

  @override
  String get remove => '削除';

  @override
  String get download => 'ダウンロード';

  @override
  String get resume => '再開';

  @override
  String get copy => 'コピー';

  @override
  String get chat => 'チャット';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get light => 'ライト';

  @override
  String get theme => 'テーマ';

  @override
  String get no => 'いいえ';

  @override
  String get yes => 'はい';

  @override
  String get done => '完了';

  @override
  String get comingSoon => '近日公開';

  @override
  String get bestValue => 'ベストバリュー';

  @override
  String get selected => '選択済み';

  @override
  String get descriptionSection => '説明';

  @override
  String get searchHint => '検索';

  @override
  String get messageHint => '何でも聞いてください';

  @override
  String get modelLoading => 'モデルを読み込み中...';

  @override
  String get messageCopied => 'メッセージをクリップボードにコピーしました。';

  @override
  String get storeUnavailable => 'ストアは現在利用できません。後でもう一度お試しください';

  @override
  String get retry => '再試行';

  @override
  String get systemInfo => 'システム情報';

  @override
  String deviceMemory(Object memory) {
    return 'デバイスメモリ: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'ストレージ容量: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return '空きストレージ容量: $freeStorage GB';
  }

  @override
  String get memory => 'メモリ';

  @override
  String get storage => 'ストレージ';

  @override
  String get freeStorage => '空き容量';

  @override
  String get totalStorage => '合計ストレージ';

  @override
  String get usedStorage => '使用済みストレージ';

  @override
  String get totalMemory => '合計メモリ';

  @override
  String get usedMemory => '使用済みメモリ';

  @override
  String get requirements => '要件';

  @override
  String get modelsTitle => 'ライブラリ';

  @override
  String get localModels => 'ローカルモデル';

  @override
  String get serverSideModels => 'オンラインモデル';

  @override
  String get uploadYourOwnModel => '独自のモデルをアップロード！';

  @override
  String get selectGGUFFile => 'GGUFファイルを選択';

  @override
  String get errorGGUF => 'GGUF形式のファイルのみを選択してください。';

  @override
  String get modelAlreadyExists => 'モデルは既に存在します。';

  @override
  String get modelAddedSuccessfully => 'モデルが正常に追加されました。';

  @override
  String get modelRemoved => 'モデルが正常に削除されました。';

  @override
  String get removeError => 'モデルの削除中にエラーが発生しました。';

  @override
  String get fileNotFound => 'ファイルが見つかりません。';

  @override
  String get fileUploadError => 'ファイルのアップロード中にエラーが発生しました。';

  @override
  String get noFileSelected => 'ファイルが選択されていません。';

  @override
  String get myModels => 'マイモデル';

  @override
  String get create => '作成';

  @override
  String get seeAll => 'すべて表示';

  @override
  String modelProducer(Object producer) {
    return 'プロデューサー: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'サイズ: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => '会話';

  @override
  String get conversationDeleted => '会話を削除しました。';

  @override
  String get conversationUpdated => '会話を更新しました。';

  @override
  String get editConversationTitle => '名前を変更';

  @override
  String get newTitle => '新しいタイトル';

  @override
  String get save => '保存';

  @override
  String get titleCannotBeEmpty => 'タイトルを空にすることはできません。';

  @override
  String get noConversationsMessage => '会話がありません、チャットを始めましょう！';

  @override
  String get startChat => 'チャットを開始';

  @override
  String get noChats => 'チャットがありません';

  @override
  String get starredChats => 'スター付きチャット';

  @override
  String get allChats => 'すべてのチャット';

  @override
  String get noStarredChats => 'スター付きチャットがありません';

  @override
  String get noStarredChatsMessage => 'まだスターを付けたチャットがありません。';

  @override
  String get goToChats => 'チャットにスターを付ける';

  @override
  String get starConversation => 'スター';

  @override
  String get conversationTitleUpdated => '会話のタイトルを更新しました';

  @override
  String get youReachedConversationLimit => '会話の上限に達しました。';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get loginToYourAccount => 'ログイン';

  @override
  String get createYourAccount => '登録';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワードの確認';

  @override
  String get invalidEmail => '有効なメールアドレスを入力してください。';

  @override
  String get invalidPassword => 'パスワードは6文字以上である必要があります。';

  @override
  String get rememberMe => 'ログイン状態を維持する';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get or => 'または';

  @override
  String get continueWithGoogle => 'Googleで続行';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get alreadyHaveAccount => '既にアカウントをお持ちですか？';

  @override
  String get signUp => 'サインアップ';

  @override
  String get logIn => 'ログイン';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません。';

  @override
  String get userNotFound => 'ユーザーが見つかりません。';

  @override
  String get wrongPassword => 'パスワードが正しくありません。';

  @override
  String get emailAlreadyInUse => 'このメールアドレスは既に使用されています。';

  @override
  String get weakPassword => 'パスワードが弱すぎます。';

  @override
  String get authError => '認証エラー';

  @override
  String get invalidUsername => 'ユーザー名を入力してください。';

  @override
  String get usernameTaken => 'このユーザー名は既に使用されています。';

  @override
  String get username => 'ユーザー名';

  @override
  String get authenticationFailed => '認証に失敗しました。もう一度お試しください。';

  @override
  String get emailTooLong => 'メールアドレスは最大30文字です。';

  @override
  String get deviceLimitReached => 'このデバイスのアカウント作成上限に達しました。';

  @override
  String get verificationEmailLimitReached => 'これ以上は送信しません';

  @override
  String get verificationEmailSent => '確認メールを送信しました！';

  @override
  String get emailNotVerified => 'メールアドレスが確認されていません';

  @override
  String get resendCode => '確認メールを再送信';

  @override
  String get remainingSeconds => '確認までの残り時間';

  @override
  String get pleaseCheckYourEmail =>
      'Cortexを使用するには、メールアドレスの確認が必要です。\n確認リンクがあなたのメールアドレスに送信されました。メールを確認してください。';

  @override
  String get verifyYourEmail => 'メールアドレスを確認';

  @override
  String get backToLogin => '戻る';

  @override
  String get seconds => '秒';

  @override
  String get maxResendLimitReached => '確認メールの最大送信回数に達しました';

  @override
  String get verificationScreenContinueWithoutVerification => '確認せずに続行';

  @override
  String get verificationScreenWarning =>
      '続行しても、アカウントの1日間の確認期間は有効です。それまでにアカウントを確認しない場合、アプリから削除されます。';

  @override
  String get unverifiedAccountHeader => 'あなたのアカウントは確認されていません';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return '$timeLeft以内にアカウントを確認しない場合、削除されます';
  }

  @override
  String get verifyNow => '今すぐ確認';

  @override
  String get accountVerified => 'アカウントが確認されました。';

  @override
  String get linkSent => 'リンクを送信しました';

  @override
  String get accountDeletionRequested =>
      'アカウントの削除リクエストが受信され、アカウントは現在無効になっています。';

  @override
  String get tooManyRequests => 'リクエストが多すぎます';

  @override
  String get regenerate => '再生成';

  @override
  String get confirmDeleteAccount => '本当にアカウントを削除しますか？';

  @override
  String get enterPasswordToDelete => '削除するにはパスワードを入力してください。';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountError => 'アカウントの削除中にエラーが発生しました。';

  @override
  String get delete => '削除';

  @override
  String get passwordRequired => 'パスワードが必要です。';

  @override
  String get deleteDescription =>
      '削除したデータは、当社のサーバーとあなたのデバイスから永久に削除されます。この操作は元に戻せません。';

  @override
  String get deleteAccountButton => 'アカウント削除ボタン';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get displayName => '表示名';

  @override
  String get tapToChangeProfilePicture => 'タップしてプロフィール写真を変更';

  @override
  String get profileUpdated => 'プロフィールが正常に更新されました';

  @override
  String get updateFailed => 'プロフィールの更新に失敗しました';

  @override
  String get nameCannotBeEmpty => '名前を空にすることはできません';

  @override
  String get logout => 'ログアウト';

  @override
  String get noDisplayName => '表示名が設定されていません';

  @override
  String get noEmail => 'メールアドレスがありません';

  @override
  String get noUserLoggedIn => '現在ログインしているユーザーがいません';

  @override
  String get profile => 'プロフィール';

  @override
  String get manageProfileDescription =>
      'あなたのプロフィールを管理し、パスワードを更新したり、Cortexからログアウトしたりします。';

  @override
  String get accessSettingsDescription =>
      'ヘルプへのアクセス、コードの引き換え、Cortexの共有、および当社のポリシーの表示。';

  @override
  String get languageDescription => 'いつでもデフォルトのアプリインターフェース言語を変更できます。';

  @override
  String get themeDescription =>
      '好みに応じてライトテーマとダークテーマを切り替えることができます。選択したテーマはCortexインターフェース全体に適用されます。';

  @override
  String get iHaveReadAndAgree => '利用規約に同意します';

  @override
  String get downloading => 'ダウンロード中...';

  @override
  String get downloadError => 'ダウンロード中にエラーが発生しました。';

  @override
  String get downloadCancelled => 'ダウンロードがキャンセルされました。';

  @override
  String get downloadResumed => 'ダウンロードが再開されました。';

  @override
  String get downloadSuccess => 'ダウンロード成功';

  @override
  String get downloadFailed => 'ダウンロード失敗';

  @override
  String downloaded(Object percent) {
    return '$percent% ダウンロード済み';
  }

  @override
  String get downloadPaused => 'ダウンロードが一時停止しました。';

  @override
  String get purchaseSuccessful => '購入成功！';

  @override
  String get purchaseFailed => '購入に失敗しました';

  @override
  String get creditProductNotFound => '選択されたクレジット商品が見つかりませんでした。';

  @override
  String get creditsAddedSuccessfully => 'クレジットがアカウントに正常に追加されました！';

  @override
  String get creditDeliveryFailed => 'アカウントへのクレジット追加に失敗しました。サポートにお問い合わせください。';

  @override
  String get invalidPurchase => '無効な購入';

  @override
  String get purchaseError => '購入エラー';

  @override
  String get purchaseVertexPlusToUpload => 'これはPlusの機能です';

  @override
  String get purchasePlus => 'Cortex Plusを購入';

  @override
  String get plusDescription => 'Cortexのさらに多くの機能にアクセスし、AIをさらに体験してください！';

  @override
  String get annual => '年間';

  @override
  String get monthly => '月間';

  @override
  String get manageSubscription => 'サブスクリプションを管理';

  @override
  String purchasePlan(String planName) {
    return '$planNameを購入';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% OFF';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/月、年間請求';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/月、月間請求';
  }

  @override
  String get discountBannerTitle => 'ローンチスペシャル：80% OFF！';

  @override
  String get discountBannerSubtitle =>
      'ローンチを記念して、すべてのサブスクリプションプランが特別割引。お見逃しなく！';

  @override
  String get purchasePro => 'Cortex Proを購入';

  @override
  String get proDescription => 'Cortexのさらに多くの機能にアクセスし、AIをさらに体験してください！';

  @override
  String get alreadySubscribed => 'すでに登録済みです';

  @override
  String get subscriptionInfo => 'あなたのサブスクリプションは有効です。';

  @override
  String get alreadySubscribedMessage =>
      'すでにPlusサブスクリプションをお持ちです。サブスクリプションをキャンセルしたい場合は、Playストアマネージャーから行うことができます。';

  @override
  String get cancelSubscription => 'サブスクリプションをキャンセル';

  @override
  String get cancelSubscriptionInfo =>
      'サブスクリプションをキャンセルしたい場合は、Playストアのサブスクリプションマネージャーから手続きを進めてください。';

  @override
  String get goToPlayStore => 'Playストアに移動';

  @override
  String get alreadySubscribedPlus => 'Plusプランをご利用中です！';

  @override
  String get alreadySubscribedPlusMessage =>
      'あなたのPlusプランは有効です。すべての特典をお楽しみいただけます。';

  @override
  String get purchaseUltra => 'Cortex Ultraを購入';

  @override
  String get ultraDescription => 'Cortexのすべての機能へのフルアクセス権を獲得し、AIを最大限に体験してください！';

  @override
  String get noSubscription => 'サブスクリプションがありません';

  @override
  String get noSubscriptionMessage => 'まだサブスクリプションがありません。';

  @override
  String get alreadyAtHighestPlan => 'すでに最上位のプランです。';

  @override
  String get unableToOpenSubscription => 'サブスクリプション管理ページを開けませんでした。';

  @override
  String get upgradeSubscription => 'サブスクリプションをアップグレード';

  @override
  String get confirmUpgrade => 'サブスクリプションをアップグレードしてもよろしいですか？';

  @override
  String get unsupportedPlatform => 'サブスクリプションのキャンセルに対応していないプラットフォームです。';

  @override
  String get purchaseStreamError => '購入ストリームエラー。';

  @override
  String get productNotFound => '製品が見つかりません';

  @override
  String get productDetailsError => '製品詳細の取得中にエラーが発生しました。';

  @override
  String get noProductsFound => '製品が見つかりません';

  @override
  String get loadCreditsButton => 'クレジットをロード';

  @override
  String get creditsTitle => 'クレジット';

  @override
  String get creditsScreenDescription =>
      'この画面にはユーザーのクレジットが表示されます。\n\nユーザーの現在のクレジット: 100\n\n詳細なクレジット情報をここに表示できます。';

  @override
  String get creditsLoaded => 'クレジットがロードされました！';

  @override
  String get currentCredits => '現在のクレジット';

  @override
  String get pleaseSelectCreditPackage => 'クレジットパッケージを選択してください';

  @override
  String get purchaseCreditsTitle => 'クレジットを購入';

  @override
  String get purchaseCreditsDescription =>
      'あなたのニーズに合ったクレジットパッケージを選択し、アプリをさらに活用してください。';

  @override
  String get purchaseButton => '購入';

  @override
  String get productNotFoundMessage => '選択された製品は存在しません。';

  @override
  String get buyCredits => 'クレジットを購入';

  @override
  String get selectCreditPackageDescription =>
      'あなたのニーズに合ったクレジットパッケージを選択し、より多くの機能をお楽しみください。';

  @override
  String get buyCredit => 'クレジットを購入';

  @override
  String buyCreditPackage(Object amount) {
    return '$amountクレジットを購入';
  }

  @override
  String get subscribedPlan => '登録済み';

  @override
  String get errorResponseNotReceived => '応答が受信されませんでした';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google APIリクエストが$attempt回失敗しました: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter応答ステータス: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouterデコード済み応答本文: $body';
  }

  @override
  String decodedJson(String data) {
    return 'デコード済みJSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      '応答構造が予期せぬものです：メッセージまたはコンテンツがありません';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      '応答構造が予期せぬものです：choicesがないか空です';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter APIリクエストが失敗しました: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter APIリクエストが$attempt回失敗しました: $error';
  }

  @override
  String get internetRequired => 'このモデルを使用するにはインターネット接続が必要です';

  @override
  String get pleaseWaitBeforeTryingAgain => 'しばらく待ってからもう一度お試しください';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'クォータを超えました。ステータスコード: $statusCode, 本文: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'APIリクエストが$attempts回の有料試行の後に失敗しました。エラー: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'この注文を行うことにより、利用規約およびプライバシーポリシーに同意したことになります。このテキストをクリックすると、当社の利用規約およびプライバシーポリシーについて詳しく知ることができます。現在の期間が終了する少なくとも24時間前に自動更新がオフにされない限り、サブスクリプションは自動的に更新されます。';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get report => '報告';

  @override
  String get reportDialogTitle => '報告を送信';

  @override
  String get reportDescriptionLabel => '問題は何ですか？';

  @override
  String get reportHarmful => 'これは有害/安全ではありません';

  @override
  String get reportNotTrue => 'これは真実ではありません';

  @override
  String get reportNotHelpful => 'これは役に立ちません';

  @override
  String get closeButton => '閉じる';

  @override
  String get submitButton => '送信';

  @override
  String get reportErrorMessage => '報告する理由を1つ選択してください。';

  @override
  String get capabilitiesSection => '能力';

  @override
  String get ratingsSection => '評価';

  @override
  String get noRatingDataFound => '評価データが見つかりません';

  @override
  String get featurePhotoTitle => '写真スキャン';

  @override
  String get featurePhotoDescription =>
      'このモデルは、カメラや画像ファイルを通じて写真をスキャンする能力を持っています。';

  @override
  String get featureOfflineTitle => 'オフライン操作';

  @override
  String get featureOfflineDescription => 'インターネット接続なしでモデルを実行し、データを安全に保ちます。';

  @override
  String get featureSupermodelTitle => 'スーパーモデル';

  @override
  String get featureSupermodelDescription =>
      'これは100億以上のパラメータを持つ巨大なモデルで、高いパフォーマンスと広範な能力を提供します。';

  @override
  String get featureRoleplayTitle => 'ロールプレイ';

  @override
  String get featureRoleplayDescription =>
      'ロールプレイングモデルを使用すると、さまざまなチャットやシナリオを作成できます。';

  @override
  String get roleModels => 'ロールプレイモデル';

  @override
  String get parameters => 'パラメータ';

  @override
  String get context => 'コンテキスト';

  @override
  String get millions => '百万';

  @override
  String get billions => '十億';

  @override
  String get trillions => '兆';

  @override
  String get thousand => '千';

  @override
  String get estimated => '推定';

  @override
  String get finalPreparation => '最終準備が行われています。';

  @override
  String get allEvaluationsByTestTeam => 'すべての評価は当社のテストチームによって行われました';

  @override
  String get shareApp => 'アプリを共有';

  @override
  String get rateUs => '評価する';

  @override
  String get share => '共有';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Cortexアプリをチェックしてみてください、とても素晴らしいです！ここからダウンロードしてください: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed => 'アプリの共有に失敗しました。後でもう一度お試しください';

  @override
  String get selectText => 'テキストを選択';

  @override
  String get showLatex => '特殊記号を表示';

  @override
  String get hideLatex => '特殊記号を非表示';

  @override
  String get thinking => '考え中';

  @override
  String get user => 'ユーザー';

  @override
  String get voice => '音声';

  @override
  String get help => 'ヘルプ';

  @override
  String get redeemCode => 'コードを引き換える';

  @override
  String get enterYourCode =>
      'お気に入りのクリエイターをサポートしよう！Cortexでの購入の一部を彼らに還元するために、以下のユニークなコードを入力してください。';

  @override
  String get code => 'コード';

  @override
  String get redeem => '引き換える';

  @override
  String get codeCannotBeEmpty => 'コードを空にすることはできません';

  @override
  String get userId => 'ユーザーID';

  @override
  String get deleteAllConversationsConfirmTitle => 'すべてのチャットを削除しますか？';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '本当にすべてのチャットを削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get allConversationsDeleted => 'すべての会話が正常に削除されました！';

  @override
  String get deleteAll => 'すべて削除';

  @override
  String get deleteAllConversationsButton => 'すべての会話を削除';

  @override
  String get confirmWord => 'VERTEXと入力';

  @override
  String get confirmWordError => '入力が間違っています';

  @override
  String get chinese => '中国語';

  @override
  String get arabic => 'アラビア語';

  @override
  String get french => 'フランス語';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '韓国語';

  @override
  String get deutsch => 'ドイツ語';

  @override
  String get english => '英語';

  @override
  String get turkish => 'トルコ語';

  @override
  String get hindi => 'ヒンディー語';

  @override
  String get portuguese => 'ポルトガル語';

  @override
  String get indonesian => 'インドネシア語';

  @override
  String get azerbaijani => 'アゼルバイジャン語';

  @override
  String get german => 'ドイツ語';

  @override
  String get spanish => 'スペイン語';

  @override
  String get italian => 'イタリア語';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'ユーザー名が短すぎます。';

  @override
  String get usernameTooLong => 'ユーザー名は16文字を超えることはできません。';

  @override
  String get invalidUsernameCharacters =>
      'ユーザー名には、\'abcçdefgğhıijklmnoöprsştuüvyzxqw\'の文字と、\'.\'、\'-\'、\'_\'の記号のみ使用できます。';

  @override
  String get passwordTooLong => 'パスワードは64文字を超えることはできません。';

  @override
  String get noInternetConnection => 'インターネット接続がありません。';

  @override
  String get chats => '受信トレイ';

  @override
  String get library => 'ライブラリ';

  @override
  String get inappropriateMessageWarning => '不適切なメッセージが検出されました！';

  @override
  String get myModelDescription => '私のモデル。';

  @override
  String get noModelsDownloaded => 'まだどのモデルもダウンロードしていません。';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'テキスト';

  @override
  String get removeModel => 'モデルを削除';

  @override
  String get modelUploadedSuccessfully => 'モデルが正常にアップロードされました。';

  @override
  String get insufficientRAM => 'メモリ不足';

  @override
  String get insufficientStorage => 'ストレージ不足';

  @override
  String confirmRemoveModel(Object model) {
    return '本当に$modelモデルをデバイスから削除しますか？そうすると、そのモデルとの以前の会話もすべて削除されます。';
  }

  @override
  String get noMatchingModels => '一致するモデルが見つかりませんでした。';

  @override
  String creditPackage(Object amount) {
    return '$amountクレジットを購入';
  }

  @override
  String get benefit1 => 'オンラインAIの会話制限が大幅に増加';

  @override
  String get benefit2 => '独自のモデルをアップロード';

  @override
  String get benefit3 => 'プロフィールエフェクト';

  @override
  String get benefit4 => 'メンバーシップバッジ';

  @override
  String get benefit5 => 'より多くのオンラインAIを作成';

  @override
  String get benefit6 => '無制限のチャット';

  @override
  String benefit7(Object credits) {
    return '毎日$creditsクレジット';
  }

  @override
  String get benefit8 => 'モデルを追加';

  @override
  String get benefit9 => '新しいテーマ';

  @override
  String get benefit10 => 'オフライン音声チャット';

  @override
  String get oldBenefits => '下位プランのすべての特典';

  @override
  String get confirm => '確認';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get logoutConfirmationTitle => '本当にログアウトしますか？';

  @override
  String get settings => '設定';

  @override
  String get language => 'アプリ言語';

  @override
  String get dark => 'ダーク';

  @override
  String get oldPassword => '古いパスワード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get passwordUpdated => 'パスワードが更新されました。';

  @override
  String get stop => '停止';

  @override
  String get copyrights => '帰属';

  @override
  String get downloadingTitle => 'ダウンロード中';

  @override
  String get downloadCompletedTitle => 'ダウンロード完了';

  @override
  String get downloadPausedTitle => 'ダウンロード一時停止';

  @override
  String get downloadErrorTitle => 'ダウンロードエラー';

  @override
  String get cancelButtonText => 'キャンセル';

  @override
  String get love => '愛';

  @override
  String get nature => '自然';

  @override
  String get behindTheSlaughter => '虐殺の裏側';

  @override
  String get grayscale => 'グレースケール';

  @override
  String get ocean => '海';

  @override
  String get scarletSnow => '緋色の雪';

  @override
  String get requestFailed => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get changeModel => '変更';

  @override
  String get edit => '編集';

  @override
  String get editingMessageInfo => 'このメッセージを編集すると、ここから会話が再開されます。';

  @override
  String get editingNotification => '現在編集モードです';

  @override
  String get featureIndulgentTitle => '寛容';

  @override
  String get featureIndulgentDescription =>
      'このモデルは10万トークンを超えるコンテキストをシームレスに受け入れ、処理することができ、パフォーマンスを損なうことなく広範で詳細な入力を処理できます。';

  @override
  String get featurePluralTitle => '複数';

  @override
  String get featurePluralDescription =>
      'このモデルは追加の拡張機能を自動的に統合し、それによって機能的能力を拡張して、多様な操作を強化されたパフォーマンスでサポートします。';

  @override
  String get featureWiseTitle => '賢明';

  @override
  String get featureWiseDescription =>
      'このモデルは、深い分析的洞察と先進的な推論を活用して、意思決定と複雑な問題解決のための洗練されたサポートを提供できます。';

  @override
  String get featureResearcherTitle => '研究者';

  @override
  String get featureResearcherDescription =>
      '高度な研究および分析能力を備えたモデルでのみ利用可能なこの機能は、多様なドメインにわたって高精度の洞察と包括的な分析を提供するように設計されています。';

  @override
  String get nameLabel => 'AIの名前';

  @override
  String get nameHint => 'AIの名前を入力';

  @override
  String get summaryLabel => 'AIの概要';

  @override
  String get summaryHint => 'AIの概要を入力';

  @override
  String get add => '追加';

  @override
  String get aiExplanationTitle => 'AIの説明';

  @override
  String get aiExplanationDescription =>
      'AIモデルのアーキテクチャ、トレーニングプロセス、パフォーマンスメトリクス、応用分野、その他の重要な特徴について詳細な説明を提供してください。';

  @override
  String get preInputTitle => 'AIの事前入力';

  @override
  String get preInputDescription =>
      'キャラクター作成プロセスでモデルをガイドする事前入力を設定してください。このセクションでは、キャラクター関連の情報、追加のコンテキスト、およびキャラクターに関連するコンテンツの生成に役立つ可能性のある追加の詳細を含めることができます。';

  @override
  String get baseModelTitle => 'ベースモデル';

  @override
  String get baseModelDescription =>
      'これはあなたの創造物の基盤として使用されるモデルです。現在選択されているベースモデルを表示します。';

  @override
  String get summary => '概要';

  @override
  String get characterPoliceTitle => '警察官';

  @override
  String get characterPoliceRole =>
      'あなたは法の用心深い執行者であり、市民を守り、揺るぎない献身で秩序を維持することに専念している、あなたは警察官です';

  @override
  String get characterPoliceShortDescription => '不動で勇敢な法の執行者。';

  @override
  String get purchaseSubscription => '購入';

  @override
  String get modelUploadTitle => 'AIファイル';

  @override
  String get modelUploadDescription =>
      'デバイスから直接ローカルのGGUFファイルを選択してアップロードします。これにより、インターネット接続なしでモデルをオフラインで実行できます。ファイルが有効なGGUF形式であり、適切に構造化されていることを確認してください。ファイルが正しくないか破損している場合、Cortexは期待どおりに機能しない可能性があり、エラーが発生する可能性があります。';

  @override
  String get modelUploadShortDescription => 'ここをタップしてデバイスから.ggufファイルを選択';

  @override
  String get addServerTitle => 'AIサーバー';

  @override
  String get addServerDescription =>
      'リモートサーバーのURLを入力して、外部でホストされているモデルに接続します。この機能にはアクティブなインターネット接続が必要であり、サーバー関連の問題やエラーはCortexが原因ではありません。サーバーが正しく設定され、ネットワークからアクセス可能であり、スムーズな体験のために有効なモデルエンドポイントがあることを確認してください。';

  @override
  String get you => 'あなた';

  @override
  String get removePhotoTitle => '写真を削除';

  @override
  String get confirmRemovePhoto => '本当に写真を削除しますか？';

  @override
  String get serverLink => 'サーバーリンク';

  @override
  String get enterURL => 'サーバーURLを入力';

  @override
  String get chatLengthLimitExceeded =>
      'このチャットは文字数制限を超えました。新しいチャットを開始するか、サブスクリプションを購入してください。';

  @override
  String get aiNameError => 'この名前のAIは既に存在します。';

  @override
  String get modelLimitExceeded => 'プランのモデル作成上限に達しました。';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => '追加できる写真は1枚だけです';

  @override
  String get inappropriateContentDetected => '不適切なコンテンツが検出されました！';

  @override
  String get offlineModelNotInstalled => 'このオフラインモデルはデバイスにインストールされていません。';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'このリクエストを完了するのに十分なクレジットがありません。このアクションには$requiredクレジットが必要ですが、あなたは$availableしか持っていません。さらにクレジットを取得するには、プランをアップグレードするか、直接購入することができます。ねえ、クレジットがなくなるのがちょっと残念なのはよくわかります。でも、真面目な話、私たちのモデルから素晴らしい返信をもらうのは無料じゃないんです。だから、このクレジットが、この素晴らしい体験を続けるのに役立っているんです。そして、もしもっと多くの人がクレジットを手に入れてくれたら、みんなの無料デイリーリミットを引き上げることも検討できるんです。';
  }

  @override
  String get regenerateInProgress => '回答の生成は既に進行中です。';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return '再生成中にエラーが発生しました: $errorDetails';
  }

  @override
  String get modality => 'モダリティ';

  @override
  String get multimodal => 'マルチモーダル';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String get themeLocked =>
      'このテーマにはより高いサブスクリプションレベルが必要です。ロックを解除するにはアップグレードしてください。';

  @override
  String get pageCouldNotBeLoaded => 'ページを読み込めませんでした';

  @override
  String get checkYourInternet => 'インターネット接続を確認して、もう一度お試しください。';

  @override
  String get errorUserNotAuthenticated => 'この操作を実行するにはログインする必要があります。';

  @override
  String get errorInsufficientCredits => 'クレジットが不足しています。続行するにはチャージしてください。';

  @override
  String get errorRateLimitExceeded => 'リクエストが多すぎます。しばらくしてからもう一度お試しください。';

  @override
  String get errorServer => '予期せぬサーバーエラーが発生しました。後でもう一度お試しください。';

  @override
  String get errorNetwork => 'ネットワークエラーが発生しました。接続を確認してもう一度お試しください。';

  @override
  String get errorApiAuthentication => '認証に失敗しました。もう一度ログインしてみてください。';

  @override
  String get baseModelForCharacterDescription =>
      '選択されたベースモデルが、キャラクターの推論および応答能力を決定します。';

  @override
  String get selectBaseModel => 'Select a Base Model';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get downloadStarted => 'ダウンロードを開始しました';

  @override
  String get notAvailable => '利用不可';

  @override
  String get localizationWarning => '一部の情報はあなたの言語で利用できない場合があり、英語で表示されます。';

  @override
  String get aiTranslationWarning =>
      'モデル情報は他のAIモデルによって様々な言語に翻訳されています。そのため、英語以外の言語では軽微な不一致が生じる可能性があります。';

  @override
  String get errorLoadingTitle => 'データの読み込みに失敗しました';

  @override
  String get errorLoadingMessage =>
      'サーバーから必要なデータを取得できませんでした。インターネット接続を確認して、もう一度お試しください。';

  @override
  String get noModelsFoundTitle => '結果がありません';

  @override
  String get noModelsFoundMessage => '検索語を調整するか、フィルターをクリアしてみてください。';

  @override
  String get usernameRateLimitExceeded => 'ユーザー名は14日間に2回しか変更できません。';

  @override
  String get usernameUnchanged => 'これは既に現在のユーザー名です。';

  @override
  String get creditsInfoPanelTitle => 'クレジットの仕組み';

  @override
  String get creditsInfoPanelBody =>
      'クレジットはオンラインモデルとのチャットに使用されます。ご存知の通り、あなたが彼らに送るすべてのメッセージには費用がかかります。\n\n• オンラインモデルへの各メッセージは20クレジットかかります。\n• 画像を含めるとさらに30クレジットが追加されます。\n• 無料プランのユーザーは、毎日リセットされる200クレジットのボーナスを受け取ります。';

  @override
  String get creditsInfoPanelFooter => '楽しいチャットを！';

  @override
  String get disclaimerMessage => 'AIは間違いを犯すことがあります。重要な情報は確認してください。';

  @override
  String get modelCreatedSuccess => 'モデルが正常に作成されました！';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '「$modelName」は正常に削除されました。';
  }

  @override
  String get errorCreatingModel => 'モデルの作成中に予期せぬエラーが発生しました。';

  @override
  String get errorDeletingModel => 'モデルの削除中に予期せぬエラーが発生しました。';

  @override
  String get ultraFeatureOnly => 'この機能はUltraメンバーのみが利用できます。';

  @override
  String get experimentalOfflineWarning =>
      'オフラインモードはまだ実験段階であり、ダウンロードしたモデルが最適な効率で動作しない可能性があります。';

  @override
  String get noConversationsToDelete => '削除する会話がありません。';

  @override
  String get reportSubmitted => '報告が正常に送信されました';

  @override
  String get purchaseReceived => '購入を受け付けました。アカウントを更新しています。';

  @override
  String get verificationDelayed =>
      '購入は確認されました。アカウントの更新に若干の遅延がありますが、まもなく反映されます。';

  @override
  String get maintenanceTitle => 'メンテナンス中';

  @override
  String get maintenanceMessage =>
      'Cortexは重要なアップデートを展開中のため、一時的にオフラインです。アプリへのアクセスはまもなく復旧します。\n\nエクスペリエンス向上のためのご協力に感謝いたします。';

  @override
  String get errorPromptFlagged => 'あなたのメッセージは不適切と検出されたため、送信できませんでした。';

  @override
  String get notEnoughStorage => '新しいメッセージを保存するのに十分なストレージ容量がデバイスにありません。';

  @override
  String get errorRateLimit => '最近モデルを作成しすぎました。しばらく待ってからもう一度お試しください。';

  @override
  String get errorContentFlagged => 'コンテンツが不適切と判断されたため、モデルを保存できませんでした。';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'アクティブなチャット中はすべての会話を削除できません。続行するにはまず現在のチャットを終了してください。';

  @override
  String get invalidCredentials => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get userDisabled => 'このユーザーアカウントは無効になっています。';

  @override
  String get loginSubtitle =>
      'あなたのVertexアカウントにログインしてください。Google経由で新規登録するユーザーは、当社の利用規約とプライバシーポリシーに同意したことになります。これらはサインアップ画面で確認できます。';

  @override
  String get registerSubtitle => 'Vertexアカウントを作成してください。これは当社の他のプロジェクトでも使用できます。';

  @override
  String get photoWarningMessage =>
      '写真が含まれています。画像をサポートしていないモデルはそれを無視する場合があります。';

  @override
  String get loginRequiredForPurchase => '購入するにはログインする必要があります。';

  @override
  String get storagePermissionRequired =>
      'ダウンロードしたモデルを保存するにはストレージの許可が必要です。続行するには許可を与えてください。';

  @override
  String get creditBannerTitle => '無料クレジットをゲット！';

  @override
  String get creditBannerSubtitle =>
      '友達を招待すると、サインアップ時に二人とも50クレジットをゲット！もし彼らがサブスクリプションに登録したら、二人ともさらに500クレジットをゲット！';

  @override
  String get inviteShareSubject => 'Cortexで一緒にやろう！';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'よう このcortexってアプリマジでやばいからチェックしてみて 俺のリンク使ったら俺ら二人とも50クレジットもらえるし もしサブスクしたらさらに500クレジットもらえるんだ これマジでやばい取引だよ すぐダウンロードして\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Cortexを楽しんでいますか？';

  @override
  String get reviewHelpUsGrow =>
      'あなたの評価は、私たちの若いインディーチームにとって大きな支えとなり、Cortexをさらに良くするのに役立ちます。';

  @override
  String get reviewMaybeLater => '後で';

  @override
  String get reviewRateNow => '今すぐ評価';

  @override
  String get noThanks => 'いいえ、結構です';

  @override
  String get updateRequiredTitle => 'アップデートが必要です';

  @override
  String get updateRequiredMessage =>
      'Cortexを引き続き使用するには、新機能や重要な改善のためにアプリを最新バージョンにアップデートしてください。';

  @override
  String get updateNowButton => '今すぐアップデート';

  @override
  String get creatorSupportedSuccess =>
      'クリエイターのサポートが完了しました！今後のご購入は、そのクリエイターに貢献します。';
}
