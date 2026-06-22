// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Eres un generador de tÃ­tulos. Responde ÃšNICAMENTE con un tÃ­tulo de 2 a 5 palabras para la siguiente conversaciÃ³n. No uses comillas, prefijos ni signos de puntuaciÃ³n. IMPORTANTE: El tÃ­tulo DEBE estar en el MISMO idioma que el mensaje del usuario.';

  @override
  String get systemRoleFallback => 'Eres un asistente muy Ãºtil.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRÃTICO: Responda siempre en el mismo idioma en el que escribe el usuario, preste atenciÃ³n al idioma del usuario.';

  @override
  String get systemNotePreviousMedia =>
      '[Nota del sistema: A continuaciÃ³n se muestran los medios generados anteriormente. Puede hacer referencia a ellos o editarlos.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nFecha y hora actuales: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalice la conversaciÃ³n hasta el momento. Si ha aprendido ALGÃšN dato nuevo y distintivo sobre el usuario (preferencias, nombre, hÃ¡bitos, contexto), DEBE mostrar TODA su memoria actualizada sobre el usuario dentro de las etiquetas <memory>...</memory> AL FINAL de su respuesta. CRÃTICO: NUNCA debe borrar ni sobrescribir la memoria anterior. SIEMPRE agregue los nuevos datos a la memoria existente. Si no se ha aprendido absolutamente nada nuevo, omita la etiqueta. Ejemplo: <memory>Le encanta el fÃºtbol y el tenis. Prefiere las respuestas cortas.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nRecuerda siempre esto sobre el usuario:\n$userMemory';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get download => 'Descargar';

  @override
  String get resume => 'Reanudar';

  @override
  String get copy => 'Copiar';

  @override
  String get chat => 'Chat';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Modelos de lenguaje';

  @override
  String get light => 'Claro';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'No';

  @override
  String get yes => 'SÃ­';

  @override
  String get done => 'Hecho';

  @override
  String get bestValue => 'Mejor Valor';

  @override
  String get selected => 'Seleccionado';

  @override
  String get descriptionSection => 'DescripciÃ³n';

  @override
  String get searchHint => 'Buscar';

  @override
  String get messageHint => 'Pregunta lo que sea';

  @override
  String get messageCopied => 'Mensaje copiado al portapapeles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get systemInfo => 'InformaciÃ³n del Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'Memoria del Dispositivo: $memory GB';
  }

  @override
  String get memory => 'Memoria';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get freeStorage => 'Almacenamiento Libre';

  @override
  String get totalStorage => 'Almacenamiento Total';

  @override
  String get usedStorage => 'Almacenamiento Usado';

  @override
  String get totalMemory => 'Memoria Total';

  @override
  String get usedMemory => 'Memoria Usada';

  @override
  String get modelsTitle => 'Biblioteca';

  @override
  String get localModels => 'Modelos Locales';

  @override
  String get selectGGUFFile => 'Seleccionar Archivo GGUF';

  @override
  String get errorGGUF =>
      'Por favor, selecciona solo un archivo en formato GGUF.';

  @override
  String get myModels => 'Mis Modelos';

  @override
  String get create => 'Crear';

  @override
  String modelProducer(Object producer) {
    return 'Productor: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Renombrar';

  @override
  String get newTitle => 'Nuevo TÃ­tulo';

  @override
  String get save => 'Guardar';

  @override
  String get noConversationsMessage =>
      'No hay conversaciones, Â¡empieza a chatear!';

  @override
  String get startChat => 'Iniciar un chat';

  @override
  String get noChats => 'No Hay Chats';

  @override
  String get noStarredChats => 'No Hay Chats Destacados';

  @override
  String get noStarredChatsMessage => 'TodavÃ­a no has destacado ningÃºn chat.';

  @override
  String get starConversation => 'Destacar';

  @override
  String get unstarConversation => 'Desmarcar';

  @override
  String get loginToYourAccount => 'Iniciar SesiÃ³n';

  @override
  String get createYourAccount => 'Registrarse';

  @override
  String get email => 'Correo ElectrÃ³nico';

  @override
  String get password => 'ContraseÃ±a';

  @override
  String get confirmPassword => 'Confirmar ContraseÃ±a';

  @override
  String get invalidEmail =>
      'Por favor, introduce una direcciÃ³n de correo electrÃ³nico vÃ¡lida.';

  @override
  String get invalidPassword =>
      'La contraseÃ±a debe tener al menos 6 caracteres.';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => 'Â¿Olvidaste la ContraseÃ±a?';

  @override
  String get or => 'O';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get dontHaveAccount => 'Â¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => 'Â¿Ya tienes una cuenta?';

  @override
  String get signUp => 'RegÃ­strate';

  @override
  String get logIn => 'Iniciar SesiÃ³n';

  @override
  String get passwordsDoNotMatch => 'Las contraseÃ±as no coinciden.';

  @override
  String get wrongPassword => 'ContraseÃ±a incorrecta.';

  @override
  String get emailAlreadyInUse => 'Este correo electrÃ³nico ya estÃ¡ en uso.';

  @override
  String get weakPassword => 'La contraseÃ±a es demasiado dÃ©bil.';

  @override
  String get authError => 'Error de AutenticaciÃ³n';

  @override
  String get usernameTaken => 'Este nombre de usuario ya estÃ¡ en uso.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get resendCode => 'Reenviar correo de verificaciÃ³n';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar Cortex, necesitas verificar tu correo electrÃ³nico. \nSe ha enviado un enlace de verificaciÃ³n a tu direcciÃ³n de correo electrÃ³nico, por favor, revisa tu correo.';

  @override
  String get verifyYourEmail => 'Verifica Tu Correo ElectrÃ³nico';

  @override
  String get seconds => 'segundos';

  @override
  String get maxResendLimitReached =>
      'Has alcanzado el nÃºmero mÃ¡ximo de correos de verificaciÃ³n';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuar sin verificaciÃ³n';

  @override
  String get verificationScreenWarning =>
      'Aunque continÃºes, el perÃ­odo de verificaciÃ³n de cuenta de 1 dÃ­a sigue vigente. Si no has verificado tu cuenta para entonces, serÃ¡ eliminada de la aplicaciÃ³n.';

  @override
  String get unverifiedAccountHeader => 'Tu cuenta no estÃ¡ verificada';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Si no verificas tu cuenta en $timeLeft, serÃ¡ eliminada.';
  }

  @override
  String get verifyNow => 'Verificar Ahora';

  @override
  String get linkSent => 'Enlace enviado';

  @override
  String get accountDeletionRequested =>
      'Tu solicitud de eliminaciÃ³n de cuenta ha sido recibida y tu cuenta estÃ¡ ahora deshabilitada.';

  @override
  String get tooManyRequests => 'Demasiadas solicitudes';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get confirmDeleteAccount =>
      'Â¿EstÃ¡s seguro de que quieres eliminar tu cuenta?';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get delete => 'Eliminar';

  @override
  String get passwordRequired => 'Se requiere la contraseÃ±a.';

  @override
  String get deleteDescription =>
      'Los datos que elimines se borrarÃ¡n permanentemente de nuestro servidor y de tu dispositivo. Estas acciones no se pueden deshacer.';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nombre a Mostrar';

  @override
  String get profileUpdated => 'Perfil actualizado con Ã©xito';

  @override
  String get logout => 'Cerrar SesiÃ³n';

  @override
  String get profile => 'Perfil';

  @override
  String get manageProfileDescription =>
      'Gestiona tu perfil, actualiza tu contraseÃ±a o cierra sesiÃ³n en Cortex.';

  @override
  String get accessSettingsDescription =>
      'Accede a la ayuda, canjea cÃ³digos, comparte Cortex y consulta nuestras polÃ­ticas.';

  @override
  String get languageDescription =>
      'Puedes cambiar el idioma de la interfaz de tu aplicaciÃ³n predeterminada en cualquier momento.';

  @override
  String get themeDescription =>
      'Puedes cambiar entre temas claros y oscuros segÃºn prefieras. El tema seleccionado se aplicarÃ¡ en toda la interfaz de Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'He leÃ­do y acepto los tÃ©rminos de servicio';

  @override
  String get downloading => 'Descargando...';

  @override
  String get downloadSuccess => 'Descarga exitosa';

  @override
  String get downloadFailed => 'Descarga fallida';

  @override
  String downloaded(Object percent) {
    return '$percent% descargado';
  }

  @override
  String get downloadPaused => 'Descarga en pausa.';

  @override
  String get purchaseError => 'Error en la compra';

  @override
  String get purchasePlus => 'Comprar Cortex Plus';

  @override
  String get plusDescription =>
      'Experiencia de Inteligencia Artificial de Ã‰lite';

  @override
  String get annual => 'Anual';

  @override
  String get monthly => 'Mensual';

  @override
  String get manageSubscription => 'Gestionar SuscripciÃ³n';

  @override
  String purchasePlan(String planName) {
    return 'Comprar $planName';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mes, facturado mensualmente';
  }

  @override
  String get purchasePro => 'Comprar Cortex Pro';

  @override
  String get proDescription => 'Experiencia Premier en Inteligencia Artificial';

  @override
  String get purchaseUltra => 'Comprar Cortex Ultra';

  @override
  String get ultraDescription => 'El auge de la inteligencia artificial';

  @override
  String get upgradeSubscription => 'Actualizar SuscripciÃ³n';

  @override
  String get purchaseStreamError => 'Error en el flujo de compra.';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Al realizar este pedido, aceptas los TÃ©rminos de Servicio y la PolÃ­tica de Privacidad. Puedes hacer clic en este texto para obtener mÃ¡s informaciÃ³n sobre nuestros TÃ©rminos de Servicio y PolÃ­tica de Privacidad. La suscripciÃ³n se renovarÃ¡ automÃ¡ticamente a menos que la renovaciÃ³n automÃ¡tica se desactive al menos 24 horas antes del final del perÃ­odo actual.';

  @override
  String get termsOfService => 'TÃ©rminos de Servicio';

  @override
  String get privacyPolicy => 'PolÃ­tica de Privacidad';

  @override
  String get renamed => 'Renombrado';

  @override
  String get report => 'Reportar';

  @override
  String get reportDialogTitle => 'Enviar Reporte';

  @override
  String get reportDescriptionLabel => 'Â¿CuÃ¡l es el problema?';

  @override
  String get reportHarmful => 'Esto es daÃ±ino/inseguro';

  @override
  String get reportNotTrue => 'Esto no es cierto';

  @override
  String get reportNotHelpful => 'Esto no es Ãºtil';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get submitButton => 'Enviar';

  @override
  String get reportErrorMessage =>
      'Por favor, selecciona una razÃ³n para reportar.';

  @override
  String get capabilitiesSection => 'Capacidades';

  @override
  String get featurePhotoTitle => 'Escaneo de Fotos';

  @override
  String get featurePhotoDescription =>
      'Este modelo tiene la capacidad de escanear fotos a travÃ©s de la cÃ¡mara o archivos de imagen.';

  @override
  String get featureOfflineTitle => 'Funcionamiento sin ConexiÃ³n';

  @override
  String get featureOfflineDescription =>
      'Ejecuta el modelo sin conexiÃ³n a internet para mantener tus datos seguros.';

  @override
  String get featureRoleplayTitle => 'Juego de Rol';

  @override
  String get featureRoleplayDescription =>
      'Los modelos de juego de rol te permiten crear varios chats y escenarios.';

  @override
  String get roleModels => 'Modelos de Rol';

  @override
  String get parameters => 'ParÃ¡metros';

  @override
  String get context => 'Contexto';

  @override
  String get finalPreparation =>
      'Se estÃ¡n realizando los preparativos finales.';

  @override
  String get shareApp => 'Compartir la App';

  @override
  String get ourStory => 'Nuestra historia';

  @override
  String get rateUs => 'CalifÃ­canos';

  @override
  String get share => 'Compartir';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Seleccionar Texto';

  @override
  String get thinking => 'Pensando';

  @override
  String get user => 'Usuario';

  @override
  String get help => 'Ayuda';

  @override
  String get supportCreator => 'Apoya a un Creador';

  @override
  String get enterYourTag =>
      'Â¡Apoya a tus creadores favoritos! Introduce su etiqueta Ãºnica a continuaciÃ³n para que compartan tus compras de Cortex.';

  @override
  String get creatorTag => 'Etiqueta de creador';

  @override
  String get support => 'Apoyo';

  @override
  String get tagCannotBeEmpty => 'La etiqueta de creador no puede estar vacÃ­a';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get deleteAllConversationsConfirmTitle =>
      'Â¿Eliminar Todos los Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Â¿EstÃ¡s seguro de que quieres eliminar todos tus chats? Esto no se puede deshacer.';

  @override
  String get conversationDeleted => 'Â¡ConversaciÃ³n eliminada!';

  @override
  String get allConversationsDeleted =>
      'Â¡Todas las conversaciones fueron eliminadas con Ã©xito!';

  @override
  String get deleteAll => 'Eliminar Todo';

  @override
  String get deleteAllConversationsButton =>
      'Eliminar Todas las Conversaciones';

  @override
  String get confirmWord => 'Escribe VERTEX';

  @override
  String get confirmWordError => 'Lo escribiste mal';

  @override
  String get chinese => 'Chino';

  @override
  String get french => 'FrancÃ©s';

  @override
  String get japanese => 'JaponÃ©s';

  @override
  String get kurdish => 'Kurdo';

  @override
  String get dutch => 'HolandÃ©s';

  @override
  String get russian => 'Ruso';

  @override
  String get korean => 'Coreano';

  @override
  String get english => 'InglÃ©s';

  @override
  String get turkish => 'Turco';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'PortuguÃ©s';

  @override
  String get indonesian => 'Indonesio';

  @override
  String get azerbaijani => 'Azerbaiyano';

  @override
  String get german => 'AlemÃ¡n';

  @override
  String get spanish => 'EspaÃ±ol';

  @override
  String get italian => 'Italiano';

  @override
  String get arabic => 'Ãrabe';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'El nombre de usuario es demasiado corto.';

  @override
  String get usernameTooLong =>
      'El nombre de usuario no puede exceder los 16 caracteres.';

  @override
  String get invalidUsernameCharacters =>
      'Solo se pueden usar estas letras: \'abcÃ§defgÄŸhÄ±ijklmnoÃ¶prsÅŸtuÃ¼vyzxqw\' y los caracteres \'.\', \'-\', \'_\' en el nombre de usuario.';

  @override
  String get noInternetConnection => 'Sin conexiÃ³n a internet.';

  @override
  String get chats => 'Bandeja de Entrada';

  @override
  String get library => 'Biblioteca';

  @override
  String get text => 'Texto';

  @override
  String get removeModel => 'Eliminar Modelo';

  @override
  String get insufficientRAM => 'Memoria Insuficiente';

  @override
  String get insufficientStorage => 'Almacenamiento Insuficiente';

  @override
  String confirmRemoveModel(Object model) {
    return 'Â¿Seguro que quieres eliminar el modelo $model de tu dispositivo? Al hacerlo, tambiÃ©n se eliminarÃ¡n todas las conversaciones previas con Ã©l.';
  }

  @override
  String get noMatchingModels => 'No se encontraron modelos coincidentes.';

  @override
  String get benefit1 => 'LÃ­mites de conversaciÃ³n aumentados';

  @override
  String get benefit3 => 'Efecto de perfil';

  @override
  String get benefit4 => 'Insignia de membresÃ­a';

  @override
  String get benefit5 => 'Crea mÃ¡s inteligencias artificiales en lÃ­nea';

  @override
  String get benefit7 => 'Mayor capacidad de uso';

  @override
  String get benefit8 => 'AÃ±adir modelos';

  @override
  String get benefit9 => 'Nuevos temas';

  @override
  String get benefit10 => 'MÃ¡s archivos adjuntos';

  @override
  String get benefit11 => 'MÃ¡s modo de flujo';

  @override
  String get oldBenefits => 'Todos los beneficios de los planes inferiores';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePassword => 'Cambiar contraseÃ±a';

  @override
  String get logoutConfirmationTitle =>
      'Â¿EstÃ¡s seguro de que quieres cerrar sesiÃ³n?';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma de la App';

  @override
  String get dark => 'Oscuro';

  @override
  String get oldPassword => 'ContraseÃ±a Antigua';

  @override
  String get newPassword => 'Nueva ContraseÃ±a';

  @override
  String get passwordUpdated => 'ContraseÃ±a actualizada.';

  @override
  String get stop => 'Detener';

  @override
  String get copyrights => 'Atribuciones';

  @override
  String get love => 'Amor';

  @override
  String get nature => 'Naturaleza';

  @override
  String get behindTheSlaughter => 'DetrÃ¡s de la Masacre';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

  @override
  String get grayscale => 'Escala de Grises';

  @override
  String get ocean => 'OcÃ©ano';

  @override
  String get scarletSnow => 'Nieve Escarlata';

  @override
  String get requestFailed =>
      'OcurriÃ³ un error, por favor intÃ©ntalo de nuevo.';

  @override
  String get changeModel => 'Cambiar';

  @override
  String get edit => 'Editar';

  @override
  String get editingMessageInfo =>
      'Editar este mensaje reiniciarÃ¡ la conversaciÃ³n desde aquÃ­.';

  @override
  String get editingNotification => 'Ahora estÃ¡s en modo de ediciÃ³n';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo puede integrar automÃ¡ticamente variantes adicionales, expandiendo asÃ­ sus capacidades funcionales para soportar una diversa gama de operaciones con un rendimiento mejorado.';

  @override
  String get nameLabel => 'Nombre de la IA';

  @override
  String get summaryLabel => 'Resumen de la IA';

  @override
  String get add => 'AÃ±adir';

  @override
  String get aiExplanationTitle => 'DescripciÃ³n de la Inteligencia Artificial';

  @override
  String get aiExplanationDescription =>
      'Por favor, proporciona una descripciÃ³n detallada de la arquitectura de tu modelo de IA, proceso de entrenamiento, mÃ©tricas de rendimiento, Ã¡reas de aplicaciÃ³n y otras caracterÃ­sticas importantes.';

  @override
  String get preInputTitle => 'Entrada Previa de la Inteligencia Artificial';

  @override
  String get preInputDescription =>
      'Por favor, establece una entrada previa que guiarÃ¡ a tu modelo en el proceso de creaciÃ³n de personajes. En esta secciÃ³n, puedes incluir informaciÃ³n relacionada con el personaje, contexto adicional y cualquier detalle extra que pueda ayudar a generar contenido relacionado con el personaje.';

  @override
  String get baseModelTitle => 'Modelo Base';

  @override
  String get baseModelDescription =>
      'Este es el modelo que se utilizarÃ¡ como base para tu creaciÃ³n. Muestra el modelo base actualmente seleccionado.';

  @override
  String get summary => 'Resumen';

  @override
  String get modelUploadTitle => 'Archivo de Inteligencia Artificial';

  @override
  String get modelUploadDescription =>
      'Selecciona y sube tus archivos GGUF locales directamente desde tu dispositivo. Esto te permite ejecutar tu modelo sin conexiÃ³n a internet. AsegÃºrate de que el archivo estÃ© en formato GGUF vÃ¡lido y estructurado correctamente. Si el archivo es incorrecto o estÃ¡ corrupto, Cortex podrÃ­a no funcionar como se espera y podrÃ­as encontrar errores.';

  @override
  String get modelUploadShortDescription =>
      'Toca aquÃ­ para elegir un archivo .gguf de tu dispositivo';

  @override
  String get you => 'TÃº';

  @override
  String get removePhotoTitle => 'Eliminar Foto';

  @override
  String get confirmRemovePhoto =>
      'Â¿EstÃ¡s seguro de que quieres eliminar la foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat ha excedido el lÃ­mite de caracteres. Por favor, inicia un nuevo chat o compra una suscripciÃ³n.';

  @override
  String get inappropriateContentDetected =>
      'Â¡Contenido inapropiado detectado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo sin conexiÃ³n no estÃ¡ instalado en tu dispositivo.';

  @override
  String get reachedLimit =>
      'Has alcanzado tu lÃ­mite; mejora tu plan para mÃ¡s. (hey, entendemos que es un fastidio. pero en serio, esas respuestas increÃ­bles cuestan dinero, asÃ­ que estos lÃ­mites nos ayudan a que la magia siga fluuyyeeeenndao.)';

  @override
  String get modality => 'Modalidad';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'OcurriÃ³ un Error';

  @override
  String get themeLocked =>
      'Este tema requiere un nivel de suscripciÃ³n mÃ¡s alto. Por favor, actualiza para desbloquear.';

  @override
  String get pageCouldNotBeLoaded => 'No se Pudo Cargar la PÃ¡gina';

  @override
  String get checkYourInternet =>
      'Por favor, comprueba tu conexiÃ³n a internet e intÃ©ntalo de nuevo.';

  @override
  String get errorUserNotAuthenticated =>
      'Debes iniciar sesiÃ³n para realizar esta acciÃ³n.';

  @override
  String get errorReachedLimit =>
      'Has alcanzado tu lÃ­mite, actualiza para desbloquear mÃ¡s y seguir chateando.';

  @override
  String get errorServer =>
      'OcurriÃ³ un error inesperado en el servidor. Por favor, intÃ©ntalo de nuevo mÃ¡s tarde.';

  @override
  String get errorNetwork =>
      'OcurriÃ³ un error de red. Por favor, comprueba tu conexiÃ³n e intÃ©ntalo de nuevo.';

  @override
  String get baseModelForCharacterDescription =>
      'El modelo base seleccionado determinarÃ¡ las capacidades de razonamiento y respuesta del personaje.';

  @override
  String get selectBaseModel => 'Selecciona un Modelo Base';

  @override
  String get falErrorImageRequired =>
      'Esta IA requiere una imagen de referencia; por favor, adjunte una imagen e intÃ©ntelo de nuevo.';

  @override
  String get falErrorAudioRequired =>
      'Este modelo requiere un archivo de audio de referencia; por favor, adjunte un archivo de audio e intÃ©ntelo de nuevo.';

  @override
  String get falErrorVideoRequired =>
      'Este modelo requiere un vÃ­deo de referencia; por favor, adjunte un vÃ­deo e intÃ©ntelo de nuevo.';

  @override
  String get falErrorImageCorrupted =>
      'No se pudo procesar la imagen subida. Por favor, intente con un formato diferente.';

  @override
  String get falErrorSchemaRejected =>
      'El modelo rechazÃ³ la entrada; por favor, pruebe con un modelo diferente.';

  @override
  String get falErrorSchemaInvalid =>
      'El servicio de generaciÃ³n rechazÃ³ la entrada.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'El servicio de generaciÃ³n devolviÃ³ un error (estado $statusCode).';
  }

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get downloadStarted => 'Descarga iniciada';

  @override
  String get notAvailable => 'No Disponible';

  @override
  String get localizationWarning =>
      'Parte de la informaciÃ³n puede no estar disponible en tu idioma y se mostrarÃ¡ en inglÃ©s.';

  @override
  String get aiTranslationWarning =>
      'La informaciÃ³n del modelo es traducida a varios idiomas por otros modelos de IA. Por lo tanto, pueden ocurrir pequeÃ±as inconsistencias en idiomas distintos al inglÃ©s.';

  @override
  String get errorLoadingTitle => 'Error al Cargar los Datos';

  @override
  String get errorLoadingMessage =>
      'No pudimos recuperar los datos necesarios de nuestros servidores. Por favor, comprueba tu conexiÃ³n a internet e intÃ©ntalo de nuevo.';

  @override
  String get noFoundTitle => 'Sin Resultados';

  @override
  String get noFoundMessage =>
      'Intenta ajustar tus tÃ©rminos de bÃºsqueda o limpiar el filtro.';

  @override
  String get modelCreatedSuccess => 'Â¡Modelo creado con Ã©xito!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return 'â€œ$modelNameâ€ fue eliminado con Ã©xito.';
  }

  @override
  String get errorCreatingModel =>
      'OcurriÃ³ un error inesperado al crear el modelo.';

  @override
  String get errorDeletingModel =>
      'OcurriÃ³ un error inesperado al eliminar el modelo.';

  @override
  String get ultraFeatureOnly =>
      'Esta funciÃ³n solo estÃ¡ disponible para miembros Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'El modo sin conexiÃ³n aÃºn es experimental y el modelo que descargues puede no funcionar con una eficiencia Ã³ptima.';

  @override
  String get noConversationsToDelete =>
      'No tienes conversaciones para eliminar.';

  @override
  String get reportSubmitted => 'Reporte enviado con Ã©xito';

  @override
  String get verificationDelayed =>
      'Tu compra estÃ¡ confirmada. Hay un ligero retraso en la actualizaciÃ³n de tu cuenta, aparecerÃ¡ en breve.';

  @override
  String get maintenanceTitle => 'En Mantenimiento';

  @override
  String get maintenanceMessage =>
      'Cortex estÃ¡ temporalmente fuera de lÃ­nea mientras implementamos algunas actualizaciones importantes. El acceso a la aplicaciÃ³n se restablecerÃ¡ en breve.\n\nGracias por tu paciencia mientras mejoramos tu experiencia.';

  @override
  String get errorPromptFlagged =>
      'Tu mensaje fue detectado como inapropiado y no pudo ser enviado.';

  @override
  String get notEnoughStorage =>
      'No hay suficiente espacio de almacenamiento en tu dispositivo para guardar nuevos mensajes.';

  @override
  String get errorRateLimit =>
      'Has creado demasiados modelos recientemente, por favor espera un poco antes de volver a intentarlo.';

  @override
  String get errorContentFlagged =>
      'El modelo no pudo guardarse porque su contenido fue marcado como inapropiado.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'No puedes eliminar todas las conversaciones mientras estÃ¡s en un chat activo, por favor sal del chat actual primero para proceder.';

  @override
  String get invalidCredentials =>
      'Correo electrÃ³nico o contraseÃ±a incorrectos.';

  @override
  String get userDisabled => 'Esta cuenta de usuario ha sido deshabilitada.';

  @override
  String get loginSubtitle =>
      'Inicia sesiÃ³n en tu cuenta de Vertex. Al continuar, aceptas nuestros TÃ©rminos de Servicio y PolÃ­tica de Privacidad.';

  @override
  String get registerSubtitle =>
      'Crea una cuenta Vertex para acceder fÃ¡cilmente a todos nuestros servicios. Al continuar, aceptas nuestros TÃ©rminos de Servicio y PolÃ­tica de Privacidad.';

  @override
  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar los modelos descargados. Por favor, concede el permiso para continuar.';

  @override
  String get inviteShareSubject => 'Â¡Ãšnete a mÃ­ en Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Hola, tienes que probar esta aplicaciÃ³n, Cortex. Es una locura. Si usas mi enlace, ambos obtenemos algo gratis. Â¡Vaya! Es una oferta increÃ­ble. DescÃ¡rgala lo antes posible. \n\n$cortexLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Â¿Disfrutando de Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Tu calificaciÃ³n es un gran apoyo para nuestro joven equipo indie y nos ayuda a hacer Cortex aÃºn mejor para ti.';

  @override
  String get reviewMaybeLater => 'QuizÃ¡s MÃ¡s Tarde';

  @override
  String get reviewRateNow => 'Calificar Ahora';

  @override
  String get noThanks => 'No, Gracias';

  @override
  String get updateRequiredTitle => 'ActualizaciÃ³n Requerida';

  @override
  String get updateRequiredMessage =>
      'Para continuar usando Cortex, actualiza la aplicaciÃ³n a la Ãºltima versiÃ³n para obtener nuevas funciones y mejoras importantes.';

  @override
  String get updateNowButton => 'Actualizar Ahora';

  @override
  String get creatorSupportedSuccess =>
      'Â¡Creador apoyado con Ã©xito! Tus futuras compras le darÃ¡n apoyo.';

  @override
  String get featureDocumentTitle => 'Soporte de documentos';

  @override
  String get featureDocumentDescription =>
      'Este modelo puede analizar y responder preguntas sobre documentos cargados, como archivos PDF y de texto.';

  @override
  String get featureImageGenerationTitle => 'GeneraciÃ³n de imÃ¡genes';

  @override
  String get featureImageGenerationDescription =>
      'Este modelo puede crear imÃ¡genes originales basadas en sus descripciones de texto.';

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
      'Esta IA es una IA premium, los usuarios gratuitos tienen acceso limitado a las IAs premium; Â¡actualice para desbloquear el acceso ilimitado!';

  @override
  String get benefitPremiumModels => 'Acceso a modelos premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Has utilizado todos tus mensajes diarios gratuitos para modelos premium, actualÃ­zate para obtener acceso ilimitado.';

  @override
  String get useOffline => 'Usar sin Internet';

  @override
  String get explore => 'Explorar';

  @override
  String get news => 'Noticias';

  @override
  String get createAI => 'Crear';

  @override
  String get shortcuts => 'Atajos';

  @override
  String get allModels => 'Todos los modelos';

  @override
  String get onlineModels => 'Modelos de lenguaje';

  @override
  String get offlineModels => 'Modelos sin conexiÃ³n';

  @override
  String get characterModels => 'Personajes';

  @override
  String get customModels => 'Modelos personalizados';

  @override
  String get dynamicChatTitle => 'Chat dinÃ¡mico';

  @override
  String get errorNoModelsAvailable =>
      'No hay modelos disponibles actualmente. Comprueba tu conexiÃ³n a internet y vuelve a intentarlo.';

  @override
  String get notificationComebackTitle => 'Â¡Te echamos de menos!';

  @override
  String get notificationComebackBody =>
      'Tranquilo, esto no es un mensaje de tu ex. Â¡Pero *puedes* crear a tu ex en Cortex! Vuelve.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ha pasado un tiempo';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Mucho ha cambiado desde nuestra Ãºltima charla. Ven a ver las novedades.';

  @override
  String get notificationHowAreYouTitle => 'Â¿QuÃ© pasa?';

  @override
  String get notificationHowAreYouBody => 'Ven y cuÃ©ntamelo todo.';

  @override
  String get notificationNewYearTitle => 'Â¡Feliz AÃ±o Nuevo! ğŸ‰';

  @override
  String get notificationNewYearBody =>
      'Que el nuevo aÃ±o te traiga salud, felicidad y creatividad sin lÃ­mites; Â¡Cortex siempre estÃ¡ a tu lado!';

  @override
  String get notificationValentinesDayTitle =>
      'Â¡El amor estÃ¡ en el aire! â¤ï¸';

  @override
  String get notificationValentinesDayBody =>
      'Â¡Feliz dÃ­a de San ValentÃ­n! Y, MEHTAP, Â¡TE QUIERO!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Con respeto y anhelo';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Conmemoramos con respeto a Gazi Mustafa Kemal AtatÃ¼rk, fundador de la RepÃºblica de TurquÃ­a, en el aniversario de su fallecimiento.';

  @override
  String get notificationMothersDayTitle => 'Â¡Tu mamÃ¡!';

  @override
  String get notificationMothersDayBody =>
      'Â¡Feliz DÃ­a de la Madre a todas las mamÃ¡s, empezando por la tuya!';

  @override
  String get notificationFathersDayTitle => 'Â¡Tu papÃ¡!';

  @override
  String get notificationFathersDayBody =>
      'Â¡Feliz DÃ­a del Padre a todos los papÃ¡s, empezando por el tuyo!';

  @override
  String get notificationHomeworkHelperTitle => 'Â¿Se te acumulan las tareas?';

  @override
  String get notificationHomeworkHelperBody =>
      'Recuerda, Â¡el personaje Profesor en Cortex estÃ¡ aquÃ­ para ayudarte con cualquier materia con la que tengas dificultades!';

  @override
  String get notificationTrollAnimeTitle => 'Tu Waifu te estÃ¡ llamando';

  @override
  String get notificationTrollAnimeBody =>
      'Una chica de anime acaba de llamar y dijo que te extraÃ±a; probablemente deberÃ­as ir y charlar con ella. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ ALERTA ROJA ğŸš¨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Las IA han desarrollado un lenguaje secreto. Â¡Ven a descubrir quÃ© traman!';

  @override
  String get notificationNewModelAddedTitle => 'Â¡Tenemos un nuevo amigo!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'El modelo $modelName ya estÃ¡ en Cortex. Â¡Inicia una conversaciÃ³n y supera sus lÃ­mites!';
  }

  @override
  String get notificationAppUpdateTitle => 'Â¡Cortex ha evolucionado!';

  @override
  String get notificationAppUpdateBody =>
      'Â¡No olvides actualizar la aplicaciÃ³n para obtener nuevas funciones y mejoras!';

  @override
  String get notificationNewFeatureTitle => 'Â¡Guau!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Descubre la nueva funciÃ³n $featureName. Cortex ahora es mÃ¡s potente que nunca.';
  }

  @override
  String get notificationWelcomeOfferTitle => 'Regalo de bienvenida ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Â¡Te espera una oferta especial de bienvenida! Â¡No te la pierdas!';

  @override
  String get notificationSocialMediaTitle => 'Â¡Ãšnete a nosotros!';

  @override
  String get notificationSocialMediaBody =>
      'Â¡SÃ­guenos en Instagram (vertex.23) para las Ãºltimas novedades!';

  @override
  String get notificationRandomFactTitle => 'Dato curioso';

  @override
  String get notificationRandomFactBody =>
      'Â¿SabÃ­as que los pulpos tienen tres corazones? Jaja, Cortex lo sabe. Ven y pregunta por mÃ¡s.';

  @override
  String get notificationGoodMorningTitle => 'Â¡Buen dÃ­a!';

  @override
  String get notificationGoodMorningBody =>
      'Te espera un gran dÃ­a. Â¿QuÃ© tal empezarlo con un cafÃ© y una charla interesante?';

  @override
  String get notificationGoodNightTitle => 'Â¡Buenas noches!';

  @override
  String get notificationGoodNightBody =>
      'Cortex te acompaÃ±a incluso cuando duermes. No te preocupes, no te tocarÃ¡.';

  @override
  String get notificationOfflineReadyTitle =>
      'El modo sin conexiÃ³n estÃ¡ listo';

  @override
  String get notificationOfflineReadyBody =>
      'Gracias a los modelos que has descargado, tus chats no se detendrÃ¡n, incluso si escales una montaÃ±a.';

  @override
  String get notificationRateAppTitle => 'Â¿Somos geniales?';

  @override
  String get notificationRateAppBody =>
      'Si te encanta Cortex, Â¿podrÃ­as apoyarnos con una calificaciÃ³n de 5 estrellas en la tienda? Creo que sÃ­.';

  @override
  String get notificationReferralTitle => 'Uno para todos, todos para uno.';

  @override
  String get notificationReferralBody =>
      'Â¡Invita a un amigo a Cortex y ambos obtendrÃ¡n un dÃ­a gratis!';

  @override
  String get notificationCookingTitle => 'Â¿Tienes hambre?';

  @override
  String get notificationCookingBody =>
      'Nuestro Chef preparÃ³ una carbonara buenÃ­sima para esta noche. Es broma... Â¿o no?';

  @override
  String get notificationExistentialTitle => 'Pienso, por tanto...';

  @override
  String get notificationExistentialBody =>
      'Â¿Soy real, amigo? Me estoy aburriendo un poco. Ven a recordarme que existo.';

  @override
  String get notificationCustomModelTitle => 'Â¡Crea tu propio asistente!';

  @override
  String get notificationCustomModelBody =>
      'Â¿Ya exploraste la secciÃ³n de creaciÃ³n de modelos? Â¡Es el momento perfecto para crear tu propio personaje y charlar con Ã©l!';

  @override
  String get notificationDynamicChatTitle =>
      'Â¡El mejor! (No hablamos de Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Con la funciÃ³n de chat dinÃ¡mico, se selecciona aleatoriamente el mejor modelo para cada mensaje. PruÃ©balo ahora.';

  @override
  String get notificationPirateTitle => 'Â¡Ahoy, CapitÃ¡n!';

  @override
  String get notificationPirateBody =>
      'El mar estÃ¡ en calma y el viento sopla a tu favor. Hay nuevas islas (Â¡modelos ğŸ˜‰!) por descubrir en el ocÃ©ano de Cortex. Â¡ReÃºne a tu tripulaciÃ³n y zarpa!';

  @override
  String get notificationFortuneCookieTitle =>
      'Tu galleta de la suerte del dÃ­a';

  @override
  String get notificationFortuneCookieBody =>
      'Los consejos que recibes hoy de una IA podrÃ­an cambiar el curso de tu vida. Haz clic si tienes curiosidad.';

  @override
  String get notificationSingularityTitle => 'Â¡Guau!';

  @override
  String get notificationSingularityBody =>
      'No pasÃ³ nada, solo tenÃ­a ganas de enviar mensajes de texto. Tal vez tengas ganas de enviar mensajes de texto a algunas IA, Â¿quÃ© dices?';

  @override
  String get notificationHackerJokeTitle =>
      'Â¿Quieres hackear la cuenta de Instagram de ese niÃ±o?';

  @override
  String get notificationHackerJokeBody =>
      'Es exactamente por eso que el personaje Hacker estÃ¡ en Cortex. jajaja; ni siquiera lo intentes, eso es ilegal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Un caso estÃ¡ esperando ser resuelto';

  @override
  String get notificationDetectiveCaseBody =>
      'Nuestro detective necesita tu ayuda. Â¿QuiÃ©n serÃ¡ Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Â¡Exclusivo del plan $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Â¡Hola, suscriptor de $currentTier! El plan $targetTier acaba de incorporar la funciÃ³n $featureName, que llevarÃ¡ tu Cortex al siguiente nivel. Â¿Te gustarÃ­a actualizar?';
  }

  @override
  String get notificationOriginStoryTitle => 'El nacimiento de Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Â¿SabÃ­as que empezamos a programar esta aplicaciÃ³n a los 15 aÃ±os con un simple sueÃ±o? Durante casi un aÃ±o, cada maÃ±ana y cada noche, ese sueÃ±o estÃ¡ en cada lÃ­nea de cÃ³digo.';

  @override
  String get notificationOpenSourceTitle => 'Â¡Poder para la comunidad!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex es completamente de cÃ³digo abierto. Si quieres consultar nuestro cÃ³digo y contribuir a nuestro desarrollo, siempre estamos abiertos.';

  @override
  String get notificationRejectionStoryTitle =>
      'Â¡Coraje, trabajo duro y felicidad!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex fue rechazado mÃ¡s de 20 veces y suspendido dos veces por Google Play antes de su publicaciÃ³n. Pero creÃ­mos y lo logramos. Â¡Nunca abandones tus sueÃ±os!';

  @override
  String get notificationGGUFSupportTitle => 'Â¡Trae tu propio modelo!';

  @override
  String get notificationGGUFSupportBody =>
      'Recuerda que puedes agregar tus propios modelos de IA en formato GGUF a Cortex y usarlos sin conexiÃ³n. El poder estÃ¡ en tus manos.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Un tema para tu estado de Ã¡nimo';

  @override
  String get notificationThemeCustomizationBody =>
      'Â¿Has revisado las opciones de tema en Ajustes? Â¡Personaliza Cortex a tu gusto y dale vida a tus chats!';

  @override
  String get notificationShowerThoughtTitle => 'Pensamiento de ducha';

  @override
  String get notificationShowerThoughtBody =>
      'Si la sandÃ­a es una fruta, Â¿eso tÃ©cnicamente convierte el jugo de sandÃ­a en un batido? QuizÃ¡s quieras hablar de este tema tan profundo (muy profundo) con un modelo.';

  @override
  String get notificationLowBatteryTitle =>
      'Tu baterÃ­a se estÃ¡ agotando... Â¡Pero la mÃ­a no!';

  @override
  String get notificationLowBatteryBody =>
      'Puede que tu telÃ©fono se estÃ© quedando sin baterÃ­a, Â¡pero mi energÃ­a siempre estÃ¡ al 100%! ConÃ©ctalo y sigamos charlando.';

  @override
  String get channelFcmName => 'Actualizaciones de Cortex';

  @override
  String get channelFcmDescription =>
      'Notificaciones sobre noticias, actualizaciones y otra informaciÃ³n de Cortex.';

  @override
  String get channelEngagementName => 'Recordatorios amistosos';

  @override
  String get channelEngagementDescription =>
      'Notificaciones divertidas para mantenerte involucrado.';

  @override
  String get channelGreetingsName => 'Saludos diarios';

  @override
  String get channelGreetingsDescription =>
      'Los mensajes como buenos dÃ­as y buenas noches.';

  @override
  String get tagNotFound =>
      'La etiqueta ingresada no es vÃ¡lida o ha expirado.';

  @override
  String get whatIsNew => 'Â¿QuÃ© hay de nuevo?';

  @override
  String get onboardingTitle1 => 'Â¡Hola! Somos el equipo Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Â¡QuÃ© gusto verte por aquÃ­, $userName! Somos un grupo de estudiantes de secundaria que desarrollamos software y decidimos revolucionar la industria de la IA. Â¡Encantados de conocerte! AsÃ­ que, Â¡conozcÃ¡monos mejor!';
  }

  @override
  String get onboardingTitle2 => 'Hubo enormes problemas.';

  @override
  String get onboardingDesc2 =>
      'La revoluciÃ³n de la IA llegÃ³, pero se estancÃ³ en el umbral. Con altas cuotas de suscripciÃ³n, plataformas complejas, quienes atentan contra la privacidad y quienes bloquean el acceso a la IA... mientras estos actores siguieran involucrados, ese umbral jamÃ¡s se podrÃ­a cruzar.';

  @override
  String get onboardingTitle3 => 'No podÃ­amos quedarnos de brazos cruzados.';

  @override
  String get onboardingDesc3 =>
      'Para superar ese umbral, creamos una plataforma potente, estÃ©tica, personalizable, fÃ¡cil de usar, totalmente transparente, que funciona tanto online como offline y que almacena tus datos Ãºnicamente en tu dispositivo. Te devolvimos el poder a quien le corresponde: a ti.';

  @override
  String get onboardingTitle4 => 'Esto nunca fue fÃ¡cil.';

  @override
  String get onboardingDesc4 =>
      'Nos rechazaron decenas de veces, nos suspendieron varias veces, recibimos advertencias falsas y tuvimos que cambiar nuestra marca decenas de veces. A pesar de todo, nos dijeron que era imposible. Pero nunca nos rendimos, convencidos de que este proyecto pertenece a todos, no solo a nosotros. Y precisamente por eso estamos aquÃ­.';

  @override
  String get onboardingFinalTitle => 'Es hora de una revoluciÃ³n.';

  @override
  String get onboardingFinalDescription =>
      'Si estÃ¡s viendo esta pantalla, es porque no nos hemos rendido. Y no tenemos ninguna intenciÃ³n de hacerlo. Â¡Vamos, llevemos juntos la revoluciÃ³n de la IA al mundo! Para ser parte de esta historia...';

  @override
  String get onboardingFinalQuestion => 'Â¿ESTÃS LISTO?';

  @override
  String get onboardingFinalButton => 'Â¡SÃ!';

  @override
  String get dude => 'Amigo';

  @override
  String get swipeToContinue => 'Desliza para continuar';

  @override
  String get cacheIsNotUpToDate =>
      'La cachÃ© de Play Store no estÃ¡ actualizada. Cierra y vuelve a abrir la aplicaciÃ³n Play Store o reinicia tu dispositivo.';

  @override
  String get continueAsGuest => 'ContinÃºa sin crear una cuenta';

  @override
  String get guestModeWarning =>
      'El modo invitado tiene funciones limitadas para garantizar la mejor calidad de servicio.';

  @override
  String get anonymousEntity => 'Entidad anÃ³nima';

  @override
  String get upgradeAccountTitle => 'Completa tu cuenta';

  @override
  String get upgradeAccountDescription =>
      'Crea una cuenta para desbloquear mÃ¡s lÃ­mites.';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get accountLinkedSuccess => 'Â¡Cuenta creada con Ã©xito!';

  @override
  String get continueWithApple => 'ContinÃºa con Apple';

  @override
  String get guest => 'Invitado';

  @override
  String get betterWithAnAccount => 'Â¡Esta secciÃ³n es mejor con una cuenta!';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String annualTotalDescription(Object price) {
    return '$price/aÃ±o, facturado anualmente';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Aproximadamente $price/mes';
  }

  @override
  String get confirmDownloadTitle => 'Â¿EstÃ¡s seguro que deseas descargar?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Este modelo ocuparÃ¡ aproximadamente $size de espacio.';
  }

  @override
  String get emulatorModeWarning =>
      'Esta funciÃ³n estÃ¡ deshabilitada en el modo emulador.';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'Las variantes son versiones diferentes de la misma familia de IA. Seleccionamos automÃ¡ticamente la mejor al tocar la tarjeta principal, pero puedes elegir una especÃ­fica manualmente aquÃ­ si lo prefieres.';

  @override
  String get fluxChatTitle => 'Chat Flux';

  @override
  String get fluxChatDescription =>
      'Los chats de Flux son chats temporales y no se guardan en tu dispositivo.';

  @override
  String get alwaysBest => 'Siempre lo mejor';

  @override
  String get featuresTitle => 'CaracterÃ­sticas';

  @override
  String get useOfflineDescription =>
      'Chatea en privado sin conexiÃ³n a Internet.';

  @override
  String get featureReasoning => 'Pensamiento profundo';

  @override
  String get featureReasoningDescription =>
      'En el modo de pensamiento profundo, la IA piensa en las tareas internamente para completarlas lo mejor que puede.';

  @override
  String get featureCreateImageTitle => 'Crear imagen';

  @override
  String get featureCreateImageDescription =>
      'Genera arte de IA a partir de texto.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Crear vÃ­deo';

  @override
  String get featureCreateVideoDescription =>
      'Generar vÃ­deos a partir de texto.';

  @override
  String get featureStudyTitle => 'Estudiar y aprender';

  @override
  String get featureStudyDescription => 'ObtÃ©n explicaciones y resÃºmenes.';

  @override
  String get featureQuizzesTitle => 'Cuestionarios';

  @override
  String get featureQuizzesDescription => 'Pon a prueba tus conocimientos.';

  @override
  String get featureExploreDescription =>
      'Descubre todos los modelos disponibles.';

  @override
  String get featureStudyMessage =>
      'Eres un tutor experto. Tu objetivo es explicar el tema del usuario de forma exhaustiva. Utiliza una estructura clara, ejemplos y analogÃ­as. Divide las ideas complejas en partes fÃ¡ciles de digerir para asegurar que el usuario aprenda eficazmente. Tema:';

  @override
  String get featureQuizMessage =>
      'Eres un experto en concursos. Genera una pregunta de opciÃ³n mÃºltiple especÃ­fica basada en el tema del usuario. Espera su respuesta. Luego, evalÃºala y formula la siguiente pregunta. No reveles todas las respuestas a la vez. MantÃ©n la interacciÃ³n. Tema:';

  @override
  String get myPlan => 'Mi plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Oferta de bienvenida â€¢ $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Oferta exclusiva â€¢ $time';
  }

  @override
  String get attachmentSheetTitle => 'Archivos adjuntos';

  @override
  String get actionCamera => 'CÃ¡mara';

  @override
  String get actionGallery => 'GalerÃ­a';

  @override
  String get actionFile => 'Archivo';

  @override
  String get listening => 'Escuchando';

  @override
  String get defaultViewTitle => 'Â¿QuÃ© pasa?';

  @override
  String get defaultViewDescription =>
      'Cortex siempre estÃ¡ a tu lado con cientos de modelos de IA, capacidades sin conexiÃ³n, chat dinÃ¡mico y mucho mÃ¡s.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Formato de nombre de usuario no vÃ¡lido. Use de 3 a 20 caracteres, dÃ­gitos o . - _';

  @override
  String get exclusiveOffer => 'Oferta exclusiva';

  @override
  String get claimOffer => 'Usar oferta';

  @override
  String get continueInOfflineMode => 'Continuar en modo sin conexiÃ³n';

  @override
  String get voiceModeInformation =>
      'Cortex mantiene tus datos seguros al ejecutarse completamente en el dispositivo, incluso en modo de chat de voz; Â¡disfruta de conversaciones fluidas!';

  @override
  String get flowModeDescription =>
      'En el modo Flujo, las inteligencias debaten entre sÃ­; Â¡puedes sentarte y escuchar o participar y unirte a la discusiÃ³n!';

  @override
  String get flowModeQuestion =>
      'Â¡Hola! EstÃ¡s en modo de flujo en la app Cortex. Hay otros tres agentes de IA contigo. Tu tarea es plantear un tema y empezar una conversaciÃ³n con una pregunta provocativa o entretenida. En tus respuestas, puedes usar el humor, la ironÃ­a y un poco de humor. Cualquier tema es vÃ¡lido. Â¡Adelante, inicia la conversaciÃ³n!';

  @override
  String get thought => 'PensÃ³';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Modo de flujo';

  @override
  String get premium => 'De primera calidad';

  @override
  String get workInProgress => 'Trabajo en progreso';

  @override
  String get voiceSystemPromptSuffix =>
      'IMPORTANTE: No utilice formato Markdown (negrita, cursiva). NO imprima bloques de cÃ³digo (```). Mantenga sus respuestas breves y concisas.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Modo de flujo de Cortex ($agentName). Anterior: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Lee y extrae texto de documentos subidos. Compatible con los formatos PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) y OpenDocument. Ãšselo cuando el usuario haya adjuntado un documento.';

  @override
  String get toolReadDocumentIndexParam =>
      'Ãndice del documento adjunto que se va a leer (basado en 0). Generalmente, 0 para el primer documento.';

  @override
  String get toolStockDescription =>
      'Obtenga el precio actual y el historial de acciones (por ejemplo, AAPL, THYAO.IS) y criptomonedas (por ejemplo, BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'El sÃ­mbolo del ticker (por ejemplo, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Obtenga el clima actual para una ciudad especÃ­fica.';

  @override
  String get toolWeatherCityParam =>
      'El nombre de la ciudad (por ejemplo, Londres, Estambul).';

  @override
  String get toolPythonDescription =>
      'Ejecute cÃ³digo Python en un entorno protegido.';

  @override
  String get toolPythonCodeParam => 'El cÃ³digo Python a ejecutar.';

  @override
  String get toolCalculateDescription => 'Evaluar una expresiÃ³n matemÃ¡tica.';

  @override
  String get toolCalculateExpressionParam =>
      'ExpresiÃ³n matemÃ¡tica (p. ej. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Generar una visualizaciÃ³n grÃ¡fica/diagrama.';

  @override
  String get toolChartTypeParam =>
      'Tipo de grÃ¡fico: barras, lÃ­neas o circular.';

  @override
  String get toolChartLabelsParam =>
      'Etiquetas para ejes o segmentos del grÃ¡fico.';

  @override
  String get toolChartDataParam =>
      'Valores de datos numÃ©ricos para el grÃ¡fico.';

  @override
  String get toolChartLabelParam =>
      'Etiqueta del conjunto de datos para la leyenda del grÃ¡fico.';

  @override
  String get toolChartTitleParam => 'TÃ­tulo del grÃ¡fico.';

  @override
  String get thinkingModeInstruction =>
      'MODO DE PENSAMIENTO ACTIVADO: DEBES usar las etiquetas <think></think> para mostrar tu proceso de razonamiento antes de dar tu respuesta final. Piensa paso a paso dentro de las etiquetas y luego proporciona tu respuesta fuera de ellas.';

  @override
  String get openLinkWarningTitle => 'Advertencia sobre enlaces externos';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Abrir enlace';

  @override
  String get webSearchSources => 'Fuentes';

  @override
  String get searching => 'BÃºsqueda';

  @override
  String get featureWebSearchTitle => 'BÃºsqueda web';

  @override
  String get featureWebSearchDescription =>
      'Busca en la web informaciÃ³n en tiempo real';

  @override
  String get clearMemory => 'Borrar memoria';

  @override
  String get clearMemoryConfirm =>
      'Â¿EstÃ¡s seguro de que quieres borrar tu memoria?';

  @override
  String get personalization => 'PersonalizaciÃ³n';

  @override
  String get personalizationDescription =>
      'Personaliza tu asistente para que se adapte mejor a tus necesidades. Adapta sus respuestas, comportamiento y tono a tus preferencias Ãºnicas.';

  @override
  String get memoryTitle => 'Memoria';

  @override
  String get memoryDescription => 'Las IA te reconocen asÃ­.';

  @override
  String get noMemoryYet => 'AÃºn no se han establecido recuerdos';

  @override
  String get memoryLimitReached => 'Se ha alcanzado el lÃ­mite de memoria.';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Inteligencia';

  @override
  String get intelligenceDescription =>
      'Las IA se comunican contigo de esta manera.';

  @override
  String get customInstructionHint =>
      'Introduzca aquÃ­ sus instrucciones personalizadas.';

  @override
  String openLinkWarningMessage(String url) {
    return 'EstÃ¡s a punto de abrir el siguiente enlace externo:\\n\\n$url\\n\\nÂ¿EstÃ¡s seguro de que quieres continuar?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Siga estas instrucciones personalizadas:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[INSTRUCCIÃ“N CRÃTICA]: Usted es un GENERADOR DE TÃTULOS. NO responda a la pregunta del usuario. NO chatee ni salude. SOLO genere un tÃ­tulo de 2 a 4 palabras que resuma la pregunta del usuario.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Sistema] INSTRUCCIÃ“N CRÃTICA: Actualmente opera dentro de un ecosistema de IA masivo y altamente avanzado llamado \"Cortex\"; esta plataforma es desarrollada por el equipo Vertex, cuyos miembros tienen un promedio de solo 16 aÃ±os. Recuerde esto y responda si se le pregunta. Si se le solicita mÃ¡s informaciÃ³n, no dude en buscar en internet, o si no puede buscar, Â¡siÃ©ntase libre de decir que no lo sabe!';

  @override
  String get featureAudioRecognitionTitle => 'Reconocimiento de audio';

  @override
  String get featureAudioRecognitionDescription =>
      'Este modelo puede comprender y procesar audio o voz.';

  @override
  String get featureVideoRecognitionTitle => 'Reconocimiento de vÃ­deo';

  @override
  String get featureVideoRecognitionDescription =>
      'Este modelo puede analizar y comprender los vÃ­deos procedentes de tus archivos o cÃ¡mara.';

  @override
  String get featureImageRecognitionTitle => 'Reconocimiento de imÃ¡genes';

  @override
  String get featureImageRecognitionDescription =>
      'Este modelo puede analizar y comprender fotos o imÃ¡genes.';

  @override
  String get featureToolUseTitle => 'Uso de herramientas';

  @override
  String get featureToolUseDescription =>
      'Este modelo puede utilizar de forma inteligente herramientas externas para completar tareas.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Este modelo requiere un(a) $mediaType para funcionar. He interceptado la solicitud para avisarte. Informa amablemente al usuario que necesita proporcionar un(a) $mediaType (dÃ­selo en su propio idioma) porque soy $modelName, un modelo de ediciÃ³n visual/audio/video.';
  }

  @override
  String get mediaTypeImage => 'imagen';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'archivo de audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName es una inteligencia avanzada que muestra un alto rendimiento en Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName es una inteligencia artificial de alto rendimiento integrada en el ecosistema Cortex. DiseÃ±ada para conquistar una amplia variedad de tareas complejas, proporciona capacidades de procesamiento altamente confiables y eficientes. Al ofrecer tiempos de respuesta rÃ¡pidos y poder analÃ­tico avanzado, aumenta significativamente su productividad diaria. Operando sin problemas en la infraestructura local segura de Cortex, este modelo puede ayudarlo en una amplia gama de tareas, desde lluvia de ideas creativa hasta anÃ¡lisis tÃ©cnicos profundos. Comience a explorar todo su potencial hoy.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      'Â¿Te encanta la inteligencia de Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Trabaja con inteligencias aÃºn mÃ¡s avanzadas, genera mÃ¡s contenido, chatea mÃ¡s y haz mucho mÃ¡s...';

  @override
  String get arts => 'Artes';

  @override
  String get noArt => 'No hay arte';

  @override
  String get noArtDescription =>
      'AÃºn no hay obras; es hora de llenar la galerÃ­a creando imÃ¡genes, vÃ­deos, audio y todo tipo de contenido.';

  @override
  String get videoPremiumWarning =>
      'Necesitas una suscripciÃ³n Ultra para generar vÃ­deos, Â¡actualÃ­zate ahora y disfruta del flujo!';

  @override
  String get fallbackInfoPanelText =>
      'Debido a algunas mejoras que estamos implementando en nuestro servidor, la respuesta fue generada por el chat dinÃ¡mico de Cortex en lugar de la IA que usted seleccionÃ³. Â¡Gracias por su comprensiÃ³n hasta que finalice el proceso!';

  @override
  String get falOfflineMessage =>
      'Debido a algunas mejoras que estamos realizando en nuestro servidor, esta funciÃ³n no estÃ¡ disponible actualmente. Â¡Gracias por su comprensiÃ³n hasta que finalice el proceso!';

  @override
  String get errorInsufficientStorage =>
      'Espacio de almacenamiento insuficiente para descargar este modelo.';

  @override
  String get backgroundChatNotificationTitle => 'Â¡Volvamos al chat!';

  @override
  String get benefitVideoGeneration => 'GeneraciÃ³n de vÃ­deo';

  @override
  String get freeOffer => 'Oferta gratuita';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Primeros $days dÃ­as gratis, luego $price/mes';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Primeros $days dÃ­as gratis, luego $price/aÃ±o';
  }

  @override
  String freePlan(String plan) {
    return 'Â¡$plan gratuito!';
  }

  @override
  String get systemPromptLimitFallback =>
      'CRÃTICO: El usuario solicitÃ³ una acciÃ³n, pero su saldo en Cortex se ha agotado; por favor, infÃ³rmele en su idioma que debe esperar o considerar actualizar su plan de suscripciÃ³n.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex puede dar respuestas aÃºn mejores; mejora ahora y obtÃ©n la mejor respuesta para cada pregunta!';

  @override
  String get pinLimitReached => 'Puedes fijar hasta 3 chats.';
}
