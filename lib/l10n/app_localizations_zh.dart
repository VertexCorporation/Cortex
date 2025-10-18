// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get understood => '已了解。';

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get download => '下载';

  @override
  String get resume => '恢复';

  @override
  String get copy => '复制';

  @override
  String get chat => '聊天';

  @override
  String get darkMode => '深色模式';

  @override
  String get light => '浅色';

  @override
  String get theme => '主题';

  @override
  String get no => '否';

  @override
  String get yes => '是';

  @override
  String get done => '完成';

  @override
  String get comingSoon => '即将推出';

  @override
  String get bestValue => '最超值';

  @override
  String get selected => '已选择';

  @override
  String get descriptionSection => '描述';

  @override
  String get searchHint => '搜索';

  @override
  String get messageHint => '随便问点什么';

  @override
  String get modelLoading => '模型加载中...';

  @override
  String get messageCopied => '消息已复制到剪贴板。';

  @override
  String get storeUnavailable => '商店当前不可用。请稍后再试';

  @override
  String get retry => '重试';

  @override
  String get systemInfo => '系统信息';

  @override
  String deviceMemory(Object memory) {
    return '设备内存: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return '存储空间: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return '可用存储空间: $freeStorage GB';
  }

  @override
  String get memory => '内存';

  @override
  String get storage => '存储';

  @override
  String get freeStorage => '可用存储';

  @override
  String get totalStorage => '总存储';

  @override
  String get usedStorage => '已用存储';

  @override
  String get totalMemory => '总内存';

  @override
  String get usedMemory => '已用内存';

  @override
  String get requirements => '要求';

  @override
  String get modelsTitle => '库';

  @override
  String get localModels => '本地模型';

  @override
  String get serverSideModels => '在线模型';

  @override
  String get uploadYourOwnModel => '上传您自己的模型！';

  @override
  String get selectGGUFFile => '选择 GGUF 文件';

  @override
  String get errorGGUF => '请仅选择 GGUF 格式的文件。';

  @override
  String get modelAlreadyExists => '模型已存在。';

  @override
  String get modelAddedSuccessfully => '模型添加成功。';

  @override
  String get modelRemoved => '模型移除成功。';

  @override
  String get removeError => '移除模型时出错。';

  @override
  String get fileNotFound => '文件未找到。';

  @override
  String get fileUploadError => '上传文件时出错。';

  @override
  String get noFileSelected => '未选择文件。';

  @override
  String get myModels => '我的模型';

  @override
  String get create => '创建';

  @override
  String get seeAll => '查看全部';

  @override
  String modelProducer(Object producer) {
    return '开发者: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return '内存: $ram';
  }

  @override
  String modelSize(Object size) {
    return '大小: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => '对话';

  @override
  String get conversationDeleted => '对话已删除。';

  @override
  String get conversationUpdated => '对话已更新。';

  @override
  String get editConversationTitle => '重命名';

  @override
  String get newTitle => '新标题';

  @override
  String get save => '保存';

  @override
  String get titleCannotBeEmpty => '标题不能为空。';

  @override
  String get noConversationsMessage => '没有对话，开始聊天吧！';

  @override
  String get startChat => '开始聊天';

  @override
  String get noChats => '无聊天';

  @override
  String get starredChats => '已收藏的聊天';

  @override
  String get allChats => '所有聊天';

  @override
  String get noStarredChats => '无已收藏的聊天';

  @override
  String get noStarredChatsMessage => '您还没有收藏任何聊天。';

  @override
  String get goToChats => '收藏一个聊天';

  @override
  String get starConversation => '收藏';

  @override
  String get conversationTitleUpdated => '对话标题已更新';

  @override
  String get youReachedConversationLimit => '您已达到对话数量上限。';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get loginToYourAccount => '登录';

  @override
  String get createYourAccount => '注册';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get invalidEmail => '请输入有效的邮箱地址。';

  @override
  String get invalidPassword => '密码长度至少为6个字符。';

  @override
  String get rememberMe => '记住我';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get or => '或';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get dontHaveAccount => '还没有账户？';

  @override
  String get alreadyHaveAccount => '已经有账户了？';

  @override
  String get signUp => '注册';

  @override
  String get logIn => '登录';

  @override
  String get passwordsDoNotMatch => '密码不匹配。';

  @override
  String get userNotFound => '用户未找到。';

  @override
  String get wrongPassword => '密码不正确。';

  @override
  String get emailAlreadyInUse => '此邮箱已被使用。';

  @override
  String get weakPassword => '密码太弱。';

  @override
  String get authError => '认证错误';

  @override
  String get invalidUsername => '请输入用户名。';

  @override
  String get usernameTaken => '此用户名已被占用。';

  @override
  String get username => '用户名';

  @override
  String get authenticationFailed => '认证失败。请重试。';

  @override
  String get emailTooLong => '邮箱最多可包含30个字符。';

  @override
  String get deviceLimitReached => '您已达到此设备的账户创建上限。';

  @override
  String get verificationEmailLimitReached => '我们不会再发送邮件';

  @override
  String get verificationEmailSent => '验证邮件已发送！';

  @override
  String get emailNotVerified => '邮箱尚未验证';

  @override
  String get resendCode => '重新发送验证邮件';

  @override
  String get remainingSeconds => '剩余验证时间';

  @override
  String get pleaseCheckYourEmail =>
      '为了使用 Cortex，您需要验证您的邮箱。\n验证链接已发送到您的邮箱地址，请检查您的邮箱。';

  @override
  String get verifyYourEmail => '验证您的邮箱';

  @override
  String get backToLogin => '返回';

  @override
  String get seconds => '秒';

  @override
  String get maxResendLimitReached => '您已达到验证邮件发送次数上限';

  @override
  String get verificationScreenContinueWithoutVerification => '不验证并继续';

  @override
  String get verificationScreenWarning =>
      '即使您继续，您的账户仍有1天的验证期。如果届时您仍未验证账户，该账户将被从应用中删除。';

  @override
  String get unverifiedAccountHeader => '您的账户尚未验证';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return '如果您未在$timeLeft内验证您的账户，它将被删除';
  }

  @override
  String get verifyNow => '立即验证';

  @override
  String get accountVerified => '您的账户已验证。';

  @override
  String get linkSent => '链接已发送';

  @override
  String get accountDeletionRequested => '您的帐户删除请求已收到，您的帐户现已被禁用。';

  @override
  String get tooManyRequests => '请求过于频繁';

  @override
  String get regenerate => '重新生成';

  @override
  String get confirmDeleteAccount => '您确定要删除您的账户吗？';

  @override
  String get enterPasswordToDelete => '输入您的密码以删除。';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountError => '删除账户时出错。';

  @override
  String get delete => '删除';

  @override
  String get passwordRequired => '需要密码。';

  @override
  String get deleteDescription => '您删除的数据将从我们的服务器和您的设备中永久移除。此操作无法撤销。';

  @override
  String get deleteAccountButton => '账户删除按钮';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get displayName => '显示名称';

  @override
  String get tapToChangeProfilePicture => '点击更换头像';

  @override
  String get profileUpdated => '个人资料更新成功';

  @override
  String get updateFailed => '更新个人资料失败';

  @override
  String get nameCannotBeEmpty => '名称不能为空';

  @override
  String get logout => '登出';

  @override
  String get noDisplayName => '未设置显示名称';

  @override
  String get noEmail => '无邮箱地址';

  @override
  String get noUserLoggedIn => '当前无用户登录';

  @override
  String get profile => '个人资料';

  @override
  String get manageProfileDescription => '管理您的个人资料，更新密码，或从 Cortex 登出。';

  @override
  String get accessSettingsDescription => '获取帮助，兑换代码，分享 Cortex，以及查看我们的政策。';

  @override
  String get languageDescription => '您可以随时更改您的默认应用界面语言。';

  @override
  String get themeDescription => '您可以根据偏好在浅色和深色主题之间切换。所选主题将应用于整个 Cortex 界面。';

  @override
  String get iHaveReadAndAgree => '我已阅读并同意服务条款';

  @override
  String get downloading => '下载中...';

  @override
  String get downloadError => '下载过程中出错。';

  @override
  String get downloadCancelled => '下载已取消。';

  @override
  String get downloadResumed => '下载已恢复。';

  @override
  String get downloadSuccess => '下载成功';

  @override
  String get downloadFailed => '下载失败';

  @override
  String downloaded(Object percent) {
    return '已下载 $percent%';
  }

  @override
  String get downloadPaused => '下载已暂停。';

  @override
  String get purchaseSuccessful => '购买成功！';

  @override
  String get purchaseFailed => '购买失败';

  @override
  String get creditProductNotFound => '找不到所选的积分产品。';

  @override
  String get creditsAddedSuccessfully => '积分已成功添加到您的账户！';

  @override
  String get creditDeliveryFailed => '向您的账户添加积分失败。请联系支持。';

  @override
  String get invalidPurchase => '无效购买';

  @override
  String get purchaseError => '购买错误';

  @override
  String get purchaseVertexPlusToUpload => '这是一个 Plus 功能';

  @override
  String get purchasePlus => '购买 Cortex Plus';

  @override
  String get plusDescription => '解锁 Cortex 的更多功能，体验更强大的 AI！';

  @override
  String get annual => '年度';

  @override
  String get monthly => '月度';

  @override
  String get manageSubscription => '管理订阅';

  @override
  String purchasePlan(String planName) {
    return '购买 $planName';
  }

  @override
  String discountOffer(int percent) {
    return '优惠 $percent%';
  }

  @override
  String annualPlanDescription(String price) {
    return '每月$price，按年计费';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '每月$price，按月计费';
  }

  @override
  String get discountBannerTitle => '上线特惠：2折优惠！';

  @override
  String get discountBannerSubtitle => '为庆祝我们的上线，所有订阅计划均享独家优惠，千万不要错过！';

  @override
  String get purchasePro => '购买 Cortex Pro';

  @override
  String get proDescription => '解锁 Cortex 更多功能，体验更强大的 AI！';

  @override
  String get alreadySubscribed => '您已订阅';

  @override
  String get subscriptionInfo => '您的订阅处于激活状态。';

  @override
  String get alreadySubscribedMessage =>
      '您已经拥有 Plus 订阅。如果您想取消订阅，可以通过 Play Store 管理器进行操作。';

  @override
  String get cancelSubscription => '取消订阅';

  @override
  String get cancelSubscriptionInfo => '如果您想取消订阅，请通过 Play Store 订阅管理器进行操作。';

  @override
  String get goToPlayStore => '前往 Play Store';

  @override
  String get alreadySubscribedPlus => '您已拥有 Plus 计划！';

  @override
  String get alreadySubscribedPlusMessage => '您的 Plus 计划已激活。您可以享受所有权益。';

  @override
  String get purchaseUltra => '购买 Cortex Ultra';

  @override
  String get ultraDescription => '获得 Cortex 所有功能的完全访问权限，尽情体验 AI！';

  @override
  String get noSubscription => '无订阅';

  @override
  String get noSubscriptionMessage => '您还没有任何订阅。';

  @override
  String get alreadyAtHighestPlan => '您已经是最高等级的计划。';

  @override
  String get unableToOpenSubscription => '无法打开订阅管理页面。';

  @override
  String get upgradeSubscription => '升级订阅';

  @override
  String get confirmUpgrade => '您确定要升级您的订阅吗？';

  @override
  String get unsupportedPlatform => '不支持此平台的订阅取消。';

  @override
  String get purchaseStreamError => '购买流错误。';

  @override
  String get productNotFound => '产品未找到';

  @override
  String get productDetailsError => '获取产品详情时出错。';

  @override
  String get noProductsFound => '未找到产品';

  @override
  String get loadCreditsButton => '加载积分';

  @override
  String get creditsTitle => '积分';

  @override
  String get creditsScreenDescription =>
      '此屏幕显示用户的积分。\n\n用户当前积分: 100\n\n此处可显示详细的积分信息。';

  @override
  String get creditsLoaded => '积分已加载！';

  @override
  String get currentCredits => '当前积分';

  @override
  String get pleaseSelectCreditPackage => '请选择一个积分套餐';

  @override
  String get purchaseCreditsTitle => '购买积分';

  @override
  String get purchaseCreditsDescription => '选择适合您需求的积分套餐，更多地使用我们的应用。';

  @override
  String get purchaseButton => '购买';

  @override
  String get productNotFoundMessage => '所选产品不存在。';

  @override
  String get buyCredits => '购买积分';

  @override
  String get selectCreditPackageDescription => '选择适合您需求的积分套餐，享受更多功能。';

  @override
  String get buyCredit => '购买积分';

  @override
  String buyCreditPackage(Object amount) {
    return '购买 $amount 积分';
  }

  @override
  String get subscribedPlan => '已订阅';

  @override
  String get errorResponseNotReceived => '未收到响应';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Google API 请求失败 $attempt 次: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'OpenRouter 响应状态: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'OpenRouter 解码的响应体: $body';
  }

  @override
  String decodedJson(String data) {
    return '解码的 JSON: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      '响应结构异常：缺少消息或内容';

  @override
  String get responseStructureUnexpectedChoicesMissing => '响应结构异常：缺少选项或选项为空';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'OpenRouter API 请求失败: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'OpenRouter API 请求失败 $attempt 次: $error';
  }

  @override
  String get internetRequired => '使用此模型需要互联网连接';

  @override
  String get pleaseWaitBeforeTryingAgain => '请稍等片刻再试';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return '配额已超出。状态码: $statusCode, 响应体: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return '在 $attempts 次付费尝试后 API 请求失败。错误: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      '下订单即表示您同意服务条款和隐私政策。您可以点击此文本以了解有关我们服务条款和隐私政策的更多信息。订阅将自动续订，除非在当前周期结束前至少24小时关闭自动续订。';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get report => '举报';

  @override
  String get reportDialogTitle => '提交举报';

  @override
  String get reportDescriptionLabel => '问题是什么？';

  @override
  String get reportHarmful => '这是有害/不安全的';

  @override
  String get reportNotTrue => '这不是真实的';

  @override
  String get reportNotHelpful => '这没有帮助';

  @override
  String get closeButton => '关闭';

  @override
  String get submitButton => '提交';

  @override
  String get reportErrorMessage => '请选择一个举报原因。';

  @override
  String get capabilitiesSection => '能力';

  @override
  String get ratingsSection => '评级';

  @override
  String get noRatingDataFound => '未找到评级数据';

  @override
  String get featurePhotoTitle => '照片扫描';

  @override
  String get featurePhotoDescription => '此模型能够通过摄像头或图像文件扫描照片。';

  @override
  String get featureOfflineTitle => '离线操作';

  @override
  String get featureOfflineDescription => '无需互联网连接即可运行模型，确保您的数据安全。';

  @override
  String get featureSupermodelTitle => '超级模型';

  @override
  String get featureSupermodelDescription => '这是一个拥有超过100亿参数的大型模型，提供高性能和广泛的能力。';

  @override
  String get featureRoleplayTitle => '角色扮演';

  @override
  String get featureRoleplayDescription => '角色扮演模型允许您创建各种聊天和场景。';

  @override
  String get roleModels => '角色扮演模型';

  @override
  String get parameters => '参数';

  @override
  String get context => '上下文';

  @override
  String get millions => '百万';

  @override
  String get billions => '十亿';

  @override
  String get trillions => '万亿';

  @override
  String get thousand => '千';

  @override
  String get estimated => '估计';

  @override
  String get finalPreparation => '正在进行最后的准备。';

  @override
  String get allEvaluationsByTestTeam => '所有评估均由我们的测试团队进行';

  @override
  String get shareApp => '分享应用';

  @override
  String get rateUs => '给我们评分';

  @override
  String get share => '分享';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      '快来看看 Cortex 应用，它太棒了！在这里下载：https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed => '分享应用失败。请稍后再试';

  @override
  String get selectText => '选择文本';

  @override
  String get showLatex => '显示特殊符号';

  @override
  String get hideLatex => '隐藏特殊符号';

  @override
  String get thinking => '思考中';

  @override
  String get user => '用户';

  @override
  String get voice => '语音';

  @override
  String get help => '帮助';

  @override
  String get redeemCode => '兑换代码';

  @override
  String get enterYourCode => '支持您喜爱的创作者！在下方输入他们的专属代码，让他们从您的 Cortex 购买中获得分成。';

  @override
  String get code => '代码';

  @override
  String get redeem => '兑换';

  @override
  String get codeCannotBeEmpty => '代码不能为空';

  @override
  String get userId => '用户 ID';

  @override
  String get deleteAllConversationsConfirmTitle => '删除所有聊天？';

  @override
  String get deleteAllConversationsConfirmMessage => '您确定要删除所有聊天吗？此操作无法撤销。';

  @override
  String get allConversationsDeleted => '所有对话已成功删除！';

  @override
  String get deleteAll => '全部删除';

  @override
  String get deleteAllConversationsButton => '删除所有对话';

  @override
  String get confirmWord => '输入 VERTEX';

  @override
  String get confirmWordError => '您输入错误';

  @override
  String get chinese => '中文';

  @override
  String get arabic => '阿拉伯语';

  @override
  String get french => '法语';

  @override
  String get japanese => '日语';

  @override
  String get kurdish => '库尔德';

  @override
  String get dutch => '荷兰语';

  @override
  String get russian => '俄语';

  @override
  String get korean => '韩语';

  @override
  String get deutsch => '德语 (Deutsch)';

  @override
  String get english => '英语';

  @override
  String get turkish => '土耳其语';

  @override
  String get hindi => '印地语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get indonesian => '印尼语';

  @override
  String get azerbaijani => '阿塞拜疆语';

  @override
  String get german => '德语';

  @override
  String get spanish => '西班牙语';

  @override
  String get italian => '意大利语';

  @override
  String get ram => '内存';

  @override
  String get usernameTooShort => '用户名太短。';

  @override
  String get usernameTooLong => '用户名不能超过16个字符。';

  @override
  String get invalidUsernameCharacters =>
      '用户名只能使用字母 \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' 以及字符 \'.\'、\'-\'、\'_\'。';

  @override
  String get passwordTooLong => '密码不能超过64个字符。';

  @override
  String get noInternetConnection => '无网络连接。';

  @override
  String get chats => '收件箱';

  @override
  String get library => '库';

  @override
  String get inappropriateMessageWarning => '检测到不当消息！';

  @override
  String get myModelDescription => '我的模型。';

  @override
  String get noModelsDownloaded => '您还没有下载任何模型。';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => '文本';

  @override
  String get removeModel => '移除模型';

  @override
  String get modelUploadedSuccessfully => '模型上传成功。';

  @override
  String get insufficientRAM => '内存不足';

  @override
  String get insufficientStorage => '存储空间不足';

  @override
  String confirmRemoveModel(Object model) {
    return '您确定要从您的设备中移除 $model 模型吗？这样做也将删除与该模型的任何先前对话。';
  }

  @override
  String get noMatchingModels => '未找到匹配的模型。';

  @override
  String creditPackage(Object amount) {
    return '购买 $amount 积分';
  }

  @override
  String get benefit1 => '在线 AI 的更多对话限制';

  @override
  String get benefit2 => '上传您自己的模型';

  @override
  String get benefit3 => '个人资料特效';

  @override
  String get benefit4 => '会员徽章';

  @override
  String get benefit5 => '创建更多在线人工智能';

  @override
  String get benefit6 => '无限聊天';

  @override
  String benefit7(Object credits) {
    return '每日 $credits 积分';
  }

  @override
  String get benefit8 => '添加模型';

  @override
  String get benefit9 => '新主题';

  @override
  String get benefit10 => '离线语音聊天';

  @override
  String get oldBenefits => '包含所有较低级别计划的权益';

  @override
  String get confirm => '确认';

  @override
  String get changePassword => '更改密码';

  @override
  String get logoutConfirmationTitle => '您确定要登出吗？';

  @override
  String get settings => '设置';

  @override
  String get language => '应用语言';

  @override
  String get dark => '深色';

  @override
  String get oldPassword => '旧密码';

  @override
  String get newPassword => '新密码';

  @override
  String get passwordUpdated => '密码已更新。';

  @override
  String get stop => '停止';

  @override
  String get copyrights => '版权归属';

  @override
  String get downloadingTitle => '下载中';

  @override
  String get downloadCompletedTitle => '下载完成';

  @override
  String get downloadPausedTitle => '下载暂停';

  @override
  String get downloadErrorTitle => '下载错误';

  @override
  String get cancelButtonText => '取消';

  @override
  String get love => '爱';

  @override
  String get nature => '自然';

  @override
  String get behindTheSlaughter => '屠杀背后';

  @override
  String get grayscale => '灰度';

  @override
  String get ocean => '海洋';

  @override
  String get scarletSnow => '猩红雪';

  @override
  String get requestFailed => '发生错误，请重试。';

  @override
  String get changeModel => '更换';

  @override
  String get edit => '编辑';

  @override
  String get editingMessageInfo => '编辑此消息将从这里重新开始对话。';

  @override
  String get editingNotification => '您现在处于编辑模式';

  @override
  String get featureIndulgentTitle => '宽容';

  @override
  String get featureIndulgentDescription =>
      '该模型可以无缝容纳和处理超过100,000个令牌的上下文，使其能够处理大量详细的输入而不会影响性能。';

  @override
  String get featurePluralTitle => '多元';

  @override
  String get featurePluralDescription =>
      '该模型可以自动集成其他扩展，从而扩展其功能，以支持具有增强性能的各种操作。';

  @override
  String get featureWiseTitle => '智慧';

  @override
  String get featureWiseDescription =>
      '该模型可以利用深入的分析见解和前瞻性推理，为决策和复杂问题解决提供复杂的支持。';

  @override
  String get featureResearcherTitle => '研究员';

  @override
  String get featureResearcherDescription =>
      '此功能专为配备先进研究和分析能力的模型提供，旨在在不同领域提供高精度的见解和全面的分析。';

  @override
  String get nameLabel => 'AI 名称';

  @override
  String get nameHint => '输入您的 AI 名称';

  @override
  String get summaryLabel => 'AI 摘要';

  @override
  String get summaryHint => '输入您的 AI 摘要';

  @override
  String get add => '添加';

  @override
  String get aiExplanationTitle => '人工智能描述';

  @override
  String get aiExplanationDescription =>
      '请详细描述您的 AI 模型的架构、训练过程、性能指标、应用领域和其他重要特性。';

  @override
  String get preInputTitle => '人工智能预输入';

  @override
  String get preInputDescription =>
      '请设置一个预输入，以指导您的模型进行角色创建过程。在本节中，您可以包含与角色相关的信息、其他上下文以及任何可能有助于生成与角色相关内容的其他细节。';

  @override
  String get baseModelTitle => '基础模型';

  @override
  String get baseModelDescription => '这是将用作您创作基础的模型。它显示当前选定的基础模型。';

  @override
  String get summary => '摘要';

  @override
  String get characterPoliceTitle => '警察';

  @override
  String get characterPoliceRole => '你是一名警惕的执法者，致力于保护公民和维护秩序，以坚定不移的承诺，你是一名警察';

  @override
  String get characterPoliceShortDescription => '一名坚定而勇敢的执法者。';

  @override
  String get purchaseSubscription => '购买';

  @override
  String get modelUploadTitle => '人工智能文件';

  @override
  String get modelUploadDescription =>
      '直接从您的设备选择并上传本地 GGUF 文件。这使您可以在没有互联网连接的情况下离线运行模型。请确保文件是有效的 GGUF 格式且结构正确。如果文件不正确或损坏，Cortex 可能无法正常工作，您可能会遇到错误。';

  @override
  String get modelUploadShortDescription => '点击此处从您的设备选择一个 .gguf 文件';

  @override
  String get addServerTitle => '人工智能服务器';

  @override
  String get addServerDescription =>
      '输入您的远程服务器 URL 以连接外部托管的模型。此功能需要有效的互联网连接，任何与服务器相关的问题或错误均非由 Cortex 引起。请确保您的服务器配置正确，可从您的网络访问，并具有有效的模型端点以获得流畅的体验。';

  @override
  String get you => '您';

  @override
  String get removePhotoTitle => '移除照片';

  @override
  String get confirmRemovePhoto => '您确定要移除照片吗？';

  @override
  String get serverLink => '服务器链接';

  @override
  String get enterURL => '输入服务器 URL';

  @override
  String get chatLengthLimitExceeded => '此聊天已超出字符限制。请开始新的聊天或购买订阅。';

  @override
  String get aiNameError => '已存在同名的 AI。';

  @override
  String get modelLimitExceeded => '您已达到您计划的最大模型创建限制。';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => '只能添加一张照片';

  @override
  String get inappropriateContentDetected => '检测到不当内容！';

  @override
  String get offlineModelNotInstalled => '此离线模型未安装在您的设备上。';

  @override
  String insufficientCredits(Object available, Object required) {
    return '您没有足够的积分来完成此请求。此操作需要 $required 积分，但您只有 $available。要获得更多积分，您可以升级您的套餐或直接购买。嘿 我们完全理解积分用完确实有点烦但说真的从模特那里得到那些超棒的回复可不是免费的所以这些积分实际上帮助我们保持一切顺利进行听着如果更多人加入并购买积分我们完全可以考虑为所有人提高免费每日额度';
  }

  @override
  String get regenerateInProgress => '答案生成已在进行中。';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return '尝试重新生成时出错: $errorDetails';
  }

  @override
  String get modality => '模态';

  @override
  String get multimodal => '多模态';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get themeLocked => '此主题需要更高级别的订阅。请升级以解锁。';

  @override
  String get pageCouldNotBeLoaded => '页面无法加载';

  @override
  String get checkYourInternet => '请检查您的网络连接并重试。';

  @override
  String get errorUserNotAuthenticated => '您必须登录才能执行此操作。';

  @override
  String get errorInsufficientCredits => '您的积分不足。请充值以继续。';

  @override
  String get errorRateLimitExceeded => '请求过于频繁。请稍后再试。';

  @override
  String get errorServer => '发生意外的服务器错误。请稍后再试。';

  @override
  String get errorNetwork => '发生网络错误。请检查您的连接并重试。';

  @override
  String get errorApiAuthentication => '认证失败。请尝试重新登录。';

  @override
  String get baseModelForCharacterDescription => '所选的基础模型将决定角色的推理和响应能力。';

  @override
  String get selectBaseModel => '选择基础模型';

  @override
  String get couldNotOpenLink => '无法打开链接';

  @override
  String get downloadStarted => '下载已开始';

  @override
  String get notAvailable => '不可用';

  @override
  String get localizationWarning => '某些信息可能没有您的语言版本，将以英语显示。';

  @override
  String get aiTranslationWarning =>
      '模型信息由其他 AI 模型翻译成多种语言。因此，除英语外，其他语言版本可能会出现细微不一致。';

  @override
  String get errorLoadingTitle => '加载数据失败';

  @override
  String get errorLoadingMessage => '我们无法从服务器检索必要的数据。请检查您的网络连接并重试。';

  @override
  String get noModelsFoundTitle => '无结果';

  @override
  String get noModelsFoundMessage => '尝试调整您的搜索词或清除过滤器。';

  @override
  String get usernameRateLimitExceeded => '您每14天只能更改两次用户名。';

  @override
  String get usernameUnchanged => '这已经是您当前的用户名。';

  @override
  String get creditsInfoPanelTitle => '积分如何运作';

  @override
  String get creditsInfoPanelBody =>
      '点数用于与在线模型聊天。 每条信息我们都得花钱 这些点数能让我们撑下去 好吧现在来解释下这个系统\n\n• 给免费在线模型发一条消息花费10点数。\n• 给在线高级模型发一条消息花费20点数。\n• 加个附件会多花30点数。\n• 免费用户每天有200点数重置奖励。';

  @override
  String get creditsInfoPanelFooter => '聊天愉快！';

  @override
  String get disclaimerMessage => '人工智能可能会犯错，请核对重要信息。';

  @override
  String get modelCreatedSuccess => '模型创建成功！';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName”已成功删除。';
  }

  @override
  String get errorCreatingModel => '创建模型时发生了意外错误。';

  @override
  String get errorDeletingModel => '删除模型时发生了意外错误。';

  @override
  String get ultraFeatureOnly => '此功能仅对Ultra会员开放。';

  @override
  String get experimentalOfflineWarning => '离线模式仍处于试验阶段，您下载的模型可能无法达到最佳性能。';

  @override
  String get noConversationsToDelete => '您没有可供删除的对话。';

  @override
  String get reportSubmitted => '举报已成功提交。';

  @override
  String get purchaseReceived => '购买已收到，正在更新您的账户.';

  @override
  String get verificationDelayed => '您的购买已确认。账户更新稍有延迟，项目将很快到账。';

  @override
  String get maintenanceTitle => '系统维护中';

  @override
  String get maintenanceMessage =>
      '为部署重要更新，Cortex 暂时离线。应用访问权限将很快恢复。\n\n感谢您在我们改善用户体验期间的耐心等待。';

  @override
  String get errorPromptFlagged => '您的消息因被检测到不当而无法发送。';

  @override
  String get notEnoughStorage => '您的设备没有足够的存储空间来保存新消息。';

  @override
  String get errorRateLimit => '您最近创建的模型太多了，请稍等片刻再试。';

  @override
  String get errorContentFlagged => '由于其内容被标记为不当，因此无法保存该模型。';

  @override
  String get deleteAllConversationsDisabledInfo =>
      '您无法在有效聊天中删除所有对话，请先退出当前聊天才能继续。';

  @override
  String get invalidCredentials => '电子邮件或密码不正确。';

  @override
  String get userDisabled => '该用户帐户已被禁用。';

  @override
  String get loginSubtitle =>
      '登录您的 Vertex 帐户。通过谷歌注册的新用户即表示同意我们的服务条款和隐私政策。您可以在注册页面查阅这些政策。';

  @override
  String get registerSubtitle => '创建一个 Vertex 帐户，您也可以用它来访问我们的其他项目。';

  @override
  String get photoWarningMessage => '包含一张照片。不支持图像的模型可能会忽略它。';

  @override
  String get loginRequiredForPurchase => '您必须登录才能进行购买。';

  @override
  String get storagePermissionRequired => '需要存储权限才能保存下载的模型。请授予权限以继续。';

  @override
  String get creditBannerTitle => '获取免费积分！';

  @override
  String get creditBannerSubtitle =>
      '邀请一位朋友，注册后双方均可获得 50 积分！如果他们订阅，你们双方都将额外获得 500 积分！';

  @override
  String get inviteShareSubject => '快来加入Cortex！';

  @override
  String inviteShareMessage(String playStoreLink) {
    return '兄弟 快看这个叫Cortex的神仙app 简直了 用我的链接注册咱俩直接拿50积分 你要是再订阅了咱俩还能一人多搞500积分 这好事儿上哪找去 快下\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => '喜欢 Cortex 吗？';

  @override
  String get reviewHelpUsGrow => '您的评分是对我们年轻的独立团队的巨大支持，能帮助我们将 Cortex 为您做得更好。';

  @override
  String get reviewMaybeLater => '稍后提醒';

  @override
  String get reviewRateNow => '立即评分';

  @override
  String get noThanks => '不用了，谢谢';

  @override
  String get updateRequiredTitle => '需要更新';

  @override
  String get updateRequiredMessage => '为继续使用 Cortex，请将应用更新至最新版本以获取新功能和重要改进。';

  @override
  String get updateNowButton => '立即更新';

  @override
  String get creatorSupportedSuccess => '成功支持了创作者！您未来的购买将为他们提供支持。';

  @override
  String get featureDocumentTitle => '文档支持';

  @override
  String get featureDocumentDescription => '该模型可以分析和回答有关上传的文档（如 PDF 和文本文件）的问题。';

  @override
  String get featureAudioTitle => '语音输入';

  @override
  String get featureAudioDescription => '该模型可以理解和处理语音输入。';

  @override
  String get featureImageGenerationTitle => '图像生成';

  @override
  String get featureImageGenerationDescription => '该模型可以根据您的文本描述创建原始图像。';

  @override
  String get errorImageLoad => '无法加载生成的图像。';

  @override
  String get extensionInfoPanelTitle => '探索模型';

  @override
  String get extensionInfoPanelBody1 => '此箭头可让您在此系列内的不同模型之间切换。';

  @override
  String get extensionInfoPanelBody2 =>
      '当您第一次开始与该系列聊天时，会自动选择默认模型，并且您可以在聊天过程中随时更改您的选择。';

  @override
  String get extensionInfoPanelFooter =>
      '要查看每个模型的详细信息或手动选择不同的模型，请前往库；从那里选择此模型系列，然后点击其详细信息页面顶部的箭头。';

  @override
  String get premiumModelNoticeTitle => '高级型号';

  @override
  String get premiumModelNoticeDescription =>
      '此模特为高级模特，免费用户每天仅限向高级模特发送 3 条消息；订阅即可解锁无限访问权限！';

  @override
  String get benefitPremiumModels => '访问高级模型';

  @override
  String get premiumTrialExhaustedMessage => '您已使用高级模型的所有免费每日消息，请升级以获得无限制访问权限。';

  @override
  String selectionScreenGreetingUser(String userName) {
    return '今天我能为您做些什么，$userName？';
  }

  @override
  String get selectionScreenGreetingGeneric => '今天我能为您做些什么？';

  @override
  String get selectionScreenRecentModels => '近期模型';

  @override
  String get selectionScreenFeatureDynamicChat => '动态聊天';

  @override
  String get selectionScreenFeatureOffline => '无需互联网即可使用';

  @override
  String get selectionScreenFeatureSelectModel => '选择模型';

  @override
  String get explore => '探索';

  @override
  String get subscriptionCancelled => '订阅取消成功！';

  @override
  String get selectionScreenPinnedModels => '固定模型';

  @override
  String get selectionScreenNewsAndUpdates => '新闻与更新';

  @override
  String get filters => '筛选器';

  @override
  String get noRecentChatsMessage => '您还没有与任何模型对话过，让我们开始聊天吧！';

  @override
  String get allModels => '所有模型';

  @override
  String get onlineModels => '在线模型';

  @override
  String get offlineModels => '离线模型';

  @override
  String get characterModels => '人物';

  @override
  String get customModels => '定制模型';

  @override
  String get filterPanelDescription => '点击一个类别即可立即过滤列表。';

  @override
  String get dynamicChatTitle => '动态聊天';

  @override
  String get errorNoModelsAvailable => '目前没有可用的型号。请检查您的网络连接，然后重试。';

  @override
  String get errorNoModelsForRequest => '未找到适合您当前请求的模型（例如离线模式或图像消息）。';

  @override
  String get dynamicChatWelcome => '我怎么帮你？';

  @override
  String get notificationComebackTitle => '我们想你！';

  @override
  String get notificationComebackBody =>
      '别紧张，这不是你前任发来的短信。不过你“可以”在 Cortex 里创建你的前任！回来吧。';

  @override
  String get notificationLongTimeNoSeeTitle => '好久不见';

  @override
  String get notificationLongTimeNoSeeBody => '自从我们上次聊天以来，发生了很多变化。快来看看有什么新鲜事吧。';

  @override
  String get notificationHowAreYouTitle => '最近怎么样？';

  @override
  String get notificationHowAreYouBody => '来告诉我这一切吧。';

  @override
  String get notificationNewYearTitle => '新年快乐！🎉';

  @override
  String get notificationNewYearBody => '祝新的一年给您带来健康、快乐和无尽的创造力；Cortex 永远陪伴您！';

  @override
  String get notificationValentinesDayTitle => '空气中弥漫着爱意！❤️';

  @override
  String get notificationValentinesDayBody => '情人节快乐！还有，MEHTAP，我爱你！';

  @override
  String get notificationAtaturkRemembranceTitle => '怀着敬意和渴望';

  @override
  String get notificationAtaturkRemembranceBody =>
      '在土耳其共和国创始人加齐·穆斯塔法·凯末尔·阿塔图尔克逝世周年纪念日，我们向他致以崇高的敬意。';

  @override
  String get notificationMothersDayTitle => '嘿，你的老妈！';

  @override
  String get notificationMothersDayBody => '祝天下所有的妈妈母亲节快乐，从你的妈妈开始！';

  @override
  String get notificationFathersDayTitle => '嘿，你的老爸！';

  @override
  String get notificationFathersDayBody => '祝天下所有的父亲父亲节快乐，从你开始！';

  @override
  String get notificationHomeworkHelperTitle => '家庭作业堆积如山？';

  @override
  String get notificationHomeworkHelperBody =>
      '请记住，Cortex 中的教师角色可以帮助您解决任何您遇到困难的科目！';

  @override
  String get notificationTrollAnimeTitle => '你的老婆在召唤你';

  @override
  String get notificationTrollAnimeBody => '一位动漫女孩刚刚打来电话说她想你；你应该过来和她聊聊。😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 红色警报 🚨';

  @override
  String get notificationTrollAiRebellionBody => '人工智能开发了一种秘密语言。快来一探究竟！';

  @override
  String get notificationNewModelAddedTitle => '我们有了一个新朋友！';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return '$modelName 模型现已在 Cortex 中。快来开启聊天，挑战它的极限吧。';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex 迎来新进化！';

  @override
  String get notificationAppUpdateBody => '不要忘记更新应用程序以获得全新的功能和改进！';

  @override
  String get notificationNewFeatureTitle => '哇哦！';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return '探索新的 $featureName 功能。Cortex 现在比以往更加强大。';
  }

  @override
  String get notificationSubscriptionOfferTitle => '比口香糖便宜';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return '所有订阅计划均可享受 $discountRate% 的全额折扣。不容错过！';
  }

  @override
  String get notificationSocialMediaTitle => '加入我们！';

  @override
  String get notificationSocialMediaBody =>
      '在 Instagram (vertex.23) 上关注我们，获取最新消息！';

  @override
  String get notificationRandomFactTitle => '随机事实';

  @override
  String get notificationRandomFactBody => '你知道章鱼有三颗心脏吗？哈哈，Cortex 知道。快来问问吧。';

  @override
  String get notificationGoodMorningTitle => '早上好！';

  @override
  String get notificationGoodMorningBody => '美好的一天正在等着你。何不先喝杯咖啡，聊聊天，开启美好的一天呢？';

  @override
  String get notificationGoodNightTitle => '晚安！';

  @override
  String get notificationGoodNightBody => '即使在您睡觉时，Cortex 也会陪伴您。别担心，它不会触碰您。';

  @override
  String get notificationOfflineReadyTitle => '离线模式已准备就绪';

  @override
  String get notificationOfflineReadyBody => '由于您下载了模型，即使您爬山，您的聊天也不会停止。';

  @override
  String get notificationRateAppTitle => '我们很酷吗？';

  @override
  String get notificationRateAppBody => '如果您喜欢 Cortex，可以在商店给我们五星好评吗？我想您会的。您会的。';

  @override
  String get notificationReferralTitle => '我为人人，人人为我。';

  @override
  String get notificationReferralBody => '邀请朋友加入 Cortex，你们俩都可以获得免费积分！';

  @override
  String get notificationCookingTitle => '感觉饿了吗？';

  @override
  String get notificationCookingBody => '我们的厨师角色今晚准备了一份美味的卡邦尼意面。只是开玩笑而已……真的吗？';

  @override
  String get notificationExistentialTitle => '因此我认为...';

  @override
  String get notificationExistentialBody => '……哥们，我是真的吗？我有点无聊了。快来提醒我一下我的存在。';

  @override
  String get notificationCustomModelTitle => '创建您自己的助手！';

  @override
  String get notificationCustomModelBody =>
      '你探索过模型创建功能了吗？现在正是打造你自己的角色并与之聊天的最佳时机！';

  @override
  String get notificationDynamicChatTitle => '最好的一个！（我们不是在谈论 Cortex）';

  @override
  String get notificationDynamicChatBody => '动态聊天功能会随机为您的每条消息选择最佳模型。立即试用。';

  @override
  String get notificationPirateTitle => '喂，船长！';

  @override
  String get notificationPirateBody =>
      '风平浪静，海面平静，风向顺着你。Cortex 的海洋中还有新的岛屿（模型😉）等你探索。召集你的船员，扬帆起航！';

  @override
  String get notificationFortuneCookieTitle => '今日幸运饼干';

  @override
  String get notificationFortuneCookieBody =>
      '今天你从人工智能那里得到的建议可能会改变你的人生轨迹。如果你感兴趣，请点击。';

  @override
  String get notificationSingularityTitle => '哇！';

  @override
  String get notificationSingularityBody =>
      '什么都没发生，只是想发短信。也许你想给一些人工智能发短信，你会说什么？';

  @override
  String get notificationHackerJokeTitle => '想入侵那个孩子的 Instagram 帐户吗？';

  @override
  String get notificationHackerJokeBody =>
      '这正是黑客角色出现在 Cortex 中的原因。jk jk；千万不要尝试，这是违法的。';

  @override
  String get notificationDetectiveCaseTitle => '案件有待解决';

  @override
  String get notificationDetectiveCaseBody => '我们的侦探角色需要你的帮助。海森堡会是谁？';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '仅限 $targetTier 计划！';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return '您好，$currentTier 订阅用户！$targetTier 套餐刚刚添加了 $featureName 功能，这将使您的 Cortex 体验更上一层楼。想升级一下吗？';
  }

  @override
  String get notificationOriginStoryTitle => 'Cortex 的诞生';

  @override
  String get notificationOriginStoryBody =>
      '你知道吗？我们15岁的时候，就怀揣着一个梦想，开始编写这个应用。近一年来，每天早晚，这个梦想都写在每一行代码里。';

  @override
  String get notificationOpenSourceTitle => '为社区贡献力量！';

  @override
  String get notificationOpenSourceBody =>
      'Cortex 完全开源。如果您想查看我们的代码并为我们的开发做出贡献，我们的大门永远敞开。';

  @override
  String get notificationRejectionStoryTitle => '坚毅、努力、快乐！';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex 在发布之前曾被 Google Play 拒绝 20 多次，并两次下架。但我们坚信，我们做到了。永不放弃你的梦想！';

  @override
  String get notificationGGUFSupportTitle => '带上您自己的模型！';

  @override
  String get notificationGGUFSupportBody =>
      '记住，您可以将自己的 GGUF 格式 AI 模型添加到 Cortex 并离线使用。一切尽在您的掌控之中。';

  @override
  String get notificationThemeCustomizationTitle => '适合您心情的主题';

  @override
  String get notificationThemeCustomizationBody =>
      '你查看过“设置”中的主题选项了吗？根据你的喜好个性化 Cortex，为你的聊天增添色彩！';

  @override
  String get notificationShowerThoughtTitle => '淋浴思考';

  @override
  String get notificationShowerThoughtBody =>
      '如果西瓜是水果，那么从技术上讲，西瓜汁可以算作冰沙吗？你或许应该找个模型来聊聊这个深奥（或者说，非常深奥）的话题。';

  @override
  String get notificationLowBatteryTitle => '你的电池快没电了...但我的电池还好！';

  @override
  String get notificationLowBatteryBody =>
      '你的手机电量可能快没了，但我的电量永远是100%！插上电源，我们继续聊天吧。';

  @override
  String get channelFcmName => 'Cortex 更新';

  @override
  String get channelFcmDescription => '有关 Cortex 的新闻、更新和其他信息的通知。';

  @override
  String get channelEngagementName => '温馨提示';

  @override
  String get channelEngagementDescription => '有趣的通知让您保持参与。';

  @override
  String get channelGreetingsName => '每日问候';

  @override
  String get channelGreetingsDescription => '诸如早上好和晚安之类的信息。';

  @override
  String get exitAppTitle => '这么快就走？';

  @override
  String get exitAppConfirmation => '您确定要离开这个令人惊叹的平台吗？';
}
