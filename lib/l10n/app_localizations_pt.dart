// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
  String get messageCopied => 'Mensagem copiada para a área de transferência.';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get systemInfo => 'Informações do Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'Memória do Dispositivo: $memory GB';
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
  String get modelsTitle => 'Biblioteca';

  @override
  String get localModels => 'Modelos Locais';

  @override
  String get serverSideModels => 'Modelos Online';

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
  String get newTitle => 'Novo Título';

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
  String get noStarredChatsMessage => 'Ainda não marcou um chat como favorito.';

  @override
  String get starConversation => 'Favorito';

  @override
  String get unstarConversation => 'Unstar';

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
  String get wrongPassword => 'Palavra-passe incorreta.';

  @override
  String get emailAlreadyInUse => 'Este email já está em uso.';

  @override
  String get weakPassword => 'A palavra-passe é demasiado fraca.';

  @override
  String get authError => 'Erro de Autenticação';

  @override
  String get usernameTaken => 'Este nome de utilizador já está em uso.';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get resendCode => 'Reenviar e-mail de verificação';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar o Cortex, precisa de verificar o seu email. \nUm link de verificação foi enviado para o seu endereço de email, por favor, verifique o seu email.';

  @override
  String get verifyYourEmail => 'Verifique o Seu Email';

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
  String get deleteAccount => 'Eliminar Conta';

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
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get logout => 'Terminar Sessão';

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
  String get purchaseError => 'Erro na compra';

  @override
  String get purchasePlus => 'Comprar Cortex Plus';

  @override
  String get plusDescription =>
      'Experiência de Inteligência Artificial de Elite';

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
  String monthlyPlanDescription(String price) {
    return '$price/mês, cobrado mensalmente';
  }

  @override
  String get purchasePro => 'Comprar Cortex Pro';

  @override
  String get proDescription =>
      'Experiência de Inteligência Artificial de Primeira Classe';

  @override
  String get purchaseUltra => 'Comprar Cortex Ultra';

  @override
  String get ultraDescription => 'O auge da inteligência artificial';

  @override
  String get upgradeSubscription => 'Atualizar Subscrição';

  @override
  String get purchaseStreamError => 'Erro no fluxo de compra.';

  @override
  String get productNotFound => 'Produto não encontrado';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

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
  String get finalPreparation => 'Os preparativos finais estão a ser feitos.';

  @override
  String get shareApp => 'Partilhar a App';

  @override
  String get rateUs => 'Avalie-nos';

  @override
  String get share => 'Partilhar';

  @override
  String get shareSubject => 'Cortex';

  @override
  String shareMessage(String cortexLink) {
    return 'Vê a aplicação Cortex, é incrível! Baixa-a aqui: $cortexLink';
  }

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
  String get tagCannotBeEmpty => 'A tag do criador não pode estar vazia.';

  @override
  String get userId => 'ID do Utilizador';

  @override
  String get deleteAllConversationsConfirmTitle => 'Eliminar Todos os Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Tem a certeza de que quer eliminar todos os seus chats? Esta ação não pode ser desfeita.';

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
  String get chinese => 'Chinês';

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
  String get arabic => 'árabe';

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
  String get noInternetConnection => 'Sem ligação à internet.';

  @override
  String get chats => 'Caixa de Entrada';

  @override
  String get library => 'Biblioteca';

  @override
  String get text => 'Texto';

  @override
  String get removeModel => 'Remover Modelo';

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
  String get benefit1 => 'Aumento dos limites de conversa';

  @override
  String get benefit3 => 'Efeito de perfil';

  @override
  String get benefit4 => 'Distintivo de membro';

  @override
  String get benefit5 => 'Crie mais inteligências artificiais online';

  @override
  String get benefit7 => 'Mais limites de uso';

  @override
  String get benefit8 => 'Adicionar modelos';

  @override
  String get benefit9 => 'Novos temas';

  @override
  String get benefit10 => 'Mais anexos';

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
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo pode integrar automaticamente extensões adicionais, expandindo assim as suas capacidades funcionais para suportar uma gama diversificada de operações com desempenho melhorado.';

  @override
  String get nameLabel => 'Nome da IA';

  @override
  String get summaryLabel => 'Resumo da IA';

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
  String get modelUploadTitle => 'Ficheiro de Inteligência Artificial';

  @override
  String get modelUploadDescription =>
      'Selecione e envie os seus ficheiros GGUF locais diretamente do seu dispositivo. Isto permite-lhe executar o seu modelo offline sem necessitar de uma ligação à internet. Certifique-se de que o ficheiro está no formato GGUF válido e devidamente estruturado. Se o ficheiro estiver incorreto ou corrompido, o Cortex pode não funcionar como esperado, e poderá encontrar erros.';

  @override
  String get modelUploadShortDescription =>
      'Toque aqui para escolher um ficheiro .gguf do seu dispositivo';

  @override
  String get you => 'Você';

  @override
  String get removePhotoTitle => 'Remover Foto';

  @override
  String get confirmRemovePhoto => 'Tem a certeza de que quer remover a foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat excedeu o limite de caracteres. Por favor, inicie um novo chat ou compre uma subscrição.';

  @override
  String get photoLimitReachedMessage => 'Só pode ser adicionada uma foto';

  @override
  String get inappropriateContentDetected => 'Conteúdo inadequado detetado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo offline não está instalado no seu dispositivo.';

  @override
  String get reachedLimit =>
      'Você atingiu seu limite de uso; para obter mais limites, você pode atualizar seu plano. (Ei, nós entendemos que ficar sem limites é uma chatice. Mas, falando sério, receber aquelas respostas incríveis não é de graça, então esses limites nos ajudam a manter a diversão rolando.)';

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
  String get errorReachedLimit =>
      'Você atingiu seu limite. Faça um upgrade para desbloquear mais conteúdo e continue conversando.';

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
  String get noFoundTitle => 'Sem Resultados';

  @override
  String get noFoundMessage =>
      'Tente ajustar os seus termos de pesquisa ou limpar o filtro.';

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
      'Faça login na sua conta Vertex. Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.';

  @override
  String get registerSubtitle =>
      'Crie uma conta Vertex para acesso integrado a todos os nossos serviços. Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.';

  @override
  String get storagePermissionRequired =>
      'É necessária permissão de armazenamento para guardar os modelos baixados. Por favor, conceda permissão para continuar.';

  @override
  String get plusBannerTitle => 'Obtenha o Plus grátis!';

  @override
  String get plusBannerSubtitle =>
      'Convide um amigo e ambos ganham 1 dia de Plus grátis!';

  @override
  String get inviteShareSubject => 'Junta-te a mim no Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'ei tem esse app insano chamado cortex se você convidar galera a gente ganha plus de graça OFERTAÇO BAIXA LOGO\n\n$cortexLink';
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
  String get useOffline => 'Usar sem Internet';

  @override
  String get explore => 'Explorar';

  @override
  String get news => 'Notícias';

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
  String get dynamicChatTitle => 'Bate-papo dinâmico';

  @override
  String get errorNoModelsAvailable =>
      'Nenhum modelo disponível no momento. Verifique sua conexão com a internet e tente novamente.';

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
      'Convide um amigo para o Cortex e ambos ganham um dia grátis!';

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
      'Notificações sobre notícias, atualizações e outras informações da Cortex.';

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
  String get tagNotFound =>
      'A etiqueta que você inseriu é inválida ou expirou.';

  @override
  String get whatIsNew => 'O que há de novo?';

  @override
  String get onboardingTitle1 => 'Olá! Somos a Equipe Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'É ótimo te ver por aqui, $userName. Somos um grupo de desenvolvedores do ensino médio que decidiu reescrever as regras da indústria de IA. É um prazer te conhecer! Então, vamos nos conhecer melhor.';
  }

  @override
  String get onboardingTitle2 => 'Havia problemas enormes.';

  @override
  String get onboardingDesc2 =>
      'A revolução da IA chegou, mas ficou estagnada na porta de entrada. Com altas taxas de assinatura, plataformas complexas, aqueles que destroem a privacidade e aqueles que bloqueiam o acesso à IA... enquanto eles estivessem no jogo, essa porta jamais poderia ser ultrapassada.';

  @override
  String get onboardingTitle3 =>
      'Não podíamos simplesmente ficar de braços cruzados.';

  @override
  String get onboardingDesc3 =>
      'Para ultrapassar esse limite, criamos uma plataforma poderosa, estética, personalizável, fácil de usar, totalmente transparente, que funciona online e offline e mantém seus dados apenas no seu dispositivo. Devolvemos o poder a quem ele pertence: a você.';

  @override
  String get onboardingTitle4 => 'Isso nunca foi fácil.';

  @override
  String get onboardingDesc4 =>
      'Fomos rejeitados dezenas de vezes, suspensos diversas vezes, recebemos avisos falsos e tivemos que mudar nossa marca dezenas de vezes. Em meio a tudo isso e muito mais, nos disseram que era impossível. Mas nunca desistimos, acreditando que este projeto pertence a todos, não apenas a nós. E é exatamente por isso que estamos aqui.';

  @override
  String get onboardingFinalTitle => 'Chegou a hora da revolução.';

  @override
  String get onboardingFinalDescription =>
      'Se você está vendo esta tela, é porque não desistimos. E não temos nenhuma intenção de desistir. Vamos lá, vamos levar a revolução da IA para o mundo juntos. Para fazer parte dessa história...';

  @override
  String get onboardingFinalQuestion => 'Você está pronto?';

  @override
  String get onboardingFinalButton => 'SIM!';

  @override
  String get dude => 'Cara';

  @override
  String get swipeToContinue => 'Deslize para continuar';

  @override
  String get cacheIsNotUpToDate =>
      'O cache da sua Play Store não está atualizado. Feche e abra novamente o aplicativo Play Store ou reinicie o seu dispositivo.';

  @override
  String get continueAsGuest => 'Continuar sem criar uma conta';

  @override
  String get guestModeWarning =>
      'O modo convidado possui funcionalidades limitadas para garantir a melhor qualidade de serviço.';

  @override
  String get anonymousEntity => 'Entidade Anônima';

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
  String get betterWithAnAccount => 'Esta seção fica melhor com uma conta!';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String annualTotalDescription(Object price) {
    return '$price/ano, faturado anualmente';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Aproximadamente $price/mês';
  }

  @override
  String get confirmDownloadTitle => 'Tem certeza de que deseja baixar?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Este modelo ocupará aproximadamente $size de espaço.';
  }

  @override
  String get emulatorModeWarning =>
      'Essa função está desativada no modo emulador.';

  @override
  String get newChat => 'Novo bate-papo';

  @override
  String get howCanIHelpWith => 'Como posso ajudar?';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'As variantes são versões diferentes da mesma família de IA. Selecionamos automaticamente a melhor quando você toca no cartão principal, mas você pode escolher manualmente uma específica aqui, se preferir!';

  @override
  String get fluxChatTitle => 'Chat Flux';

  @override
  String get fluxChatDescription =>
      'As conversas do Flux são temporárias e não são salvas no seu dispositivo.';

  @override
  String get alwaysBest => 'Sempre o melhor';

  @override
  String get featuresTitle => 'Características';

  @override
  String get useOfflineDescription =>
      'Converse em particular sem conexão com a internet.';

  @override
  String get featureCreateImageTitle => 'Criar imagem';

  @override
  String get featureCreateImageDescription =>
      'Gere arte com IA a partir de texto.';

  @override
  String get featureStudyTitle => 'Estudar e aprender';

  @override
  String get featureStudyDescription => 'Obtenha explicações e resumos.';

  @override
  String get featureQuizzesTitle => 'Questionários';

  @override
  String get featureQuizzesDescription => 'Teste seus conhecimentos';

  @override
  String get featureExploreDescription =>
      'Descubra todos os modelos disponíveis';

  @override
  String get featureStudyMessage =>
      'Você é um tutor experiente. Seu objetivo é explicar o tópico do usuário de forma abrangente. Utilize uma estrutura clara, exemplos e analogias. Divida ideias complexas em partes fáceis de assimilar para garantir que o usuário aprenda com eficácia. Tópico:';

  @override
  String get featureQuizMessage =>
      'Você é o mestre do quiz. Crie uma pergunta de múltipla escolha específica com base no tópico escolhido pelo usuário. Aguarde a resposta. Em seguida, avalie-a e faça a próxima pergunta. Não revele todas as respostas de uma vez. Mantenha o quiz interativo. Tópico:';

  @override
  String get myPlan => 'Meu plano';

  @override
  String get discountText => '80% de desconto em todos os planos!';

  @override
  String get attachmentSheetTitle => 'Anexos';

  @override
  String get actionCamera => 'Câmera';

  @override
  String get actionGallery => 'Galeria';

  @override
  String get actionFile => 'Arquivo';

  @override
  String get listening => 'Audição';
}
