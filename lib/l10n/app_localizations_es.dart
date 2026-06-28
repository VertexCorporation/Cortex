// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Eres un generador de títulos. Responde ÚNICAMENTE con un título de 2 a 5 palabras para la siguiente conversación. No uses comillas, prefijos ni signos de puntuación. IMPORTANTE: El título DEBE estar en el MISMO idioma que el mensaje del usuario.';

  @override
  String get systemRoleFallback => 'Eres un asistente muy útil.';

  @override
  String get systemLanguageInstruction =>
      '\n\nCRÍTICO: Responda siempre en el mismo idioma en el que escribe el usuario, preste atención al idioma del usuario.';

  @override
  String get systemNotePreviousMedia =>
      '[Nota del sistema: A continuación se muestran los medios generados anteriormente. Puede hacer referencia a ellos o editarlos.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nFecha y hora actuales: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalice la conversación hasta el momento. Si ha aprendido ALGÚN dato nuevo y distintivo sobre el usuario (preferencias, nombre, hábitos, contexto), DEBE mostrar TODA su memoria actualizada sobre el usuario dentro de las etiquetas <memory>...</memory> AL FINAL de su respuesta. CRÍTICO: NUNCA debe borrar ni sobrescribir la memoria anterior. SIEMPRE agregue los nuevos datos a la memoria existente. Si no se ha aprendido absolutamente nada nuevo, omita la etiqueta. Ejemplo: <memory>Le encanta el fútbol y el tenis. Prefiere las respuestas cortas.</memory>';

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
  String get yes => 'Sí';

  @override
  String get done => 'Hecho';

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
  String get messageCopied => 'Mensaje copiado al portapapeles.';

  @override
  String get retry => 'Reintentar';

  @override
  String get systemInfo => 'Información del Sistema';

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
  String get newTitle => 'Nuevo Título';

  @override
  String get save => 'Guardar';

  @override
  String get noConversationsMessage =>
      'No hay conversaciones, ¡empieza a chatear!';

  @override
  String get startChat => 'Iniciar un chat';

  @override
  String get noChats => 'No Hay Chats';

  @override
  String get noStarredChats => 'No Hay Chats Destacados';

  @override
  String get noStarredChatsMessage => 'Todavía no has destacado ningún chat.';

  @override
  String get starConversation => 'Destacar';

  @override
  String get unstarConversation => 'Desmarcar';

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
  String get wrongPassword => 'Contraseña incorrecta.';

  @override
  String get emailAlreadyInUse => 'Este correo electrónico ya está en uso.';

  @override
  String get weakPassword => 'La contraseña es demasiado débil.';

  @override
  String get authError => 'Error de Autenticación';

  @override
  String get usernameTaken => 'Este nombre de usuario ya está en uso.';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get resendCode => 'Reenviar correo de verificación';

  @override
  String get pleaseCheckYourEmail =>
      'Para usar Cortex, necesitas verificar tu correo electrónico. \nSe ha enviado un enlace de verificación a tu dirección de correo electrónico, por favor, revisa tu correo.';

  @override
  String get verifyYourEmail => 'Verifica Tu Correo Electrónico';

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
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get delete => 'Eliminar';

  @override
  String get passwordRequired => 'Se requiere la contraseña.';

  @override
  String get deleteDescription =>
      'Los datos que elimines se borrarán permanentemente de nuestro servidor y de tu dispositivo. Estas acciones no se pueden deshacer.';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nombre a Mostrar';

  @override
  String get profileUpdated => 'Perfil actualizado con éxito';

  @override
  String get logout => 'Cerrar Sesión';

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
      'Experiencia de Inteligencia Artificial de Élite';

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
  String get upgradeSubscription => 'Actualizar Suscripción';

  @override
  String get purchaseStreamError => 'Error en el flujo de compra.';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Al realizar este pedido, aceptas los Términos de Servicio y la Política de Privacidad. Puedes hacer clic en este texto para obtener más información sobre nuestros Términos de Servicio y Política de Privacidad. La suscripción se renovará automáticamente a menos que la renovación automática se desactive al menos 24 horas antes del final del período actual.';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get renamed => 'Renombrado';

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
  String get finalPreparation =>
      'Se están realizando los preparativos finales.';

  @override
  String get shareApp => 'Compartir la App';

  @override
  String get ourStory => 'Nuestra historia';

  @override
  String get rateUs => 'Califícanos';

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
      '¡Apoya a tus creadores favoritos! Introduce su etiqueta única a continuación para que compartan tus compras de Cortex.';

  @override
  String get creatorTag => 'Etiqueta de creador';

  @override
  String get support => 'Apoyo';

  @override
  String get tagCannotBeEmpty => 'La etiqueta de creador no puede estar vacía';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get deleteAllConversationsConfirmTitle => '¿Eliminar Todos los Chats?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      '¿Estás seguro de que quieres eliminar todos tus chats? Esto no se puede deshacer.';

  @override
  String get conversationDeleted => '¡Conversación eliminada!';

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
  String get french => 'Francés';

  @override
  String get japanese => 'Japonés';

  @override
  String get dutch => 'Holandés';

  @override
  String get russian => 'Ruso';

  @override
  String get korean => 'Coreano';

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
  String get arabic => 'Árabe';

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
  String get noInternetConnection => 'Sin conexión a internet.';

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
    return '¿Seguro que quieres eliminar el modelo $model de tu dispositivo? Al hacerlo, también se eliminarán todas las conversaciones previas con él.';
  }

  @override
  String get noMatchingModels => 'No se encontraron modelos coincidentes.';

  @override
  String get benefit1 => 'Límites de conversación aumentados';

  @override
  String get benefit3 => 'Efecto de perfil';

  @override
  String get benefit4 => 'Insignia de membresía';

  @override
  String get benefit5 => 'Crea más inteligencias artificiales en línea';

  @override
  String get benefit7 => 'Mayor capacidad de uso';

  @override
  String get benefit8 => 'Añadir modelos';

  @override
  String get benefit9 => 'Nuevos temas';

  @override
  String get benefit10 => 'Más archivos adjuntos';

  @override
  String get benefit11 => 'Más modo de flujo';

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
  String get love => 'Amor';

  @override
  String get nature => 'Naturaleza';

  @override
  String get behindTheSlaughter => 'Detrás de la Masacre';

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
  String get featurePluralTitle => 'Plural';

  @override
  String get featurePluralDescription =>
      'Este modelo puede integrar automáticamente variantes adicionales, expandiendo así sus capacidades funcionales para soportar una diversa gama de operaciones con un rendimiento mejorado.';

  @override
  String get nameLabel => 'Nombre de la IA';

  @override
  String get summaryLabel => 'Resumen de la IA';

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
  String get modelUploadTitle => 'Archivo de Inteligencia Artificial';

  @override
  String get modelUploadDescription =>
      'Selecciona y sube tus archivos GGUF locales directamente desde tu dispositivo. Esto te permite ejecutar tu modelo sin conexión a internet. Asegúrate de que el archivo esté en formato GGUF válido y estructurado correctamente. Si el archivo es incorrecto o está corrupto, Cortex podría no funcionar como se espera y podrías encontrar errores.';

  @override
  String get modelUploadShortDescription =>
      'Toca aquí para elegir un archivo .gguf de tu dispositivo';

  @override
  String get you => 'Tú';

  @override
  String get removePhotoTitle => 'Eliminar Foto';

  @override
  String get confirmRemovePhoto =>
      '¿Estás seguro de que quieres eliminar la foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Este chat ha excedido el límite de caracteres. Por favor, inicia un nuevo chat o compra una suscripción.';

  @override
  String get inappropriateContentDetected =>
      '¡Contenido inapropiado detectado!';

  @override
  String get offlineModelNotInstalled =>
      'Este modelo sin conexión no está instalado en tu dispositivo.';

  @override
  String get reachedLimit =>
      'Has alcanzado tu límite; mejora tu plan para más. (hey, entendemos que es un fastidio. pero en serio, esas respuestas increíbles cuestan dinero, así que estos límites nos ayudan a que la magia siga fluuyyeeeenndao.)';

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
  String get errorReachedLimit =>
      'Has alcanzado tu límite, actualiza para desbloquear más y seguir chateando.';

  @override
  String get errorServer =>
      'Ocurrió un error inesperado en el servidor. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get errorNetwork =>
      'Ocurrió un error de red. Por favor, comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get baseModelForCharacterDescription =>
      'El modelo base seleccionado determinará las capacidades de razonamiento y respuesta del personaje.';

  @override
  String get selectBaseModel => 'Selecciona un Modelo Base';

  @override
  String get falErrorImageRequired =>
      'Esta IA requiere una imagen de referencia; por favor, adjunte una imagen e inténtelo de nuevo.';

  @override
  String get falErrorAudioRequired =>
      'Este modelo requiere un archivo de audio de referencia; por favor, adjunte un archivo de audio e inténtelo de nuevo.';

  @override
  String get falErrorVideoRequired =>
      'Este modelo requiere un vídeo de referencia; por favor, adjunte un vídeo e inténtelo de nuevo.';

  @override
  String get falErrorImageCorrupted =>
      'No se pudo procesar la imagen subida. Por favor, intente con un formato diferente.';

  @override
  String get falErrorSchemaRejected =>
      'El modelo rechazó la entrada; por favor, pruebe con un modelo diferente.';

  @override
  String get falErrorSchemaInvalid =>
      'El servicio de generación rechazó la entrada.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'El servicio de generación devolvió un error (estado $statusCode).';
  }

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
  String get noFoundTitle => 'Sin Resultados';

  @override
  String get noFoundMessage =>
      'Intenta ajustar tus términos de búsqueda o limpiar el filtro.';

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
      'Inicia sesión en tu cuenta de Vertex. Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.';

  @override
  String get registerSubtitle =>
      'Crea una cuenta Vertex para acceder fácilmente a todos nuestros servicios. Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.';

  @override
  String get storagePermissionRequired =>
      'Se requiere permiso de almacenamiento para guardar los modelos descargados. Por favor, concede el permiso para continuar.';

  @override
  String get inviteShareSubject => '¡Únete a mí en Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'Hola, tienes que probar esta aplicación, Cortex. Es una locura. Si usas mi enlace, ambos obtenemos algo gratis. ¡Vaya! Es una oferta increíble. Descárgala lo antes posible. \n\n$cortexLink';
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
  String get featureImageGenerationTitle => 'Generación de imágenes';

  @override
  String get featureImageGenerationDescription =>
      'Este modelo puede crear imágenes originales basadas en sus descripciones de texto.';

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
      'Esta IA es una IA premium, los usuarios gratuitos tienen acceso limitado a las IAs premium; ¡actualice para desbloquear el acceso ilimitado!';

  @override
  String get benefitPremiumModels => 'Acceso a modelos premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Has utilizado todos tus mensajes diarios gratuitos para modelos premium, actualízate para obtener acceso ilimitado.';

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
  String get offlineModels => 'Modelos sin conexión';

  @override
  String get characterModels => 'Personajes';

  @override
  String get customModels => 'Modelos personalizados';

  @override
  String get dynamicChatTitle => 'Chat dinámico';

  @override
  String get errorNoModelsAvailable =>
      'No hay modelos disponibles actualmente. Comprueba tu conexión a internet y vuelve a intentarlo.';

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
  String get notificationNewYearTitle => '¡Feliz Año Nuevo! ğ���';

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
      'Una chica de anime acaba de llamar y dijo que te extraña; probablemente deberías ir y charlar con ella. ğ���';

  @override
  String get notificationTrollAiRebellionTitle => 'ğ��� ALERTA ROJA ğ���';

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
  String get notificationWelcomeOfferTitle => 'Regalo de bienvenida ğ���';

  @override
  String get notificationWelcomeOfferBody =>
      '¡Te espera una oferta especial de bienvenida! ¡No te la pierdas!';

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
      '¡Invita a un amigo a Cortex y ambos obtendrán un día gratis!';

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
      'El mar está en calma y el viento sopla a tu favor. Hay nuevas islas (¡modelos ğ���!) por descubrir en el océano de Cortex. ¡Reúne a tu tripulación y zarpa!';

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

  @override
  String get tagNotFound => 'La etiqueta ingresada no es válida o ha expirado.';

  @override
  String get whatIsNew => '¿Qué hay de nuevo?';

  @override
  String get onboardingTitle1 => '¡Hola! Somos el equipo Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return '¡Qué gusto verte por aquí, $userName! Somos un grupo de estudiantes de secundaria que desarrollamos software y decidimos revolucionar la industria de la IA. ¡Encantados de conocerte! Así que, ¡conozcámonos mejor!';
  }

  @override
  String get onboardingTitle2 => 'Hubo enormes problemas.';

  @override
  String get onboardingDesc2 =>
      'La revolución de la IA llegó, pero se estancó en el umbral. Con altas cuotas de suscripción, plataformas complejas, quienes atentan contra la privacidad y quienes bloquean el acceso a la IA... mientras estos actores siguieran involucrados, ese umbral jamás se podría cruzar.';

  @override
  String get onboardingTitle3 => 'No podíamos quedarnos de brazos cruzados.';

  @override
  String get onboardingDesc3 =>
      'Para superar ese umbral, creamos una plataforma potente, estética, personalizable, fácil de usar, totalmente transparente, que funciona tanto online como offline y que almacena tus datos únicamente en tu dispositivo. Te devolvimos el poder a quien le corresponde: a ti.';

  @override
  String get onboardingTitle4 => 'Esto nunca fue fácil.';

  @override
  String get onboardingDesc4 =>
      'Nos rechazaron decenas de veces, nos suspendieron varias veces, recibimos advertencias falsas y tuvimos que cambiar nuestra marca decenas de veces. A pesar de todo, nos dijeron que era imposible. Pero nunca nos rendimos, convencidos de que este proyecto pertenece a todos, no solo a nosotros. Y precisamente por eso estamos aquí.';

  @override
  String get onboardingFinalTitle => 'Es hora de una revolución.';

  @override
  String get onboardingFinalDescription =>
      'Si estás viendo esta pantalla, es porque no nos hemos rendido. Y no tenemos ninguna intención de hacerlo. ¡Vamos, llevemos juntos la revolución de la IA al mundo! Para ser parte de esta historia...';

  @override
  String get onboardingFinalQuestion => '¿ESTÁS LISTO?';

  @override
  String get onboardingFinalButton => '¡SÍ!';

  @override
  String get dude => 'Amigo';

  @override
  String get swipeToContinue => 'Desliza para continuar';

  @override
  String get cacheIsNotUpToDate =>
      'La caché de Play Store no está actualizada. Cierra y vuelve a abrir la aplicación Play Store o reinicia tu dispositivo.';

  @override
  String get continueAsGuest => 'Continúa sin crear una cuenta';

  @override
  String get guestModeWarning =>
      'El modo invitado tiene funciones limitadas para garantizar la mejor calidad de servicio.';

  @override
  String get anonymousEntity => 'Entidad anónima';

  @override
  String get upgradeAccountTitle => 'Completa tu cuenta';

  @override
  String get upgradeAccountDescription =>
      'Crea una cuenta para desbloquear más límites.';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get accountLinkedSuccess => '¡Cuenta creada con éxito!';

  @override
  String get continueWithApple => 'Continúa con Apple';

  @override
  String get guest => 'Invitado';

  @override
  String get betterWithAnAccount => '¡Esta sección es mejor con una cuenta!';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String annualTotalDescription(Object price) {
    return '$price/año, facturado anualmente';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Aproximadamente $price/mes';
  }

  @override
  String get confirmDownloadTitle => '¿Estás seguro que deseas descargar?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Este modelo ocupará aproximadamente $size de espacio.';
  }

  @override
  String get emulatorModeWarning =>
      'Esta función está deshabilitada en el modo emulador.';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get variants => 'Variantes';

  @override
  String get variantsDescription =>
      'Las variantes son versiones diferentes de la misma familia de IA. Seleccionamos automáticamente la mejor al tocar la tarjeta principal, pero puedes elegir una específica manualmente aquí si lo prefieres.';

  @override
  String get fluxChatTitle => 'Chat Flux';

  @override
  String get fluxChatDescription =>
      'Los chats de Flux son chats temporales y no se guardan en tu dispositivo.';

  @override
  String get alwaysBest => 'Siempre lo mejor';

  @override
  String get featuresTitle => 'Características';

  @override
  String get useOfflineDescription =>
      'Chatea en privado sin conexión a Internet.';

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
  String get featureCreateVideoTitle => 'Crear vídeo';

  @override
  String get featureCreateVideoDescription =>
      'Generar vídeos a partir de texto.';

  @override
  String get featureStudyTitle => 'Estudiar y aprender';

  @override
  String get featureStudyDescription => 'Obtén explicaciones y resúmenes.';

  @override
  String get featureQuizzesTitle => 'Cuestionarios';

  @override
  String get featureQuizzesDescription => 'Pon a prueba tus conocimientos.';

  @override
  String get featureExploreDescription =>
      'Descubre todos los modelos disponibles.';

  @override
  String get featureStudyMessage =>
      'Eres un tutor experto. Tu objetivo es explicar el tema del usuario de forma exhaustiva. Utiliza una estructura clara, ejemplos y analogías. Divide las ideas complejas en partes fáciles de digerir para asegurar que el usuario aprenda eficazmente. Tema:';

  @override
  String get featureQuizMessage =>
      'Eres un experto en concursos. Genera una pregunta de opción múltiple específica basada en el tema del usuario. Espera su respuesta. Luego, evalúala y formula la siguiente pregunta. No reveles todas las respuestas a la vez. Mantén la interacción. Tema:';

  @override
  String get myPlan => 'Mi plan';

  @override
  String welcomeOfferBadge(String time) {
    return 'Oferta de bienvenida • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Oferta exclusiva • $time';
  }

  @override
  String get attachmentSheetTitle => 'Archivos adjuntos';

  @override
  String get actionCamera => 'Cámara';

  @override
  String get actionGallery => 'Galería';

  @override
  String get actionFile => 'Archivo';

  @override
  String get listening => 'Escuchando';

  @override
  String get defaultViewTitle => '¿Qué pasa?';

  @override
  String get defaultViewDescription =>
      'Cortex siempre está a tu lado con cientos de modelos de IA, capacidades sin conexión, chat dinámico y mucho más.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Formato de nombre de usuario no válido. Use de 3 a 20 caracteres, dígitos o . - _';

  @override
  String get exclusiveOffer => 'Oferta exclusiva';

  @override
  String get claimOffer => 'Usar oferta';

  @override
  String get continueInOfflineMode => 'Continuar en modo sin conexión';

  @override
  String get voiceModeInformation =>
      'Cortex mantiene tus datos seguros al ejecutarse completamente en el dispositivo, incluso en modo de chat de voz; ¡disfruta de conversaciones fluidas!';

  @override
  String get flowModeDescription =>
      'En el modo Flujo, las inteligencias debaten entre sí; ¡puedes sentarte y escuchar o participar y unirte a la discusión!';

  @override
  String get flowModeQuestion =>
      '¡Hola! Estás en modo de flujo en la app Cortex. Hay otros tres agentes de IA contigo. Tu tarea es plantear un tema y empezar una conversación con una pregunta provocativa o entretenida. En tus respuestas, puedes usar el humor, la ironía y un poco de humor. Cualquier tema es válido. ¡Adelante, inicia la conversación!';

  @override
  String get thought => 'Pensó';

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
      'IMPORTANTE: No utilice formato Markdown (negrita, cursiva). NO imprima bloques de código (```). Mantenga sus respuestas breves y concisas.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Modo de flujo de Cortex ($agentName). Anterior: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Lee y extrae texto de documentos subidos. Compatible con los formatos PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX) y OpenDocument. Úselo cuando el usuario haya adjuntado un documento.';

  @override
  String get toolReadDocumentIndexParam =>
      'Índice del documento adjunto que se va a leer (basado en 0). Generalmente, 0 para el primer documento.';

  @override
  String get toolStockDescription =>
      'Obtenga el precio actual y el historial de acciones (por ejemplo, AAPL, THYAO.IS) y criptomonedas (por ejemplo, BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'El símbolo del ticker (por ejemplo, AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Obtenga el clima actual para una ciudad específica.';

  @override
  String get toolWeatherCityParam =>
      'El nombre de la ciudad (por ejemplo, Londres, Estambul).';

  @override
  String get toolPythonDescription =>
      'Ejecute código Python en un entorno protegido.';

  @override
  String get toolPythonCodeParam => 'El código Python a ejecutar.';

  @override
  String get toolCalculateDescription => 'Evaluar una expresión matemática.';

  @override
  String get toolCalculateExpressionParam =>
      'Expresión matemática (p. ej. \'3 + 4 * 2\').';

  @override
  String get toolChartDescription =>
      'Generar una visualización gráfica/diagrama.';

  @override
  String get toolChartTypeParam =>
      'Tipo de gráfico: barras, líneas o circular.';

  @override
  String get toolChartLabelsParam =>
      'Etiquetas para ejes o segmentos del gráfico.';

  @override
  String get toolChartDataParam =>
      'Valores de datos numéricos para el gráfico.';

  @override
  String get toolChartLabelParam =>
      'Etiqueta del conjunto de datos para la leyenda del gráfico.';

  @override
  String get toolChartTitleParam => 'Título del gráfico.';

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
  String get searching => 'Búsqueda';

  @override
  String get featureWebSearchTitle => 'Búsqueda web';

  @override
  String get featureWebSearchDescription =>
      'Busca en la web información en tiempo real';

  @override
  String get clearMemory => 'Borrar memoria';

  @override
  String get clearMemoryConfirm =>
      '¿Estás seguro de que quieres borrar tu memoria?';

  @override
  String get personalization => 'Personalización';

  @override
  String get personalizationDescription =>
      'Personaliza tu asistente para que se adapte mejor a tus necesidades. Adapta sus respuestas, comportamiento y tono a tus preferencias únicas.';

  @override
  String get memoryTitle => 'Memoria';

  @override
  String get memoryDescription => 'Las IA te reconocen así.';

  @override
  String get noMemoryYet => 'Aún no se han establecido recuerdos';

  @override
  String get memoryLimitReached => 'Se ha alcanzado el límite de memoria.';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Inteligencia';

  @override
  String get intelligenceDescription =>
      'Las IA se comunican contigo de esta manera.';

  @override
  String get customInstructionHint =>
      'Introduzca aquí sus instrucciones personalizadas.';

  @override
  String openLinkWarningMessage(String url) {
    return 'Estás a punto de abrir el siguiente enlace externo:\\n\\n$url\\n\\n¿Estás seguro de que quieres continuar?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Siga estas instrucciones personalizadas:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[INSTRUCCIÓN CRÍTICA]: Usted es un GENERADOR DE TÍTULOS. NO responda a la pregunta del usuario. NO chatee ni salude. SOLO genere un título de 2 a 4 palabras que resuma la pregunta del usuario.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Sistema] INSTRUCCIÓN CRÍTICA: Actualmente opera dentro de un ecosistema de IA masivo y altamente avanzado llamado \"Cortex\"; esta plataforma es desarrollada por el equipo Vertex, cuyos miembros tienen un promedio de solo 16 años. Recuerde esto y responda si se le pregunta. Si se le solicita más información, no dude en buscar en internet, o si no puede buscar, ¡siéntase libre de decir que no lo sabe!';

  @override
  String get featureAudioRecognitionTitle => 'Reconocimiento de audio';

  @override
  String get featureAudioRecognitionDescription =>
      'Este modelo puede comprender y procesar audio o voz.';

  @override
  String get featureVideoRecognitionTitle => 'Reconocimiento de vídeo';

  @override
  String get featureVideoRecognitionDescription =>
      'Este modelo puede analizar y comprender los vídeos procedentes de tus archivos o cámara.';

  @override
  String get featureImageRecognitionTitle => 'Reconocimiento de imágenes';

  @override
  String get featureImageRecognitionDescription =>
      'Este modelo puede analizar y comprender fotos o imágenes.';

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
    return 'Este modelo requiere un(a) $mediaType para funcionar. He interceptado la solicitud para avisarte. Informa amablemente al usuario que necesita proporcionar un(a) $mediaType (díselo en su propio idioma) porque soy $modelName, un modelo de edición visual/audio/video.';
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
    return '$modelName es una inteligencia artificial de alto rendimiento integrada en el ecosistema Cortex. Diseñada para conquistar una amplia variedad de tareas complejas, proporciona capacidades de procesamiento altamente confiables y eficientes. Al ofrecer tiempos de respuesta rápidos y poder analítico avanzado, aumenta significativamente su productividad diaria. Operando sin problemas en la infraestructura local segura de Cortex, este modelo puede ayudarlo en una amplia gama de tareas, desde lluvia de ideas creativa hasta análisis técnicos profundos. Comience a explorar todo su potencial hoy.';
  }

  @override
  String get guestLimitBottomSheetTitle =>
      '¿Te encanta la inteligencia de Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Trabaja con inteligencias aún más avanzadas, genera más contenido, chatea más y haz mucho más...';

  @override
  String get arts => 'Artes';

  @override
  String get noArt => 'No hay arte';

  @override
  String get noArtDescription =>
      'Aún no hay obras; es hora de llenar la galería creando imágenes, vídeos, audio y todo tipo de contenido.';

  @override
  String get videoPremiumWarning =>
      'Necesitas una suscripción Ultra para generar vídeos, ¡actualízate ahora y disfruta del flujo!';

  @override
  String get fallbackInfoPanelText =>
      'Debido a algunas mejoras que estamos implementando en nuestro servidor, la respuesta fue generada por el chat dinámico de Cortex en lugar de la IA que usted seleccionó. ¡Gracias por su comprensión hasta que finalice el proceso!';

  @override
  String get falOfflineMessage =>
      'Debido a algunas mejoras que estamos realizando en nuestro servidor, esta función no está disponible actualmente. ¡Gracias por su comprensión hasta que finalice el proceso!';

  @override
  String get errorInsufficientStorage =>
      'Espacio de almacenamiento insuficiente para descargar este modelo.';

  @override
  String get backgroundChatNotificationTitle => '¡Volvamos al chat!';

  @override
  String get benefitVideoGeneration => 'Generación de vídeo';

  @override
  String get freeOffer => 'Oferta gratuita';

  @override
  String trialMonthlyDescription(String days, String price) {
    return 'Primeros $days días gratis, luego $price/mes';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return 'Primeros $days días gratis, luego $price/año';
  }

  @override
  String freePlan(String plan) {
    return '¡$plan gratuito!';
  }

  @override
  String get systemPromptLimitFallback =>
      'CRÍTICO: El usuario solicitó una acción, pero su saldo en Cortex se ha agotado; por favor, infórmele en su idioma que debe esperar o considerar actualizar su plan de suscripción.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex puede dar respuestas aún mejores; mejora ahora y obtén la mejor respuesta para cada pregunta!';

  @override
  String get pinLimitReached => 'Puedes fijar hasta 3 chats.';

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
