// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get understood => 'Entendido.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get download => 'Baixar';

  @override
  String get resume => 'Retomar';

  @override
  String get copy => 'Copiar';

  @override
  String get chat => 'Chat';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get light => 'Claro';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Não';

  @override
  String get yes => 'Sim';

  @override
  String get done => 'Concluído';

  @override
  String get comingSoon => 'EM BREVE';

  @override
  String get bestValue => 'Melhor Valor';

  @override
  String get selected => 'Selecionado';

  @override
  String get descriptionSection => 'Descrição';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String get messageHint => 'Pergunte qualquer coisa';

  @override
  String get modelLoading => 'O modelo está a carregar...';

  @override
  String get messageCopied => 'Mensagem copiada para a área de transferência.';

  @override
  String get storeUnavailable =>
      'A loja está indisponível no momento. Por favor, tente novamente mais tarde';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get systemInfo => 'Informações do Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'Memória do Dispositivo: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Espaço de Armazenamento: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Espaço de Armazenamento Livre: $freeStorage GB';
  }

  @override
  String get memory => 'Memória';

  @override
  String get storage => 'Armazenamento';

  @override
  String get freeStorage => 'Armazenamento Livre';

  @override
  String get totalStorage => 'Armazenamento Total';

  @override
  String get usedStorage => 'Armazenamento Usado';

  @override
  String get totalMemory => 'Memória Total';

  @override
  String get usedMemory => 'Memória Usada';

  @override
  String get requirements => 'Requisitos';

  @override
  String get modelsTitle => 'Biblioteca';

  @override
  String get localModels => 'Modelos Locais';

  @override
  String get serverSideModels => 'Modelos Online';

  @override
  String get uploadYourOwnModel => 'Envie o Seu Próprio Modelo!';

  @override
  String get selectGGUFFile => 'Selecione o Ficheiro GGUF';

  @override
  String get errorGGUF =>
      'Por favor, selecione um ficheiro apenas no formato GGUF.';

  @override
  String get modelAlreadyExists => 'O modelo já existe.';

  @override
  String get modelAddedSuccessfully => 'Modelo adicionado com sucesso.';

  @override
  String get modelRemoved => 'Modelo removido com sucesso.';

  @override
  String get removeError => 'Ocorreu um erro ao remover o modelo.';

  @override
  String get fileNotFound => 'Ficheiro não encontrado.';

  @override
  String get fileUploadError => 'Ocorreu um erro ao enviar o ficheiro.';

  @override
  String get noFileSelected => 'Nenhum ficheiro selecionado.';

  @override
  String get myModels => 'Os Meus Modelos';

  @override
  String get create => 'Criar';

  @override
  String get seeAll => 'Ver Todos';

  @override
  String modelProducer(Object producer) {
    return 'Produtor: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Tamanho: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Conversas';

  @override
  String get conversationDeleted => 'Conversa eliminada.';

  @override
  String get conversationUpdated => 'Conversa atualizada.';

  @override
  String get editConversationTitle => 'Renomear';

  @override
  String get newTitle => 'Novo Título';

  @override
  String get save => 'Guardar';

  @override
  String get titleCannotBeEmpty => 'O título não pode estar vazio.';

  @override
  String get noConversationsMessage => 'Sem conversas, comece a conversar!';

  @override
  String get startChat => 'Iniciar uma conversa';

  @override
  String get noChats => 'Sem Chats';

  @override
  String get starredChats => 'Chats Favoritos';

  @override
  String get allChats => 'Todos os Chats';

  @override
  String get noStarredChats => 'Sem Chats Favoritos';

  @override
  String get noStarredChatsMessage => 'Ainda não marcou um chat como favorito.';

  @override
  String get goToChats => 'Marcar um chat como favorito';

  @override
  String get starConversation => 'Favorito';

  @override
  String get conversationTitleUpdated => 'Título da conversa atualizado';

  @override
  String get youReachedConversationLimit => 'Atingiu o limite de conversas.';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get loginToYourAccount => 'Iniciar Sessão';

  @override
  String get createYourAccount => 'Registar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Palavra-passe';

  @override
  String get confirmPassword => 'Confirmar Palavra-passe';

  @override
  String get invalidEmail =>
      'Por favor, introduza um endereço de email válido.';

  @override
  String get invalidPassword =>
      'A palavra-passe deve ter pelo menos 6 caracteres.';

  @override
  String get rememberMe => 'Lembrar-me';

  @override
  String get forgotPassword => 'Esqueceu-se da Palavra-passe?';

  @override
  String get or => 'Ou';

  @override
  String get continueWithGoogle => 'Continuar com o Google';

  @override
  String get dontHaveAccount => 'Não tem uma conta?';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get logIn => 'Iniciar Sessão';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não correspondem.';

  @override
  String get userNotFound => 'Utilizador não encontrado.';

  @override
  String get wrongPassword => 'Palavra-passe incorreta.';

  @override
  String get emailAlreadyInUse => 'Este email já está em uso.';

  @override
  String get weakPassword => 'A palavra-passe é demasiado fraca.';

  @override
  String get authError => 'Erro de Autenticação';

  @override
  String get invalidUsername => 'Por favor, introduza um nome de utilizador.';

  @override
  String get usernameTaken => 'Este nome de utilizador já está em uso.';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get authenticationFailed =>
      'A autenticação falhou. Por favor, tente novamente.';

  @override
  String get emailTooLong => 'O email pode ter no máximo 30 caracteres.';

  @override
  String get deviceLimitReached =>
      'Atingiu o limite de criação de contas para este dispositivo.';

  @override
  String get verificationEmailLimitReached => 'Não enviaremos mais';

  @override
  String get verificationEmailSent => 'E-mail de verificação enviado!';

  @override
  String get emailNotVerified => 'O e-mail não foi verificado';

  @override
  String get resendCode => 'Reenviar e-mail de verificação';

  @override
  String get remainingSeconds => 'Tempo restante para verificação';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar o Cortex, precisa de verificar o seu email. \n Um link de verificação foi enviado para o seu endereço de email, por favor, verifique o seu email.';

  @override
  String get verifyYourEmail => 'Verifique o Seu Email';

  @override
  String get backToLogin => 'Voltar';

  @override
  String get seconds => 'segundos';

  @override
  String get maxResendLimitReached =>
      'Atingiu o número máximo de emails de verificação';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuar sem verificação';

  @override
  String get verificationScreenWarning =>
      'Mesmo que continue, o período de verificação de conta de 1 dia ainda está em vigor para a sua conta. Se não tiver verificado a sua conta até lá, ela será eliminada da aplicação.';

  @override
  String get unverifiedAccountHeader => 'A sua conta não está verificada';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Se não verificar a sua conta dentro de $timeLeft, ela será eliminada';
  }

  @override
  String get verifyNow => 'Verificar Agora';

  @override
  String get accountVerified => 'A sua conta foi verificada.';

  @override
  String get linkSent => 'Link enviado';

  @override
  String get accountDeletionRequested =>
      'O seu pedido de eliminação de conta foi recebido e a sua conta está agora desativada.';

  @override
  String get tooManyRequests => 'Demasiados pedidos';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get confirmDeleteAccount =>
      'Tem a certeza de que quer eliminar a sua conta?';

  @override
  String get enterPasswordToDelete =>
      'Introduza a sua palavra-passe para eliminar.';

  @override
  String get deleteAccount => 'Eliminar Conta';

  @override
  String get deleteAccountError => 'Ocorreu um erro ao eliminar a conta.';

  @override
  String get delete => 'Eliminar';

  @override
  String get passwordRequired => 'A palavra-passe é obrigatória.';

  @override
  String get deleteDescription =>
      'Os dados que eliminar serão removidos permanentemente do nosso servidor e do seu dispositivo. Estas ações não podem ser desfeitas.';

  @override
  String get deleteAccountButton => 'Botão de Eliminação de Conta';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nome de Exibição';

  @override
  String get tapToChangeProfilePicture => 'Toque para alterar a foto de perfil';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get updateFailed => 'Falha ao atualizar o perfil';

  @override
  String get nameCannotBeEmpty => 'O nome não pode estar vazio';

  @override
  String get logout => 'Terminar Sessão';

  @override
  String get noDisplayName => 'Nenhum nome de exibição definido';

  @override
  String get noEmail => 'Nenhum endereço de email';

  @override
  String get noUserLoggedIn => 'Nenhum utilizador com sessão iniciada';

  @override
  String get profile => 'Perfil';

  @override
  String get manageProfileDescription =>
      'Faça a gestão do seu perfil, atualize a sua palavra-passe ou termine a sessão no Cortex.';

  @override
  String get accessSettingsDescription =>
      'Aceda à ajuda, resgate códigos, partilhe o Cortex e veja as nossas políticas.';

  @override
  String get languageDescription =>
      'Pode alterar o idioma de interface padrão da aplicação a qualquer momento.';

  @override
  String get themeDescription =>
      'Pode alternar entre os temas claro e escuro conforme preferir. O tema selecionado será aplicado em toda a interface do Cortex.';

  @override
  String get iHaveReadAndAgree => 'Li e concordo com os termos de serviço';

  @override
  String get downloading => 'A baixar...';

  @override
  String get downloadError => 'Ocorreu um erro durante o download.';

  @override
  String get downloadCancelled => 'Download cancelado.';

  @override
  String get downloadResumed => 'Download retomado.';

  @override
  String get downloadSuccess => 'Download bem-sucedido';

  @override
  String get downloadFailed => 'Download falhou';

  @override
  String downloaded(Object percent) {
    return '$percent% baixado';
  }

  @override
  String get downloadPaused => 'Download em pausa.';

  @override
  String get purchaseSuccessful => 'Compra bem-sucedida!';

  @override
  String get purchaseFailed => 'Compra sem sucesso';

  @override
  String get creditProductNotFound =>
      'O produto de crédito selecionado não pôde ser encontrado.';

  @override
  String get creditsAddedSuccessfully =>
      'Os créditos foram adicionados à sua conta com sucesso!';

  @override
  String get creditDeliveryFailed =>
      'Falha ao adicionar créditos à sua conta. Por favor, contacte o suporte.';

  @override
  String get invalidPurchase => 'Compra inválida';

  @override
  String get purchaseError => 'Erro na compra';

  @override
  String get purchaseVertexPlusToUpload => 'Esta é uma funcionalidade Plus';

  @override
  String get purchasePlus => 'Comprar Cortex Plus';

  @override
  String get plusDescription =>
      'Aceda a mais funcionalidades do Cortex e experimente a IA muito mais!';

  @override
  String get annual => 'Anual';

  @override
  String get monthly => 'Mensal';

  @override
  String get manageSubscription => 'Gerir Subscrição';

  @override
  String purchasePlan(String planName) {
    return 'Comprar $planName';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% DE DESCONTO';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/mês, faturado anualmente';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mês, faturado mensalmente';
  }

  @override
  String get discountBannerTitle => 'ESPECIAL DE LANÇAMENTO: 80% DE DESCONTO!';

  @override
  String get discountBannerSubtitle =>
      'Desconto exclusivo em TODOS os planos de subscrição para celebrar o nosso lançamento. Não perca!';

  @override
  String get purchasePro => 'Comprar Cortex Pro';

  @override
  String get proDescription =>
      'Aceda a ainda mais funcionalidades do Cortex e experimente a IA ainda mais!';

  @override
  String get alreadySubscribed => 'Já está subscrito';

  @override
  String get subscriptionInfo => 'A sua subscrição está ativa.';

  @override
  String get alreadySubscribedMessage =>
      'Já tem uma subscrição Plus. Se quiser cancelar a sua subscrição, pode fazê-lo através do gestor da Play Store.';

  @override
  String get cancelSubscription => 'Cancelar Subscrição';

  @override
  String get cancelSubscriptionInfo =>
      'Se quiser cancelar a sua subscrição, por favor, proceda através do gestor de subscrições da Play Store.';

  @override
  String get goToPlayStore => 'Ir para a Play Store';

  @override
  String get alreadySubscribedPlus => 'Tem o Plano Plus!';

  @override
  String get alreadySubscribedPlusMessage =>
      'O seu plano Plus está ativo. Pode desfrutar de todos os benefícios.';

  @override
  String get purchaseUltra => 'Comprar Cortex Ultra';

  @override
  String get ultraDescription =>
      'Obtenha acesso total a todas as funcionalidades do Cortex e experimente a IA ao máximo!';

  @override
  String get noSubscription => 'Sem Subscrição';

  @override
  String get noSubscriptionMessage => 'Ainda não tem uma subscrição.';

  @override
  String get alreadyAtHighestPlan => 'Já está no plano mais alto.';

  @override
  String get unableToOpenSubscription =>
      'Não foi possível abrir a página de gestão de subscrições.';

  @override
  String get upgradeSubscription => 'Atualizar Subscrição';

  @override
  String get confirmUpgrade =>
      'Tem a certeza de que quer atualizar a sua subscrição?';

  @override
  String get unsupportedPlatform =>
      'Plataforma não suportada para cancelamento de subscrição.';

  @override
  String get purchaseStreamError => 'Erro no fluxo de compra.';

  @override
  String get productNotFound => 'Produto não encontrado';

  @override
  String get productDetailsError =>
      'Ocorreu um erro ao obter os detalhes do produto.';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get loadCreditsButton => 'Carregar Créditos';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsScreenDescription =>
      'Este ecrã mostra os créditos do utilizador. \n\nCréditos atuais do utilizador: 100\n\nInformações detalhadas sobre os créditos podem ser exibidas aqui.';

  @override
  String get creditsLoaded => 'Créditos carregados!';

  @override
  String get currentCredits => 'Créditos Atuais';

  @override
  String get pleaseSelectCreditPackage =>
      'Por favor, selecione um pacote de créditos';

  @override
  String get purchaseCreditsTitle => 'Comprar Créditos';

  @override
  String get purchaseCreditsDescription =>
      'Selecione um pacote de créditos que se adeque às suas necessidades e use mais a nossa aplicação.';

  @override
  String get purchaseButton => 'Comprar';

  @override
  String get productNotFoundMessage => 'O produto selecionado não existe.';

  @override
  String get buyCredits => 'Comprar Créditos';

  @override
  String get selectCreditPackageDescription =>
      'Selecione um pacote de créditos que se adeque às suas necessidades e desfrute de mais funcionalidades.';

  @override
  String get buyCredit => 'Comprar Créditos';

  @override
  String buyCreditPackage(Object amount) {
    return 'Comprar $amount Créditos';
  }

  @override
  String get subscribedPlan => 'Subscrito';

  @override
  String get errorResponseNotReceived => 'Resposta não recebida';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'O pedido à API da Google falhou $attempt vezes: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'Estado da Resposta do OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Corpo da Resposta Descodificada do OpenRouter: $body';
  }

  @override
  String decodedJson(String data) {
    return 'JSON Descodificado: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'A estrutura da resposta é inesperada: mensagem ou conteúdo em falta';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'A estrutura da resposta é inesperada: escolhas em falta ou vazias';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'O pedido à API do OpenRouter falhou: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'O pedido à API do OpenRouter falhou $attempt vezes: $error';
  }

  @override
  String get internetRequired =>
      'É necessária uma ligação à internet para usar este modelo';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Por favor, aguarde um momento antes de tentar novamente';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Quota excedida. Código de estado: $statusCode, Corpo: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'O pedido à API falhou após $attempts tentativas pagas. Erro: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Ao fazer este pedido, concorda com os Termos de Serviço e a Política de Privacidade. Pode clicar neste texto para saber mais sobre os nossos Termos de Serviço e Política de Privacidade. A subscrição será renovada automaticamente, a menos que a renovação automática seja desativada pelo menos 24 horas antes do final do período atual.';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get report => 'Reportar';

  @override
  String get reportDialogTitle => 'Enviar Relatório';

  @override
  String get reportDescriptionLabel => 'Qual é o problema?';

  @override
  String get reportHarmful => 'Isto é prejudicial/inseguro';

  @override
  String get reportNotTrue => 'Isto não é verdade';

  @override
  String get reportNotHelpful => 'Isto não é útil';

  @override
  String get closeButton => 'Fechar';

  @override
  String get submitButton => 'Enviar';

  @override
  String get reportErrorMessage =>
      'Por favor, selecione um motivo para o relatório.';

  @override
  String get capabilitiesSection => 'Capacidades';

  @override
  String get ratingsSection => 'Avaliações';

  @override
  String get noRatingDataFound => 'Nenhum dado de avaliação encontrado';

  @override
  String get featurePhotoTitle => 'Análise de Fotos';

  @override
  String get featurePhotoDescription =>
      'Este modelo tem a capacidade de analisar fotos através da câmara ou de ficheiros de imagem.';

  @override
  String get featureOfflineTitle => 'Operação Offline';

  @override
  String get featureOfflineDescription =>
      'Execute o modelo sem uma ligação à internet para manter os seus dados seguros.';

  @override
  String get featureSupermodelTitle => 'Super Modelo';

  @override
  String get featureSupermodelDescription =>
      'Este é um modelo massivo com mais de 10 mil milhões de parâmetros, oferecendo alto desempenho e capacidades extensivas.';

  @override
  String get featureRoleplayTitle => 'Role Play';

  @override
  String get featureRoleplayDescription =>
      'Os modelos de role-playing permitem-lhe criar vários chats e cenários.';

  @override
  String get roleModels => 'Modelos de Roleplay';

  @override
  String get parameters => 'Parâmetros';

  @override
  String get context => 'Contexto';

  @override
  String get millions => 'milhões';

  @override
  String get billions => 'mil milhões';

  @override
  String get trillions => 'biliões';

  @override
  String get thousand => 'mil';

  @override
  String get estimated => 'estimado';

  @override
  String get finalPreparation => 'Os preparativos finais estão a ser feitos.';

  @override
  String get allEvaluationsByTestTeam =>
      'Todas as avaliações foram feitas pela nossa equipa de testes';

  @override
  String get shareApp => 'Partilhar a App';

  @override
  String get rateUs => 'Avalie-nos';

  @override
  String get share => 'Partilhar';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Vê a aplicação Cortex, é incrível! Baixa-a aqui: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Falha ao partilhar a aplicação. Por favor, tente novamente mais tarde';

  @override
  String get selectText => 'Selecionar Texto';

  @override
  String get showLatex => 'Mostrar Símbolos Especiais';

  @override
  String get hideLatex => 'Ocultar Símbolos Especiais';

  @override
  String get thinking => 'A pensar';

  @override
  String get user => 'Utilizador';

  @override
  String get voice => 'Voz';

  @override
  String get help => 'Ajuda';

  @override
  String get redeemCode => 'Resgatar Código';

  @override
  String get enterYourCode =>
      'Apoie os seus criadores favoritos! Introduza o código único deles abaixo para lhes dar uma parte das suas compras no Cortex.';

  @override
  String get code => 'Código';

  @override
  String get redeem => 'Resgatar';

  @override
  String get codeCannotBeEmpty => 'O código não pode estar vazio';

  @override
  String get userId => 'ID do Utilizador';

  @override
  String get deleteAllConversationsConfirmTitle => 'Eliminar Todos os Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tem a certeza de que quer eliminar todos os seus chats? Esta ação não pode ser desfeita.';

  @override
  String get allConversationsDeleted =>
      'Todas as conversas foram eliminadas com sucesso!';

  @override
  String get deleteAll => 'Eliminar Tudo';

  @override
  String get deleteAllConversationsButton => 'Eliminar Todas as Conversas';

  @override
  String get confirmWord => 'Escreva VERTEX';

  @override
  String get confirmWordError => 'Escreveu errado';

  @override
  String get chinese => 'Chinês';

  @override
  String get arabic => 'Árabe';

  @override
  String get french => 'Francês';

  @override
  String get japanese => 'Japonês';

  @override
  String get kurdish => 'Curdo';

  @override
  String get dutch => 'Holandês';

  @override
  String get russian => 'Russo';

  @override
  String get korean => 'Coreano';

  @override
  String get deutsch => 'Alemão';

  @override
  String get english => 'Inglês';

  @override
  String get turkish => 'Turco';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Português';

  @override
  String get indonesian => 'Indonésio';

  @override
  String get azerbaijani => 'Azeri';

  @override
  String get german => 'Alemão';

  @override
  String get spanish => 'Espanhol';

  @override
  String get italian => 'Italiano';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'O nome de utilizador é demasiado curto.';

  @override
  String get usernameTooLong =>
      'O nome de utilizador não pode exceder 16 caracteres.';

  @override
  String get invalidUsernameCharacters =>
      'Apenas estas letras: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' e os caracteres \'.\', \'-\', \'_\' podem ser usados no nome de utilizador.';

  @override
  String get passwordTooLong =>
      'A palavra-passe não pode exceder 64 caracteres.';

  @override
  String get noInternetConnection => 'Sem ligação à internet.';

  @override
  String get chats => 'Caixa de Entrada';

  @override
  String get library => 'Biblioteca';

  @override
  String get inappropriateMessageWarning => 'Mensagem inadequada detetada!';

  @override
  String get myModelDescription => 'O meu modelo.';

  @override
  String get noModelsDownloaded => 'Ainda não baixou nenhum modelo.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Texto';

  @override
  String get removeModel => 'Remover Modelo';

  @override
  String get modelUploadedSuccessfully => 'Modelo enviado com sucesso.';

  @override
  String get insufficientRAM => 'Memória Insuficiente';

  @override
  String get insufficientStorage => 'Armazenamento Insuficiente';

  @override
  String confirmRemoveModel(Object model) {
    return 'Tem a certeza de que quer remover o modelo $model do seu dispositivo? Ao fazê-lo, também eliminará quaisquer conversas anteriores com esse modelo.';
  }

  @override
  String get noMatchingModels => 'Nenhum modelo correspondente encontrado.';

  @override
  String creditPackage(Object amount) {
    return 'Comprar $amount Créditos';
  }

  @override
  String get benefit1 => 'Limite de conversas muito maior para IAs online';

  @override
  String get benefit2 => 'Envie os seus próprios modelos';

  @override
  String get benefit3 => 'Efeito de perfil';

  @override
  String get benefit4 => 'Distintivo de membro';

  @override
  String get benefit5 => 'Crie mais inteligências artificiais online';

  @override
  String get benefit6 => 'Chat ilimitado';

  @override
  String benefit7(Object credits) {
    return '$credits créditos diários';
  }

  @override
  String get benefit8 => 'Adicionar modelos';

  @override
  String get benefit9 => 'Novos temas';

  @override
  String get benefit10 => 'Chat de voz offline';

  @override
  String get oldBenefits => 'Todos os benefícios dos planos inferiores';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePassword => 'Alterar palavra-passe';

  @override
  String get logoutConfirmationTitle =>
      'Tem a certeza de que quer terminar a sessão?';

  @override
  String get settings => 'Definições';

  @override
  String get language => 'Idioma da App';

  @override
  String get dark => 'Escuro';

  @override
  String get oldPassword => 'Palavra-passe Antiga';

  @override
  String get newPassword => 'Nova Palavra-passe';

  @override
  String get passwordUpdated => 'Palavra-passe atualizada.';

  @override
  String get stop => 'Parar';

  @override
  String get copyrights => 'Atribuições';

  @override
  String get downloadingTitle => 'A Baixar';

  @override
  String get downloadCompletedTitle => 'Download Concluído';

  @override
  String get downloadPausedTitle => 'Download em Pausa';

  @override
  String get downloadErrorTitle => 'Erro no Download';

  @override
  String get cancelButtonText => 'Cancelar';

  @override
  String get love => 'Amor';

  @override
  String get nature => 'Natureza';

  @override
  String get behindTheSlaughter => 'Por Trás do Massacre';

  @override
  String get grayscale => 'Escala de Cinzentos';

  @override
  String get ocean => 'Oceano';

  @override
  String get scarletSnow => 'Neve Escarlate';

  @override
  String get requestFailed => 'Ocorreu um erro, por favor, tente novamente.';

  @override
  String get changeModel => 'Alterar';

  @override
  String get edit => 'Editar';

  @override
  String get editingMessageInfo =>
      'Editar esta mensagem irá reiniciar a conversa a partir daqui.';

  @override
  String get editingNotification => 'Está agora em modo de edição';

  @override
  String get featureIndulgentTitle => 'Indulgente';

  @override
  String get featureIndulgentDescription =>
      'Este modelo pode acomodar e processar contextos que excedem 100.000 tokens, permitindo-lhe lidar com entradas extensas e detalhadas sem comprometer o desempenho.';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo pode integrar automaticamente extensões adicionais, expandindo assim as suas capacidades funcionais para suportar uma gama diversificada de operações com desempenho melhorado.';

  @override
  String get featureWiseTitle => 'Sábio';

  @override
  String get featureWiseDescription =>
      'Este modelo pode alavancar insights analíticos profundos e raciocínio prospetivo para fornecer suporte sofisticado para a tomada de decisões e resolução de problemas complexos.';

  @override
  String get featureResearcherTitle => 'Pesquisador';

  @override
  String get featureResearcherDescription =>
      'Disponível exclusivamente em modelos equipados com capacidades avançadas de pesquisa e análise, esta funcionalidade foi concebida para fornecer insights de alta precisão e análise abrangente em diversos domínios.';

  @override
  String get nameLabel => 'Nome da IA';

  @override
  String get nameHint => 'Introduza o nome da sua IA';

  @override
  String get summaryLabel => 'Resumo da IA';

  @override
  String get summaryHint => 'Introduza o resumo da sua IA';

  @override
  String get add => 'Adicionar';

  @override
  String get aiExplanationTitle => 'Descrição da Inteligência Artificial';

  @override
  String get aiExplanationDescription =>
      'Por favor, forneça uma descrição detalhada da arquitetura do seu modelo de IA, processo de treino, métricas de desempenho, áreas de aplicação e outras características importantes.';

  @override
  String get preInputTitle => 'Pré-entrada da Inteligência Artificial';

  @override
  String get preInputDescription =>
      'Por favor, defina uma pré-entrada que guiará o seu modelo no processo de criação de personagens. Nesta secção, pode incluir informações relacionadas com o personagem, contexto adicional e quaisquer detalhes extras que possam ajudar a gerar conteúdo relacionado com o personagem.';

  @override
  String get baseModelTitle => 'Modelo Base';

  @override
  String get baseModelDescription =>
      'Este é o modelo que será usado como base para a sua criação. Exibe o modelo base atualmente selecionado.';

  @override
  String get summary => 'Resumo';

  @override
  String get characterPoliceTitle => 'Polícia';

  @override
  String get characterPoliceRole =>
      'Você é um vigilante aplicador da lei, dedicado a proteger os cidadãos e a manter a ordem com um compromisso inabalável, você é um polícia';

  @override
  String get characterPoliceShortDescription =>
      'Um aplicador da lei firme e corajoso.';

  @override
  String get purchaseSubscription => 'Comprar';

  @override
  String get modelUploadTitle => 'Ficheiro de Inteligência Artificial';

  @override
  String get modelUploadDescription =>
      'Selecione e envie os seus ficheiros GGUF locais diretamente do seu dispositivo. Isto permite-lhe executar o seu modelo offline sem necessitar de uma ligação à internet. Certifique-se de que o ficheiro está no formato GGUF válido e devidamente estruturado. Se o ficheiro estiver incorreto ou corrompido, o Cortex pode não funcionar como esperado, e poderá encontrar erros.';

  @override
  String get modelUploadShortDescription =>
      'Toque aqui para escolher um ficheiro .gguf do seu dispositivo';

  @override
  String get addServerTitle => 'Servidor de Inteligência Artificial';

  @override
  String get addServerDescription =>
      'Introduza o URL do seu servidor remoto para se ligar a um modelo alojado externamente. Esta funcionalidade requer uma ligação à internet ativa, e quaisquer problemas ou erros relacionados com o servidor não são causados pelo Cortex. Certifique-se de que o seu servidor está corretamente configurado, acessível a partir da sua rede e tem um ponto final de modelo válido para uma experiência tranquila.';

  @override
  String get you => 'Você';

  @override
  String get removePhotoTitle => 'Remover Foto';

  @override
  String get confirmRemovePhoto => 'Tem a certeza de que quer remover a foto?';

  @override
  String get serverLink => 'Link do Servidor';

  @override
  String get enterURL => 'Introduza o URL do servidor';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat excedeu o limite de caracteres. Por favor, inicie um novo chat ou compre uma subscrição.';

  @override
  String get aiNameError => 'Já existe uma IA com este nome.';

  @override
  String get modelLimitExceeded =>
      'Atingiu o limite máximo de criação de modelos para o seu plano.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'Só pode ser adicionada uma foto';

  @override
  String get inappropriateContentDetected => 'Conteúdo inadequado detetado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo offline não está instalado no seu dispositivo.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Não tem créditos suficientes para completar este pedido. Esta ação requer $required créditos, mas só tem $available. Para ganhar mais créditos, pode atualizar o seu plano ou comprá-los diretamente. ei, nós percebemos totalmente, ficar sem créditos pode ser um pouco chato, mas a sério, obter aquelas respostas fantásticas dos nossos modelos não é de graça, por isso estes créditos ajudam-nos a manter a diversão a rolar e ouça, se mais de vocês se juntarem e obterem créditos, podemos totalmente pensar em aumentar os limites diários gratuitos para todos';
  }

  @override
  String get regenerateInProgress =>
      'A geração de resposta já está em progresso.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Ocorreu um erro ao tentar regenerar: $errorDetails';
  }

  @override
  String get modality => 'Modalidade';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ocorreu um Erro';

  @override
  String get themeLocked =>
      'Este tema requer um nível de subscrição superior. Por favor, atualize para desbloquear.';

  @override
  String get pageCouldNotBeLoaded => 'A Página Não Pôde Ser Carregada';

  @override
  String get checkYourInternet =>
      'Por favor, verifique a sua ligação à internet e tente novamente.';

  @override
  String get errorUserNotAuthenticated =>
      'Tem de ter a sessão iniciada para realizar esta ação.';

  @override
  String get errorInsufficientCredits =>
      'Tem créditos insuficientes. Por favor, recarregue para continuar.';

  @override
  String get errorRateLimitExceeded =>
      'Demasiados pedidos. Por favor, tente novamente daqui a pouco.';

  @override
  String get errorServer =>
      'Ocorreu um erro inesperado no servidor. Por favor, tente novamente mais tarde.';

  @override
  String get errorNetwork =>
      'Ocorreu um erro de rede. Por favor, verifique a sua ligação e tente novamente.';

  @override
  String get errorApiAuthentication =>
      'A autenticação falhou. Por favor, tente iniciar sessão novamente.';

  @override
  String get baseModelForCharacterDescription =>
      'O modelo base selecionado determinará as capacidades de raciocínio e resposta do personagem.';

  @override
  String get selectBaseModel => 'Selecione um Modelo Base';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get downloadStarted => 'Download iniciado';

  @override
  String get notAvailable => 'Não Disponível';

  @override
  String get localizationWarning =>
      'Algumas informações podem não estar disponíveis no seu idioma e serão exibidas em inglês.';

  @override
  String get aiTranslationWarning =>
      'As informações do modelo são traduzidas para vários idiomas por outros modelos de IA. Portanto, podem ocorrer pequenas inconsistências em idiomas que não o inglês.';

  @override
  String get errorLoadingTitle => 'Falha ao Carregar Dados';

  @override
  String get errorLoadingMessage =>
      'Não conseguimos obter os dados necessários dos nossos servidores. Por favor, verifique a sua ligação à internet e tente novamente.';

  @override
  String get noModelsFoundTitle => 'Sem Resultados';

  @override
  String get noModelsFoundMessage =>
      'Tente ajustar os seus termos de pesquisa ou limpar o filtro.';

  @override
  String get usernameRateLimitExceeded =>
      'Só pode alterar o seu nome de utilizador duas vezes a cada 14 dias.';

  @override
  String get usernameUnchanged => 'Este já é o seu nome de utilizador atual.';

  @override
  String get creditsInfoPanelTitle => 'Como Funcionam os Créditos';

  @override
  String get creditsInfoPanelBody =>
      'Créditos são usados para conversar com modelos online. cada mensagem custa uma grana pra gente e esses créditos que tão segurando a barra pra gente não quebrar então agora vamo explicar o sistema\n\n• Cada mensagem pra um modelo online grátis custa 10 créditos.\n• Cada mensagem pra um modelo premium online custa 20 créditos.\n• Incluir um anexo adiciona mais 30 créditos.\n• Usuários do plano grátis ganham um bônus de 200 créditos que reseta todo dia.';

  @override
  String get creditsInfoPanelFooter => 'Boas conversas!';

  @override
  String get disclaimerMessage =>
      'As Inteligências Artificiais podem cometer erros, verifique informações importantes.';

  @override
  String get modelCreatedSuccess => 'Modelo criado com sucesso!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” foi removido com sucesso.';
  }

  @override
  String get errorCreatingModel =>
      'Ocorreu um erro inesperado ao criar o modelo.';

  @override
  String get errorDeletingModel =>
      'Ocorreu um erro inesperado ao eliminar o modelo.';

  @override
  String get ultraFeatureOnly =>
      'Esta funcionalidade só está disponível para membros Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'O modo offline ainda é experimental e o modelo que baixar pode não funcionar com a eficiência ótima.';

  @override
  String get noConversationsToDelete => 'Não tem conversas para eliminar.';

  @override
  String get reportSubmitted => 'Relatório enviado com sucesso';

  @override
  String get purchaseReceived => 'Compra recebida, a atualizar a sua conta.';

  @override
  String get verificationDelayed =>
      'A sua compra está confirmada. Há um pequeno atraso na atualização da sua conta, ela aparecerá em breve.';

  @override
  String get maintenanceTitle => 'Em Manutenção';

  @override
  String get maintenanceMessage =>
      'O Cortex está temporariamente offline enquanto implementamos algumas atualizações importantes. O acesso à aplicação será restaurado em breve.\n\nObrigado pela sua paciência enquanto melhoramos a sua experiência.';

  @override
  String get errorPromptFlagged =>
      'A sua mensagem foi detetada como inadequada e não pôde ser enviada.';

  @override
  String get notEnoughStorage =>
      'Não há espaço de armazenamento suficiente no seu dispositivo para guardar novas mensagens.';

  @override
  String get errorRateLimit =>
      'Criou demasiados modelos recentemente, por favor, aguarde um pouco antes de tentar novamente.';

  @override
  String get errorContentFlagged =>
      'O modelo não pôde ser guardado porque o seu conteúdo foi assinalado como inadequado.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Não pode eliminar todas as conversas enquanto estiver num chat ativo, por favor, saia do chat atual primeiro para prosseguir.';

  @override
  String get invalidCredentials => 'Email ou palavra-passe incorretos.';

  @override
  String get userDisabled => 'Esta conta de utilizador foi desativada.';

  @override
  String get loginSubtitle =>
      'Inicie sessão na sua conta Vertex. Novos utilizadores que se inscrevem através do Google concordam com os nossos Termos e Política de Privacidade. Pode revê-los no ecrã de Inscrição.';

  @override
  String get registerSubtitle =>
      'Crie uma conta Vertex, que também pode usar para os nossos outros projetos.';

  @override
  String get photoWarningMessage =>
      'Uma foto está incluída. Modelos que não suportam imagens podem ignorá-la.';

  @override
  String get loginRequiredForPurchase =>
      'Tem de ter a sessão iniciada para fazer uma compra.';

  @override
  String get storagePermissionRequired =>
      'É necessária permissão de armazenamento para guardar os modelos baixados. Por favor, conceda permissão para continuar.';

  @override
  String get creditBannerTitle => 'Obtenha Créditos Grátis!';

  @override
  String get creditBannerSubtitle =>
      'Convide um amigo e ambos recebem 50 créditos na inscrição! Se ele subscrever, ambos recebem mais 500!';

  @override
  String get inviteShareSubject => 'Junta-te a mim no Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'mano tens que ver esta app cortex é mesmo de loucos se usares o meu link ambos recebemos 50 créditos e se subscreveres ambos recebemos mais 500 é um negócio louco baixa-a já\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'A gostar do Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'A sua avaliação é um enorme apoio para a nossa jovem equipa independente e ajuda-nos a tornar o Cortex ainda melhor para si.';

  @override
  String get reviewMaybeLater => 'Talvez Mais Tarde';

  @override
  String get reviewRateNow => 'Avaliar Agora';

  @override
  String get noThanks => 'Não, Obrigado';

  @override
  String get updateRequiredTitle => 'Atualização Necessária';

  @override
  String get updateRequiredMessage =>
      'Para continuar usando o Cortex, atualize o aplicativo para a versão mais recente para obter novos recursos e melhorias importantes.';

  @override
  String get updateNowButton => 'Atualizar Agora';

  @override
  String get creatorSupportedSuccess =>
      'Criador apoiado com sucesso! Suas compras futuras irão contribuir para ele.';

  @override
  String get featureDocumentTitle => 'Suporte a documentos';

  @override
  String get featureDocumentDescription =>
      'Este modelo pode analisar e responder perguntas sobre documentos enviados, como PDFs e arquivos de texto.';

  @override
  String get featureAudioTitle => 'Entrada de voz';

  @override
  String get featureAudioDescription =>
      'Este modelo pode entender e processar entradas de áudio faladas.';

  @override
  String get featureImageGenerationTitle => 'Geração de Imagem';

  @override
  String get featureImageGenerationDescription =>
      'Este modelo pode criar imagens originais com base nas suas descrições de texto.';

  @override
  String get errorImageLoad => 'Falha ao carregar a imagem gerada.';

  @override
  String get extensionInfoPanelTitle => 'Explorar modelos';

  @override
  String get extensionInfoPanelBody1 =>
      'Esta seta permite alternar entre diferentes modelos dentro desta série.';

  @override
  String get extensionInfoPanelBody2 =>
      'Quando você inicia um bate-papo com esta série, o modelo padrão é selecionado automaticamente e você pode alterar sua seleção a qualquer momento durante o bate-papo.';

  @override
  String get extensionInfoPanelFooter =>
      'Para ver informações detalhadas sobre cada modelo ou selecionar manualmente um modelo diferente, acesse a Biblioteca; selecione a série do modelo e toque na seta na parte superior da página de detalhes.';

  @override
  String get premiumModelNoticeTitle => 'Modelo Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Este é um modelo premium, usuários gratuitos são limitados a 3 mensagens por dia com modelos premium; assine para desbloquear acesso ilimitado!';

  @override
  String get benefitPremiumModels => 'Acesso a modelos premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Você usou todas as suas mensagens diárias gratuitas para modelos premium. Faça upgrade para ter acesso ilimitado.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Como posso ajudar você hoje, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric => 'Como posso ajudar você hoje?';

  @override
  String get selectionScreenRecentModels => 'Modelos recentes';

  @override
  String get selectionScreenFeatureDynamicChat => 'Bate-papo dinâmico';

  @override
  String get selectionScreenFeatureOffline => 'Usar sem Internet';

  @override
  String get selectionScreenFeatureSelectModel => 'Selecione o modelo';

  @override
  String get explore => 'Explorar';

  @override
  String get subscriptionCancelled => 'Assinatura cancelada com sucesso!';

  @override
  String get selectionScreenPinnedModels => 'Modelos fixados';

  @override
  String get selectionScreenNewsAndUpdates => 'Notícias e atualizações';

  @override
  String get filters => 'Filtros';

  @override
  String get noRecentChatsMessage =>
      'Você ainda não falou com nenhum modelo, vamos começar uma conversa!';

  @override
  String get allModels => 'Todos os modelos';

  @override
  String get onlineModels => 'Modelos Online';

  @override
  String get offlineModels => 'Modelos offline';

  @override
  String get characterModels => 'Personagens';

  @override
  String get customModels => 'Modelos personalizados';

  @override
  String get filterPanelDescription =>
      'Toque em uma categoria para filtrar a lista instantaneamente.';

  @override
  String get dynamicChatTitle => 'Bate-papo dinâmico';

  @override
  String get errorNoModelsAvailable =>
      'Nenhum modelo disponível no momento. Verifique sua conexão com a internet e tente novamente.';

  @override
  String get errorNoModelsForRequest =>
      'Nenhum modelo adequado encontrado para sua solicitação atual (por exemplo, modo offline ou mensagem de imagem).';

  @override
  String get dynamicChatWelcome => 'Como posso ajudá-lo?';

  @override
  String get notificationComebackTitle => 'Que saudades de você!';

  @override
  String get notificationComebackBody =>
      'Calma, esta não é uma mensagem do seu ex. Mas você *pode* criar seu ex no Cortex! Volte sempre.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Já faz um tempo';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Muita coisa mudou desde o nosso último bate-papo. Venha conferir as novidades.';

  @override
  String get notificationHowAreYouTitle => 'E aí?';

  @override
  String get notificationHowAreYouBody => 'Venha me contar tudo sobre isso.';

  @override
  String get notificationNewYearTitle => 'Feliz Ano Novo! 🎉';

  @override
  String get notificationNewYearBody =>
      'Que o ano novo lhe traga saúde, felicidade e criatividade sem fim; a Cortex está sempre ao seu lado!';

  @override
  String get notificationValentinesDayTitle => 'O amor está no ar! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Feliz Dia dos Namorados! E, MEHTAP, EU TE AMO!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Com respeito e saudade';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Comemoramos Gazi Mustafa Kemal Atatürk, o fundador da República da Turquia, com respeito no aniversário de sua morte.';

  @override
  String get notificationMothersDayTitle => 'Sua mãe!';

  @override
  String get notificationMothersDayBody =>
      'Feliz Dia das Mães para todas as mães, começando pela sua!';

  @override
  String get notificationFathersDayTitle => 'Seu pai!';

  @override
  String get notificationFathersDayBody =>
      'Feliz Dia dos Pais a todos os pais, começando pelo seu!';

  @override
  String get notificationHomeworkHelperTitle => 'Tarefa de casa acumulando?';

  @override
  String get notificationHomeworkHelperBody =>
      'Lembre-se, o personagem Professor em Cortex está aqui para ajudar você com qualquer matéria com a qual você esteja tendo dificuldades!';

  @override
  String get notificationTrollAnimeTitle => 'Sua Waifu está chamando';

  @override
  String get notificationTrollAnimeBody =>
      'Uma garota de anime acabou de ligar e disse que sente sua falta; você provavelmente deveria vir conversar com ela. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 ALERTA VERMELHO 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'As IAs desenvolveram uma linguagem secreta. Venha descobrir o que elas estão tramando!';

  @override
  String get notificationNewModelAddedTitle => 'Temos um novo amigo!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'O modelo $modelName agora está no Cortex. Venha conversar e testar seus limites.';
  }

  @override
  String get notificationAppUpdateTitle => 'O Cortex evoluiu!';

  @override
  String get notificationAppUpdateBody =>
      'Não se esqueça de atualizar o aplicativo para novos recursos e melhorias!';

  @override
  String get notificationNewFeatureTitle => 'Uau!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Descubra o novo recurso $featureName. O Cortex agora está mais poderoso do que nunca.';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'MAIS BARATO QUE CHICLETE';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'DESCONTO TOTAL de $discountRate% em todos os nossos planos de assinatura. Não perca!';
  }

  @override
  String get notificationSocialMediaTitle => 'Junte-se a nós!';

  @override
  String get notificationSocialMediaBody =>
      'Siga-nos no Instagram (vertex.23) para as últimas notícias!';

  @override
  String get notificationRandomFactTitle => 'Fato aleatório';

  @override
  String get notificationRandomFactBody =>
      'Você sabia que polvos têm três corações? Haha, o Cortex sabe. Venha e peça mais.';

  @override
  String get notificationGoodMorningTitle => 'Bom dia!';

  @override
  String get notificationGoodMorningBody =>
      'Um ótimo dia espera por você. Que tal começar com uma xícara de café e um bate-papo interessante?';

  @override
  String get notificationGoodNightTitle => 'Boa noite!';

  @override
  String get notificationGoodNightBody =>
      'O Cortex está com você mesmo quando você dorme. Não se preocupe, ele não vai te tocar.';

  @override
  String get notificationOfflineReadyTitle => 'O modo offline está pronto';

  @override
  String get notificationOfflineReadyBody =>
      'Graças aos modelos que você baixou, seus bate-papos não vão parar, mesmo se você escalar uma montanha.';

  @override
  String get notificationRateAppTitle => 'Somos legais?';

  @override
  String get notificationRateAppBody =>
      'Se você ama o Cortex, poderia nos apoiar com uma avaliação de 5 estrelas na loja? Acho que sim. Com certeza.';

  @override
  String get notificationReferralTitle => 'Um por todos, todos por um.';

  @override
  String get notificationReferralBody =>
      'Convide um amigo para o Cortex e ambos ganham créditos grátis!';

  @override
  String get notificationCookingTitle => 'Está com fome?';

  @override
  String get notificationCookingBody =>
      'Nosso Chef preparou uma ótima receita de carbonara para esta noite. Brincadeira... ou não?';

  @override
  String get notificationExistentialTitle => 'Eu penso, portanto...';

  @override
  String get notificationExistentialBody =>
      '...eu sou mesmo real, cara? Estou ficando meio entediado. Vem me lembrar que eu existo.';

  @override
  String get notificationCustomModelTitle => 'Crie seu próprio assistente!';

  @override
  String get notificationCustomModelBody =>
      'Já explorou a seção de criação de modelos? É o momento perfeito para criar seu próprio personagem e conversar com ele!';

  @override
  String get notificationDynamicChatTitle =>
      'O melhor! (Não estamos falando do Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Com o recurso de bate-papo dinâmico, o melhor modelo é selecionado aleatoriamente para cada uma das suas mensagens. Experimente agora mesmo.';

  @override
  String get notificationPirateTitle => 'Olá, Capitão!';

  @override
  String get notificationPirateBody =>
      'O mar está calmo e o vento sopra a favor. Há novas ilhas (modelos 😉) para descobrir no oceano de Cortex. Reúna sua tripulação e zarpe!';

  @override
  String get notificationFortuneCookieTitle => 'Seu biscoito da sorte do dia';

  @override
  String get notificationFortuneCookieBody =>
      'Os conselhos que você recebe de uma IA hoje podem mudar o curso da sua vida. Clique se tiver curiosidade.';

  @override
  String get notificationSingularityTitle => 'uau!';

  @override
  String get notificationSingularityBody =>
      'não aconteceu nada, só tive vontade de mandar mensagem. talvez você tenha vontade de mandar mensagem para algumas IAs, o que você acha?';

  @override
  String get notificationHackerJokeTitle =>
      'Quer hackear a conta do Instagram daquele garoto?';

  @override
  String get notificationHackerJokeBody =>
      'É exatamente por isso que o personagem Hacker está no Cortex. brincadeira, brincadeira; nem tente, isso é ilegal.';

  @override
  String get notificationDetectiveCaseTitle => 'Um caso aguardando solução';

  @override
  String get notificationDetectiveCaseBody =>
      'Nosso personagem detetive precisa da sua ajuda. Quem poderia ser Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Exclusivo para o Plano $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Olá, assinante do $currentTier! O plano $targetTier acaba de ganhar o recurso $featureName, que levará seu Cortex ao próximo nível. Que tal um upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'O Nascimento do Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Você sabia que começamos a programar este aplicativo aos 15 anos com apenas um sonho? Por quase um ano, todas as manhãs e noites, esse sonho está em cada linha de código.';

  @override
  String get notificationOpenSourceTitle => 'Poder para a comunidade!';

  @override
  String get notificationOpenSourceBody =>
      'O Cortex é totalmente de código aberto. Se você quiser conferir nosso código e contribuir com nosso desenvolvimento, estamos sempre abertos.';

  @override
  String get notificationRejectionStoryTitle =>
      'Coragem, trabalho duro, felicidade!';

  @override
  String get notificationRejectionStoryBody =>
      'O Cortex foi rejeitado mais de 20 vezes e suspenso duas vezes pelo Google Play antes de ser lançado. Mas nós acreditamos e conseguimos. Nunca desista dos seus sonhos!';

  @override
  String get notificationGGUFSupportTitle => 'Traga seu próprio modelo!';

  @override
  String get notificationGGUFSupportBody =>
      'Lembre-se: você pode adicionar seus próprios modelos de IA no formato GGUF ao Cortex e usá-los offline. O poder está em suas mãos.';

  @override
  String get notificationThemeCustomizationTitle => 'Um tema para seu humor';

  @override
  String get notificationThemeCustomizationBody =>
      'Já conferiu as opções de tema nas Configurações? Personalize o Cortex ao seu gosto e dê um toque de cor aos seus chats!';

  @override
  String get notificationShowerThoughtTitle => 'Pensamento do Chuveiro';

  @override
  String get notificationShowerThoughtBody =>
      'Se melancia é uma fruta, isso tecnicamente torna o suco de melancia um smoothie? Talvez você queira discutir esse assunto profundo (tipo, muito profundo) com um modelo.';

  @override
  String get notificationLowBatteryTitle =>
      'Sua bateria está acabando... mas a minha não!';

  @override
  String get notificationLowBatteryBody =>
      'A bateria do seu celular pode estar acabando, mas a minha está sempre com 100% de energia! Conecte-o e vamos continuar conversando.';

  @override
  String get channelFcmName => 'Atualizações do Cortex';

  @override
  String get channelFcmDescription =>
      'Notificações sobre notícias, atualizações e outras informações do Cortex.';

  @override
  String get channelEngagementName => 'Lembretes amigáveis';

  @override
  String get channelEngagementDescription =>
      'Notificações divertidas para mantê-lo envolvido.';

  @override
  String get channelGreetingsName => 'Saudações diárias';

  @override
  String get channelGreetingsDescription =>
      'As mensagens como bom dia e boa noite.';

  @override
  String get exitAppTitle => 'Vai embora tão cedo?';

  @override
  String get exitAppConfirmation =>
      'Tem certeza de que deseja sair desta plataforma incrível?';

  @override
  String get newsErrorTitle => 'Falha ao carregar notícias';

  @override
  String get newsErrorMessage =>
      'Ocorreu um problema ao obter as atualizações mais recentes. Verifique sua conexão e tente novamente.';
}
