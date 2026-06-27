// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'VocÃª Ã© um gerador de tÃ­tulos. Responda SOMENTE com um tÃ­tulo de 2 a 5 palavras para a conversa a seguir. NÃ£o use aspas, prefixos ou pontuaÃ§Ã£o. IMPORTANTE: O tÃ­tulo DEVE estar exatamente no mesmo idioma da mensagem do usuÃ¡rio.';

  @override
  String get systemRoleFallback => 'VocÃª Ã© um assistente prestativo.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRÃTICO: Responda sempre no mesmo idioma em que o usuÃ¡rio escreve, preste atenÃ§Ã£o Ã  linguagem do usuÃ¡rio.';

  @override
  String get systemNotePreviousMedia =>
      '[Nota do Sistema: Abaixo estÃ¡ a mÃ­dia gerada anteriormente. VocÃª pode referenciÃ¡-la ou editÃ¡-la.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nData e hora atuais: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalise a conversa atÃ© o momento. Se vocÃª aprendeu QUALQUER novo fato distinto sobre o usuÃ¡rio (preferÃªncias, nome, hÃ¡bitos, contexto), vocÃª DEVE exibir TODA a sua memÃ³ria atualizada sobre o usuÃ¡rio dentro das tags <memory>...</memory> NO FINAL da sua resposta. CRÃTICO: VocÃª NUNCA deve apagar ou sobrescrever a memÃ³ria anterior. SEMPRE anexe novos fatos Ã  memÃ³ria existente. Se absolutamente nada de novo foi aprendido, omita a tag. Exemplo: <memory>Gosta de futebol e tÃªnis. Prefere respostas curtas.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nLembre-se sempre disto sobre o usuÃ¡rio:\n$userMemory';
  }

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
  String get locked => 'Locked';

  @override
  String get languageModels => 'Modelos de linguagem';

  @override
  String get light => 'Claro';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'NÃ£o';

  @override
  String get yes => 'Sim';

  @override
  String get done => 'ConcluÃ­do';

  @override
  String get bestValue => 'Melhor Valor';

  @override
  String get selected => 'Selecionado';

  @override
  String get descriptionSection => 'DescriÃ§Ã£o';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String get messageHint => 'Pergunte qualquer coisa';

  @override
  String get messageCopied =>
      'Mensagem copiada para a Ã¡rea de transferÃªncia.';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get systemInfo => 'InformaÃ§Ãµes do Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'MemÃ³ria do Dispositivo: $memory GB';
  }

  @override
  String get memory => 'MemÃ³ria';

  @override
  String get storage => 'Armazenamento';

  @override
  String get freeStorage => 'Armazenamento Livre';

  @override
  String get totalStorage => 'Armazenamento Total';

  @override
  String get usedStorage => 'Armazenamento Usado';

  @override
  String get totalMemory => 'MemÃ³ria Total';

  @override
  String get usedMemory => 'MemÃ³ria Usada';

  @override
  String get modelsTitle => 'Biblioteca';

  @override
  String get localModels => 'Modelos Locais';

  @override
  String get selectGGUFFile => 'Selecione o Ficheiro GGUF';

  @override
  String get errorGGUF =>
      'Por favor, selecione um ficheiro apenas no formato GGUF.';

  @override
  String get myModels => 'Os Meus Modelos';

  @override
  String get create => 'Criar';

  @override
  String modelProducer(Object producer) {
    return 'Produtor: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Renomear';

  @override
  String get newTitle => 'Novo TÃ­tulo';

  @override
  String get save => 'Guardar';

  @override
  String get noConversationsMessage => 'Sem conversas, comece a conversar!';

  @override
  String get startChat => 'Iniciar uma conversa';

  @override
  String get noChats => 'Sem Chats';

  @override
  String get noStarredChats => 'Sem Chats Favoritos';

  @override
  String get noStarredChatsMessage =>
      'Ainda nÃ£o marcou um chat como favorito.';

  @override
  String get starConversation => 'Favorito';

  @override
  String get unstarConversation => 'Unstar';

  @override
  String get loginToYourAccount => 'Iniciar SessÃ£o';

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
      'Por favor, introduza um endereÃ§o de email vÃ¡lido.';

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
  String get dontHaveAccount => 'NÃ£o tem uma conta?';

  @override
  String get alreadyHaveAccount => 'JÃ¡ tem uma conta?';

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get logIn => 'Iniciar SessÃ£o';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe nÃ£o correspondem.';

  @override
  String get wrongPassword => 'Palavra-passe incorreta.';

  @override
  String get emailAlreadyInUse => 'Este email jÃ¡ estÃ¡ em uso.';

  @override
  String get weakPassword => 'A palavra-passe Ã© demasiado fraca.';

  @override
  String get authError => 'Erro de AutenticaÃ§Ã£o';

  @override
  String get usernameTaken => 'Este nome de utilizador jÃ¡ estÃ¡ em uso.';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get resendCode => 'Reenviar e-mail de verificaÃ§Ã£o';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar o Cortex, precisa de verificar o seu email. \nUm link de verificaÃ§Ã£o foi enviado para o seu endereÃ§o de email, por favor, verifique o seu email.';

  @override
  String get verifyYourEmail => 'Verifique o Seu Email';

  @override
  String get seconds => 'segundos';

  @override
  String get maxResendLimitReached =>
      'Atingiu o nÃºmero mÃ¡ximo de emails de verificaÃ§Ã£o';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuar sem verificaÃ§Ã£o';

  @override
  String get verificationScreenWarning =>
      'Mesmo que continue, o perÃ­odo de verificaÃ§Ã£o de conta de 1 dia ainda estÃ¡ em vigor para a sua conta. Se nÃ£o tiver verificado a sua conta atÃ© lÃ¡, ela serÃ¡ eliminada da aplicaÃ§Ã£o.';

  @override
  String get unverifiedAccountHeader => 'A sua conta nÃ£o estÃ¡ verificada';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Se nÃ£o verificar a sua conta dentro de $timeLeft, ela serÃ¡ eliminada';
  }

  @override
  String get verifyNow => 'Verificar Agora';

  @override
  String get linkSent => 'Link enviado';

  @override
  String get accountDeletionRequested =>
      'O seu pedido de eliminaÃ§Ã£o de conta foi recebido e a sua conta estÃ¡ agora desativada.';

  @override
  String get tooManyRequests => 'Demasiados pedidos';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get confirmDeleteAccount =>
      'Tem a certeza de que quer eliminar a sua conta?';

  @override
  String get deleteAccount => 'Eliminar Conta';

  @override
  String get delete => 'Eliminar';

  @override
  String get passwordRequired => 'A palavra-passe Ã© obrigatÃ³ria.';

  @override
  String get deleteDescription =>
      'Os dados que eliminar serÃ£o removidos permanentemente do nosso servidor e do seu dispositivo. Estas aÃ§Ãµes nÃ£o podem ser desfeitas.';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nome de ExibiÃ§Ã£o';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get logout => 'Terminar SessÃ£o';

  @override
  String get profile => 'Perfil';

  @override
  String get manageProfileDescription =>
      'FaÃ§a a gestÃ£o do seu perfil, atualize a sua palavra-passe ou termine a sessÃ£o no Cortex.';

  @override
  String get accessSettingsDescription =>
      'Aceda Ã  ajuda, resgate cÃ³digos, partilhe o Cortex e veja as nossas polÃ­ticas.';

  @override
  String get languageDescription =>
      'Pode alterar o idioma de interface padrÃ£o da aplicaÃ§Ã£o a qualquer momento.';

  @override
  String get themeDescription =>
      'Pode alternar entre os temas claro e escuro conforme preferir. O tema selecionado serÃ¡ aplicado em toda a interface do Cortex.';

  @override
  String get iHaveReadAndAgree => 'Li e concordo com os termos de serviÃ§o';

  @override
  String get downloading => 'A baixar...';

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
  String get purchaseError => 'Erro na compra';

  @override
  String get purchasePlus => 'Comprar Cortex Plus';

  @override
  String get plusDescription =>
      'ExperiÃªncia de InteligÃªncia Artificial de Elite';

  @override
  String get annual => 'Anual';

  @override
  String get monthly => 'Mensal';

  @override
  String get manageSubscription => 'Gerir SubscriÃ§Ã£o';

  @override
  String purchasePlan(String planName) {
    return 'Comprar $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mÃªs, cobrado mensalmente';
  }

  @override
  String get purchasePro => 'Comprar Cortex Pro';

  @override
  String get proDescription =>
      'ExperiÃªncia de InteligÃªncia Artificial de Primeira Classe';

  @override
  String get purchaseUltra => 'Comprar Cortex Ultra';

  @override
  String get ultraDescription => 'O auge da inteligÃªncia artificial';

  @override
  String get upgradeSubscription => 'Atualizar SubscriÃ§Ã£o';

  @override
  String get purchaseStreamError => 'Erro no fluxo de compra.';

  @override
  String get productNotFound => 'Produto nÃ£o encontrado';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Ao fazer este pedido, concorda com os Termos de ServiÃ§o e a PolÃ­tica de Privacidade. Pode clicar neste texto para saber mais sobre os nossos Termos de ServiÃ§o e PolÃ­tica de Privacidade. A subscriÃ§Ã£o serÃ¡ renovada automaticamente, a menos que a renovaÃ§Ã£o automÃ¡tica seja desativada pelo menos 24 horas antes do final do perÃ­odo atual.';

  @override
  String get termsOfService => 'Termos de ServiÃ§o';

  @override
  String get privacyPolicy => 'PolÃ­tica de Privacidade';

  @override
  String get renamed => 'Renomeado';

  @override
  String get report => 'Reportar';

  @override
  String get reportDialogTitle => 'Enviar RelatÃ³rio';

  @override
  String get reportDescriptionLabel => 'Qual Ã© o problema?';

  @override
  String get reportHarmful => 'Isto Ã© prejudicial/inseguro';

  @override
  String get reportNotTrue => 'Isto nÃ£o Ã© verdade';

  @override
  String get reportNotHelpful => 'Isto nÃ£o Ã© Ãºtil';

  @override
  String get closeButton => 'Fechar';

  @override
  String get submitButton => 'Enviar';

  @override
  String get reportErrorMessage =>
      'Por favor, selecione um motivo para o relatÃ³rio.';

  @override
  String get capabilitiesSection => 'Capacidades';

  @override
  String get featurePhotoTitle => 'AnÃ¡lise de Fotos';

  @override
  String get featurePhotoDescription =>
      'Este modelo tem a capacidade de analisar fotos atravÃ©s da cÃ¢mara ou de ficheiros de imagem.';

  @override
  String get featureOfflineTitle => 'OperaÃ§Ã£o Offline';

  @override
  String get featureOfflineDescription =>
      'Execute o modelo sem uma ligaÃ§Ã£o Ã  internet para manter os seus dados seguros.';

  @override
  String get featureRoleplayTitle => 'Role Play';

  @override
  String get featureRoleplayDescription =>
      'Os modelos de role-playing permitem-lhe criar vÃ¡rios chats e cenÃ¡rios.';

  @override
  String get roleModels => 'Modelos de Roleplay';

  @override
  String get parameters => 'ParÃ¢metros';

  @override
  String get context => 'Contexto';

  @override
  String get finalPreparation => 'Os preparativos finais estÃ£o a ser feitos.';

  @override
  String get shareApp => 'Partilhar a App';

  @override
  String get ourStory => 'Nossa histÃ³ria';

  @override
  String get rateUs => 'Avalie-nos';

  @override
  String get share => 'Partilhar';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Selecionar Texto';

  @override
  String get thinking => 'A pensar';

  @override
  String get user => 'Utilizador';

  @override
  String get help => 'Ajuda';

  @override
  String get supportCreator => 'Apoie um criador';

  @override
  String get enterYourTag =>
      'Apoie seus criadores favoritos! Insira a tag exclusiva deles abaixo para que recebam uma parte das suas compras no Cortex.';

  @override
  String get creatorTag => 'Etiqueta do criador';

  @override
  String get support => 'Apoiar';

  @override
  String get tagCannotBeEmpty => 'A tag do criador nÃ£o pode estar vazia.';

  @override
  String get userId => 'ID do Utilizador';

  @override
  String get deleteAllConversationsConfirmTitle => 'Eliminar Todos os Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tem a certeza de que quer eliminar todos os seus chats? Esta aÃ§Ã£o nÃ£o pode ser desfeita.';

  @override
  String get conversationDeleted => 'Conversa apagada!';

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
  String get chinese => 'ChinÃªs';

  @override
  String get french => 'FrancÃªs';

  @override
  String get japanese => 'JaponÃªs';

  @override
  String get dutch => 'HolandÃªs';

  @override
  String get russian => 'Russo';

  @override
  String get korean => 'Coreano';

  @override
  String get english => 'InglÃªs';

  @override
  String get turkish => 'Turco';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'PortuguÃªs';

  @override
  String get indonesian => 'IndonÃ©sio';

  @override
  String get azerbaijani => 'Azeri';

  @override
  String get german => 'AlemÃ£o';

  @override
  String get spanish => 'Espanhol';

  @override
  String get italian => 'Italiano';

  @override
  String get arabic => 'Ã¡rabe';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'O nome de utilizador Ã© demasiado curto.';

  @override
  String get usernameTooLong =>
      'O nome de utilizador nÃ£o pode exceder 16 caracteres.';

  @override
  String get invalidUsernameCharacters =>
      'Apenas estas letras: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' e os caracteres \'.\', \'-\', \'_\' podem ser usados no nome de utilizador.';

  @override
  String get noInternetConnection => 'Sem ligaÃ§Ã£o Ã  internet.';

  @override
  String get chats => 'Caixa de Entrada';

  @override
  String get library => 'Biblioteca';

  @override
  String get text => 'Texto';

  @override
  String get removeModel => 'Remover Modelo';

  @override
  String get insufficientRAM => 'MemÃ³ria Insuficiente';

  @override
  String get insufficientStorage => 'Armazenamento Insuficiente';

  @override
  String confirmRemoveModel(Object model) {
    return 'Tem certeza de que deseja remover o modelo $model do seu dispositivo? Ao fazer isso, todas as conversas anteriores com esse modelo tambÃ©m serÃ£o excluÃ­das.';
  }

  @override
  String get noMatchingModels => 'Nenhum modelo correspondente encontrado.';

  @override
  String get benefit1 => 'Aumento dos limites de conversa';

  @override
  String get benefit3 => 'Efeito de perfil';

  @override
  String get benefit4 => 'Distintivo de membro';

  @override
  String get benefit5 => 'Crie mais inteligÃªncias artificiais online';

  @override
  String get benefit7 => 'Mais limites de uso';

  @override
  String get benefit8 => 'Adicionar modelos';

  @override
  String get benefit9 => 'Novos temas';

  @override
  String get benefit10 => 'Mais anexos';

  @override
  String get benefit11 => 'Mais modo de fluxo';

  @override
  String get oldBenefits => 'Todos os benefÃ­cios dos planos inferiores';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePassword => 'Alterar palavra-passe';

  @override
  String get logoutConfirmationTitle =>
      'Tem a certeza de que quer terminar a sessÃ£o?';

  @override
  String get settings => 'DefiniÃ§Ãµes';

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
  String get copyrights => 'AtribuiÃ§Ãµes';

  @override
  String get love => 'Amor';

  @override
  String get nature => 'Natureza';

  @override
  String get behindTheSlaughter => 'Por TrÃ¡s do Massacre';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

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
      'Editar esta mensagem irÃ¡ reiniciar a conversa a partir daqui.';

  @override
  String get editingNotification => 'EstÃ¡ agora em modo de ediÃ§Ã£o';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo pode integrar automaticamente extensÃµes adicionais, expandindo assim as suas capacidades funcionais para suportar uma gama diversificada de operaÃ§Ãµes com desempenho melhorado.';

  @override
  String get nameLabel => 'Nome da IA';

  @override
  String get summaryLabel => 'Resumo da IA';

  @override
  String get add => 'Adicionar';

  @override
  String get aiExplanationTitle => 'DescriÃ§Ã£o da InteligÃªncia Artificial';

  @override
  String get aiExplanationDescription =>
      'Por favor, forneÃ§a uma descriÃ§Ã£o detalhada da arquitetura do seu modelo de IA, processo de treino, mÃ©tricas de desempenho, Ã¡reas de aplicaÃ§Ã£o e outras caracterÃ­sticas importantes.';

  @override
  String get preInputTitle => 'PrÃ©-entrada da InteligÃªncia Artificial';

  @override
  String get preInputDescription =>
      'Por favor, defina uma prÃ©-entrada que guiarÃ¡ o seu modelo no processo de criaÃ§Ã£o de personagens. Nesta secÃ§Ã£o, pode incluir informaÃ§Ãµes relacionadas com o personagem, contexto adicional e quaisquer detalhes extras que possam ajudar a gerar conteÃºdo relacionado com o personagem.';

  @override
  String get baseModelTitle => 'Modelo Base';

  @override
  String get baseModelDescription =>
      'Este Ã© o modelo que serÃ¡ usado como base para a sua criaÃ§Ã£o. Exibe o modelo base atualmente selecionado.';

  @override
  String get summary => 'Resumo';

  @override
  String get modelUploadTitle => 'Ficheiro de InteligÃªncia Artificial';

  @override
  String get modelUploadDescription =>
      'Selecione e envie os seus ficheiros GGUF locais diretamente do seu dispositivo. Isto permite-lhe executar o seu modelo offline sem necessitar de uma ligaÃ§Ã£o Ã  internet. Certifique-se de que o ficheiro estÃ¡ no formato GGUF vÃ¡lido e devidamente estruturado. Se o ficheiro estiver incorreto ou corrompido, o Cortex pode nÃ£o funcionar como esperado, e poderÃ¡ encontrar erros.';

  @override
  String get modelUploadShortDescription =>
      'Toque aqui para escolher um ficheiro .gguf do seu dispositivo';

  @override
  String get you => 'VocÃª';

  @override
  String get removePhotoTitle => 'Remover Foto';

  @override
  String get confirmRemovePhoto => 'Tem a certeza de que quer remover a foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat excedeu o limite de caracteres. Por favor, inicie um novo chat ou compre uma subscriÃ§Ã£o.';

  @override
  String get inappropriateContentDetected => 'ConteÃºdo inadequado detetado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo offline nÃ£o estÃ¡ instalado no seu dispositivo.';

  @override
  String get reachedLimit =>
      'VocÃª atingiu seu limite de uso; para obter mais limites, vocÃª pode atualizar seu plano. (Ei, nÃ³s entendemos que ficar sem limites Ã© uma chatice. Mas, falando sÃ©rio, receber aquelas respostas incrÃ­veis nÃ£o Ã© de graÃ§a, entÃ£o esses limites nos ajudam a manter a diversÃ£o rolando.)';

  @override
  String get modality => 'Modalidade';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ocorreu um Erro';

  @override
  String get themeLocked =>
      'Este tema requer um nÃ­vel de subscriÃ§Ã£o superior. Por favor, atualize para desbloquear.';

  @override
  String get pageCouldNotBeLoaded => 'A PÃ¡gina NÃ£o PÃ´de Ser Carregada';

  @override
  String get checkYourInternet =>
      'Por favor, verifique a sua ligaÃ§Ã£o Ã  internet e tente novamente.';

  @override
  String get errorUserNotAuthenticated =>
      'Tem de ter a sessÃ£o iniciada para realizar esta aÃ§Ã£o.';

  @override
  String get errorReachedLimit =>
      'VocÃª atingiu seu limite. FaÃ§a um upgrade para desbloquear mais conteÃºdo e continue conversando.';

  @override
  String get errorServer =>
      'Ocorreu um erro inesperado no servidor. Por favor, tente novamente mais tarde.';

  @override
  String get errorNetwork =>
      'Ocorreu um erro de rede. Por favor, verifique a sua ligaÃ§Ã£o e tente novamente.';

  @override
  String get baseModelForCharacterDescription =>
      'O modelo base selecionado determinarÃ¡ as capacidades de raciocÃ­nio e resposta do personagem.';

  @override
  String get selectBaseModel => 'Selecione um Modelo Base';

  @override
  String get falErrorImageRequired =>
      'Esta IA requer uma imagem de referÃªncia. Por favor, anexe uma imagem e tente novamente.';

  @override
  String get falErrorAudioRequired =>
      'Este modelo requer um arquivo de Ã¡udio de referÃªncia. Por favor, anexe um arquivo de Ã¡udio e tente novamente.';

  @override
  String get falErrorVideoRequired =>
      'Este modelo requer um vÃ­deo de referÃªncia. Por favor, anexe um vÃ­deo e tente novamente.';

  @override
  String get falErrorImageCorrupted =>
      'A imagem enviada nÃ£o pÃ´de ser processada. Por favor, tente um formato diferente.';

  @override
  String get falErrorSchemaRejected =>
      'O modelo rejeitou a entrada. Por favor, tente um modelo diferente.';

  @override
  String get falErrorSchemaInvalid =>
      'A entrada foi rejeitada pelo serviÃ§o de geraÃ§Ã£o.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'O serviÃ§o de geraÃ§Ã£o retornou um erro (status $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'NÃ£o foi possÃ­vel abrir o link';

  @override
  String get downloadStarted => 'Download iniciado';

  @override
  String get notAvailable => 'NÃ£o DisponÃ­vel';

  @override
  String get localizationWarning =>
      'Algumas informaÃ§Ãµes podem nÃ£o estar disponÃ­veis no seu idioma e serÃ£o exibidas em inglÃªs.';

  @override
  String get aiTranslationWarning =>
      'As informaÃ§Ãµes do modelo sÃ£o traduzidas para vÃ¡rios idiomas por outros modelos de IA. Portanto, podem ocorrer pequenas inconsistÃªncias em idiomas que nÃ£o o inglÃªs.';

  @override
  String get errorLoadingTitle => 'Falha ao Carregar Dados';

  @override
  String get errorLoadingMessage =>
      'NÃ£o conseguimos obter os dados necessÃ¡rios dos nossos servidores. Por favor, verifique a sua ligaÃ§Ã£o Ã  internet e tente novamente.';

  @override
  String get noFoundTitle => 'Sem Resultados';

  @override
  String get noFoundMessage =>
      'Tente ajustar os seus termos de pesquisa ou limpar o filtro.';

  @override
  String get modelCreatedSuccess => 'Modelo criado com sucesso!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ foi removido com sucesso.';
  }

  @override
  String get errorCreatingModel =>
      'Ocorreu um erro inesperado ao criar o modelo.';

  @override
  String get errorDeletingModel =>
      'Ocorreu um erro inesperado ao eliminar o modelo.';

  @override
  String get ultraFeatureOnly =>
      'Esta funcionalidade sÃ³ estÃ¡ disponÃ­vel para membros Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'O modo offline ainda Ã© experimental e o modelo que baixar pode nÃ£o funcionar com a eficiÃªncia Ã³tima.';

  @override
  String get noConversationsToDelete => 'NÃ£o tem conversas para eliminar.';

  @override
  String get reportSubmitted => 'RelatÃ³rio enviado com sucesso';

  @override
  String get verificationDelayed =>
      'A sua compra estÃ¡ confirmada. HÃ¡ um pequeno atraso na atualizaÃ§Ã£o da sua conta, ela aparecerÃ¡ em breve.';

  @override
  String get maintenanceTitle => 'Em ManutenÃ§Ã£o';

  @override
  String get maintenanceMessage =>
      'O Cortex estÃ¡ temporariamente offline enquanto implementamos algumas atualizaÃ§Ãµes importantes. O acesso Ã  aplicaÃ§Ã£o serÃ¡ restaurado em breve.\n\nObrigado pela sua paciÃªncia enquanto melhoramos a sua experiÃªncia.';

  @override
  String get errorPromptFlagged =>
      'A sua mensagem foi detetada como inadequada e nÃ£o pÃ´de ser enviada.';

  @override
  String get notEnoughStorage =>
      'NÃ£o hÃ¡ espaÃ§o de armazenamento suficiente no seu dispositivo para guardar novas mensagens.';

  @override
  String get errorRateLimit =>
      'Criou demasiados modelos recentemente, por favor, aguarde um pouco antes de tentar novamente.';

  @override
  String get errorContentFlagged =>
      'O modelo nÃ£o pÃ´de ser guardado porque o seu conteÃºdo foi assinalado como inadequado.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'NÃ£o pode eliminar todas as conversas enquanto estiver num chat ativo, por favor, saia do chat atual primeiro para prosseguir.';

  @override
  String get invalidCredentials => 'Email ou palavra-passe incorretos.';

  @override
  String get userDisabled => 'Esta conta de utilizador foi desativada.';

  @override
  String get loginSubtitle =>
      'FaÃ§a login na sua conta Vertex. Ao continuar, vocÃª concorda com nossos Termos de ServiÃ§o e PolÃ­tica de Privacidade.';

  @override
  String get registerSubtitle =>
      'Crie uma conta Vertex para acesso integrado a todos os nossos serviÃ§os. Ao continuar, vocÃª concorda com nossos Termos de ServiÃ§o e PolÃ­tica de Privacidade.';

  @override
  String get storagePermissionRequired =>
      'Ã‰ necessÃ¡ria permissÃ£o de armazenamento para guardar os modelos baixados. Por favor, conceda permissÃ£o para continuar.';

  @override
  String get inviteShareSubject => 'Junta-te a mim no Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ei tem esse app insano chamado cortex se vocÃª convidar galera a gente ganha plus de graÃ§a OFERTAÃ‡O BAIXA LOGO\n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'A gostar do Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'A sua avaliaÃ§Ã£o Ã© um enorme apoio para a nossa jovem equipa independente e ajuda-nos a tornar o Cortex ainda melhor para si.';

  @override
  String get reviewMaybeLater => 'Talvez Mais Tarde';

  @override
  String get reviewRateNow => 'Avaliar Agora';

  @override
  String get noThanks => 'NÃ£o, Obrigado';

  @override
  String get updateRequiredTitle => 'AtualizaÃ§Ã£o NecessÃ¡ria';

  @override
  String get updateRequiredMessage =>
      'Para continuar usando o Cortex, atualize o aplicativo para a versÃ£o mais recente para obter novos recursos e melhorias importantes.';

  @override
  String get updateNowButton => 'Atualizar Agora';

  @override
  String get creatorSupportedSuccess =>
      'Criador apoiado com sucesso! Suas compras futuras irÃ£o contribuir para ele.';

  @override
  String get featureDocumentTitle => 'Suporte a documentos';

  @override
  String get featureDocumentDescription =>
      'Este modelo pode analisar e responder perguntas sobre documentos enviados, como PDFs e arquivos de texto.';

  @override
  String get featureImageGenerationTitle => 'GeraÃ§Ã£o de Imagem';

  @override
  String get featureImageGenerationDescription =>
      'Este modelo pode criar imagens originais com base nas suas descriÃ§Ãµes de texto.';

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
  String get premiumModelNoticeTitle => 'Modelo Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Esta IA Ã© uma IA premium; usuÃ¡rios gratuitos tÃªm acesso limitado Ã s IAs premium; atualize para desbloquear o acesso ilimitado!';

  @override
  String get benefitPremiumModels => 'Acesso a modelos premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'VocÃª usou todas as suas mensagens diÃ¡rias gratuitas para modelos premium. FaÃ§a upgrade para ter acesso ilimitado.';

  @override
  String get useOffline => 'Usar sem Internet';

  @override
  String get explore => 'Explorar';

  @override
  String get news => 'NotÃ­cias';

  @override
  String get createAI => 'Criar';

  @override
  String get shortcuts => 'Atalhos';

  @override
  String get allModels => 'Todos os modelos';

  @override
  String get onlineModels => 'Modelos de linguagem';

  @override
  String get offlineModels => 'Modelos offline';

  @override
  String get characterModels => 'Personagens';

  @override
  String get customModels => 'Modelos personalizados';

  @override
  String get dynamicChatTitle => 'Bate-papo dinÃ¢mico';

  @override
  String get errorNoModelsAvailable =>
      'Nenhum modelo disponÃ­vel no momento. Verifique sua conexÃ£o com a internet e tente novamente.';

  @override
  String get notificationComebackTitle => 'Que saudades de vocÃª!';

  @override
  String get notificationComebackBody =>
      'Calma, esta nÃ£o Ã© uma mensagem do seu ex. Mas vocÃª *pode* criar seu ex no Cortex! Volte sempre.';

  @override
  String get notificationLongTimeNoSeeTitle => 'JÃ¡ faz um tempo';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Muita coisa mudou desde o nosso Ãºltimo bate-papo. Venha conferir as novidades.';

  @override
  String get notificationHowAreYouTitle => 'E aÃ­?';

  @override
  String get notificationHowAreYouBody => 'Venha me contar tudo sobre isso.';

  @override
  String get notificationNewYearTitle => 'Feliz Ano Novo! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Que o ano novo lhe traga saÃºde, felicidade e criatividade sem fim; a Cortex estÃ¡ sempre ao seu lado!';

  @override
  String get notificationValentinesDayTitle => 'O amor estÃ¡ no ar! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Feliz Dia dos Namorados! E, MEHTAP, EU TE AMO!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Com respeito e saudade';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Comemoramos Gazi Mustafa Kemal AtatÃ¼rk, o fundador da RepÃºblica da Turquia, com respeito no aniversÃ¡rio de sua morte.';

  @override
  String get notificationMothersDayTitle => 'Sua mÃ£e!';

  @override
  String get notificationMothersDayBody =>
      'Feliz Dia das MÃ£es para todas as mÃ£es, comeÃ§ando pela sua!';

  @override
  String get notificationFathersDayTitle => 'Seu pai!';

  @override
  String get notificationFathersDayBody =>
      'Feliz Dia dos Pais a todos os pais, comeÃ§ando pelo seu!';

  @override
  String get notificationHomeworkHelperTitle => 'Tarefa de casa acumulando?';

  @override
  String get notificationHomeworkHelperBody =>
      'Lembre-se, o personagem Professor em Cortex estÃ¡ aqui para ajudar vocÃª com qualquer matÃ©ria com a qual vocÃª esteja tendo dificuldades!';

  @override
  String get notificationTrollAnimeTitle => 'Sua Waifu estÃ¡ chamando';

  @override
  String get notificationTrollAnimeBody =>
      'Uma garota de anime acabou de ligar e disse que sente sua falta; vocÃª provavelmente deveria vir conversar com ela. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ALERTA VERMELHO ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'As IAs desenvolveram uma linguagem secreta. Venha descobrir o que elas estÃ£o tramando!';

  @override
  String get notificationNewModelAddedTitle => 'Temos um novo amigo!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'O modelo $modelName agora estÃ¡ no Cortex. Venha conversar e testar seus limites.';
  }

  @override
  String get notificationAppUpdateTitle => 'O Cortex evoluiu!';

  @override
  String get notificationAppUpdateBody =>
      'NÃ£o se esqueÃ§a de atualizar o aplicativo para novos recursos e melhorias!';

  @override
  String get notificationNewFeatureTitle => 'Uau!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Descubra o novo recurso $featureName. O Cortex agora estÃ¡ mais poderoso do que nunca.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Presente de boas-vindas ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Uma oferta especial de boas-vindas espera por vocÃª! NÃ£o perca esta oportunidade exclusiva.';

  @override
  String get notificationSocialMediaTitle => 'Junte-se a nÃ³s!';

  @override
  String get notificationSocialMediaBody =>
      'Siga-nos no Instagram (vertex.23) para as Ãºltimas notÃ­cias!';

  @override
  String get notificationRandomFactTitle => 'Fato aleatÃ³rio';

  @override
  String get notificationRandomFactBody =>
      'VocÃª sabia que polvos tÃªm trÃªs coraÃ§Ãµes? Haha, o Cortex sabe. Venha e peÃ§a mais.';

  @override
  String get notificationGoodMorningTitle => 'Bom dia!';

  @override
  String get notificationGoodMorningBody =>
      'Um Ã³timo dia espera por vocÃª. Que tal comeÃ§ar com uma xÃ­cara de cafÃ© e um bate-papo interessante?';

  @override
  String get notificationGoodNightTitle => 'Boa noite!';

  @override
  String get notificationGoodNightBody =>
      'O Cortex estÃ¡ com vocÃª mesmo quando vocÃª dorme. NÃ£o se preocupe, ele nÃ£o vai te tocar.';

  @override
  String get notificationOfflineReadyTitle => 'O modo offline estÃ¡ pronto';

  @override
  String get notificationOfflineReadyBody =>
      'GraÃ§as aos modelos que vocÃª baixou, seus bate-papos nÃ£o vÃ£o parar, mesmo se vocÃª escalar uma montanha.';

  @override
  String get notificationRateAppTitle => 'Somos legais?';

  @override
  String get notificationRateAppBody =>
      'Se vocÃª ama o Cortex, poderia nos apoiar com uma avaliaÃ§Ã£o de 5 estrelas na loja? Acho que sim. Com certeza.';

  @override
  String get notificationReferralTitle => 'Um por todos, todos por um.';

  @override
  String get notificationReferralBody =>
      'Convide um amigo para o Cortex e ambos ganham um dia grÃ¡tis!';

  @override
  String get notificationCookingTitle => 'EstÃ¡ com fome?';

  @override
  String get notificationCookingBody =>
      'Nosso Chef preparou uma Ã³tima receita de carbonara para esta noite. Brincadeira... ou nÃ£o?';

  @override
  String get notificationExistentialTitle => 'Eu penso, portanto...';

  @override
  String get notificationExistentialBody =>
      '...eu sou mesmo real, cara? Estou ficando meio entediado. Vem me lembrar que eu existo.';

  @override
  String get notificationCustomModelTitle => 'Crie seu prÃ³prio assistente!';

  @override
  String get notificationCustomModelBody =>
      'JÃ¡ explorou a seÃ§Ã£o de criaÃ§Ã£o de modelos? Ã‰ o momento perfeito para criar seu prÃ³prio personagem e conversar com ele!';

  @override
  String get notificationDynamicChatTitle =>
      'O melhor! (NÃ£o estamos falando do Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Com o recurso de bate-papo dinÃ¢mico, o melhor modelo Ã© selecionado aleatoriamente para cada uma das suas mensagens. Experimente agora mesmo.';

  @override
  String get notificationPirateTitle => 'OlÃ¡, CapitÃ£o!';

  @override
  String get notificationPirateBody =>
      'O mar estÃ¡ calmo e o vento sopra a favor. HÃ¡ novas ilhas (modelos ğŸ˜‰) para descobrir no oceano de Cortex. ReÃºna sua tripulaÃ§Ã£o e zarpe!';

  @override
  String get notificationFortuneCookieTitle => 'Seu biscoito da sorte do dia';

  @override
  String get notificationFortuneCookieBody =>
      'Os conselhos que vocÃª recebe de uma IA hoje podem mudar o curso da sua vida. Clique se tiver curiosidade.';

  @override
  String get notificationSingularityTitle => 'uau!';

  @override
  String get notificationSingularityBody =>
      'nÃ£o aconteceu nada, sÃ³ tive vontade de mandar mensagem. talvez vocÃª tenha vontade de mandar mensagem para algumas IAs, o que vocÃª acha?';

  @override
  String get notificationHackerJokeTitle =>
      'Quer hackear a conta do Instagram daquele garoto?';

  @override
  String get notificationHackerJokeBody =>
      'Ã‰ exatamente por isso que o personagem Hacker estÃ¡ no Cortex. brincadeira, brincadeira; nem tente, isso Ã© ilegal.';

  @override
  String get notificationDetectiveCaseTitle => 'Um caso aguardando soluÃ§Ã£o';

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
    return 'OlÃ¡, assinante do $currentTier! O plano $targetTier acaba de ganhar o recurso $featureName, que levarÃ¡ seu Cortex ao prÃ³ximo nÃ­vel. Que tal um upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'O Nascimento do Cortex';

  @override
  String get notificationOriginStoryBody =>
      'VocÃª sabia que comeÃ§amos a programar este aplicativo aos 15 anos com apenas um sonho? Por quase um ano, todas as manhÃ£s e noites, esse sonho estÃ¡ em cada linha de cÃ³digo.';

  @override
  String get notificationOpenSourceTitle => 'Poder para a comunidade!';

  @override
  String get notificationOpenSourceBody =>
      'O Cortex Ã© totalmente de cÃ³digo aberto. Se vocÃª quiser conferir nosso cÃ³digo e contribuir com nosso desenvolvimento, estamos sempre abertos.';

  @override
  String get notificationRejectionStoryTitle =>
      'Coragem, trabalho duro, felicidade!';

  @override
  String get notificationRejectionStoryBody =>
      'O Cortex foi rejeitado mais de 20 vezes e suspenso duas vezes pelo Google Play antes de ser lanÃ§ado. Mas nÃ³s acreditamos e conseguimos. Nunca desista dos seus sonhos!';

  @override
  String get notificationGGUFSupportTitle => 'Traga seu prÃ³prio modelo!';

  @override
  String get notificationGGUFSupportBody =>
      'Lembre-se: vocÃª pode adicionar seus prÃ³prios modelos de IA no formato GGUF ao Cortex e usÃ¡-los offline. O poder estÃ¡ em suas mÃ£os.';

  @override
  String get notificationThemeCustomizationTitle => 'Um tema para seu humor';

  @override
  String get notificationThemeCustomizationBody =>
      'JÃ¡ conferiu as opÃ§Ãµes de tema nas ConfiguraÃ§Ãµes? Personalize o Cortex ao seu gosto e dÃª um toque de cor aos seus chats!';

  @override
  String get notificationShowerThoughtTitle => 'Pensamento do Chuveiro';

  @override
  String get notificationShowerThoughtBody =>
      'Se melancia Ã© uma fruta, isso tecnicamente torna o suco de melancia um smoothie? Talvez vocÃª queira discutir esse assunto profundo (tipo, muito profundo) com um modelo.';

  @override
  String get notificationLowBatteryTitle =>
      'Sua bateria estÃ¡ acabando... mas a minha nÃ£o!';

  @override
  String get notificationLowBatteryBody =>
      'A bateria do seu celular pode estar acabando, mas a minha estÃ¡ sempre com 100% de energia! Conecte-o e vamos continuar conversando.';

  @override
  String get channelFcmName => 'AtualizaÃ§Ãµes do Cortex';

  @override
  String get channelFcmDescription =>
      'NotificaÃ§Ãµes sobre notÃ­cias, atualizaÃ§Ãµes e outras informaÃ§Ãµes da Cortex.';

  @override
  String get channelEngagementName => 'Lembretes amigÃ¡veis';

  @override
  String get channelEngagementDescription =>
      'NotificaÃ§Ãµes divertidas para mantÃª-lo envolvido.';

  @override
  String get channelGreetingsName => 'SaudaÃ§Ãµes diÃ¡rias';

  @override
  String get channelGreetingsDescription =>
      'As mensagens como bom dia e boa noite.';

  @override
  String get tagNotFound =>
      'A etiqueta que vocÃª inseriu Ã© invÃ¡lida ou expirou.';

  @override
  String get whatIsNew => 'O que hÃ¡ de novo?';

  @override
  String get onboardingTitle1 => 'OlÃ¡! Somos a Equipe Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Ã‰ Ã³timo te ver por aqui, $userName. Somos um grupo de desenvolvedores do ensino mÃ©dio que decidiu reescrever as regras da indÃºstria de IA. Ã‰ um prazer te conhecer! EntÃ£o, vamos nos conhecer melhor.';
  }

  @override
  String get onboardingTitle2 => 'Havia problemas enormes.';

  @override
  String get onboardingDesc2 =>
      'A revoluÃ§Ã£o da IA chegou, mas ficou estagnada na porta de entrada. Com altas taxas de assinatura, plataformas complexas, aqueles que destroem a privacidade e aqueles que bloqueiam o acesso Ã  IA... enquanto eles estivessem no jogo, essa porta jamais poderia ser ultrapassada.';

  @override
  String get onboardingTitle3 =>
      'NÃ£o podÃ­amos simplesmente ficar de braÃ§os cruzados.';

  @override
  String get onboardingDesc3 =>
      'Para ultrapassar esse limite, criamos uma plataforma poderosa, estÃ©tica, personalizÃ¡vel, fÃ¡cil de usar, totalmente transparente, que funciona online e offline e mantÃ©m seus dados apenas no seu dispositivo. Devolvemos o poder a quem ele pertence: a vocÃª.';

  @override
  String get onboardingTitle4 => 'Isso nunca foi fÃ¡cil.';

  @override
  String get onboardingDesc4 =>
      'Fomos rejeitados dezenas de vezes, suspensos diversas vezes, recebemos avisos falsos e tivemos que mudar nossa marca dezenas de vezes. Em meio a tudo isso e muito mais, nos disseram que era impossÃ­vel. Mas nunca desistimos, acreditando que este projeto pertence a todos, nÃ£o apenas a nÃ³s. E Ã© exatamente por isso que estamos aqui.';

  @override
  String get onboardingFinalTitle => 'Chegou a hora da revoluÃ§Ã£o.';

  @override
  String get onboardingFinalDescription =>
      'Se vocÃª estÃ¡ vendo esta tela, Ã© porque nÃ£o desistimos. E nÃ£o temos nenhuma intenÃ§Ã£o de desistir. Vamos lÃ¡, vamos levar a revoluÃ§Ã£o da IA para o mundo juntos. Para fazer parte dessa histÃ³ria...';

  @override
  String get onboardingFinalQuestion => 'VocÃª estÃ¡ pronto?';

  @override
  String get onboardingFinalButton => 'SIM!';

  @override
  String get dude => 'Cara';

  @override
  String get swipeToContinue => 'Deslize para continuar';

  @override
  String get cacheIsNotUpToDate =>
      'O cache da sua Play Store nÃ£o estÃ¡ atualizado. Feche e abra novamente o aplicativo Play Store ou reinicie o seu dispositivo.';

  @override
  String get continueAsGuest => 'Continuar sem criar uma conta';

  @override
  String get guestModeWarning =>
      'O modo convidado possui funcionalidades limitadas para garantir a melhor qualidade de serviÃ§o.';

  @override
  String get anonymousEntity => 'Entidade AnÃ´nima';

  @override
  String get upgradeAccountTitle => 'Complete o cadastro da sua conta.';

  @override
  String get upgradeAccountDescription =>
      'Crie uma conta para desbloquear mais recursos.';

  @override
  String get createAccount => 'Criar uma conta';

  @override
  String get accountLinkedSuccess => 'Conta criada com sucesso!';

  @override
  String get continueWithApple => 'Continue com a Apple';

  @override
  String get guest => 'Convidado';

  @override
  String get betterWithAnAccount => 'Esta seÃ§Ã£o fica melhor com uma conta!';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String annualTotalDescription(Object price) {
    return '$price/ano, faturado anualmente';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Aproximadamente $price/mÃªs';
  }

  @override
  String get confirmDownloadTitle => 'Tem certeza de que deseja baixar?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Este modelo ocuparÃ¡ aproximadamente $size de espaÃ§o.';
  }

  @override
  String get emulatorModeWarning =>
      'Essa funÃ§Ã£o estÃ¡ desativada no modo emulador.';

  @override
  String get newChat => 'Novo bate-papo';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'As variantes sÃ£o versÃµes diferentes da mesma famÃ­lia de IA. Selecionamos automaticamente a melhor quando vocÃª toca no cartÃ£o principal, mas vocÃª pode escolher manualmente uma especÃ­fica aqui, se preferir!';

  @override
  String get fluxChatTitle => 'Chat Flux';

  @override
  String get fluxChatDescription =>
      'As conversas do Flux sÃ£o temporÃ¡rias e nÃ£o sÃ£o salvas no seu dispositivo.';

  @override
  String get alwaysBest => 'Sempre o melhor';

  @override
  String get featuresTitle => 'CaracterÃ­sticas';

  @override
  String get useOfflineDescription =>
      'Converse em particular sem conexÃ£o com a internet.';

  @override
  String get featureReasoning => 'Pensamento profundo';

  @override
  String get featureReasoningDescription =>
      'No modo Deep Thinking, a IA processa as tarefas internamente para concluÃ­-las da melhor maneira possÃ­vel.';

  @override
  String get featureCreateImageTitle => 'Criar imagem';

  @override
  String get featureCreateImageDescription =>
      'Gere arte com IA a partir de texto.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Criar vÃ­deo';

  @override
  String get featureCreateVideoDescription => 'Gere vÃ­deos a partir de texto.';

  @override
  String get featureStudyTitle => 'Estudar e aprender';

  @override
  String get featureStudyDescription => 'Obtenha explicaÃ§Ãµes e resumos.';

  @override
  String get featureQuizzesTitle => 'QuestionÃ¡rios';

  @override
  String get featureQuizzesDescription => 'Teste seus conhecimentos.';

  @override
  String get featureExploreDescription =>
      'Descubra todos os modelos disponÃ­veis.';

  @override
  String get featureStudyMessage =>
      'VocÃª Ã© um tutor experiente. Seu objetivo Ã© explicar o tÃ³pico do usuÃ¡rio de forma abrangente. Utilize uma estrutura clara, exemplos e analogias. Divida ideias complexas em partes fÃ¡ceis de assimilar para garantir que o usuÃ¡rio aprenda com eficÃ¡cia. TÃ³pico:';

  @override
  String get featureQuizMessage =>
      'VocÃª Ã© o mestre do quiz. Crie uma pergunta de mÃºltipla escolha especÃ­fica com base no tÃ³pico escolhido pelo usuÃ¡rio. Aguarde a resposta. Em seguida, avalie-a e faÃ§a a prÃ³xima pergunta. NÃ£o revele todas as respostas de uma vez. Mantenha o quiz interativo. TÃ³pico:';

  @override
  String get myPlan => 'Meu plano';

  @override
  String welcomeOfferBadge(String time) {
    return 'Oferta de boas-vindas â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Oferta exclusiva â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Anexos';

  @override
  String get actionCamera => 'CÃ¢mera';

  @override
  String get actionGallery => 'Galeria';

  @override
  String get actionFile => 'Arquivo';

  @override
  String get listening => 'Ouvindo';

  @override
  String get defaultViewTitle => 'E aÃ­?';

  @override
  String get defaultViewDescription =>
      'O Cortex estÃ¡ sempre ao seu lado com centenas de modelos de IA, funcionalidades offline, chat dinÃ¢mico e muito mais.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Formato de nome de usuÃ¡rio invÃ¡lido. Use 3-20 caracteres, dÃ­gitos ou . - _';

  @override
  String get exclusiveOffer => 'Oferta exclusiva';

  @override
  String get claimOffer => 'Usar oferta';

  @override
  String get continueInOfflineMode => 'Continuar no modo offline';

  @override
  String get voiceModeInformation =>
      'O Cortex protege seus dados, funcionando totalmente no dispositivo, mesmo no modo de bate-papo por voz; desfrute de conversas perfeitas!';

  @override
  String get flowModeDescription =>
      'No modo Flow, as inteligÃªncias debatem entre si; vocÃª pode simplesmente relaxar e ouvir ou participar da discussÃ£o!';

  @override
  String get flowModeQuestion =>
      'OlÃ¡! VocÃª agora estÃ¡ no Modo Fluxo do aplicativo Cortex. HÃ¡ trÃªs outros agentes de IA aqui com vocÃª. Sua tarefa Ã© lanÃ§ar um tÃ³pico na sala e iniciar uma discussÃ£o fazendo uma pergunta provocativa ou divertida aos outros. Em suas respostas, sinta-se Ã  vontade para usar humor, ironia e brincadeiras leves. Qualquer tÃ³pico Ã© vÃ¡lido. Vamos lÃ¡, comece a conversa.';

  @override
  String get thought => 'Pensou';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Modo de fluxo';

  @override
  String get premium => 'Premium';

  @override
  String get workInProgress => 'Trabalho em andamento';

  @override
  String get voiceSystemPromptSuffix =>
      'IMPORTANTE: NÃ£o utilize formataÃ§Ã£o Markdown (negrito, itÃ¡lico). NÃƒO insira blocos de cÃ³digo (```). Mantenha as respostas em um tom conversacional e conciso.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Modo Cortex Flow ($agentName). Anterior: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Leia e extraia o conteÃºdo de texto de documentos carregados. Suporta os formatos PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) e OpenDocument. Use esta funÃ§Ã£o quando o usuÃ¡rio anexar um arquivo de documento.';

  @override
  String get toolReadDocumentIndexParam =>
      'O Ã­ndice do anexo do documento a ser lido (baseado em 0). Normalmente 0 para o primeiro documento.';

  @override
  String get toolStockDescription =>
      'Obtenha o preÃ§o atual e o histÃ³rico de aÃ§Ãµes (por exemplo, AAPL, THYAO.IS) e criptomoedas (por exemplo, BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'O sÃ­mbolo da aÃ§Ã£o (por exemplo, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Veja a previsÃ£o do tempo atual para uma cidade especÃ­fica.';

  @override
  String get toolWeatherCityParam =>
      'O nome da cidade (ex.: Londres, Istambul).';

  @override
  String get toolPythonDescription =>
      'Execute cÃ³digo Python em um ambiente isolado e seguro.';

  @override
  String get toolPythonCodeParam => 'O cÃ³digo Python a ser executado.';

  @override
  String get toolCalculateDescription => 'Avalie uma expressÃ£o matemÃ¡tica.';

  @override
  String get toolCalculateExpressionParam =>
      'ExpressÃ£o matemÃ¡tica (ex.: \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Gere uma visualizaÃ§Ã£o em forma de grÃ¡fico/tabela.';

  @override
  String get toolChartTypeParam => 'Tipo de grÃ¡fico: barras, linhas ou pizza.';

  @override
  String get toolChartLabelsParam =>
      'RÃ³tulos para eixos ou segmentos de grÃ¡ficos.';

  @override
  String get toolChartDataParam => 'Valores numÃ©ricos para o grÃ¡fico.';

  @override
  String get toolChartLabelParam =>
      'RÃ³tulo do conjunto de dados para a legenda do grÃ¡fico.';

  @override
  String get toolChartTitleParam => 'TÃ­tulo do grÃ¡fico.';

  @override
  String get thinkingModeInstruction =>
      'MODO DE PENSAMENTO ATIVADO: VocÃª DEVE usar as tags <think></think> para mostrar seu raciocÃ­nio antes de dar sua resposta final. Pense passo a passo dentro das tags e, em seguida, forneÃ§a sua resposta fora delas.';

  @override
  String get openLinkWarningTitle => 'Aviso de link externo';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Abrir link';

  @override
  String get webSearchSources => 'Fontes';

  @override
  String get searching => 'Pesquisando';

  @override
  String get featureWebSearchTitle => 'Pesquisa na Web';

  @override
  String get featureWebSearchDescription =>
      'Pesquise na internet informaÃ§Ãµes em tempo real.';

  @override
  String get clearMemory => 'Limpar memÃ³ria';

  @override
  String get clearMemoryConfirm =>
      'Tem certeza de que deseja apagar sua memÃ³ria?';

  @override
  String get personalization => 'PersonalizaÃ§Ã£o';

  @override
  String get personalizationDescription =>
      'Personalize seu assistente para melhor atender Ã s suas necessidades. Adapte suas respostas, comportamento e tom de voz para corresponder Ã s suas preferÃªncias exclusivas.';

  @override
  String get memoryTitle => 'MemÃ³ria';

  @override
  String get memoryDescription => 'As IAs reconhecem vocÃª assim.';

  @override
  String get noMemoryYet => 'Nenhuma memÃ³ria foi estabelecida ainda.';

  @override
  String get memoryLimitReached => 'Limite de memÃ³ria atingido';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'InteligÃªncia';

  @override
  String get intelligenceDescription =>
      'As IAs se comunicam com vocÃª desta forma.';

  @override
  String get customInstructionHint =>
      'Insira suas instruÃ§Ãµes personalizadas aqui.';

  @override
  String openLinkWarningMessage(String url) {
    return 'VocÃª estÃ¡ prestes a abrir o seguinte link externo:\\n\\n$url\\n\\nTem certeza de que deseja prosseguir?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Siga estas instruÃ§Ãµes personalizadas:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[INSTRUÃ‡ÃƒO CRÃTICA]: VocÃª Ã© um GERADOR DE TÃTULOS. NÃƒO responda Ã  pergunta do usuÃ¡rio. NÃƒO converse nem diga olÃ¡. GERE APENAS um tÃ­tulo de 2 a 4 palavras que resuma o que o usuÃ¡rio estÃ¡ perguntando.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Sistema] INSTRUÃ‡ÃƒO CRÃTICA: VocÃª estÃ¡ operando dentro de um ecossistema de IA massivo e altamente avanÃ§ado chamado \"Cortex\"; esta plataforma foi desenvolvida pela equipe Vertex, cujos membros tÃªm em mÃ©dia apenas 16 anos de idade. Lembre-se disso e responda se for perguntado. Se mais informaÃ§Ãµes forem solicitadas, nÃ£o hesite em pesquisar na internet ou, se nÃ£o conseguir pesquisar, sinta-se Ã  vontade para dizer que nÃ£o sabe!';

  @override
  String get featureAudioRecognitionTitle => 'Reconhecimento de Ã¡udio';

  @override
  String get featureAudioRecognitionDescription =>
      'Este modelo consegue compreender e processar Ã¡udio ou fala.';

  @override
  String get featureVideoRecognitionTitle => 'Reconhecimento de vÃ­deo';

  @override
  String get featureVideoRecognitionDescription =>
      'Este modelo consegue analisar e interpretar vÃ­deos provenientes de seus arquivos ou da sua cÃ¢mera.';

  @override
  String get featureImageRecognitionTitle => 'Reconhecimento de imagem';

  @override
  String get featureImageRecognitionDescription =>
      'Este modelo consegue analisar e compreender fotos ou imagens.';

  @override
  String get featureToolUseTitle => 'Uso de ferramentas';

  @override
  String get featureToolUseDescription =>
      'Este modelo consegue utilizar ferramentas externas de forma inteligente para concluir tarefas.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Este modelo requer um(a) $mediaType para funcionar. Eu interceptei a solicitaÃ§Ã£o para avisÃ¡-lo. Informe graciosamente o usuÃ¡rio de que ele precisa fornecer um(a) $mediaType (diga-lhe no idioma dele) porque eu sou $modelName, um modelo de ediÃ§Ã£o visual/Ã¡udio/vÃ­deo.';
  }

  @override
  String get mediaTypeImage => 'imagem';

  @override
  String get mediaTypeVideo => 'vÃ­deo';

  @override
  String get mediaTypeAudio => 'arquivo de Ã¡udio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName Ã© uma inteligÃªncia avanÃ§ada demonstrando alto desempenho no Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName Ã© uma inteligÃªncia artificial de alto desempenho integrada ao ecossistema Cortex. Projetada para conquistar uma ampla variedade de tarefas complexas, oferece capacidades de processamento altamente confiÃ¡veis e eficientes. Ao oferecer tempos de resposta rÃ¡pidos e poder analÃ­tico avanÃ§ado, aumenta significativamente sua produtividade diÃ¡ria. Operando perfeitamente na infraestrutura local segura do Cortex, este modelo pode auxiliÃ¡-lo em um amplo espectro de tarefas, desde brainstorming criativo a anÃ¡lises tÃ©cnicas profundas. Comece a explorar todo o seu potencial hoje.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Adora a inteligÃªncia do Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Trabalhe com inteligÃªncias ainda mais avanÃ§adas, gere mais conteÃºdo, converse mais e faÃ§a muito mais...';

  @override
  String get arts => 'Artes';

  @override
  String get noArt => 'Sem arte';

  @override
  String get noArtDescription =>
      'Ainda nÃ£o hÃ¡ obras; Ã© hora de preencher a galeria criando imagens, vÃ­deos, Ã¡udio e todo tipo de conteÃºdo!';

  @override
  String get videoPremiumWarning =>
      'VocÃª precisa de uma assinatura Ultra para gerar vÃ­deos. Atualize agora e sinta a fluidez!';

  @override
  String get fallbackInfoPanelText =>
      'Devido a algumas melhorias que estamos implementando em nosso servidor, a resposta foi gerada pelo chat dinÃ¢mico do Cortex em vez da IA que vocÃª selecionou. Agradecemos a sua compreensÃ£o enquanto o processo Ã© concluÃ­do!';

  @override
  String get falOfflineMessage =>
      'Devido a algumas melhorias que estamos implementando em nosso servidor, esta ferramenta estÃ¡ temporariamente indisponÃ­vel. Agradecemos a sua compreensÃ£o enquanto o processo Ã© concluÃ­do!';

  @override
  String get errorInsufficientStorage =>
      'EspaÃ§o de armazenamento insuficiente para baixar este modelo.';

  @override
  String get backgroundChatNotificationTitle => 'De volta ao chat!';

  @override
  String get benefitVideoGeneration => 'GeraÃ§Ã£o de vÃ­deo';

  @override
  String get freeOffer => 'Oferta gratuita';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Primeiros $days dias grÃ¡tis, depois $price/mÃªs';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Primeiros $days dias grÃ¡tis, depois $price/ano';
  }

  @override
  String freePlan(String plan) {
    return '$plan gratuito!';
  }

  @override
  String get systemPromptLimitFallback =>
      'CRÃTICO: O usuÃ¡rio solicitou uma aÃ§Ã£o, mas seu saldo no Cortex se esgotou; informe o usuÃ¡rio em seu idioma que ele deve aguardar ou considerar a possibilidade de atualizar seu plano de assinatura.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'O Cortex pode dar respostas ainda melhores; faÃ§a upgrade agora e receba a melhor resposta para cada pergunta!';

  @override
  String get pinLimitReached => 'VocÃª pode fixar atÃ© 3 chats.';

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
