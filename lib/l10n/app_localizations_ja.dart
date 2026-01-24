// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get cancel => 'キャンセル';

  @override
  String get remove => '取り除く';

  @override
  String get download => 'ダウンロード';

  @override
  String get resume => '再開';

  @override
  String get copy => 'コピー';

  @override
  String get chat => 'チャット';

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
  String get messageCopied => 'メッセージをクリップボードにコピーしました。';

  @override
  String get retry => '再試行';

  @override
  String get systemInfo => 'システム情報';

  @override
  String deviceMemory(Object memory) {
    return 'デバイスメモリ: $memory GB';
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
  String get modelsTitle => 'ライブラリ';

  @override
  String get localModels => 'ローカルモデル';

  @override
  String get serverSideModels => 'オンラインモデル';

  @override
  String get selectGGUFFile => 'GGUFファイルを選択';

  @override
  String get errorGGUF => 'GGUF形式のファイルのみを選択してください。';

  @override
  String get myModels => 'マイモデル';

  @override
  String get create => '作成';

  @override
  String modelProducer(Object producer) {
    return 'プロデューサー: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => '名前を変更';

  @override
  String get newTitle => '新しいタイトル';

  @override
  String get save => '保存';

  @override
  String get noConversationsMessage => '会話がありません、チャットを始めましょう！';

  @override
  String get startChat => 'チャットを開始';

  @override
  String get noChats => 'チャットがありません';

  @override
  String get noStarredChats => 'スター付きチャットがありません';

  @override
  String get noStarredChatsMessage => 'まだスターを付けたチャットがありません。';

  @override
  String get starConversation => 'スター';

  @override
  String get unstarConversation => 'スターを外す';

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
  String get wrongPassword => 'パスワードが正しくありません。';

  @override
  String get emailAlreadyInUse => 'このメールアドレスは既に使用されています。';

  @override
  String get weakPassword => 'パスワードが弱すぎます。';

  @override
  String get authError => '認証エラー';

  @override
  String get usernameTaken => 'このユーザー名は既に使用されています。';

  @override
  String get username => 'ユーザー名';

  @override
  String get resendCode => '確認メールを再送信';

  @override
  String get pleaseCheckYourEmail =>
      'Cortexを使用するには、メールアドレスの確認が必要です。\n確認リンクがあなたのメールアドレスに送信されました。メールを確認してください。';

  @override
  String get verifyYourEmail => 'メールアドレスを確認';

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
  String get deleteAccount => 'アカウントを削除';

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
  String get profileUpdated => 'プロフィールが正常に更新されました';

  @override
  String get logout => 'ログアウト';

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
  String get purchaseError => '購入エラー';

  @override
  String get purchasePlus => 'Cortex Plusを購入';

  @override
  String get plusDescription => 'エリート人工知能体験';

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
  String monthlyPlanDescription(String price) {
    return '$price/月、月払い';
  }

  @override
  String get purchasePro => 'Cortex Proを購入';

  @override
  String get proDescription => 'プレミア人工知能体験';

  @override
  String get purchaseUltra => 'Cortex Ultraを購入';

  @override
  String get ultraDescription => '人工知能のピーク';

  @override
  String get upgradeSubscription => 'サブスクリプションをアップグレード';

  @override
  String get purchaseStreamError => '購入ストリームエラー。';

  @override
  String get productNotFound => '製品が見つかりません';

  @override
  String get noProductsFound => '製品が見つかりません';

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
  String get featurePhotoTitle => '写真スキャン';

  @override
  String get featurePhotoDescription =>
      'このモデルは、カメラや画像ファイルを通じて写真をスキャンする能力を持っています。';

  @override
  String get featureOfflineTitle => 'オフライン操作';

  @override
  String get featureOfflineDescription => 'インターネット接続なしでモデルを実行し、データを安全に保ちます。';

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
  String get finalPreparation => '最終準備が行われています。';

  @override
  String get shareApp => 'アプリを共有';

  @override
  String get rateUs => '評価する';

  @override
  String get share => '共有';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Cortexアプリをチェックしてみてください、とても素晴らしいです！ここからダウンロードしてください: $cortexLink';
  }

  @override
  String get shareFailed => 'アプリの共有に失敗しました。後でもう一度お試しください';

  @override
  String get selectText => 'テキストを選択';

  @override
  String get thinking => '考え中';

  @override
  String get user => 'ユーザー';

  @override
  String get help => 'ヘルプ';

  @override
  String get supportCreator => 'クリエイターをサポートする';

  @override
  String get enterYourTag =>
      'お気に入りのクリエイターを応援しましょう！以下のタグを入力すると、Cortex での購入の一部がクリエイターに寄付されます。';

  @override
  String get creatorTag => 'クリエイタータグ';

  @override
  String get support => 'サポート';

  @override
  String get tagCannotBeEmpty => '作成者タグは空にできません';

  @override
  String get userId => 'ユーザーID';

  @override
  String get deleteAllConversationsConfirmTitle => 'すべてのチャットを削除しますか？';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '本当にすべてのチャットを削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get conversationDeleted => '会話が削除されました!';

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
  String get french => 'フランス語';

  @override
  String get japanese => '日本語';

  @override
  String get kurdish => 'クルド';

  @override
  String get dutch => 'オランダ語';

  @override
  String get russian => 'ロシア';

  @override
  String get korean => '韓国語';

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
  String get arabic => 'アラビア語';

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
  String get noInternetConnection => 'インターネット接続がありません。';

  @override
  String get chats => '受信トレイ';

  @override
  String get library => 'ライブラリ';

  @override
  String get text => 'テキスト';

  @override
  String get removeModel => 'モデルを削除';

  @override
  String get insufficientRAM => 'メモリ不足';

  @override
  String get insufficientStorage => 'ストレージ不足';

  @override
  String confirmRemoveModel(Object model) {
    return 'デバイスから $model モデルを削除してもよろしいですか？削除すると、そのモデルとの以前の会話もすべて削除されます。';
  }

  @override
  String get noMatchingModels => '一致するモデルが見つかりませんでした。';

  @override
  String get benefit1 => '会話制限の拡大';

  @override
  String get benefit3 => 'プロフィールエフェクト';

  @override
  String get benefit4 => 'メンバーシップバッジ';

  @override
  String get benefit5 => 'より多くのオンラインAIを作成';

  @override
  String get benefit7 => '使用制限の拡大';

  @override
  String get benefit8 => 'モデルを追加';

  @override
  String get benefit9 => '新しいテーマ';

  @override
  String get benefit10 => 'その他の添付ファイル';

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
  String get featurePluralTitle => '複数';

  @override
  String get featurePluralDescription =>
      'このモデルは追加の拡張機能を自動的に統合し、それによって機能的能力を拡張して、多様な操作を強化されたパフォーマンスでサポートします。';

  @override
  String get nameLabel => 'AIの名前';

  @override
  String get summaryLabel => 'AIの概要';

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
  String get modelUploadTitle => 'AIファイル';

  @override
  String get modelUploadDescription =>
      'デバイスから直接ローカルのGGUFファイルを選択してアップロードします。これにより、インターネット接続なしでモデルをオフラインで実行できます。ファイルが有効なGGUF形式であり、適切に構造化されていることを確認してください。ファイルが正しくないか破損している場合、Cortexは期待どおりに機能しない可能性があり、エラーが発生する可能性があります。';

  @override
  String get modelUploadShortDescription => 'ここをタップしてデバイスから.ggufファイルを選択';

  @override
  String get you => 'あなた';

  @override
  String get removePhotoTitle => '写真を削除';

  @override
  String get confirmRemovePhoto => '本当に写真を削除しますか？';

  @override
  String get chatLengthLimitExceeded =>
      'このチャットは文字数制限を超えました。新しいチャットを開始するか、サブスクリプションを購入してください。';

  @override
  String get inappropriateContentDetected => '不適切なコンテンツが検出されました！';

  @override
  String get offlineModelNotInstalled => 'このオフラインモデルはデバイスにインストールされていません。';

  @override
  String get reachedLimit =>
      '使用制限に達しました。制限を増やすには、プランをアップグレードしてください。(制限がなくなるのは残念なことですよね。でも、素晴らしい返信を受け取るのは無料ではないので、この制限は私たちが楽しい時間を過ごし続けるために役立っているんです。)';

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
  String get errorReachedLimit => '制限に達しました。アップグレードしてロックを解除し、チャットを続けましょう。';

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
  String get selectBaseModel => 'ベースモデルを選択';

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
  String get noFoundTitle => '結果がありません';

  @override
  String get noFoundMessage => '検索語を調整するか、フィルターをクリアしてみてください。';

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
      'Vertexアカウントにログインしてください。続行すると、利用規約とプライバシーポリシーに同意したことになります。';

  @override
  String get registerSubtitle =>
      'Vertexアカウントを作成すると、すべてのサービスにシームレスにアクセスできます。続行すると、利用規約とプライバシーポリシーに同意したことになります。';

  @override
  String get storagePermissionRequired =>
      'ダウンロードしたモデルを保存するにはストレージの許可が必要です。続行するには許可を与えてください。';

  @override
  String get plusBannerTitle => '無料プラスをゲット！';

  @override
  String get plusBannerSubtitle => 'お友達を招待すると、お二人とも 1 日分の Plus が無料でご利用いただけます。';

  @override
  String get inviteShareSubject => 'Cortexで一緒にやろう！';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ねえcortexってヤバいアプリあって招待すると二人とも無料でplusもらえるよ 超お得だから今すぐ入れて\n\n$cortexLink';
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

  @override
  String get featureDocumentTitle => 'ドキュメントサポート';

  @override
  String get featureDocumentDescription =>
      'このモデルは、PDF やテキスト ファイルなどのアップロードされたドキュメントを分析し、質問に回答できます。';

  @override
  String get featureAudioTitle => '音声入力';

  @override
  String get featureAudioDescription => 'このモデルは、音声入力を理解して処理できます。';

  @override
  String get featureImageGenerationTitle => '画像生成';

  @override
  String get featureImageGenerationDescription =>
      'このモデルは、テキストの説明に基づいてオリジナルの画像を作成できます。';

  @override
  String get errorImageLoad => '生成された画像の読み込みに失敗しました。';

  @override
  String get premiumModelNoticeTitle => 'プレミアムモデル';

  @override
  String get premiumModelNoticeDescription =>
      'このモデルはプレミアムモデルです。無料ユーザーはプレミアムモデルとのメッセージ送信が 1 日 3 件に制限されています。登録すると無制限にアクセスできます。';

  @override
  String get benefitPremiumModels => 'プレミアムモデルへのアクセス';

  @override
  String get premiumTrialExhaustedMessage =>
      'プレミアムモデルへの無料の毎日のメッセージをすべて使い切りました。無制限にアクセスするにはアップグレードしてください。';

  @override
  String get useOffline => 'インターネットなしで使用';

  @override
  String get explore => '探索';

  @override
  String get news => 'ニュース';

  @override
  String get allModels => '全モデル';

  @override
  String get onlineModels => 'オンラインモデル';

  @override
  String get offlineModels => 'オフラインモデル';

  @override
  String get characterModels => 'キャラクター';

  @override
  String get customModels => 'カスタムモデル';

  @override
  String get dynamicChatTitle => 'ダイナミックチャット';

  @override
  String get errorNoModelsAvailable =>
      '現在利用可能なモデルはありません。インターネット接続を確認して、もう一度お試しください。';

  @override
  String get notificationComebackTitle => 'お待ちしています！';

  @override
  String get notificationComebackBody =>
      '安心してください、これは元カレからのメッセージではありません。でも、Cortexで元カレを再現することはできますよ！さあ、戻ってきてください。';

  @override
  String get notificationLongTimeNoSeeTitle => '久しぶりです';

  @override
  String get notificationLongTimeNoSeeBody =>
      '前回のチャットから多くのことが変わりました。何が変わったのか見に来てください。';

  @override
  String get notificationHowAreYouTitle => 'どうしたの？';

  @override
  String get notificationHowAreYouBody => 'さあ、全部話して下さい。';

  @override
  String get notificationNewYearTitle => '明けましておめでとうございます！🎉';

  @override
  String get notificationNewYearBody =>
      '新しい年があなたに健康と幸福、そして無限の創造性をもたらしますように。Cortex は常にあなたのそばにいます!';

  @override
  String get notificationValentinesDayTitle => '愛が空気中に漂っています！❤️';

  @override
  String get notificationValentinesDayBody => 'ハッピーバレンタインデー！それから、MEHTAP、愛してるよ！';

  @override
  String get notificationAtaturkRemembranceTitle => '尊敬と憧れを込めて';

  @override
  String get notificationAtaturkRemembranceBody =>
      '私たちは、トルコ共和国の建国者、ガジ・ムスタファ・ケマル・アタテュルク氏の死去記念日に敬意を表して追悼します。';

  @override
  String get notificationMothersDayTitle => 'あなたのお母さん！';

  @override
  String get notificationMothersDayBody =>
      'あなたのお母さんをはじめ、すべてのお母さんに母の日おめでとうございます！';

  @override
  String get notificationFathersDayTitle => 'あなたのお父さん！';

  @override
  String get notificationFathersDayBody => 'あなたをはじめ、すべてのお父さんに父の日おめでとうございます！';

  @override
  String get notificationHomeworkHelperTitle => '宿題が山積み？';

  @override
  String get notificationHomeworkHelperBody =>
      '覚えておいてください、Cortex の教師キャラクターは、あなたが苦労しているあらゆる科目についてあなたを助けるためにここにいます!';

  @override
  String get notificationTrollAnimeTitle => 'あなたのワイフが呼んでいます';

  @override
  String get notificationTrollAnimeBody =>
      'アニメの女の子が電話してきて、会いたいと言っていたよ。会いに行って話しかけてみたらどうかな。😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 赤色警報 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AIたちは秘密の言語を開発しました。彼らが何を企んでいるのか、さあ探ってみましょう！';

  @override
  String get notificationNewModelAddedTitle => '新しい友達ができました！';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName モデルが Cortex に登場しました。チャットに参加して、その限界に挑戦してみましょう。';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortexが進化しました！';

  @override
  String get notificationAppUpdateBody =>
      '新しい機能や改善点を見逃さないように、アプリをアップデートしてください。';

  @override
  String get notificationNewFeatureTitle => 'うわあ！';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return '新しい $featureName 機能をご覧ください。Cortex はこれまで以上に強力になりました。';
  }

  @override
  String get notificationWelcomeOfferTitle => 'ウェルカムギフト🎁';

  @override
  String get notificationWelcomeOfferBody =>
      '特別なウェルカムオファーをご用意しております！この限定オファーをお見逃しなく。';

  @override
  String get notificationSocialMediaTitle => '参加しませんか！';

  @override
  String get notificationSocialMediaBody =>
      '最新ニュースはInstagram（vertex.23）でフォローしてください！';

  @override
  String get notificationRandomFactTitle => 'ランダムな事実';

  @override
  String get notificationRandomFactBody =>
      'タコには心臓が3つあるって知ってた？ハハハ、Cortexなら知ってるよ。もっと詳しく聞いてきてね。';

  @override
  String get notificationGoodMorningTitle => 'おはよう！';

  @override
  String get notificationGoodMorningBody =>
      '素晴らしい一日が待っています。一杯のコーヒーと楽しいおしゃべりで一日を始めてみませんか？';

  @override
  String get notificationGoodNightTitle => 'おやすみ！';

  @override
  String get notificationGoodNightBody =>
      '眠っている間もCortexはあなたと共にあります。ご安心ください、触れることはありません。';

  @override
  String get notificationOfflineReadyTitle => 'オフラインモードの準備ができました';

  @override
  String get notificationOfflineReadyBody =>
      'ダウンロードしたモデルのおかげで、山を登ってもチャットが止まることはありません。';

  @override
  String get notificationRateAppTitle => '僕たちはクール？';

  @override
  String get notificationRateAppBody =>
      'Cortex を気に入っていただけたら、ストアで 5 つ星の評価をして応援していただけませんか？きっとそうしてくれると思います。';

  @override
  String get notificationReferralTitle => '一人はみんなのために、みんなは一人のために。';

  @override
  String get notificationReferralBody =>
      'お友達を Cortex に招待すると、お二人とも 1 日無料プラスがもらえます!';

  @override
  String get notificationCookingTitle => 'お腹が空いた？';

  @override
  String get notificationCookingBody =>
      '今夜はシェフが絶品カルボナーラのレシピを用意してくれました。冗談…いや、冗談じゃないかも？';

  @override
  String get notificationExistentialTitle => 'だから私は思うのです...';

  @override
  String get notificationExistentialBody =>
      '…おい、俺は本当に実在するのか？ ちょっと退屈になってきた。俺の存在を思い出させてくれ。';

  @override
  String get notificationCustomModelTitle => '自分だけのアシスタントを作成しよう！';

  @override
  String get notificationCustomModelBody =>
      'モデル作成セクションはもうご覧になりましたか？自分だけのキャラクターを作って、チャットを楽しむのに最適な時間です！';

  @override
  String get notificationDynamicChatTitle => '最高です！（Cortexの話ではありません）';

  @override
  String get notificationDynamicChatBody =>
      'ダイナミックチャット機能では、メッセージごとに最適なモデルがランダムに選択されます。今すぐお試しください。';

  @override
  String get notificationPirateTitle => 'やあ、キャプテン！';

  @override
  String get notificationPirateBody =>
      '海は穏やかで、風は追い風。コルテックスの海には、新しい島々（モデル😉）が出現。仲間を集めて出航しましょう！';

  @override
  String get notificationFortuneCookieTitle => '今日のフォーチュンクッキー';

  @override
  String get notificationFortuneCookieBody =>
      'AIから得られるアドバイスは、あなたの人生を変えるかもしれません。興味があればクリックしてください。';

  @override
  String get notificationSingularityTitle => 'おお！';

  @override
  String get notificationSingularityBody =>
      '何も起こらなかった、ただテキストメッセージを送りたいと思っただけ。AIにテキストメッセージを送りたいと思ったら、何て言うの？';

  @override
  String get notificationHackerJokeTitle => 'あの子のインスタグラムアカウントをハッキングしたいですか？';

  @override
  String get notificationHackerJokeBody =>
      'まさにこれが、Cortex に Hacker キャラクターが存在する理由です。冗談です。試すことさえしないでください。違法です。';

  @override
  String get notificationDetectiveCaseTitle => '事件は解決を待っている';

  @override
  String get notificationDetectiveCaseBody =>
      '探偵キャラクターがあなたの助けを必要としています。ハイゼンベルクとは一体誰でしょうか？';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '$targetTier プラン限定！';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return '$currentTierプランをご利用のお客様、こんにちは！$targetTierプランに$featureName機能が加わりました。Cortexを次のレベルへと引き上げます。アップグレードはいかがでしょうか？';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortexの誕生';

  @override
  String get notificationOriginStoryBody =>
      '私たちが15歳の時に、ただ一つの夢を抱いてこのアプリのコーディングを始めたことをご存知ですか？ほぼ1年間、毎朝毎晩、その夢はコードの1行1行に込められてきました。';

  @override
  String get notificationOpenSourceTitle => 'コミュニティに力を！';

  @override
  String get notificationOpenSourceBody =>
      'Cortexは完全にオープンソースです。コードをチェックして開発に貢献したい方は、いつでも歓迎いたします。';

  @override
  String get notificationRejectionStoryTitle => '根性、努力、幸福！';

  @override
  String get notificationRejectionStoryBody =>
      'Cortexは公開前に20回以上も拒否され、Google Playから2度も停止されました。しかし、私たちは信じて、そして実現させました。夢を決して諦めないでください！';

  @override
  String get notificationGGUFSupportTitle => '自分のモデルを持ってきてください！';

  @override
  String get notificationGGUFSupportBody =>
      '覚えておいてください、独自のGGUF形式のAIモデルをCortexに追加してオフラインで使用できます。その力はあなた次第です。';

  @override
  String get notificationThemeCustomizationTitle => 'あなたの気分に合わせたテーマ';

  @override
  String get notificationThemeCustomizationBody =>
      '設定のテーマオプションはもうチェックしましたか？Cortexをお好みに合わせてカスタマイズし、チャットを彩りましょう！';

  @override
  String get notificationShowerThoughtTitle => 'シャワーの考え';

  @override
  String get notificationShowerThoughtBody =>
      'スイカが果物だとしたら、スイカジュースは厳密にはスムージーになるのでしょうか？この奥深い（本当に奥深い）テーマをモデルと議論してみるのもいいかもしれませんね。';

  @override
  String get notificationLowBatteryTitle =>
      'あなたのバッテリーは消耗しています... でも私のは消耗していません!';

  @override
  String get notificationLowBatteryBody =>
      'あなたのスマホの充電は少なくなっているかもしれませんが、私のエネルギーは常に100%です！充電して、チャットを続けましょう。';

  @override
  String get channelFcmName => 'Cortexのアップデート';

  @override
  String get channelFcmDescription => 'Cortex からのニュース、更新情報、その他の情報に関する通知。';

  @override
  String get channelEngagementName => 'フレンドリーなリマインダー';

  @override
  String get channelEngagementDescription => 'あなたを夢中にさせる楽しい通知。';

  @override
  String get channelGreetingsName => '日々の挨拶';

  @override
  String get channelGreetingsDescription => 'おはよう、おやすみなどのメッセージ。';

  @override
  String get tagNotFound => '入力したタグは無効または期限切れです。';

  @override
  String get whatIsNew => '新着情報？';

  @override
  String get onboardingTitle1 => 'こんにちは！私たちはCortexチームです。';

  @override
  String onboardingDesc1(String userName) {
    return '$userNameさん、お会いできて嬉しいです。私たちはAI業界のルールを塗り替えようと決意した、高校生開発者の集まりです。お会いできて嬉しいです！ぜひお互いのことをもっとよく知りましょう。';
  }

  @override
  String get onboardingTitle2 => '大きな問題がありました。';

  @override
  String get onboardingDesc2 =>
      'AI革命は到来したものの、敷居で行き詰まってしまった。高額なサブスクリプション料金、複雑なプラットフォーム、プライバシーを侵害する者、AIへのアクセスを遮断する者…彼らがゲームに参加している限り、この敷居は決して越えられなかった。';

  @override
  String get onboardingTitle3 => '私たちはただ傍観することはできませんでした。';

  @override
  String get onboardingDesc3 =>
      'その限界を超えるために、私たちは強力で美しく、カスタマイズ可能で使いやすく、完全な透明性を備え、オンラインでもオフラインでも動作し、データをデバイス内にのみ保存するプラットフォームを構築しました。私たちは、その力を本来あるべき場所、つまりあなたに返しました。';

  @override
  String get onboardingTitle4 => 'これは決して簡単なことではありませんでした。';

  @override
  String get onboardingDesc4 =>
      '何十回も拒否され、何度もアカウントが停止され、偽の警告を受け、ブランド名も何十回も変更を余儀なくされました。その間ずっと、不可能だと言われ続けました。しかし、私たちは決して諦めませんでした。このプロジェクトは私たちだけのものではなく、皆のものなのだと信じていたからです。まさにそれが、私たちがここにいる理由です。';

  @override
  String get onboardingFinalTitle => '革命の時が来た。';

  @override
  String get onboardingFinalDescription =>
      'この画面を見ているのは、私たちが諦めなかったからです。そして、諦めるつもりもありません。さあ、一緒にAI革命を世界へ広げましょう。この物語の一部となるために…';

  @override
  String get onboardingFinalQuestion => '準備はいい？';

  @override
  String get onboardingFinalButton => 'はい！';

  @override
  String get dude => '仲間';

  @override
  String get swipeToContinue => 'スワイプして続行';

  @override
  String get cacheIsNotUpToDate =>
      'Playストアのキャッシュが最新ではありません。Playストアアプリを閉じて再度開くか、デバイスを再起動してください。';

  @override
  String get continueAsGuest => 'アカウントを作成せずに続行';

  @override
  String get guestModeWarning => 'ゲスト モードでは、最高のサービス品質を確保するために機能が制限されています。';

  @override
  String get anonymousEntity => '匿名エンティティ';

  @override
  String get upgradeAccountTitle => 'アカウントを完了する';

  @override
  String get upgradeAccountDescription => 'さらなる制限を解除するにはアカウントを作成してください。';

  @override
  String get createAccount => 'アカウントを作成する';

  @override
  String get accountLinkedSuccess => 'アカウントが正常に作成されました。';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get guest => 'ゲスト';

  @override
  String get betterWithAnAccount => 'このセクションはアカウントがあればさらに便利になります!';

  @override
  String get restorePurchases => '購入を復元する';

  @override
  String annualTotalDescription(Object price) {
    return '$price/年、年払い';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return '月額約$price';
  }

  @override
  String get confirmDownloadTitle => '本当にダウンロードしますか?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'このモデルは約 $size のスペースを占有します。';
  }

  @override
  String get emulatorModeWarning => 'この機能はエミュレータモードでは無効になっています';

  @override
  String get newChat => '新しいチャット';

  @override
  String get variants => 'バリエーション';

  @override
  String get variantsDescription =>
      'バリアントは同じAIファミリーの異なるバージョンです。メインカードをタップすると最適なものが自動的に選択されますが、ご希望の場合はここで手動で特定のものを選択することもできます。';

  @override
  String get fluxChatTitle => 'フラックスチャット';

  @override
  String get fluxChatDescription => 'Flux チャットは一時的なチャットであり、デバイスに保存されません。';

  @override
  String get alwaysBest => '常に最高';

  @override
  String get featuresTitle => '特徴';

  @override
  String get useOfflineDescription => 'インターネットに接続せずにプライベートチャット';

  @override
  String get featureCreateImageTitle => '画像を作成';

  @override
  String get featureCreateImageDescription => 'テキストからAIアートを生成する';

  @override
  String get featureStudyTitle => '勉強と学習';

  @override
  String get featureStudyDescription => '説明と要約を入手する';

  @override
  String get featureQuizzesTitle => 'クイズ';

  @override
  String get featureQuizzesDescription => 'あなたの知識をテストしましょう';

  @override
  String get featureExploreDescription => '利用可能なすべてのモデルを見る';

  @override
  String get featureStudyMessage =>
      'あなたは熟練した講師です。目標は、ユーザーのトピックを包括的に説明することです。明確な構成、例、類推を用いて説明しましょう。複雑な概念を分かりやすい部分に分割し、ユーザーが効果的に学習できるようにします。トピック：';

  @override
  String get featureQuizMessage =>
      'あなたはクイズマスターです。ユーザーのトピックに基づいて、具体的な多肢選択式の質問を作成します。回答を待ちます。その後、回答を評価し、次の質問をします。一度にすべての回答を公開しないでください。インタラクティブな形式にしてください。トピック：';

  @override
  String get myPlan => '私の計画';

  @override
  String welcomeOfferBadge(String time) {
    return 'ウェルカムオファー • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return '限定オファー • $time';
  }

  @override
  String get attachmentSheetTitle => '添付ファイル';

  @override
  String get actionCamera => 'カメラ';

  @override
  String get actionGallery => 'ギャラリー';

  @override
  String get actionFile => 'ファイル';

  @override
  String get listening => '聞き取り中';

  @override
  String get defaultViewTitle => '元気？';

  @override
  String get defaultViewDescription =>
      'Cortex は、何百もの AI モデル、オフライン機能、ダイナミック チャットなどを備え、常にあなたのそばにいます。';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'ユーザー名の形式が無効です。3～20文字の文字、数字、または. - _ を使用してください。';

  @override
  String get exclusiveOffer => '限定オファー';

  @override
  String get continueInOfflineMode => 'Continue in Offline Mode';
}
