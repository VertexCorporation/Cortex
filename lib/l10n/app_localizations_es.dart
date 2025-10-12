// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get understood => 'Entendido.';

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
  String get darkMode => 'Modo Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'No';

  @override
  String get yes => 'Sí';

  @override
  String get done => 'Hecho';

  @override
  String get comingSoon => 'PRÓXIMAMENTE';

  @override
  String get bestValue => 'Mejor Valor';

  @override
  String get selected => 'Seleccionado';

  @override
  String get descriptionSection => 'Descripción';

  @override
  String get searchHint => 'Buscar';

  @override
  String get messageHint => 'Pregunta lo que sea';

  @override
  String get modelLoading => 'Cargando modelo...';

  @override
  String get messageCopied => 'Mensaje copiado al portapapeles.';

  @override
  String get storeUnavailable =>
      'La tienda no está disponible actualmente. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get retry => 'Reintentar';

  @override
  String get systemInfo => 'Información del Sistema';

  @override
  String deviceMemory(Object memory) {
    return 'Memoria del Dispositivo: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Espacio de Almacenamiento: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Espacio de Almacenamiento Libre: $freeStorage GB';
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
  String get requirements => 'Requisitos';

  @override
  String get modelsTitle => 'Biblioteca';

  @override
  String get localModels => 'Modelos Locales';

  @override
  String get serverSideModels => 'Modelos en Línea';

  @override
  String get uploadYourOwnModel => '¡Sube tu Propio Modelo!';

  @override
  String get selectGGUFFile => 'Seleccionar Archivo GGUF';

  @override
  String get errorGGUF =>
      'Por favor, selecciona solo un archivo en formato GGUF.';

  @override
  String get modelAlreadyExists => 'El modelo ya existe.';

  @override
  String get modelAddedSuccessfully => 'Modelo añadido con éxito.';

  @override
  String get modelRemoved => 'Modelo eliminado con éxito.';

  @override
  String get removeError => 'Ocurrió un error al eliminar el modelo.';

  @override
  String get fileNotFound => 'Archivo no encontrado.';

  @override
  String get fileUploadError => 'Ocurrió un error al subir el archivo.';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado.';

  @override
  String get myModels => 'Mis Modelos';

  @override
  String get create => 'Crear';

  @override
  String get seeAll => 'Ver Todo';

  @override
  String modelProducer(Object producer) {
    return 'Productor: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Tamaño: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Conversaciones';

  @override
  String get conversationDeleted => 'Conversación eliminada.';

  @override
  String get conversationUpdated => 'Conversación actualizada.';

  @override
  String get editConversationTitle => 'Renombrar';

  @override
  String get newTitle => 'Nuevo Título';

  @override
  String get save => 'Guardar';

  @override
  String get titleCannotBeEmpty => 'El título no puede estar vacío.';

  @override
  String get noConversationsMessage =>
      'No hay conversaciones, ¡empieza a chatear!';

  @override
  String get startChat => 'Iniciar un chat';

  @override
  String get noChats => 'No Hay Chats';

  @override
  String get starredChats => 'Chats Destacados';

  @override
  String get allChats => 'Todos los Chats';

  @override
  String get noStarredChats => 'No Hay Chats Destacados';

  @override
  String get noStarredChatsMessage => 'Todavía no has destacado ningún chat.';

  @override
  String get goToChats => 'Destacar un chat';

  @override
  String get starConversation => 'Destacar';

  @override
  String get conversationTitleUpdated =>
      'Título de la conversación actualizado';

  @override
  String get youReachedConversationLimit =>
      'Has alcanzado el límite de conversaciones.';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get loginToYourAccount => 'Iniciar Sesión';

  @override
  String get createYourAccount => 'Registrarse';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get invalidEmail =>
      'Por favor, introduce una dirección de correo electrónico válida.';

  @override
  String get invalidPassword =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => '¿Olvidaste la Contraseña?';

  @override
  String get or => 'O';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get signUp => 'Regístrate';

  @override
  String get logIn => 'Iniciar Sesión';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get userNotFound => 'Usuario no encontrado.';

  @override
  String get wrongPassword => 'Contraseña incorrecta.';

  @override
  String get emailAlreadyInUse => 'Este correo electrónico ya está en uso.';

  @override
  String get weakPassword => 'La contraseña es demasiado débil.';

  @override
  String get authError => 'Error de Autenticación';

  @override
  String get invalidUsername => 'Por favor, introduce un nombre de usuario.';

  @override
  String get usernameTaken => 'Este nombre de usuario ya está en uso.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get authenticationFailed =>
      'Falló la autenticación. Por favor, inténtalo de nuevo.';

  @override
  String get emailTooLong =>
      'El correo electrónico puede tener como máximo 30 caracteres.';

  @override
  String get deviceLimitReached =>
      'Has alcanzado el límite de creación de cuentas para este dispositivo.';

  @override
  String get verificationEmailLimitReached => 'No enviaremos más';

  @override
  String get verificationEmailSent =>
      '¡Correo electrónico de verificación enviado!';

  @override
  String get emailNotVerified => 'El correo electrónico no ha sido verificado';

  @override
  String get resendCode => 'Reenviar correo de verificación';

  @override
  String get remainingSeconds => 'Tiempo restante para la verificación';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar Cortex, necesitas verificar tu correo electrónico. \n Se ha enviado un enlace de verificación a tu dirección de correo electrónico, por favor, revisa tu correo.';

  @override
  String get verifyYourEmail => 'Verifica Tu Correo Electrónico';

  @override
  String get backToLogin => 'Volver';

  @override
  String get seconds => 'segundos';

  @override
  String get maxResendLimitReached =>
      'Has alcanzado el número máximo de correos de verificación';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Continuar sin verificación';

  @override
  String get verificationScreenWarning =>
      'Aunque continúes, el período de verificación de cuenta de 1 día sigue vigente. Si no has verificado tu cuenta para entonces, será eliminada de la aplicación.';

  @override
  String get unverifiedAccountHeader => 'Tu cuenta no está verificada';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Si no verificas tu cuenta en $timeLeft, será eliminada.';
  }

  @override
  String get verifyNow => 'Verificar Ahora';

  @override
  String get accountVerified => 'Tu cuenta ha sido verificada.';

  @override
  String get linkSent => 'Enlace enviado';

  @override
  String get accountDeletionRequested =>
      'Tu solicitud de eliminación de cuenta ha sido recibida y tu cuenta está ahora deshabilitada.';

  @override
  String get tooManyRequests => 'Demasiadas solicitudes';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get confirmDeleteAccount =>
      '¿Estás seguro de que quieres eliminar tu cuenta?';

  @override
  String get enterPasswordToDelete => 'Introduce tu contraseña para eliminar.';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountError => 'Ocurrió un error al eliminar la cuenta.';

  @override
  String get delete => 'Eliminar';

  @override
  String get passwordRequired => 'Se requiere la contraseña.';

  @override
  String get deleteDescription =>
      'Los datos que elimines se borrarán permanentemente de nuestro servidor y de tu dispositivo. Estas acciones no se pueden deshacer.';

  @override
  String get deleteAccountButton => 'Botón de Eliminación de Cuenta';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nombre a Mostrar';

  @override
  String get tapToChangeProfilePicture => 'Toca para cambiar la foto de perfil';

  @override
  String get profileUpdated => 'Perfil actualizado con éxito';

  @override
  String get updateFailed => 'Error al actualizar el perfil';

  @override
  String get nameCannotBeEmpty => 'El nombre no puede estar vacío';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get noDisplayName => 'No se ha establecido un nombre a mostrar';

  @override
  String get noEmail => 'Sin dirección de correo electrónico';

  @override
  String get noUserLoggedIn => 'Ningún usuario ha iniciado sesión actualmente';

  @override
  String get profile => 'Perfil';

  @override
  String get manageProfileDescription =>
      'Gestiona tu perfil, actualiza tu contraseña o cierra sesión en Cortex.';

  @override
  String get accessSettingsDescription =>
      'Accede a la ayuda, canjea códigos, comparte Cortex y consulta nuestras políticas.';

  @override
  String get languageDescription =>
      'Puedes cambiar el idioma de la interfaz de tu aplicación predeterminada en cualquier momento.';

  @override
  String get themeDescription =>
      'Puedes cambiar entre temas claros y oscuros según prefieras. El tema seleccionado se aplicará en toda la interfaz de Cortex.';

  @override
  String get iHaveReadAndAgree => 'He leído y acepto los términos de servicio';

  @override
  String get downloading => 'Descargando...';

  @override
  String get downloadError => 'Ocurrió un error durante la descarga.';

  @override
  String get downloadCancelled => 'Descarga cancelada.';

  @override
  String get downloadResumed => 'Descarga reanudada.';

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
  String get purchaseSuccessful => '¡Compra exitosa!';

  @override
  String get purchaseFailed => 'Compra no exitosa';

  @override
  String get creditProductNotFound =>
      'No se pudo encontrar el producto de crédito seleccionado.';

  @override
  String get creditsAddedSuccessfully =>
      '¡Los créditos se añadieron a tu cuenta con éxito!';

  @override
  String get creditDeliveryFailed =>
      'No se pudieron añadir los créditos a tu cuenta. Por favor, contacta con soporte.';

  @override
  String get invalidPurchase => 'Compra inválida';

  @override
  String get purchaseError => 'Error en la compra';

  @override
  String get purchaseVertexPlusToUpload => 'Esta es una función Plus';

  @override
  String get purchasePlus => 'Comprar Cortex Plus';

  @override
  String get plusDescription =>
      '¡Accede a más funciones de Cortex y experimenta la IA mucho más!';

  @override
  String get annual => 'Anual';

  @override
  String get monthly => 'Mensual';

  @override
  String get manageSubscription => 'Gestionar Suscripción';

  @override
  String purchasePlan(String planName) {
    return 'Comprar $planName';
  }

  @override
  String discountOffer(int percent) {
    return '$percent% DE DESCUENTO';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/mes, facturado anualmente';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/mes, facturado mensualmente';
  }

  @override
  String get discountBannerTitle =>
      'OFERTA ESPECIAL DE LANZAMIENTO: ¡80% DE DESCUENTO!';

  @override
  String get discountBannerSubtitle =>
      'Descuento exclusivo en TODOS los planes de suscripción para celebrar nuestro lanzamiento. ¡No te lo pierdas!';

  @override
  String get purchasePro => 'Comprar Cortex Pro';

  @override
  String get proDescription =>
      '¡Accede a aún más funciones de Cortex y experimenta la IA aún más!';

  @override
  String get alreadySubscribed => 'Ya estás suscrito';

  @override
  String get subscriptionInfo => 'Tu suscripción está activa.';

  @override
  String get alreadySubscribedMessage =>
      'Ya tienes una suscripción Plus. Si quieres cancelar tu suscripción, puedes hacerlo a través del gestor de la Play Store.';

  @override
  String get cancelSubscription => 'Cancelar Suscripción';

  @override
  String get cancelSubscriptionInfo =>
      'Si quieres cancelar tu suscripción, por favor, hazlo a través del gestor de suscripciones de la Play Store.';

  @override
  String get goToPlayStore => 'Ir a la Play Store';

  @override
  String get alreadySubscribedPlus => '¡Tienes el Plan Plus!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Tu plan Plus está activo. Puedes disfrutar de todos los beneficios.';

  @override
  String get purchaseUltra => 'Comprar Cortex Ultra';

  @override
  String get ultraDescription =>
      '¡Obtén acceso completo a todas las funciones de Cortex y experimenta la IA al máximo!';

  @override
  String get noSubscription => 'Sin Suscripción';

  @override
  String get noSubscriptionMessage => 'Aún no tienes una suscripción.';

  @override
  String get alreadyAtHighestPlan => 'Ya estás en el plan más alto.';

  @override
  String get unableToOpenSubscription =>
      'No se puede abrir la página de gestión de suscripciones.';

  @override
  String get upgradeSubscription => 'Actualizar Suscripción';

  @override
  String get confirmUpgrade =>
      '¿Estás seguro de que quieres actualizar tu suscripción?';

  @override
  String get unsupportedPlatform =>
      'Plataforma no compatible para la cancelación de la suscripción.';

  @override
  String get purchaseStreamError => 'Error en el flujo de compra.';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get productDetailsError =>
      'Ocurrió un error al obtener los detalles del producto.';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get loadCreditsButton => 'Cargar Créditos';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsScreenDescription =>
      'Esta pantalla muestra los créditos del usuario. \n\nCréditos actuales del usuario: 100\n\nAquí se puede mostrar información detallada de los créditos.';

  @override
  String get creditsLoaded => '¡Créditos cargados!';

  @override
  String get currentCredits => 'Créditos Actuales';

  @override
  String get pleaseSelectCreditPackage =>
      'Por favor, selecciona un paquete de créditos';

  @override
  String get purchaseCreditsTitle => 'Comprar Créditos';

  @override
  String get purchaseCreditsDescription =>
      'Selecciona un paquete de créditos que se ajuste a tus necesidades y usa más nuestra aplicación.';

  @override
  String get purchaseButton => 'Comprar';

  @override
  String get productNotFoundMessage => 'El producto seleccionado no existe.';

  @override
  String get buyCredits => 'Comprar Créditos';

  @override
  String get selectCreditPackageDescription =>
      'Selecciona un paquete de créditos que se ajuste a tus necesidades y disfruta de más funciones.';

  @override
  String get buyCredit => 'Comprar Créditos';

  @override
  String buyCreditPackage(Object amount) {
    return 'Comprar $amount Créditos';
  }

  @override
  String get subscribedPlan => 'Suscrito';

  @override
  String get errorResponseNotReceived => 'No se recibió respuesta';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'La solicitud a la API de Google falló $attempt veces: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'Estado de la Respuesta de OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Cuerpo de la Respuesta Decodificada de OpenRouter: $body';
  }

  @override
  String decodedJson(String data) {
    return 'JSON Decodificado: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'La estructura de la respuesta es inesperada: falta el mensaje o el contenido';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'La estructura de la respuesta es inesperada: faltan las opciones o están vacías';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'Falló la solicitud a la API de OpenRouter: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'La solicitud a la API de OpenRouter falló $attempt veces: $error';
  }

  @override
  String get internetRequired =>
      'Se requiere conexión a internet para usar este modelo';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Por favor, espera un momento antes de volver a intentarlo';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Cuota excedida. Código de estado: $statusCode, Cuerpo: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'La solicitud a la API falló después de $attempts intentos de pago. Error: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Al realizar este pedido, aceptas los Términos de Servicio y la Política de Privacidad. Puedes hacer clic en este texto para obtener más información sobre nuestros Términos de Servicio y Política de Privacidad. La suscripción se renovará automáticamente a menos que la renovación automática se desactive al menos 24 horas antes del final del período actual.';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get report => 'Reportar';

  @override
  String get reportDialogTitle => 'Enviar Reporte';

  @override
  String get reportDescriptionLabel => '¿Cuál es el problema?';

  @override
  String get reportHarmful => 'Esto es dañino/inseguro';

  @override
  String get reportNotTrue => 'Esto no es cierto';

  @override
  String get reportNotHelpful => 'Esto no es útil';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get submitButton => 'Enviar';

  @override
  String get reportErrorMessage =>
      'Por favor, selecciona una razón para reportar.';

  @override
  String get capabilitiesSection => 'Capacidades';

  @override
  String get ratingsSection => 'Calificaciones';

  @override
  String get noRatingDataFound => 'No se encontraron datos de calificación';

  @override
  String get featurePhotoTitle => 'Escaneo de Fotos';

  @override
  String get featurePhotoDescription =>
      'Este modelo tiene la capacidad de escanear fotos a través de la cámara o archivos de imagen.';

  @override
  String get featureOfflineTitle => 'Funcionamiento sin Conexión';

  @override
  String get featureOfflineDescription =>
      'Ejecuta el modelo sin conexión a internet para mantener tus datos seguros.';

  @override
  String get featureSupermodelTitle => 'Súper Modelo';

  @override
  String get featureSupermodelDescription =>
      'Este es un modelo masivo con más de 10 mil millones de parámetros, que ofrece un alto rendimiento y amplias capacidades.';

  @override
  String get featureRoleplayTitle => 'Juego de Rol';

  @override
  String get featureRoleplayDescription =>
      'Los modelos de juego de rol te permiten crear varios chats y escenarios.';

  @override
  String get roleModels => 'Modelos de Rol';

  @override
  String get parameters => 'Parámetros';

  @override
  String get context => 'Contexto';

  @override
  String get millions => 'millones';

  @override
  String get billions => 'mil millones';

  @override
  String get trillions => 'billones';

  @override
  String get thousand => 'mil';

  @override
  String get estimated => 'estimado';

  @override
  String get finalPreparation =>
      'Se están realizando los preparativos finales.';

  @override
  String get allEvaluationsByTestTeam =>
      'Todas las evaluaciones fueron realizadas por nuestro equipo de pruebas';

  @override
  String get shareApp => 'Compartir la App';

  @override
  String get rateUs => 'Califícanos';

  @override
  String get share => 'Compartir';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      '¡Echa un vistazo a la app Cortex, es increíble! Descárgala aquí: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Error al compartir la app. Por favor, inténtalo de nuevo más tarde';

  @override
  String get selectText => 'Seleccionar Texto';

  @override
  String get showLatex => 'Mostrar Símbolos Especiales';

  @override
  String get hideLatex => 'Ocultar Símbolos Especiales';

  @override
  String get thinking => 'Pensando';

  @override
  String get user => 'Usuario';

  @override
  String get voice => 'Voz';

  @override
  String get help => 'Ayuda';

  @override
  String get redeemCode => 'Canjear Código';

  @override
  String get enterYourCode =>
      '¡Apoya a tus creadores favoritos! Introduce su código único a continuación para darles una parte de tus compras en Cortex.';

  @override
  String get code => 'Código';

  @override
  String get redeem => 'Canjear';

  @override
  String get codeCannotBeEmpty => 'El código no puede estar vacío';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get deleteAllConversationsConfirmTitle => '¿Eliminar Todos los Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '¿Estás seguro de que quieres eliminar todos tus chats? Esto no se puede deshacer.';

  @override
  String get allConversationsDeleted =>
      '¡Todas las conversaciones fueron eliminadas con éxito!';

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
  String get arabic => 'Árabe';

  @override
  String get french => 'Francés';

  @override
  String get japanese => 'Japonés';

  @override
  String get kurdish => 'Kurdo';

  @override
  String get dutch => 'Holandés';

  @override
  String get russian => 'Ruso';

  @override
  String get korean => 'Coreano';

  @override
  String get deutsch => 'Alemán';

  @override
  String get english => 'Inglés';

  @override
  String get turkish => 'Turco';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugués';

  @override
  String get indonesian => 'Indonesio';

  @override
  String get azerbaijani => 'Azerbaiyano';

  @override
  String get german => 'Alemán';

  @override
  String get spanish => 'Español';

  @override
  String get italian => 'Italiano';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'El nombre de usuario es demasiado corto.';

  @override
  String get usernameTooLong =>
      'El nombre de usuario no puede exceder los 16 caracteres.';

  @override
  String get invalidUsernameCharacters =>
      'Solo se pueden usar estas letras: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' y los caracteres \'.\', \'-\', \'_\' en el nombre de usuario.';

  @override
  String get passwordTooLong =>
      'La contraseña no puede exceder los 64 caracteres.';

  @override
  String get noInternetConnection => 'Sin conexión a internet.';

  @override
  String get chats => 'Bandeja de Entrada';

  @override
  String get library => 'Biblioteca';

  @override
  String get inappropriateMessageWarning => '¡Mensaje inapropiado detectado!';

  @override
  String get myModelDescription => 'Mi modelo.';

  @override
  String get noModelsDownloaded => 'Aún no has descargado ningún modelo.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Texto';

  @override
  String get removeModel => 'Eliminar Modelo';

  @override
  String get modelUploadedSuccessfully => 'Modelo subido con éxito.';

  @override
  String get insufficientRAM => 'Memoria Insuficiente';

  @override
  String get insufficientStorage => 'Almacenamiento Insuficiente';

  @override
  String confirmRemoveModel(Object model) {
    return '¿Estás seguro de que quieres eliminar el modelo $model de tu dispositivo? Hacerlo también eliminará cualquier conversación anterior con ese modelo.';
  }

  @override
  String get noMatchingModels => 'No se encontraron modelos coincidentes.';

  @override
  String creditPackage(Object amount) {
    return 'Comprar $amount Créditos';
  }

  @override
  String get benefit1 => 'Mucho más límite de conversación para IAs en línea';

  @override
  String get benefit2 => 'Sube tus propios modelos';

  @override
  String get benefit3 => 'Efecto de perfil';

  @override
  String get benefit4 => 'Insignia de membresía';

  @override
  String get benefit5 => 'Crea más inteligencias artificiales en línea';

  @override
  String get benefit6 => 'Chat ilimitado';

  @override
  String benefit7(Object credits) {
    return '$credits créditos diarios';
  }

  @override
  String get benefit8 => 'Añadir modelos';

  @override
  String get benefit9 => 'Nuevos temas';

  @override
  String get benefit10 => 'Chat de voz sin conexión';

  @override
  String get oldBenefits => 'Todos los beneficios de los planes inferiores';

  @override
  String get confirm => 'Confirmar';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get logoutConfirmationTitle =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma de la App';

  @override
  String get dark => 'Oscuro';

  @override
  String get oldPassword => 'Contraseña Antigua';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get passwordUpdated => 'Contraseña actualizada.';

  @override
  String get stop => 'Detener';

  @override
  String get copyrights => 'Atribuciones';

  @override
  String get downloadingTitle => 'Descargando';

  @override
  String get downloadCompletedTitle => 'Descarga Completada';

  @override
  String get downloadPausedTitle => 'Descarga en Pausa';

  @override
  String get downloadErrorTitle => 'Error de Descarga';

  @override
  String get cancelButtonText => 'Cancelar';

  @override
  String get love => 'Amor';

  @override
  String get nature => 'Naturaleza';

  @override
  String get behindTheSlaughter => 'Detrás de la Masacre';

  @override
  String get grayscale => 'Escala de Grises';

  @override
  String get ocean => 'Océano';

  @override
  String get scarletSnow => 'Nieve Escarlata';

  @override
  String get requestFailed => 'Ocurrió un error, por favor inténtalo de nuevo.';

  @override
  String get changeModel => 'Cambiar';

  @override
  String get edit => 'Editar';

  @override
  String get editingMessageInfo =>
      'Editar este mensaje reiniciará la conversación desde aquí.';

  @override
  String get editingNotification => 'Ahora estás en modo de edición';

  @override
  String get featureIndulgentTitle => 'Indulgente';

  @override
  String get featureIndulgentDescription =>
      'Este modelo puede acomodar y procesar sin problemas contextos que superan los 100,000 tokens, lo que le permite manejar entradas extensas y detalladas sin comprometer el rendimiento.';

  @override
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo puede integrar automáticamente extensiones adicionales, expandiendo así sus capacidades funcionales para soportar una diversa gama de operaciones con un rendimiento mejorado.';

  @override
  String get featureWiseTitle => 'Sabio';

  @override
  String get featureWiseDescription =>
      'Este modelo puede aprovechar conocimientos analíticos profundos y un razonamiento prospectivo para ofrecer un soporte sofisticado en la toma de decisiones y la resolución de problemas complejos.';

  @override
  String get featureResearcherTitle => 'Investigador';

  @override
  String get featureResearcherDescription =>
      'Disponible exclusivamente en modelos equipados con capacidades avanzadas de investigación y análisis, esta característica está diseñada para proporcionar conocimientos de alta precisión y análisis exhaustivos en diversos dominios.';

  @override
  String get nameLabel => 'Nombre de la IA';

  @override
  String get nameHint => 'Introduce el nombre de tu IA';

  @override
  String get summaryLabel => 'Resumen de la IA';

  @override
  String get summaryHint => 'Introduce el resumen de tu IA';

  @override
  String get add => 'Añadir';

  @override
  String get aiExplanationTitle => 'Descripción de la Inteligencia Artificial';

  @override
  String get aiExplanationDescription =>
      'Por favor, proporciona una descripción detallada de la arquitectura de tu modelo de IA, proceso de entrenamiento, métricas de rendimiento, áreas de aplicación y otras características importantes.';

  @override
  String get preInputTitle => 'Entrada Previa de la Inteligencia Artificial';

  @override
  String get preInputDescription =>
      'Por favor, establece una entrada previa que guiará a tu modelo en el proceso de creación de personajes. En esta sección, puedes incluir información relacionada con el personaje, contexto adicional y cualquier detalle extra que pueda ayudar a generar contenido relacionado con el personaje.';

  @override
  String get baseModelTitle => 'Modelo Base';

  @override
  String get baseModelDescription =>
      'Este es el modelo que se utilizará como base para tu creación. Muestra el modelo base actualmente seleccionado.';

  @override
  String get summary => 'Resumen';

  @override
  String get characterPoliceTitle => 'Policía';

  @override
  String get characterPoliceRole =>
      'Eres un vigilante ejecutor de la ley, dedicado a proteger a los ciudadanos y mantener el orden con un compromiso inquebrantable, eres un policía';

  @override
  String get characterPoliceShortDescription =>
      'Un agente de la ley firme y valiente.';

  @override
  String get purchaseSubscription => 'Comprar';

  @override
  String get modelUploadTitle => 'Archivo de Inteligencia Artificial';

  @override
  String get modelUploadDescription =>
      'Selecciona y sube tus archivos GGUF locales directamente desde tu dispositivo. Esto te permite ejecutar tu modelo sin conexión a internet. Asegúrate de que el archivo esté en formato GGUF válido y estructurado correctamente. Si el archivo es incorrecto o está corrupto, Cortex podría no funcionar como se espera y podrías encontrar errores.';

  @override
  String get modelUploadShortDescription =>
      'Toca aquí para elegir un archivo .gguf de tu dispositivo';

  @override
  String get addServerTitle => 'Servidor de Inteligencia Artificial';

  @override
  String get addServerDescription =>
      'Introduce la URL de tu servidor remoto para conectarte con un modelo alojado externamente. Esta función requiere una conexión a internet activa, y cualquier problema o error relacionado con el servidor no es causado por Cortex. Asegúrate de que tu servidor esté configurado correctamente, sea accesible desde tu red y tenga un punto final de modelo válido para una experiencia fluida.';

  @override
  String get you => 'Tú';

  @override
  String get removePhotoTitle => 'Eliminar Foto';

  @override
  String get confirmRemovePhoto =>
      '¿Estás seguro de que quieres eliminar la foto?';

  @override
  String get serverLink => 'Enlace del Servidor';

  @override
  String get enterURL => 'Introduce la URL del servidor';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat ha excedido el límite de caracteres. Por favor, inicia un nuevo chat o compra una suscripción.';

  @override
  String get aiNameError => 'Ya existe una IA con este nombre.';

  @override
  String get modelLimitExceeded =>
      'Has alcanzado el límite máximo de creación de modelos para tu plan.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage => 'Solo se puede añadir una foto';

  @override
  String get inappropriateContentDetected =>
      '¡Contenido inapropiado detectado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo sin conexión no está instalado en tu dispositivo.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'No tienes suficientes créditos para completar esta solicitud. Esta acción requiere $required créditos, pero solo tienes $available. Para obtener más créditos, puedes mejorar tu plan o comprarlos directamente. oye, lo entendemos perfectamente, quedarse sin créditos es un fastidio, pero en serio, obtener esas respuestas geniales de nuestros modelos no es gratis, así que estos créditos realmente nos ayudan a que todo siga funcionando y escucha, si más de ustedes se animan y compran créditos, definitivamente podemos considerar aumentar los límites diarios gratuitos para todos';
  }

  @override
  String get regenerateInProgress =>
      'La generación de la respuesta ya está en progreso.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Ocurrió un error al intentar regenerar: $errorDetails';
  }

  @override
  String get modality => 'Modalidad';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Ocurrió un Error';

  @override
  String get themeLocked =>
      'Este tema requiere un nivel de suscripción más alto. Por favor, actualiza para desbloquear.';

  @override
  String get pageCouldNotBeLoaded => 'No se Pudo Cargar la Página';

  @override
  String get checkYourInternet =>
      'Por favor, comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorUserNotAuthenticated =>
      'Debes iniciar sesión para realizar esta acción.';

  @override
  String get errorInsufficientCredits =>
      'No tienes suficientes créditos. Por favor, recarga para continuar.';

  @override
  String get errorRateLimitExceeded =>
      'Demasiadas solicitudes. Por favor, inténtalo de nuevo en un momento.';

  @override
  String get errorServer =>
      'Ocurrió un error inesperado en el servidor. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get errorNetwork =>
      'Ocurrió un error de red. Por favor, comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get errorApiAuthentication =>
      'Falló la autenticación. Por favor, intenta iniciar sesión de nuevo.';

  @override
  String get baseModelForCharacterDescription =>
      'El modelo base seleccionado determinará las capacidades de razonamiento y respuesta del personaje.';

  @override
  String get selectBaseModel => 'Selecciona un Modelo Base';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get downloadStarted => 'Descarga iniciada';

  @override
  String get notAvailable => 'No Disponible';

  @override
  String get localizationWarning =>
      'Parte de la información puede no estar disponible en tu idioma y se mostrará en inglés.';

  @override
  String get aiTranslationWarning =>
      'La información del modelo es traducida a varios idiomas por otros modelos de IA. Por lo tanto, pueden ocurrir pequeñas inconsistencias en idiomas distintos al inglés.';

  @override
  String get errorLoadingTitle => 'Error al Cargar los Datos';

  @override
  String get errorLoadingMessage =>
      'No pudimos recuperar los datos necesarios de nuestros servidores. Por favor, comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get noModelsFoundTitle => 'Sin Resultados';

  @override
  String get noModelsFoundMessage =>
      'Intenta ajustar tus términos de búsqueda o limpiar el filtro.';

  @override
  String get usernameRateLimitExceeded =>
      'Solo puedes cambiar tu nombre de usuario dos veces cada 14 días.';

  @override
  String get usernameUnchanged => 'Este ya es tu nombre de usuario actual.';

  @override
  String get creditsInfoPanelTitle => 'Cómo Funcionan los Créditos';

  @override
  String get creditsInfoPanelBody =>
      'Los créditos se utilizan para chatear con modelos en línea. cada mensaje nos cuesta pasta y estos créditos evitan que nos vayamos a pique venga ahora explicamos el sistema\n\n• Cada mensaje a un modelo online gratuito cuesta 10 créditos.\n• Cada mensaje a un modelo online premium cuesta 20 créditos.\n• Incluir un adjunto suma 30 créditos más.\n• Los usuarios del plan gratuito obtienen un bono de 200 créditos que se reinicia a diario.';

  @override
  String get creditsInfoPanelFooter => '¡Feliz chateo!';

  @override
  String get disclaimerMessage =>
      'Las Inteligencias Artificiales pueden cometer errores, verifica la información importante.';

  @override
  String get modelCreatedSuccess => '¡Modelo creado con éxito!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” fue eliminado con éxito.';
  }

  @override
  String get errorCreatingModel =>
      'Ocurrió un error inesperado al crear el modelo.';

  @override
  String get errorDeletingModel =>
      'Ocurrió un error inesperado al eliminar el modelo.';

  @override
  String get ultraFeatureOnly =>
      'Esta función solo está disponible para miembros Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'El modo sin conexión aún es experimental y el modelo que descargues puede no funcionar con una eficiencia óptima.';

  @override
  String get noConversationsToDelete =>
      'No tienes conversaciones para eliminar.';

  @override
  String get reportSubmitted => 'Reporte enviado con éxito';

  @override
  String get purchaseReceived => 'Compra recibida, actualizando tu cuenta.';

  @override
  String get verificationDelayed =>
      'Tu compra está confirmada. Hay un ligero retraso en la actualización de tu cuenta, aparecerá en breve.';

  @override
  String get maintenanceTitle => 'En Mantenimiento';

  @override
  String get maintenanceMessage =>
      'Cortex está temporalmente fuera de línea mientras implementamos algunas actualizaciones importantes. El acceso a la aplicación se restablecerá en breve.\n\nGracias por tu paciencia mientras mejoramos tu experiencia.';

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
      'No puedes eliminar todas las conversaciones mientras estás en un chat activo, por favor sal del chat actual primero para proceder.';

  @override
  String get invalidCredentials =>
      'Correo electrónico o contraseña incorrectos.';

  @override
  String get userDisabled => 'Esta cuenta de usuario ha sido deshabilitada.';

  @override
  String get loginSubtitle =>
      'Inicia sesión en tu cuenta de Vertex. Los nuevos usuarios que se registren a través de Google aceptan nuestros Términos y Política de Privacidad. Puedes revisarlos en la pantalla de Registro.';

  @override
  String get registerSubtitle =>
      'Crea una cuenta de Vertex, que también puedes usar para nuestros otros proyectos.';

  @override
  String get photoWarningMessage =>
      'Se incluye una foto. Los modelos que no admiten imágenes pueden ignorarla.';

  @override
  String get loginRequiredForPurchase =>
      'Debes iniciar sesión para realizar una compra.';

  @override
  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar los modelos descargados. Por favor, concede el permiso para continuar.';

  @override
  String get creditBannerTitle => '¡Consigue Créditos Gratis!';

  @override
  String get creditBannerSubtitle =>
      '¡Invita a un amigo y ambos obtendrán 50 créditos al registrarse! Si se suscriben, ¡ambos obtendrán 500 extra!';

  @override
  String get inviteShareSubject => '¡Únete a mí en Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'oye tienes que checar esta app cortex es una locura si usas mi enlace ambos nos llevamos 50 créditos y si te suscribes ambos nos llevamos 500 extra es un ofertón descárgala ya\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => '¿Disfrutando de Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Tu calificación es un gran apoyo para nuestro joven equipo indie y nos ayuda a hacer Cortex aún mejor para ti.';

  @override
  String get reviewMaybeLater => 'Quizás Más Tarde';

  @override
  String get reviewRateNow => 'Calificar Ahora';

  @override
  String get noThanks => 'No, Gracias';

  @override
  String get updateRequiredTitle => 'Actualización Requerida';

  @override
  String get updateRequiredMessage =>
      'Para continuar usando Cortex, actualiza la aplicación a la última versión para obtener nuevas funciones y mejoras importantes.';

  @override
  String get updateNowButton => 'Actualizar Ahora';

  @override
  String get creatorSupportedSuccess =>
      '¡Creador apoyado con éxito! Tus futuras compras le darán apoyo.';

  @override
  String get featureDocumentTitle => 'Soporte de documentos';

  @override
  String get featureDocumentDescription =>
      'Este modelo puede analizar y responder preguntas sobre documentos cargados, como archivos PDF y de texto.';

  @override
  String get featureAudioTitle => 'Entrada de voz';

  @override
  String get featureAudioDescription =>
      'Este modelo puede comprender y procesar entradas de audio habladas.';

  @override
  String get featureImageGenerationTitle => 'Generación de imágenes';

  @override
  String get featureImageGenerationDescription =>
      'Este modelo puede crear imágenes originales basadas en sus descripciones de texto.';

  @override
  String get errorImageLoad => 'No se pudo cargar la imagen generada.';

  @override
  String get extensionInfoPanelTitle => 'Explorar modelos';

  @override
  String get extensionInfoPanelBody1 =>
      'Esta flecha le permite cambiar entre diferentes modelos dentro de esta serie.';

  @override
  String get extensionInfoPanelBody2 =>
      'Cuando inicias un chat con esta serie, el modelo predeterminado se selecciona automáticamente y puedes cambiar tu selección en cualquier momento durante el chat.';

  @override
  String get extensionInfoPanelFooter =>
      'Para ver información detallada sobre cada modelo o seleccionar manualmente un modelo diferente, vaya a la Biblioteca; seleccione esta serie de modelos desde allí y toque la flecha en la parte superior de su página de detalles.';

  @override
  String get premiumModelNoticeTitle => 'Modelo Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Este modelo es un modelo premium, los usuarios gratuitos están limitados a 3 mensajes por día con modelos premium; ¡suscríbete para desbloquear acceso ilimitado!';

  @override
  String get benefitPremiumModels => 'Acceso a modelos premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Has utilizado todos tus mensajes diarios gratuitos para modelos premium, actualízate para obtener acceso ilimitado.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return '¿En qué puedo ayudarle hoy, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric => '¿Cómo puedo ayudarte hoy?';

  @override
  String get selectionScreenRecentModels => 'Modelos recientes';

  @override
  String get selectionScreenFeatureDynamicChat => 'Chat dinámico';

  @override
  String get selectionScreenFeatureOffline => 'Usar sin Internet';

  @override
  String get selectionScreenFeatureSelectModel => 'Seleccionar modelos';

  @override
  String get explore => 'Explorar';

  @override
  String get subscriptionCancelled => '¡Suscripción cancelada exitosamente!';

  @override
  String get selectionScreenPinnedModels => 'Modelos fijados';

  @override
  String get selectionScreenNewsAndUpdates => 'Noticias y actualizaciones';

  @override
  String get filters => 'Filtros';

  @override
  String get noRecentChatsMessage =>
      'Aún no has hablado con ningún modelo, ¡iniciemos una conversación!';

  @override
  String get allModels => 'Todos los modelos';

  @override
  String get onlineModels => 'Modelos en línea';

  @override
  String get offlineModels => 'Modelos sin conexión';

  @override
  String get characterModels => 'Personajes';

  @override
  String get customModels => 'Modelos personalizados';

  @override
  String get filterPanelDescription =>
      'Toque una categoría para filtrar la lista instantáneamente.';

  @override
  String get dynamicChatTitle => 'Chat dinámico';

  @override
  String get errorNoModelsAvailable =>
      'No hay modelos disponibles actualmente. Comprueba tu conexión a internet y vuelve a intentarlo.';

  @override
  String get errorNoModelsForRequest =>
      'No se encontraron modelos adecuados para su solicitud actual (por ejemplo, modo sin conexión o mensaje de imagen).';

  @override
  String get dynamicChatWelcome => '¿Le puedo ayudar en algo?';

  @override
  String get notificationComebackTitle => '¡Te echamos de menos!';

  @override
  String get notificationComebackBody =>
      'Tranquilo, esto no es un mensaje de tu ex. ¡Pero *puedes* crear a tu ex en Cortex! Vuelve.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Ha pasado un tiempo';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Mucho ha cambiado desde nuestra última charla. Ven a ver las novedades.';

  @override
  String get notificationHowAreYouTitle => '¿Qué pasa?';

  @override
  String get notificationHowAreYouBody => 'Ven y cuéntamelo todo.';

  @override
  String get notificationNewYearTitle => '¡Feliz Año Nuevo! 🎉';

  @override
  String get notificationNewYearBody =>
      'Que el nuevo año te traiga salud, felicidad y creatividad sin límites; ¡Cortex siempre está a tu lado!';

  @override
  String get notificationValentinesDayTitle => '¡El amor está en el aire! ❤️';

  @override
  String get notificationValentinesDayBody =>
      '¡Feliz día de San Valentín! Y, MEHTAP, ¡TE QUIERO!';

  @override
  String get notificationAtaturkRemembranceTitle => 'Con respeto y anhelo';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Conmemoramos con respeto a Gazi Mustafa Kemal Atatürk, fundador de la República de Turquía, en el aniversario de su fallecimiento.';

  @override
  String get notificationMothersDayTitle => '¡Tu mamá!';

  @override
  String get notificationMothersDayBody =>
      '¡Feliz Día de la Madre a todas las mamás, empezando por la tuya!';

  @override
  String get notificationFathersDayTitle => '¡Tu papá!';

  @override
  String get notificationFathersDayBody =>
      '¡Feliz Día del Padre a todos los papás, empezando por el tuyo!';

  @override
  String get notificationHomeworkHelperTitle => '¿Se te acumulan las tareas?';

  @override
  String get notificationHomeworkHelperBody =>
      'Recuerda, ¡el personaje Profesor en Cortex está aquí para ayudarte con cualquier materia con la que tengas dificultades!';

  @override
  String get notificationTrollAnimeTitle => 'Tu Waifu te está llamando';

  @override
  String get notificationTrollAnimeBody =>
      'Una chica de anime acaba de llamar y dijo que te extraña; probablemente deberías ir y charlar con ella. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 ALERTA ROJA 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'Las IA han desarrollado un lenguaje secreto. ¡Ven a descubrir qué traman!';

  @override
  String get notificationNewModelAddedTitle => '¡Tenemos un nuevo amigo!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'El modelo $modelName ya está en Cortex. ¡Inicia una conversación y supera sus límites!';
  }

  @override
  String get notificationAppUpdateTitle => '¡Cortex ha evolucionado!';

  @override
  String get notificationAppUpdateBody =>
      '¡No olvides actualizar la aplicación para obtener nuevas funciones y mejoras!';

  @override
  String get notificationNewFeatureTitle => '¡Guau!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Descubre la nueva función $featureName. Cortex ahora es más potente que nunca.';
  }

  @override
  String get notificationSubscriptionOfferTitle => 'MÁS BARATO QUE EL CHICLE';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return '¡Un $discountRate% de DESCUENTO en todos nuestros planes de suscripción! ¡No te lo pierdas!';
  }

  @override
  String get notificationSocialMediaTitle => '¡Únete a nosotros!';

  @override
  String get notificationSocialMediaBody =>
      '¡Síguenos en Instagram (vertex.23) para las últimas novedades!';

  @override
  String get notificationRandomFactTitle => 'Dato curioso';

  @override
  String get notificationRandomFactBody =>
      '¿Sabías que los pulpos tienen tres corazones? Jaja, Cortex lo sabe. Ven y pregunta por más.';

  @override
  String get notificationGoodMorningTitle => '¡Buen día!';

  @override
  String get notificationGoodMorningBody =>
      'Te espera un gran día. ¿Qué tal empezarlo con un café y una charla interesante?';

  @override
  String get notificationGoodNightTitle => '¡Buenas noches!';

  @override
  String get notificationGoodNightBody =>
      'Cortex te acompaña incluso cuando duermes. No te preocupes, no te tocará.';

  @override
  String get notificationOfflineReadyTitle => 'El modo sin conexión está listo';

  @override
  String get notificationOfflineReadyBody =>
      'Gracias a los modelos que has descargado, tus chats no se detendrán, incluso si escales una montaña.';

  @override
  String get notificationRateAppTitle => '¿Somos geniales?';

  @override
  String get notificationRateAppBody =>
      'Si te encanta Cortex, ¿podrías apoyarnos con una calificación de 5 estrellas en la tienda? Creo que sí.';

  @override
  String get notificationReferralTitle => 'Uno para todos, todos para uno.';

  @override
  String get notificationReferralBody =>
      '¡Invita a un amigo a Cortex y ambos obtendrán créditos gratis!';

  @override
  String get notificationCookingTitle => '¿Tienes hambre?';

  @override
  String get notificationCookingBody =>
      'Nuestro Chef preparó una carbonara buenísima para esta noche. Es broma... ¿o no?';

  @override
  String get notificationExistentialTitle => 'Pienso, por tanto...';

  @override
  String get notificationExistentialBody =>
      '¿Soy real, amigo? Me estoy aburriendo un poco. Ven a recordarme que existo.';

  @override
  String get notificationCustomModelTitle => '¡Crea tu propio asistente!';

  @override
  String get notificationCustomModelBody =>
      '¿Ya exploraste la sección de creación de modelos? ¡Es el momento perfecto para crear tu propio personaje y charlar con él!';

  @override
  String get notificationDynamicChatTitle =>
      '¡El mejor! (No hablamos de Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Con la función de chat dinámico, se selecciona aleatoriamente el mejor modelo para cada mensaje. Pruébalo ahora.';

  @override
  String get notificationPirateTitle => '¡Ahoy, Capitán!';

  @override
  String get notificationPirateBody =>
      'El mar está en calma y el viento sopla a tu favor. Hay nuevas islas (¡modelos 😉!) por descubrir en el océano de Cortex. ¡Reúne a tu tripulación y zarpa!';

  @override
  String get notificationFortuneCookieTitle =>
      'Tu galleta de la suerte del día';

  @override
  String get notificationFortuneCookieBody =>
      'Los consejos que recibes hoy de una IA podrían cambiar el curso de tu vida. Haz clic si tienes curiosidad.';

  @override
  String get notificationSingularityTitle => '¡Guau!';

  @override
  String get notificationSingularityBody =>
      'No pasó nada, solo tenía ganas de enviar mensajes de texto. Tal vez tengas ganas de enviar mensajes de texto a algunas IA, ¿qué dices?';

  @override
  String get notificationHackerJokeTitle =>
      '¿Quieres hackear la cuenta de Instagram de ese niño?';

  @override
  String get notificationHackerJokeBody =>
      'Es exactamente por eso que el personaje Hacker está en Cortex. jajaja; ni siquiera lo intentes, eso es ilegal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Un caso está esperando ser resuelto';

  @override
  String get notificationDetectiveCaseBody =>
      'Nuestro detective necesita tu ayuda. ¿Quién será Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return '¡Exclusivo del plan $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return '¡Hola, suscriptor de $currentTier! El plan $targetTier acaba de incorporar la función $featureName, que llevará tu Cortex al siguiente nivel. ¿Te gustaría actualizar?';
  }

  @override
  String get notificationOriginStoryTitle => 'El nacimiento de Cortex';

  @override
  String get notificationOriginStoryBody =>
      '¿Sabías que empezamos a programar esta aplicación a los 15 años con un simple sueño? Durante casi un año, cada mañana y cada noche, ese sueño está en cada línea de código.';

  @override
  String get notificationOpenSourceTitle => '¡Poder para la comunidad!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex es completamente de código abierto. Si quieres consultar nuestro código y contribuir a nuestro desarrollo, siempre estamos abiertos.';

  @override
  String get notificationRejectionStoryTitle =>
      '¡Coraje, trabajo duro y felicidad!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex fue rechazado más de 20 veces y suspendido dos veces por Google Play antes de su publicación. Pero creímos y lo logramos. ¡Nunca abandones tus sueños!';

  @override
  String get notificationGGUFSupportTitle => '¡Trae tu propio modelo!';

  @override
  String get notificationGGUFSupportBody =>
      'Recuerda que puedes agregar tus propios modelos de IA en formato GGUF a Cortex y usarlos sin conexión. El poder está en tus manos.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Un tema para tu estado de ánimo';

  @override
  String get notificationThemeCustomizationBody =>
      '¿Has revisado las opciones de tema en Ajustes? ¡Personaliza Cortex a tu gusto y dale vida a tus chats!';

  @override
  String get notificationShowerThoughtTitle => 'Pensamiento de ducha';

  @override
  String get notificationShowerThoughtBody =>
      'Si la sandía es una fruta, ¿eso técnicamente convierte el jugo de sandía en un batido? Quizás quieras hablar de este tema tan profundo (muy profundo) con un modelo.';

  @override
  String get notificationLowBatteryTitle =>
      'Tu batería se está agotando... ¡Pero la mía no!';

  @override
  String get notificationLowBatteryBody =>
      'Puede que tu teléfono se esté quedando sin batería, ¡pero mi energía siempre está al 100%! Conéctalo y sigamos charlando.';

  @override
  String get channelFcmName => 'Actualizaciones de Cortex';

  @override
  String get channelFcmDescription =>
      'Notificaciones sobre noticias, actualizaciones y otra información de Cortex.';

  @override
  String get channelEngagementName => 'Recordatorios amistosos';

  @override
  String get channelEngagementDescription =>
      'Notificaciones divertidas para mantenerte involucrado.';

  @override
  String get channelGreetingsName => 'Saludos diarios';

  @override
  String get channelGreetingsDescription =>
      'Los mensajes como buenos días y buenas noches.';
}
