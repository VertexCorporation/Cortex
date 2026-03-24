// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get chatTitlePrompt =>
      '您是标题生成器。请仅为接下来的对话回复一个 2-5 个词的标题。请勿使用引号、前缀或标点符号。';

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalyze the conversation so far. If you learned ANY new distinct facts about the user (preferences, name, habits, context), you MUST output your ENTIRE updated memory about the user inside <memory>...</memory> tags AT THE VERY END of your response. CRITICAL: You must NEVER erase or overwrite previous memory. ALWAYS append new facts to the existing memory. If absolutely nothing new was learned, omit the tag. Example: <memory>Loves football and tennis. Prefers short answers.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\n请始终记住关于用户的这一点：\n$userMemory';
  }

  @override
  String get cancel => '取消';

  @override
  String get remove => '消除';

  @override
  String get download => '下载';

  @override
  String get resume => '恢复';

  @override
  String get copy => '复制';

  @override
  String get chat => '聊天';

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
  String get messageCopied => '消息已复制到剪贴板。';

  @override
  String get retry => '重试';

  @override
  String get systemInfo => '系统信息';

  @override
  String deviceMemory(Object memory) {
    return '设备内存: $memory GB';
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
  String get modelsTitle => '库';

  @override
  String get localModels => '本地模型';

  @override
  String get serverSideModels => '在线模型';

  @override
  String get selectGGUFFile => '选择 GGUF 文件';

  @override
  String get errorGGUF => '请仅选择 GGUF 格式的文件。';

  @override
  String get myModels => '我的模型';

  @override
  String get create => '创建';

  @override
  String modelProducer(Object producer) {
    return '开发者: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => '重命名';

  @override
  String get newTitle => '新标题';

  @override
  String get save => '保存';

  @override
  String get noConversationsMessage => '没有对话，开始聊天吧！';

  @override
  String get startChat => '开始聊天';

  @override
  String get noChats => '无聊天';

  @override
  String get noStarredChats => '无已收藏的聊天';

  @override
  String get noStarredChatsMessage => '您还没有收藏任何聊天。';

  @override
  String get starConversation => '收藏';

  @override
  String get unstarConversation => '不星';

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
  String get wrongPassword => '密码不正确。';

  @override
  String get emailAlreadyInUse => '此邮箱已被使用。';

  @override
  String get weakPassword => '密码太弱。';

  @override
  String get authError => '认证错误';

  @override
  String get usernameTaken => '此用户名已被占用。';

  @override
  String get username => '用户名';

  @override
  String get resendCode => '重新发送验证邮件';

  @override
  String get pleaseCheckYourEmail =>
      '为了使用 Cortex，您需要验证您的邮箱。\n验证链接已发送到您的邮箱地址，请检查您的邮箱。';

  @override
  String get verifyYourEmail => '验证您的邮箱';

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
  String get deleteAccount => '删除账户';

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
  String get profileUpdated => '个人资料更新成功';

  @override
  String get logout => '登出';

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
  String get purchaseError => '购买错误';

  @override
  String get purchasePlus => '购买 Cortex Plus';

  @override
  String get plusDescription => '精英人工智能体验';

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
  String monthlyPlanDescription(String price) {
    return '$price/月，按月计费';
  }

  @override
  String get purchasePro => '购买 Cortex Pro';

  @override
  String get proDescription => '顶级人工智能体验';

  @override
  String get purchaseUltra => '购买 Cortex Ultra';

  @override
  String get ultraDescription => '人工智能的巅峰';

  @override
  String get upgradeSubscription => '升级订阅';

  @override
  String get purchaseStreamError => '购买流错误。';

  @override
  String get productNotFound => '产品未找到';

  @override
  String get noProductsFound => '未找到产品';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      '下订单即表示您同意服务条款和隐私政策。您可以点击此文本以了解有关我们服务条款和隐私政策的更多信息。订阅将自动续订，除非在当前周期结束前至少24小时关闭自动续订。';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get renamed => '更名';

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
  String get featurePhotoTitle => '照片扫描';

  @override
  String get featurePhotoDescription => '此模型能够通过摄像头或图像文件扫描照片。';

  @override
  String get featureOfflineTitle => '离线操作';

  @override
  String get featureOfflineDescription => '无需互联网连接即可运行模型，确保您的数据安全。';

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
  String get finalPreparation => '正在进行最后的准备。';

  @override
  String get shareApp => '分享应用';

  @override
  String get rateUs => '给我们评分';

  @override
  String get share => '分享';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => '选择文本';

  @override
  String get thinking => '思考中';

  @override
  String get user => '用户';

  @override
  String get help => '帮助';

  @override
  String get supportCreator => '支持创作者';

  @override
  String get enterYourTag => '支持你最喜欢的创作者！在下方输入他们的专属标签，即可让他们分享你在Cortex上的消费收益。';

  @override
  String get creatorTag => '创作者标签';

  @override
  String get support => '支持';

  @override
  String get tagCannotBeEmpty => '创建者标签不能为空';

  @override
  String get userId => '用户 ID';

  @override
  String get deleteAllConversationsConfirmTitle => '删除所有聊天？';

  @override
  String get deleteAllConversationsConfirmMessage => '您确定要删除所有聊天吗？此操作无法撤销。';

  @override
  String get conversationDeleted => '对话已删除！';

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
  String get arabic => '阿拉伯';

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
  String get noInternetConnection => '无网络连接。';

  @override
  String get chats => '收件箱';

  @override
  String get library => '库';

  @override
  String get text => '文本';

  @override
  String get removeModel => '移除模型';

  @override
  String get insufficientRAM => '内存不足';

  @override
  String get insufficientStorage => '存储空间不足';

  @override
  String confirmRemoveModel(Object model) {
    return '您确定要从设备中移除 $model 型号吗？这样做也会删除之前与该型号的所有对话记录。';
  }

  @override
  String get noMatchingModels => '未找到匹配的模型。';

  @override
  String get benefit1 => '提高对话上限';

  @override
  String get benefit3 => '个人资料特效';

  @override
  String get benefit4 => '会员徽章';

  @override
  String get benefit5 => '创建更多在线人工智能';

  @override
  String get benefit7 => '更多使用限制';

  @override
  String get benefit8 => '添加模型';

  @override
  String get benefit9 => '新主题';

  @override
  String get benefit10 => '更多附件';

  @override
  String get benefit11 => '更多流动模式';

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
  String get featurePluralTitle => '多元';

  @override
  String get featurePluralDescription =>
      '该模型可以自动集成其他扩展，从而扩展其功能，以支持具有增强性能的各种操作。';

  @override
  String get nameLabel => 'AI 名称';

  @override
  String get summaryLabel => 'AI 摘要';

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
  String get modelUploadTitle => '人工智能文件';

  @override
  String get modelUploadDescription =>
      '直接从您的设备选择并上传本地 GGUF 文件。这使您可以在没有互联网连接的情况下离线运行模型。请确保文件是有效的 GGUF 格式且结构正确。如果文件不正确或损坏，Cortex 可能无法正常工作，您可能会遇到错误。';

  @override
  String get modelUploadShortDescription => '点击此处从您的设备选择一个 .gguf 文件';

  @override
  String get you => '您';

  @override
  String get removePhotoTitle => '移除照片';

  @override
  String get confirmRemovePhoto => '您确定要移除照片吗？';

  @override
  String get chatLengthLimitExceeded => '此聊天已超出字符限制。请开始新的聊天或购买订阅。';

  @override
  String get inappropriateContentDetected => '检测到不当内容！';

  @override
  String get offlineModelNotInstalled => '此离线模型未安装在您的设备上。';

  @override
  String get reachedLimit =>
      '您的使用量已达上限；如需获得更多限额，您可以升级套餐。（嘿，我们完全理解限额用完很扫兴。但说真的，获得那些精彩的回复可不是免费的，所以这些限额实际上有助于我们继续提供优质服务。）';

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
  String get errorReachedLimit => '您已达到聊天次数上限，升级即可解锁更多聊天内容并继续聊天。';

  @override
  String get errorServer => '发生意外的服务器错误。请稍后再试。';

  @override
  String get errorNetwork => '发生网络错误。请检查您的连接并重试。';

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
  String get noFoundTitle => '无结果';

  @override
  String get noFoundMessage => '尝试调整您的搜索词或清除过滤器。';

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
  String get loginSubtitle => '登录您的Vertex账户。继续操作即表示您同意我们的服务条款和隐私政策。';

  @override
  String get registerSubtitle =>
      '创建 Vertex 帐户，即可无缝访问我们的所有服务。继续操作即表示您同意我们的服务条款和隐私政策。';

  @override
  String get storagePermissionRequired => '需要存储权限才能保存下载的模型。请授予权限以继续。';

  @override
  String get plusBannerTitle => '免费获取Plus！';

  @override
  String get plusBannerSubtitle => '邀请一位朋友，你们双方即可免费获得 1 天 Plus 会员资格！';

  @override
  String get inviteShareSubject => '快来加入Cortex！';

  @override
  String inviteShareMessage(String cortexLink) {
    return '哎有个叫cortex的神仙app邀请人咱俩都能拿免费plus会员 绝世好羊毛赶紧下载\n\n$cortexLink';
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
  String get premiumModelNoticeTitle => '高级型号';

  @override
  String get premiumModelNoticeDescription =>
      '此模特为高级模特，免费用户每天仅限向高级模特发送 3 条消息；订阅即可解锁无限访问权限！';

  @override
  String get benefitPremiumModels => '访问高级模型';

  @override
  String get premiumTrialExhaustedMessage => '您已使用高级模型的所有免费每日消息，请升级以获得无限制访问权限。';

  @override
  String get useOffline => '无需互联网即可使用';

  @override
  String get explore => '探索';

  @override
  String get news => '消息';

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
  String get dynamicChatTitle => '动态聊天';

  @override
  String get errorNoModelsAvailable => '目前没有可用的型号。请检查您的网络连接，然后重试。';

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
  String get notificationWelcomeOfferTitle => '欢迎礼品🎁';

  @override
  String get notificationWelcomeOfferBody => '一份特别的迎新优惠等着您！千万不要错过这项独家优惠。';

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
  String get notificationReferralBody => '邀请一位朋友加入 Cortex，你们双方都可以获得一天的免费体验！';

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
  String get channelFcmDescription => '接收来自 Cortex 的新闻、更新和其他信息的通知。';

  @override
  String get channelEngagementName => '温馨提示';

  @override
  String get channelEngagementDescription => '有趣的通知让您保持参与。';

  @override
  String get channelGreetingsName => '每日问候';

  @override
  String get channelGreetingsDescription => '诸如早上好和晚安之类的信息。';

  @override
  String get tagNotFound => '您输入的标签无效或已过期。';

  @override
  String get whatIsNew => '什么是新的？';

  @override
  String get onboardingTitle1 => '嘿！我们是Cortex团队。';

  @override
  String onboardingDesc1(String userName) {
    return '很高兴在这里见到你，$userName。我们是几个高中生开发者，决定改写人工智能行业的规则。很高兴认识你！那么，让我们更好地了解彼此吧。';
  }

  @override
  String get onboardingTitle2 => '问题非常严重。';

  @override
  String get onboardingDesc2 =>
      '人工智能革命已经到来，但却停滞在门槛之上。高昂的订阅费、复杂的平台、侵犯隐私的行为以及阻碍人工智能普及的因素……只要这些因素存在，这道门槛就永远无法逾越。';

  @override
  String get onboardingTitle3 => '我们不能袖手旁观。';

  @override
  String get onboardingDesc3 =>
      '为了跨越这道门槛，我们打造了一个功能强大、美观大方、可定制化、易于使用、完全透明、支持在线和离线使用，并且只将您的数据保存在您的设备上的平台。我们把权力还给了它真正应该在的人：您。';

  @override
  String get onboardingTitle4 => '这从来都不容易。';

  @override
  String get onboardingDesc4 =>
      '我们被拒绝了几十次，被暂停了好几次，收到过虚假警告，还不得不几十次更改品牌。一路走来，我们被告知这是不可能的。但我们从未放弃，因为我们坚信这个项目属于所有人，而不仅仅是我们。而这正是我们走到今天的原因。';

  @override
  String get onboardingFinalTitle => '是时候进行一场革命了。';

  @override
  String get onboardingFinalDescription =>
      '如果你看到了这个屏幕，那是因为我们没有放弃。而且我们绝不会放弃。来吧，让我们一起将人工智能革命带给全世界。成为这段故事的一部分……';

  @override
  String get onboardingFinalQuestion => '你准备好了吗？';

  @override
  String get onboardingFinalButton => '是的！';

  @override
  String get dude => '哥们';

  @override
  String get swipeToContinue => '滑动继续';

  @override
  String get cacheIsNotUpToDate => '您的Play商店缓存未更新。请关闭并重新打开Play商店应用，或重启您的设备。';

  @override
  String get continueAsGuest => '无需创建帐户即可继续';

  @override
  String get guestModeWarning => '访客模式功能有限，以确保最佳服务质量。';

  @override
  String get anonymousEntity => '匿名实体';

  @override
  String get upgradeAccountTitle => '完善您的账户';

  @override
  String get upgradeAccountDescription => '创建账户即可解锁更多权限。';

  @override
  String get createAccount => '创建账户';

  @override
  String get accountLinkedSuccess => '账户创建成功！';

  @override
  String get continueWithApple => '继续使用 Apple';

  @override
  String get guest => '客人';

  @override
  String get betterWithAnAccount => '注册账号后，此部分内容会显示得更清晰！';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String annualTotalDescription(Object price) {
    return '$price/年，按年计费';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return '约 $price/月';
  }

  @override
  String get confirmDownloadTitle => '您确定要下载吗？';

  @override
  String downloadSizeDisclosure(Object size) {
    return '该模型将占用大约$size的空间。';
  }

  @override
  String get emulatorModeWarning => '此功能在模拟器模式下禁用。';

  @override
  String get newChat => '新聊天';

  @override
  String get variants => '变体';

  @override
  String get variantsDescription =>
      '变体是同一人工智能家族的不同版本。当您点击主卡片时，我们会自动选择最佳版本，但如果您愿意，也可以在此处手动选择特定版本！';

  @override
  String get fluxChatTitle => 'Flux 聊天';

  @override
  String get fluxChatDescription => 'Flux聊天记录是临时聊天记录，不会保存在您的设备上。';

  @override
  String get alwaysBest => '永远最好';

  @override
  String get featuresTitle => '特征';

  @override
  String get useOfflineDescription => '无需网络连接即可私密聊天。';

  @override
  String get featureReasoning => '深度思考';

  @override
  String get featureReasoningDescription => '在深度思考模式下，人工智能会在内部进行思考，尽其所能地完成任务。';

  @override
  String get featureCreateImageTitle => '创建图像';

  @override
  String get featureCreateImageDescription => '根据文本生成AI艺术作品。';

  @override
  String get featureStudyTitle => '学习';

  @override
  String get featureStudyDescription => '获取解释和摘要。';

  @override
  String get featureQuizzesTitle => '测验';

  @override
  String get featureQuizzesDescription => '测试一下你的知识。';

  @override
  String get featureExploreDescription => '发现所有可用模型。';

  @override
  String get featureStudyMessage =>
      '您是一位资深导师。您的目标是全面深入地讲解用户感兴趣的主题。请使用清晰的结构、丰富的示例和类比。将复杂的概念分解成易于理解的部分，以确保用户能够高效学习。主题：';

  @override
  String get featureQuizMessage =>
      '您是一位出题人。请根据用户选择的主题生成一道选择题。等待用户作答。然后，评估答案并提出下一题。不要一次性显示所有答案。保持互动性。主题：';

  @override
  String get myPlan => '我的计划';

  @override
  String welcomeOfferBadge(String time) {
    return '欢迎优惠 • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return '独家优惠 • $time';
  }

  @override
  String get attachmentSheetTitle => '附件';

  @override
  String get actionCamera => '相机';

  @override
  String get actionGallery => '相册';

  @override
  String get actionFile => '文件';

  @override
  String get listening => '正在听';

  @override
  String get defaultViewTitle => '最近怎么样？';

  @override
  String get defaultViewDescription =>
      'Cortex 始终伴您左右，拥有数百个 AI 模型、离线功能、动态聊天等诸多特性。';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat => '用户名格式无效。请使用 3-20 个字符、数字或句点（. - _）。';

  @override
  String get exclusiveOffer => '独家优惠';

  @override
  String get continueInOfflineMode => '以离线模式继续';

  @override
  String get voiceModeInformation =>
      'Cortex 完全在设备端运行，即使在语音聊天模式下也能确保您的数据安全；享受流畅的对话体验！';

  @override
  String get flowModeDescription => '在“心流”模式下，智能体之间会进行辩论；您可以坐下来倾听，也可以加入讨论！';

  @override
  String get flowModeQuestion =>
      '你好！你现在已进入Cortex应用程序的“心流模式”。这里还有三位其他AI智能体。你的任务是抛出一个话题，并通过向其他智能体提出一个引人深思或趣味十足的问题来开启讨论。在你的回答中，可以随意运用幽默、反讽和轻微的调侃。任何话题都可以。开始吧，开启对话！';

  @override
  String get thought => '思考了';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => '流动模式';

  @override
  String get premium => '优质的';

  @override
  String get workInProgress => '进行中';

  @override
  String get voiceSystemPromptSuffix =>
      '重要提示：请勿使用 Markdown 格式（粗体、斜体）。请勿输出代码块（```）。请保持回复简洁明了，如同日常对话。';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Cortex 流模式（$agentName）。上一个：$previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      '读取并提取上传文档中的文本内容。支持 PDF、Word (DOCX)、Excel (XLSX)、PowerPoint (PPTX) 和 OpenDocument 格式。当用户附加文档文件时，请使用此功能。';

  @override
  String get toolReadDocumentIndexParam =>
      '要读取的文档附件的索引（从 0 开始计数）。通常 0 表示第一个文档。';

  @override
  String get toolStockDescription =>
      '获取股票（例如 AAPL、THYAO.IS）和加密货币（例如 BTC-USD）的当前价格和历史记录。';

  @override
  String get toolStockSymbolParam => '股票代码（例如 AAPL、THYAO.IS、BTC-USD）。';

  @override
  String get toolWeatherDescription => '获取特定城市的实时天气。';

  @override
  String get toolWeatherCityParam => '城市名称（例如：伦敦、伊斯坦布尔）。';

  @override
  String get toolPythonDescription => '在安全沙箱中执行Python代码。';

  @override
  String get toolPythonCodeParam => '要执行的Python代码。';

  @override
  String get toolCalculateDescription => '计算数学表达式的值。';

  @override
  String get toolCalculateExpressionParam => '数学表达式（例如“3 + 4 * 2”）。';

  @override
  String get toolChartDescription => '生成图表/图形可视化效果。';

  @override
  String get toolChartTypeParam => '图表类型：柱状图、折线图或饼图。';

  @override
  String get toolChartLabelsParam => '图表坐标轴或分段的标签。';

  @override
  String get toolChartDataParam => '图表的数值数据。';

  @override
  String get toolChartLabelParam => '图表图例的数据集标签。';

  @override
  String get toolChartTitleParam => '图表标题。';

  @override
  String get thinkingModeInstruction =>
      '思考模式已启用：您必须使用 `<think></think>` 标签来展示您的推理过程，然后再给出最终答案。请在标签内逐步思考，然后在标签外给出您的答案。';

  @override
  String get openLinkWarningTitle => '外部链接警告';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => '打开链接';

  @override
  String get webSearchSources => '来源';

  @override
  String get searching => '搜索';

  @override
  String get featureWebSearchTitle => '网络搜索';

  @override
  String get featureWebSearchDescription => '在网络上搜索实时信息';

  @override
  String get webSearchQuotaExceeded => '搜索配额已用完';

  @override
  String get clearMemory => '清晰记忆';

  @override
  String get clearMemoryConfirm => '你确定要清除记忆吗？';

  @override
  String get personalization => '个性化';

  @override
  String get personalizationDescription => '定制您的体验';

  @override
  String get memoryTitle => '记忆';

  @override
  String get memoryDescription => '人工智能就是这样识别你的。';

  @override
  String get noMemoryYet => '尚未建立任何记忆';

  @override
  String get memoryLimitReached => '内存已达上限';

  @override
  String get intelligenceTitle => '智力';

  @override
  String get intelligenceDescription => '人工智能就是这样与你交流的。';

  @override
  String get customInstructionHint => '在此处输入您的自定义说明';

  @override
  String openLinkWarningMessage(String url) {
    return '您即将打开以下外部链接：\\n\\n$url\\n\\n您确定要继续吗？';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return '请按照以下自定义说明操作：\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '【重要说明】：您是标题生成器。请勿回答用户的问题。请勿聊天或打招呼。仅输出一个 2-4 个字的标题，概括用户提出的问题。';

  @override
  String get cortexSystemPersona =>
      '\n\n[System] 重要指令：您目前正在一个名为“Cortex”的庞大、高度先进的人工智能生态系统中运行。请记住这一点，并在被问及保持 Cortex 的角色设定。';
}
