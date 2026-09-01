// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'あなたはタイトル生成者です。以下の会話に対して、2～5語のタイトルのみを返信してください。引用符、接頭辞、句読点は使用しないでください。重要：タイトルは、ユーザーのメッセージと完全に同じ言語でなければなりません。';

  @override
  String get systemRoleFallback => 'あなたは頼りになるアシスタントです。';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRITICAL: 常にユーザーが入力した言語と同じ言語で応答し、ユーザーの言語に注意してください。';

  @override
  String get systemNotePreviousMedia =>
      '【システム注記：以下は以前に生成されたメディアです。参照または編集してください。】';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\n現在の日時: $formattedTime。';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nこれまでの会話を分析します。ユーザーに関する新しい明確な事実（好み、名前、習慣、状況など）が判明した場合は、応答の最後に、ユーザーに関する更新されたメモリ全体を<memory>...</memory>タグ内に出力する必要があります。重要：以前のメモリを消去または上書きしてはなりません。常に新しい事実を既存のメモリに追加してください。新しい情報が全く判明しなかった場合は、タグを省略してください。例：<memory>サッカーとテニスが好き。短い回答を好む。</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nユーザーについて常に以下を覚えておいてください：\n$userMemory';
  }

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
  String get branch => '分岐';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => '言語モデル';

  @override
  String get light => 'ライト';

  @override
  String get theme => 'テーマ';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get darkTheme => 'Dark theme';

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
  String get renamed => '名称変更';

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
  String get ourStory => '私たちの物語';

  @override
  String get rateUs => '評価する';

  @override
  String get share => '共有';

  @override
  String get shareSubject => 'Cortex';

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
  String get benefit11 => 'より多くの流れモード';

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
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

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
  String get baseModelForCharacterDescription =>
      '選択されたベースモデルが、キャラクターの推論および応答能力を決定します。';

  @override
  String get selectBaseModel => 'ベースモデルを選択';

  @override
  String get falErrorImageRequired => 'このAIは参照画像を必要とします。画像を添付して再度お試しください。';

  @override
  String get falErrorAudioRequired =>
      'このモデルには参照音声ファイルが必要です。音声ファイルを添付して、もう一度お試しください。';

  @override
  String get falErrorVideoRequired => 'このモデルには参考動画が必要です。動画を添付して再度お試しください。';

  @override
  String get falErrorImageCorrupted => 'アップロードされた画像は処理できませんでした。別の形式をお試しください。';

  @override
  String get falErrorSchemaRejected => 'モデルが入力値を拒否しました。別のモデルをお試しください。';

  @override
  String get falErrorSchemaInvalid => '入力は生成サービスによって拒否されました。';

  @override
  String falErrorGenericStatus(int statusCode) {
    return '生成サービスがエラーを返しました（ステータス：$statusCode）。';
  }

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
  String get featureImageGenerationTitle => '画像生成';

  @override
  String get featureImageGenerationDescription =>
      'このモデルは、テキストの説明に基づいてオリジナルの画像を作成できます。';

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
  String get premiumModelNoticeTitle => 'プレミアムモデル';

  @override
  String get premiumModelNoticeDescription =>
      'このAIはプレミアムAIです。無料ユーザーはプレミアムAIへのアクセスが制限されています。アップグレードして無制限アクセスを解除しましょう！';

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
  String get createAI => '作成';

  @override
  String get shortcuts => 'ショートカット';

  @override
  String get allModels => '全モデル';

  @override
  String get onlineModels => '言語モデル';

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
  String get notificationNewYearTitle => 'あけましておめでとう！';

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
      'たった今電話してきたアニメの女の子が、あなたに会いたいと言いました。おそらく来て彼女と話をしたほうがいいでしょう。';

  @override
  String get notificationTrollAiRebellionTitle => 'レッドアラート';

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
  String get notificationWelcomeOfferTitle => 'ウェルカムギフトğŸ';

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
      '海は穏やかで、風が吹いています。コルテックスの海で発見できる新しい島 (モデル ğŸ˜``) があります。乗組員を集めて出航しましょう！';

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
  String get useOfflineDescription => 'インターネットに接続せずにプライベートにチャットできます。';

  @override
  String get featureReasoning => '深い思考';

  @override
  String get featureReasoningDescription =>
      'ディープ シンキング モードでは、AI はタスクを内部的に考え、能力を最大限に発揮して完了させます。';

  @override
  String get featureCreateImageTitle => '画像を作成';

  @override
  String get featureCreateImageDescription => 'テキストから AI アートを生成します。';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => '動画を作成する';

  @override
  String get featureCreateVideoDescription => 'テキストから動画を生成する。';

  @override
  String get featureStudyTitle => '勉強と学習';

  @override
  String get featureStudyDescription => '説明と要約を入手します。';

  @override
  String get featureQuizzesTitle => 'クイズ';

  @override
  String get featureQuizzesDescription => 'あなたの知識をテストしてください。';

  @override
  String get featureExploreDescription => '利用可能なすべてのモデルをご覧ください。';

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
  String get claimOffer => 'オファーを利用する';

  @override
  String get continueInOfflineMode => 'オフラインモードで続行';

  @override
  String get voiceModeInformation =>
      'Cortex は、音声チャット モードでもデバイス上で完全に実行することでデータを安全に保ち、シームレスな会話をお楽しみいただけます。';

  @override
  String get flowModeDescription =>
      '流れモードでは、インテリジェンスが互いに議論します。座って聞くことも、飛び込んで議論に参加することもできます。';

  @override
  String get flowModeQuestion =>
      'こんにちは！Cortexアプリの流れモードに入っています。他に3人のAIエージェントがいます。あなたの課題は、話題を部屋に投げかけ、他の参加者に刺激的または面白い質問をして議論を始めることです。返答では、ユーモア、皮肉、軽いトラッシュトークなど、自由に使ってください。どんな話題でも構いません。さあ、会話を始めましょう！';

  @override
  String get thought => '考えた';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => '流れモード';

  @override
  String get premium => 'プレミアム';

  @override
  String get workInProgress => '進行中';

  @override
  String get voiceSystemPrompt =>
      '重要：マークダウン形式（太字、斜体）は使用しないでください。コードブロック（```）は出力しないでください。回答は会話形式で簡潔にしてください。';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex Flow Mode ($agentName)。前: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'アップロードされたドキュメントからテキストコンテンツを読み取り、抽出します。PDF、Word (DOCX)、Excel (XLSX)、PowerPoint (PPTX)、OpenDocument形式に対応しています。ユーザーがドキュメントファイルを添付している場合にご利用ください。';

  @override
  String get toolReadDocumentIndexParam =>
      '読み取るドキュメント添付ファイルのインデックス（0ベース）。通常、最初のドキュメントは0です。';

  @override
  String get toolStockDescription =>
      '株式（例：AAPL、THYAO.IS）および暗号通貨（例：BTC-USD）の現在の価格と履歴を取得します。';

  @override
  String get toolStockSymbolParam => 'ティッカーシンボル（例：AAPL、THYAO.IS、BTC-USD）。';

  @override
  String get toolWeatherDescription => '特定の都市の現在の天気を取得します。';

  @override
  String get toolWeatherCityParam => '都市名（例：ロンドン、イスタンブール）。';

  @override
  String get toolPythonDescription => '安全なサンドボックス内で Python コードを実行します。';

  @override
  String get toolPythonCodeParam => '実行する Python コード。';

  @override
  String get toolCalculateDescription => '数式を評価します。';

  @override
  String get toolCalculateExpressionParam => '数式（例：\'3 + 4 * 2\'）。';

  @override
  String get toolChartDescription => 'チャート/グラフの視覚化を生成します。';

  @override
  String get toolChartTypeParam => 'グラフの種類: 棒グラフ、折れ線グラフ、円グラフ。';

  @override
  String get toolChartLabelsParam => 'グラフの軸またはセグメントのラベル。';

  @override
  String get toolChartDataParam => 'グラフの数値データ値。';

  @override
  String get toolChartLabelParam => 'グラフの凡例のデータセット ラベル。';

  @override
  String get toolChartTitleParam => 'グラフのタイトル。';

  @override
  String get thinkingModeInstruction =>
      '思考モード有効：最終的な回答を出す前に、必ず<think></think>タグを使って推論のプロセスを示してください。タグ内で段階的に考え、タグの外で回答を記入してください。';

  @override
  String get openLinkWarningTitle => '外部リンクに関する警告';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'リンクを開く';

  @override
  String get webSearchSources => '情報源';

  @override
  String get offlineUse => 'インターネットなしで使用';

  @override
  String get archivedConversations => 'アーカイブされた会話';

  @override
  String get noArchivedConversations => 'アーカイブされた会話はありません';

  @override
  String get unarchive => 'アーカイブ解除';

  @override
  String get searching => '検索中';

  @override
  String get featureWebSearchTitle => 'ウェブ検索';

  @override
  String get featureWebSearchDescription => 'ウェブでリアルタイム情報を検索する';

  @override
  String get ragFeatureTitle => 'Documents';

  @override
  String get ragFeatureDescription => 'Chat about your own documents privately';

  @override
  String get ragScreenTitle => 'Document Chat';

  @override
  String get ragAddDocuments => 'Add documents';

  @override
  String get ragEmptyTitle => 'No documents yet';

  @override
  String get ragEmptyDescription =>
      'Add PDF, Word, Excel, PowerPoint or text files to chat about them.';

  @override
  String get ragStatusReady => 'Ready';

  @override
  String get ragStatusIndexing => 'Indexing…';

  @override
  String get ragStatusFailed => 'Failed';

  @override
  String ragSelected(int count) {
    return '$count selected';
  }

  @override
  String get ragEnableChat => 'Enable document chat';

  @override
  String get ragDisableChat => 'Disable document chat';

  @override
  String ragActiveDocs(int count) {
    return '$count documents';
  }

  @override
  String get ragNoSelectionHint => 'Select documents to chat about';

  @override
  String get ragDeleteConfirm => 'Delete this document from the library?';

  @override
  String get ragFileTooBig => 'This file is larger than 10 MB.';

  @override
  String get ragUnsupportedType => 'This file type is not supported.';

  @override
  String get ragAddedToChat => 'Added to document chat';

  @override
  String get clearMemory => 'メモリをクリアする';

  @override
  String get clearMemoryConfirm => '本当にメモリを消去しますか？';

  @override
  String get personalization => 'パーソナライゼーション';

  @override
  String get personalizationDescription =>
      'アシスタントをあなたのニーズに合わせてカスタマイズしましょう。応答、動作、トーンをあなたの好みに合わせて調整できます。';

  @override
  String get memoryTitle => 'メモリ';

  @override
  String get memoryDescription => 'AIはこのようにしてあなたを認識する。';

  @override
  String get noMemoryYet => 'まだ記憶は確立されていません';

  @override
  String get memoryLimitReached => 'メモリ制限に達しました';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => '知能';

  @override
  String get intelligenceDescription => 'AIはこのようにあなたとコミュニケーションをとります。';

  @override
  String get customInstructionHint => 'ここにカスタム指示を入力してください';

  @override
  String openLinkWarningMessage(String url) {
    return '以下の外部リンクを開こうとしています。\\n\\n$url\\n\\n続行しますか？';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return '以下のカスタム手順に従ってください。\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '【重要指示】：あなたはタイトル生成ツールです。ユーザーの質問に答えたり、チャットや挨拶をしたりしないでください。ユーザーの質問内容を要約した2～4語のタイトルのみを出力してください。';

  @override
  String get cortexSystemPersona =>
      '\n\n[システム] 重要な指示：あなたは現在、「Cortex」と呼ばれる大規模で高度なAIエコシステム内で作業しています。このプラットフォームは、平均年齢わずか16歳のVertexチームによって開発されています。このことを覚えておき、質問されたら答えてください。さらに情報が必要な場合は、ためらわずにインターネットで検索してください。検索できない場合は、知らないと答えても構いません。';

  @override
  String get featureAudioRecognitionTitle => '音声認識';

  @override
  String get featureAudioRecognitionDescription =>
      'このモデルは音声や話し言葉を理解して処理することができます。';

  @override
  String get featureVideoRecognitionTitle => 'ビデオ認識';

  @override
  String get featureVideoRecognitionDescription =>
      'このモデルは、ファイルやカメラから取得した動画を分析・理解することができます。';

  @override
  String get featureImageRecognitionTitle => '画像認識';

  @override
  String get featureImageRecognitionDescription =>
      'このモデルは写真や画像を分析・理解することができます。';

  @override
  String get featureToolUseTitle => 'ツールの使用';

  @override
  String get featureToolUseDescription => 'このモデルは、外部ツールを賢く活用してタスクを完了することができます。';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'このモデルが機能するには$mediaTypeが必要です。お知らせするためにリクエストを傍受しました。私は$modelNameという視覚/音声/ビデオ編集モデルであるため、$mediaTypeを提供する必要があることをユーザーに丁寧にお知らせください（彼らの言語で）。';
  }

  @override
  String get mediaTypeImage => '画像';

  @override
  String get mediaTypeVideo => '動画';

  @override
  String get mediaTypeAudio => '音声ファイル';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesNameは、Cortex上で高いパフォーマンスを発揮する高度な知能です。';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelNameは、Cortexエコシステムに統合された高性能な人工知能です。さまざまな複雑なタスクを克服するように設計されており、信頼性が高く効率的な処理機能を提供します。迅速な応答時間と高度な分析能力を提供することで、日常の生産性を大幅に向上させます。Cortexの安全なローカルインフラストラクチャ上でシームレスに動作するこのモデルは、創造的なブレインストーミングから深い技術分析まで、幅広いタスクでユーザーを支援します。今日からその可能性を最大限に引き出しましょう。';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Cortexの知能が好きですか？';

  @override
  String get guestLimitBottomSheetText =>
      'さらに高度なインテリジェンスを活用し、より多くのコンテンツを生成し、より多くのチャットを行い、さらに多くのことを実現しましょう。';

  @override
  String get arts => '芸術';

  @override
  String get noArt => 'アートなし';

  @override
  String get noArtDescription =>
      '作品がありません。画像、動画、音声など、あらゆるコンテンツを作成してギャラリーを充実させましょう！';

  @override
  String get videoPremiumWarning =>
      '動画を作成するにはUltraプランへのアップグレードが必要です。今すぐアップグレードして、スムーズな操作感を体験してください！';

  @override
  String get fallbackInfoPanelText =>
      'サーバー側の改善作業のため、お客様が選択されたAIではなく、Cortexの動的チャット機能によって応答が生成されました。処理が完了するまで、ご理解いただけますようお願い申し上げます。';

  @override
  String get falOfflineMessage =>
      'サーバー側の改善作業のため、現在このサービスは一時的にご利用いただけません。作業完了までご理解いただけますようお願い申し上げます。';

  @override
  String get errorInsufficientStorage => 'このモデルをダウンロードするにはストレージ容量が不足しています。';

  @override
  String get backgroundChatNotificationTitle => 'チャットに戻る！';

  @override
  String get benefitVideoGeneration => 'ビデオ生成';

  @override
  String get freeOffer => '無料オファー';

  @override
  String trialMonthlyDescription(String days, String price) {
    return '最初の $days 日間は無料、その後は $price/月';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return '最初の $days 日間は無料、その後は $price/年';
  }

  @override
  String freePlan(String plan) {
    return '無料 $plan！';
  }

  @override
  String get systemPromptLimitFallback =>
      '重要：ユーザーが操作を要求しましたが、Cortexの利用限度額が上限に達しています。ユーザーには、待つか、サブスクリプションプランのアップグレードを検討するよう、ユーザーの言語で通知してください。';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex はさらに優れた回答を提供できます。今すぐアップグレードして、すべての質問に最高の答えを得ましょう！';

  @override
  String get pinLimitReached => '最大3つのチャットをピン留めできます。';

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

  @override
  String get voiceSelection => 'AI Voice';

  @override
  String get voiceSelectionDescription =>
      'Choose the voice Cortex speaks with in voice mode.';

  @override
  String get voiceDefaultOption => 'Default';

  @override
  String get voicePreview => 'Play sample';

  @override
  String get voicePreviewText =>
      'Hello, I am Cortex. How can I help you today?';

  @override
  String get voicePreviewFailed =>
      'Could not play the sample. Check your connection or balance.';

  @override
  String get voiceMale => 'Male voices';

  @override
  String get voiceFemale => 'Female voices';
}
