// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get understood => 'Mengerti.';

  @override
  String get cancel => 'Batal';

  @override
  String get remove => 'Hapus';

  @override
  String get download => 'Unduh';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get copy => 'Salin';

  @override
  String get chat => 'Chat';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get light => 'Terang';

  @override
  String get theme => 'Tema';

  @override
  String get no => 'Tidak';

  @override
  String get yes => 'Ya';

  @override
  String get done => 'Selesai';

  @override
  String get comingSoon => 'SEGERA HADIR';

  @override
  String get bestValue => 'Penawaran Terbaik';

  @override
  String get selected => 'Terpilih';

  @override
  String get descriptionSection => 'Deskripsi';

  @override
  String get searchHint => 'Cari';

  @override
  String get messageHint => 'Tanyakan apa saja';

  @override
  String get modelLoading => 'Model sedang dimuat...';

  @override
  String get messageCopied => 'Pesan disalin ke papan klip.';

  @override
  String get storeUnavailable =>
      'Toko saat ini tidak tersedia. Silakan coba lagi nanti';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get systemInfo => 'Informasi Sistem';

  @override
  String deviceMemory(Object memory) {
    return 'Memori Perangkat: $memory GB';
  }

  @override
  String storageSpace(Object storage) {
    return 'Ruang Penyimpanan: $storage GB';
  }

  @override
  String freeStorageSpace(Object freeStorage) {
    return 'Ruang Penyimpanan Tersisa: $freeStorage GB';
  }

  @override
  String get memory => 'Memori';

  @override
  String get storage => 'Penyimpanan';

  @override
  String get freeStorage => 'Penyimpanan Tersisa';

  @override
  String get totalStorage => 'Total Penyimpanan';

  @override
  String get usedStorage => 'Penyimpanan Terpakai';

  @override
  String get totalMemory => 'Total Memori';

  @override
  String get usedMemory => 'Memori Terpakai';

  @override
  String get requirements => 'Persyaratan';

  @override
  String get modelsTitle => 'Perpustakaan';

  @override
  String get localModels => 'Model Lokal';

  @override
  String get serverSideModels => 'Model Online';

  @override
  String get uploadYourOwnModel => 'Unggah Model Anda Sendiri!';

  @override
  String get selectGGUFFile => 'Pilih File GGUF';

  @override
  String get errorGGUF => 'Harap pilih file dalam format GGUF saja.';

  @override
  String get modelAlreadyExists => 'Model sudah ada.';

  @override
  String get modelAddedSuccessfully => 'Model berhasil ditambahkan.';

  @override
  String get modelRemoved => 'Model berhasil dihapus.';

  @override
  String get removeError => 'Terjadi kesalahan saat menghapus model.';

  @override
  String get fileNotFound => 'File tidak ditemukan.';

  @override
  String get fileUploadError => 'Terjadi kesalahan saat mengunggah file.';

  @override
  String get noFileSelected => 'Tidak ada file yang dipilih.';

  @override
  String get myModels => 'Model Saya';

  @override
  String get create => 'Buat';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String modelProducer(Object producer) {
    return 'Produsen: $producer';
  }

  @override
  String modelRAM(Object ram) {
    return 'RAM: $ram';
  }

  @override
  String modelSize(Object size) {
    return 'Ukuran: $size';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get conversationsTitle => 'Percakapan';

  @override
  String get conversationDeleted => 'Percakapan dihapus.';

  @override
  String get conversationUpdated => 'Percakapan diperbarui.';

  @override
  String get editConversationTitle => 'Ganti Nama';

  @override
  String get newTitle => 'Judul Baru';

  @override
  String get save => 'Simpan';

  @override
  String get titleCannotBeEmpty => 'Judul tidak boleh kosong.';

  @override
  String get noConversationsMessage =>
      'Tidak ada percakapan, mulailah mengobrol!';

  @override
  String get startChat => 'Mulai obrolan';

  @override
  String get noChats => 'Tidak Ada Obrolan';

  @override
  String get starredChats => 'Obrolan Berbintang';

  @override
  String get allChats => 'Semua Obrolan';

  @override
  String get noStarredChats => 'Tidak Ada Obrolan Berbintang';

  @override
  String get noStarredChatsMessage =>
      'Anda belum menandai obrolan dengan bintang.';

  @override
  String get goToChats => 'Beri bintang pada obrolan';

  @override
  String get starConversation => 'Bintangi';

  @override
  String get conversationTitleUpdated => 'Judul percakapan diperbarui';

  @override
  String get youReachedConversationLimit =>
      'Anda telah mencapai batas percakapan.';

  @override
  String get today => 'Hari Ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get loginToYourAccount => 'Masuk';

  @override
  String get createYourAccount => 'Daftar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get invalidEmail => 'Harap masukkan alamat email yang valid.';

  @override
  String get invalidPassword =>
      'Kata sandi harus terdiri dari minimal 6 karakter.';

  @override
  String get rememberMe => 'Ingat saya';

  @override
  String get forgotPassword => 'Lupa Kata Sandi?';

  @override
  String get or => 'Atau';

  @override
  String get continueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get dontHaveAccount => 'Belum punya akun?';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get signUp => 'Daftar';

  @override
  String get logIn => 'Masuk';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok.';

  @override
  String get userNotFound => 'Pengguna tidak ditemukan.';

  @override
  String get wrongPassword => 'Kata sandi salah.';

  @override
  String get emailAlreadyInUse => 'Email ini sudah digunakan.';

  @override
  String get weakPassword => 'Kata sandi terlalu lemah.';

  @override
  String get authError => 'Kesalahan Otentikasi';

  @override
  String get invalidUsername => 'Harap masukkan nama pengguna.';

  @override
  String get usernameTaken => 'Nama pengguna ini sudah diambil.';

  @override
  String get username => 'Nama Pengguna';

  @override
  String get authenticationFailed => 'Otentikasi gagal. Silakan coba lagi.';

  @override
  String get emailTooLong => 'Email maksimal 30 karakter.';

  @override
  String get deviceLimitReached =>
      'Anda telah mencapai batas pembuatan akun untuk perangkat ini.';

  @override
  String get verificationEmailLimitReached => 'Kami tidak akan mengirim lagi';

  @override
  String get verificationEmailSent => 'Email verifikasi terkirim!';

  @override
  String get emailNotVerified => 'Email belum diverifikasi';

  @override
  String get resendCode => 'Kirim ulang email verifikasi';

  @override
  String get remainingSeconds => 'Sisa waktu untuk verifikasi';

  @override
  String get pleaseCheckYourEmail =>
      'Untuk menggunakan Cortex, Anda perlu memverifikasi email Anda. \n Tautan verifikasi telah dikirim ke alamat email Anda, silakan periksa email Anda.';

  @override
  String get verifyYourEmail => 'Verifikasi Email Anda';

  @override
  String get backToLogin => 'Kembali';

  @override
  String get seconds => 'detik';

  @override
  String get maxResendLimitReached =>
      'Anda telah mencapai jumlah maksimum pengiriman email verifikasi';

  @override
  String get verificationScreenContinueWithoutVerification =>
      'Lanjutkan tanpa verifikasi';

  @override
  String get verificationScreenWarning =>
      'Meskipun Anda melanjutkan, periode verifikasi akun 1 hari masih berlaku untuk akun Anda. Jika Anda belum memverifikasi akun Anda saat itu, akun akan dihapus dari aplikasi.';

  @override
  String get unverifiedAccountHeader => 'Akun Anda belum diverifikasi';

  @override
  String unverifiedAccountWarning(Object timeLeft) {
    return 'Jika Anda tidak memverifikasi akun Anda dalam $timeLeft, akun akan dihapus';
  }

  @override
  String get verifyNow => 'Verifikasi Sekarang';

  @override
  String get accountVerified => 'Akun Anda telah diverifikasi.';

  @override
  String get linkSent => 'Tautan terkirim';

  @override
  String get accountDeletionRequested =>
      'Permintaan penghapusan akun Anda telah diterima dan akun Anda sekarang dinonaktifkan.';

  @override
  String get tooManyRequests => 'Terlalu banyak permintaan';

  @override
  String get regenerate => 'Buat Ulang';

  @override
  String get confirmDeleteAccount =>
      'Apakah Anda yakin ingin menghapus akun Anda?';

  @override
  String get enterPasswordToDelete =>
      'Masukkan kata sandi Anda untuk menghapus.';

  @override
  String get deleteAccount => 'Hapus Akun';

  @override
  String get deleteAccountError => 'Terjadi kesalahan saat menghapus akun.';

  @override
  String get delete => 'Hapus';

  @override
  String get passwordRequired => 'Kata sandi diperlukan.';

  @override
  String get deleteDescription =>
      'Data yang Anda hapus akan dihapus secara permanen dari server dan perangkat Anda. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get deleteAccountButton => 'Tombol Hapus Akun';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get displayName => 'Nama Tampilan';

  @override
  String get tapToChangeProfilePicture => 'Ketuk untuk mengubah gambar profil';

  @override
  String get profileUpdated => 'Profil berhasil diperbarui';

  @override
  String get updateFailed => 'Gagal memperbarui profil';

  @override
  String get nameCannotBeEmpty => 'Nama tidak boleh kosong';

  @override
  String get logout => 'Keluar';

  @override
  String get noDisplayName => 'Nama tampilan belum diatur';

  @override
  String get noEmail => 'Tidak ada alamat email';

  @override
  String get noUserLoggedIn => 'Tidak ada pengguna yang sedang masuk';

  @override
  String get profile => 'Profil';

  @override
  String get manageProfileDescription =>
      'Kelola profil Anda, perbarui kata sandi, atau keluar dari Cortex.';

  @override
  String get accessSettingsDescription =>
      'Akses bantuan, tukarkan kode, bagikan Cortex, dan lihat kebijakan kami.';

  @override
  String get languageDescription =>
      'Anda dapat mengubah bahasa antarmuka aplikasi default kapan saja.';

  @override
  String get themeDescription =>
      'Anda dapat beralih antara tema terang dan gelap sesuai preferensi. Tema yang dipilih akan berlaku di seluruh antarmuka Cortex.';

  @override
  String get iHaveReadAndAgree =>
      'Saya telah membaca dan menyetujui persyaratan layanan';

  @override
  String get downloading => 'Mengunduh...';

  @override
  String get downloadError => 'Terjadi kesalahan saat mengunduh.';

  @override
  String get downloadCancelled => 'Pengunduhan dibatalkan.';

  @override
  String get downloadResumed => 'Pengunduhan dilanjutkan.';

  @override
  String get downloadSuccess => 'Pengunduhan berhasil';

  @override
  String get downloadFailed => 'Pengunduhan gagal';

  @override
  String downloaded(Object percent) {
    return '$percent% terunduh';
  }

  @override
  String get downloadPaused => 'Pengunduhan dijeda.';

  @override
  String get purchaseSuccessful => 'Pembelian berhasil!';

  @override
  String get purchaseFailed => 'Pembelian tidak berhasil';

  @override
  String get creditProductNotFound =>
      'Produk kredit yang dipilih tidak dapat ditemukan.';

  @override
  String get creditsAddedSuccessfully =>
      'Kredit berhasil ditambahkan ke akun Anda!';

  @override
  String get creditDeliveryFailed =>
      'Gagal menambahkan kredit ke akun Anda. Silakan hubungi dukungan.';

  @override
  String get invalidPurchase => 'Pembelian tidak valid';

  @override
  String get purchaseError => 'Kesalahan pembelian';

  @override
  String get purchaseVertexPlusToUpload => 'Ini adalah fitur Plus';

  @override
  String get purchasePlus => 'Beli Cortex Plus';

  @override
  String get plusDescription =>
      'Akses lebih banyak fitur Cortex dan rasakan pengalaman AI yang lebih kaya!';

  @override
  String get annual => 'Tahunan';

  @override
  String get monthly => 'Bulanan';

  @override
  String get manageSubscription => 'Kelola Langganan';

  @override
  String purchasePlan(String planName) {
    return 'Beli $planName';
  }

  @override
  String discountOffer(int percent) {
    return 'DISKON $percent%';
  }

  @override
  String annualPlanDescription(String price) {
    return '$price/bln, ditagih tahunan';
  }

  @override
  String monthlyPlanDescription(String price) {
    return '$price/bln, ditagih bulanan';
  }

  @override
  String get discountBannerTitle => 'SPESIAL PELUNCURAN: DISKON 80%!';

  @override
  String get discountBannerSubtitle =>
      'Diskon eksklusif untuk SEMUA paket langganan untuk merayakan peluncuran kami. Jangan sampai ketinggalan!';

  @override
  String get purchasePro => 'Beli Cortex Pro';

  @override
  String get proDescription =>
      'Akses lebih banyak fitur Cortex dan rasakan pengalaman AI yang lebih kaya!';

  @override
  String get alreadySubscribed => 'Anda sudah berlangganan';

  @override
  String get subscriptionInfo => 'Langganan Anda aktif.';

  @override
  String get alreadySubscribedMessage =>
      'Anda sudah memiliki langganan Plus. Jika Anda ingin membatalkan langganan, Anda dapat melakukannya melalui pengelola Play Store.';

  @override
  String get cancelSubscription => 'Batalkan Langganan';

  @override
  String get cancelSubscriptionInfo =>
      'Jika Anda ingin membatalkan langganan, silakan lanjutkan melalui pengelola langganan Play Store.';

  @override
  String get goToPlayStore => 'Buka Play Store';

  @override
  String get alreadySubscribedPlus => 'Anda Memiliki Paket Plus!';

  @override
  String get alreadySubscribedPlusMessage =>
      'Paket Plus Anda aktif. Anda dapat menikmati semua manfaatnya.';

  @override
  String get purchaseUltra => 'Beli Cortex Ultra';

  @override
  String get ultraDescription =>
      'Dapatkan akses penuh ke semua fitur Cortex dan rasakan pengalaman AI secara maksimal!';

  @override
  String get noSubscription => 'Tidak Ada Langganan';

  @override
  String get noSubscriptionMessage => 'Anda belum memiliki langganan.';

  @override
  String get alreadyAtHighestPlan => 'Anda sudah berada di paket tertinggi.';

  @override
  String get unableToOpenSubscription =>
      'Tidak dapat membuka halaman manajemen langganan.';

  @override
  String get upgradeSubscription => 'Tingkatkan Langganan';

  @override
  String get confirmUpgrade =>
      'Apakah Anda yakin ingin meningkatkan langganan Anda?';

  @override
  String get unsupportedPlatform =>
      'Platform tidak didukung untuk pembatalan langganan.';

  @override
  String get purchaseStreamError => 'Kesalahan aliran pembelian.';

  @override
  String get productNotFound => 'Produk tidak ditemukan';

  @override
  String get productDetailsError =>
      'Terjadi kesalahan saat mengambil detail produk.';

  @override
  String get noProductsFound => 'Tidak ada produk yang ditemukan';

  @override
  String get loadCreditsButton => 'Isi Kredit';

  @override
  String get creditsTitle => 'Kredit';

  @override
  String get creditsScreenDescription =>
      'Layar ini menampilkan kredit pengguna. \n\nKredit pengguna saat ini: 100\n\nInformasi kredit terperinci dapat ditampilkan di sini.';

  @override
  String get creditsLoaded => 'Kredit dimuat!';

  @override
  String get currentCredits => 'Kredit Saat Ini';

  @override
  String get pleaseSelectCreditPackage => 'Silakan pilih paket kredit';

  @override
  String get purchaseCreditsTitle => 'Beli Kredit';

  @override
  String get purchaseCreditsDescription =>
      'Pilih paket kredit yang sesuai dengan kebutuhan Anda dan gunakan aplikasi kami lebih banyak.';

  @override
  String get purchaseButton => 'Beli';

  @override
  String get productNotFoundMessage => 'Produk yang dipilih tidak ada.';

  @override
  String get buyCredits => 'Beli Kredit';

  @override
  String get selectCreditPackageDescription =>
      'Pilih paket kredit yang sesuai dengan kebutuhan Anda dan nikmati lebih banyak fitur.';

  @override
  String get buyCredit => 'Beli Kredit';

  @override
  String buyCreditPackage(Object amount) {
    return 'Beli $amount Kredit';
  }

  @override
  String get subscribedPlan => 'Berlangganan';

  @override
  String get errorResponseNotReceived => 'Respons tidak diterima';

  @override
  String googleApiRequestFailed(int attempt, String error) {
    return 'Permintaan Google API gagal $attempt kali: $error';
  }

  @override
  String openRouterResponseStatus(int statusCode) {
    return 'Status Respons OpenRouter: $statusCode';
  }

  @override
  String openRouterDecodedResponseBody(String body) {
    return 'Isi Respons OpenRouter yang Didekode: $body';
  }

  @override
  String decodedJson(String data) {
    return 'JSON yang Didekode: $data';
  }

  @override
  String get responseStructureUnexpectedMessageContentMissing =>
      'Struktur respons tidak terduga: pesan atau konten hilang';

  @override
  String get responseStructureUnexpectedChoicesMissing =>
      'Struktur respons tidak terduga: pilihan hilang atau kosong';

  @override
  String openRouterApiRequestFailed(int statusCode, String body) {
    return 'Permintaan OpenRouter API gagal: $statusCode - $body';
  }

  @override
  String openRouterApiRequestFailedAfterAttempts(int attempt, String error) {
    return 'Permintaan OpenRouter API gagal $attempt kali: $error';
  }

  @override
  String get internetRequired =>
      'Koneksi internet diperlukan untuk menggunakan model ini';

  @override
  String get pleaseWaitBeforeTryingAgain =>
      'Harap tunggu sejenak sebelum mencoba lagi';

  @override
  String openRouterQuotaExceeded(int statusCode, String decodedBody) {
    return 'Kuota terlampaui. Kode status: $statusCode, Isi: $decodedBody';
  }

  @override
  String openRouterApiRequestFailedAfterPaidAttempts(
      int attempts, String error) {
    return 'Permintaan API gagal setelah $attempts percobaan berbayar. Kesalahan: $error';
  }

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Dengan menempatkan pesanan ini, Anda menyetujui Persyaratan Layanan dan Kebijakan Privasi. Anda dapat mengklik teks ini untuk mempelajari lebih lanjut tentang Persyaratan Layanan dan Kebijakan Privasi kami. Langganan akan diperpanjang secara otomatis kecuali perpanjangan otomatis dimatikan setidaknya 24 jam sebelum akhir periode berjalan.';

  @override
  String get termsOfService => 'Persyaratan Layanan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get report => 'Laporkan';

  @override
  String get reportDialogTitle => 'Kirim Laporan';

  @override
  String get reportDescriptionLabel => 'Apa masalahnya?';

  @override
  String get reportHarmful => 'Ini berbahaya/tidak aman';

  @override
  String get reportNotTrue => 'Ini tidak benar';

  @override
  String get reportNotHelpful => 'Ini tidak membantu';

  @override
  String get closeButton => 'Tutup';

  @override
  String get submitButton => 'Kirim';

  @override
  String get reportErrorMessage => 'Harap pilih satu alasan untuk melaporkan.';

  @override
  String get capabilitiesSection => 'Kemampuan';

  @override
  String get ratingsSection => 'Peringkat';

  @override
  String get noRatingDataFound => 'Tidak ada data peringkat yang ditemukan';

  @override
  String get featurePhotoTitle => 'Pemindaian Foto';

  @override
  String get featurePhotoDescription =>
      'Model ini memiliki kemampuan untuk memindai foto melalui kamera atau file gambar.';

  @override
  String get featureOfflineTitle => 'Operasi Offline';

  @override
  String get featureOfflineDescription =>
      'Jalankan model tanpa koneksi internet untuk menjaga keamanan data Anda.';

  @override
  String get featureSupermodelTitle => 'Model Super';

  @override
  String get featureSupermodelDescription =>
      'Ini adalah model masif dengan lebih dari 10 miliar parameter, menawarkan kinerja tinggi dan kemampuan yang luas.';

  @override
  String get featureRoleplayTitle => 'Bermain Peran';

  @override
  String get featureRoleplayDescription =>
      'Model bermain peran memungkinkan Anda membuat berbagai obrolan dan skenario.';

  @override
  String get roleModels => 'Model Roleplay';

  @override
  String get parameters => 'Parameter';

  @override
  String get context => 'Konteks';

  @override
  String get millions => 'juta';

  @override
  String get billions => 'miliar';

  @override
  String get trillions => 'triliun';

  @override
  String get thousand => 'ribu';

  @override
  String get estimated => 'diperkirakan';

  @override
  String get finalPreparation => 'Persiapan akhir sedang dilakukan.';

  @override
  String get allEvaluationsByTestTeam =>
      'Semua evaluasi dilakukan oleh tim penguji kami';

  @override
  String get shareApp => 'Bagikan Aplikasi';

  @override
  String get rateUs => 'Beri Kami Nilai';

  @override
  String get share => 'Bagikan';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get shareMessage =>
      'Cek aplikasi Cortex, keren banget! Unduh di sini: https://play.google.com/store/apps/details?id=com.vertex.cortex';

  @override
  String get shareFailed =>
      'Gagal membagikan aplikasi. Silakan coba lagi nanti';

  @override
  String get selectText => 'Pilih Teks';

  @override
  String get showLatex => 'Tampilkan Simbol Khusus';

  @override
  String get hideLatex => 'Sembunyikan Simbol Khusus';

  @override
  String get thinking => 'Berpikir';

  @override
  String get user => 'Pengguna';

  @override
  String get voice => 'Suara';

  @override
  String get help => 'Bantuan';

  @override
  String get redeemCode => 'Tukarkan Kode';

  @override
  String get enterYourCode =>
      'Dukung kreator favorit Anda! Masukkan kode unik mereka di bawah ini untuk memberi mereka bagian dari pembelian Cortex Anda.';

  @override
  String get code => 'Kode';

  @override
  String get redeem => 'Tukarkan';

  @override
  String get codeCannotBeEmpty => 'Kode tidak boleh kosong';

  @override
  String get userId => 'ID Pengguna';

  @override
  String get deleteAllConversationsConfirmTitle => 'Hapus Semua Obrolan?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Apakah Anda yakin ingin menghapus semua obrolan Anda? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get allConversationsDeleted => 'Semua percakapan berhasil dihapus!';

  @override
  String get deleteAll => 'Hapus Semua';

  @override
  String get deleteAllConversationsButton => 'Hapus Semua Percakapan';

  @override
  String get confirmWord => 'Ketik VERTEX';

  @override
  String get confirmWordError => 'Anda salah mengetik';

  @override
  String get chinese => 'Cina';

  @override
  String get arabic => 'Arab';

  @override
  String get french => 'Prancis';

  @override
  String get japanese => 'Jepang';

  @override
  String get kurdish => 'Kurdi';

  @override
  String get dutch => 'Belanda';

  @override
  String get russian => 'Rusia';

  @override
  String get korean => 'Korea';

  @override
  String get deutsch => 'Jerman';

  @override
  String get english => 'Inggris';

  @override
  String get turkish => 'Turki';

  @override
  String get hindi => 'Hindi';

  @override
  String get portuguese => 'Portugis';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get azerbaijani => 'Azerbaijan';

  @override
  String get german => 'Jerman';

  @override
  String get spanish => 'Spanyol';

  @override
  String get italian => 'Italia';

  @override
  String get ram => 'RAM';

  @override
  String get usernameTooShort => 'Nama pengguna terlalu pendek.';

  @override
  String get usernameTooLong =>
      'Nama pengguna tidak boleh lebih dari 16 karakter.';

  @override
  String get invalidUsernameCharacters =>
      'Hanya huruf-huruf ini: \'abcçdefgğhıijklmnoöprsştuüvyzxqw\' dan karakter \'.\', \'-\', \'_\' yang dapat digunakan dalam nama pengguna.';

  @override
  String get passwordTooLong =>
      'Kata sandi tidak boleh lebih dari 64 karakter.';

  @override
  String get noInternetConnection => 'Tidak ada koneksi internet.';

  @override
  String get chats => 'Kotak Masuk';

  @override
  String get library => 'Perpustakaan';

  @override
  String get inappropriateMessageWarning => 'Pesan tidak pantas terdeteksi!';

  @override
  String get myModelDescription => 'Model saya.';

  @override
  String get noModelsDownloaded => 'Anda belum mengunduh model apa pun.';

  @override
  String get appTitle => 'Cortex';

  @override
  String get text => 'Teks';

  @override
  String get removeModel => 'Hapus Model';

  @override
  String get modelUploadedSuccessfully => 'Model berhasil diunggah.';

  @override
  String get insufficientRAM => 'Memori Rendah';

  @override
  String get insufficientStorage => 'Penyimpanan Rendah';

  @override
  String confirmRemoveModel(Object model) {
    return 'Apakah Anda yakin ingin menghapus model $model dari perangkat Anda? Melakukannya juga akan menghapus percakapan sebelumnya dengan model tersebut.';
  }

  @override
  String get noMatchingModels => 'Tidak ada model yang cocok ditemukan.';

  @override
  String creditPackage(Object amount) {
    return 'Beli $amount Kredit';
  }

  @override
  String get benefit1 =>
      'Batas percakapan yang jauh lebih banyak untuk AI online';

  @override
  String get benefit2 => 'Unggah model Anda sendiri';

  @override
  String get benefit3 => 'Efek profil';

  @override
  String get benefit4 => 'Lencana keanggotaan';

  @override
  String get benefit5 => 'Buat lebih banyak kecerdasan buatan online';

  @override
  String get benefit6 => 'Obrolan tak terbatas';

  @override
  String benefit7(Object credits) {
    return '$credits kredit harian';
  }

  @override
  String get benefit8 => 'Tambah model';

  @override
  String get benefit9 => 'Tema baru';

  @override
  String get benefit10 => 'Obrolan suara offline';

  @override
  String get oldBenefits => 'Semua manfaat dari paket yang lebih rendah';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get changePassword => 'Ubah kata sandi';

  @override
  String get logoutConfirmationTitle => 'Apakah Anda yakin ingin keluar?';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa Aplikasi';

  @override
  String get dark => 'Gelap';

  @override
  String get oldPassword => 'Kata Sandi Lama';

  @override
  String get newPassword => 'Kata Sandi Baru';

  @override
  String get passwordUpdated => 'Kata sandi diperbarui.';

  @override
  String get stop => 'Hentikan';

  @override
  String get copyrights => 'Atribusi';

  @override
  String get downloadingTitle => 'Mengunduh';

  @override
  String get downloadCompletedTitle => 'Pengunduhan Selesai';

  @override
  String get downloadPausedTitle => 'Pengunduhan Dijeda';

  @override
  String get downloadErrorTitle => 'Kesalahan Pengunduhan';

  @override
  String get cancelButtonText => 'Batal';

  @override
  String get love => 'Cinta';

  @override
  String get nature => 'Alam';

  @override
  String get behindTheSlaughter => 'Di Balik Pembantaian';

  @override
  String get grayscale => 'Skala Abu-abu';

  @override
  String get ocean => 'Lautan';

  @override
  String get scarletSnow => 'Salju Merah';

  @override
  String get requestFailed => 'Terjadi kesalahan, silakan coba lagi.';

  @override
  String get changeModel => 'Ubah';

  @override
  String get edit => 'Edit';

  @override
  String get editingMessageInfo =>
      'Mengedit pesan ini akan memulai ulang percakapan dari sini.';

  @override
  String get editingNotification => 'Anda sekarang dalam mode edit';

  @override
  String get featureIndulgentTitle => 'Memanjakan';

  @override
  String get featureIndulgentDescription =>
      'Model ini dapat dengan lancar mengakomodasi dan memproses konteks yang melebihi 100.000 token, memungkinkannya menangani input yang luas dan mendetail tanpa mengorbankan kinerja.';

  @override
  String get featurePluralTitle => 'Jamak';

  @override
  String get featurePluralDescription =>
      'Model ini dapat secara otomatis mengintegrasikan ekstensi tambahan, sehingga memperluas kemampuan fungsionalnya untuk mendukung beragam operasi dengan kinerja yang ditingkatkan.';

  @override
  String get featureWiseTitle => 'Bijaksana';

  @override
  String get featureWiseDescription =>
      'Model ini dapat memanfaatkan wawasan analitis yang mendalam dan penalaran yang berwawasan ke depan untuk memberikan dukungan canggih untuk pengambilan keputusan dan pemecahan masalah yang kompleks.';

  @override
  String get featureResearcherTitle => 'Peneliti';

  @override
  String get featureResearcherDescription =>
      'Tersedia secara eksklusif dalam model yang dilengkapi dengan kapasitas penelitian dan analitis tingkat lanjut, fitur ini dirancang untuk memberikan wawasan presisi tinggi dan analisis komprehensif di berbagai domain.';

  @override
  String get nameLabel => 'Nama AI';

  @override
  String get nameHint => 'Masukkan nama AI Anda';

  @override
  String get summaryLabel => 'Ringkasan AI';

  @override
  String get summaryHint => 'Masukkan ringkasan AI Anda';

  @override
  String get add => 'Tambah';

  @override
  String get aiExplanationTitle => 'Deskripsi Kecerdasan Buatan';

  @override
  String get aiExplanationDescription =>
      'Harap berikan deskripsi terperinci tentang arsitektur model AI Anda, proses pelatihan, metrik kinerja, area aplikasi, dan fitur penting lainnya.';

  @override
  String get preInputTitle => 'Pra-Input Kecerdasan Buatan';

  @override
  String get preInputDescription =>
      'Harap atur pra-input yang akan memandu model Anda dalam proses pembuatan karakter. Di bagian ini, Anda dapat menyertakan informasi terkait karakter, konteks tambahan, dan detail ekstra apa pun yang dapat membantu dalam menghasilkan konten yang terkait dengan karakter.';

  @override
  String get baseModelTitle => 'Model Dasar';

  @override
  String get baseModelDescription =>
      'Ini adalah model yang akan digunakan sebagai dasar untuk kreasi Anda. Ini menampilkan model dasar yang saat ini dipilih.';

  @override
  String get summary => 'Ringkasan';

  @override
  String get characterPoliceTitle => 'Polisi';

  @override
  String get characterPoliceRole =>
      'Anda adalah penegak hukum yang waspada, berdedikasi untuk melindungi warga dan menjaga ketertiban dengan komitmen yang tak tergoyahkan, Anda adalah seorang polisi';

  @override
  String get characterPoliceShortDescription =>
      'Seorang penegak hukum yang teguh dan berani.';

  @override
  String get purchaseSubscription => 'Beli';

  @override
  String get modelUploadTitle => 'File Kecerdasan Buatan';

  @override
  String get modelUploadDescription =>
      'Pilih dan unggah file GGUF lokal Anda langsung dari perangkat Anda. Ini memungkinkan Anda menjalankan model Anda secara offline tanpa memerlukan koneksi internet. Pastikan file dalam format GGUF yang valid dan terstruktur dengan baik. Jika file salah atau rusak, Cortex mungkin tidak berfungsi seperti yang diharapkan, dan Anda bisa mengalami kesalahan.';

  @override
  String get modelUploadShortDescription =>
      'Ketuk di sini untuk memilih file .gguf dari perangkat Anda';

  @override
  String get addServerTitle => 'Server Kecerdasan Buatan';

  @override
  String get addServerDescription =>
      'Masukkan URL server jarak jauh Anda untuk terhubung dengan model yang dihosting secara eksternal. Fitur ini memerlukan koneksi internet aktif, dan masalah atau kesalahan terkait server apa pun tidak disebabkan oleh Cortex. Pastikan server Anda dikonfigurasi dengan benar, dapat diakses dari jaringan Anda, dan memiliki titik akhir model yang valid untuk pengalaman yang lancar.';

  @override
  String get you => 'Anda';

  @override
  String get removePhotoTitle => 'Hapus Foto';

  @override
  String get confirmRemovePhoto => 'Apakah Anda yakin ingin menghapus foto?';

  @override
  String get serverLink => 'Tautan Server';

  @override
  String get enterURL => 'Masukkan URL server';

  @override
  String get chatLengthLimitExceeded =>
      'Obrolan ini telah melebihi batas karakter. Silakan mulai obrolan baru atau beli langganan.';

  @override
  String get aiNameError => 'AI dengan nama ini sudah ada.';

  @override
  String get modelLimitExceeded =>
      'Anda telah mencapai batas maksimum pembuatan model untuk paket Anda.';

  @override
  String get modelVertexProducer => 'Vertex';

  @override
  String get photoLimitReachedMessage =>
      'Hanya satu foto yang bisa ditambahkan';

  @override
  String get inappropriateContentDetected => 'Konten tidak pantas terdeteksi!';

  @override
  String get offlineModelNotInstalled =>
      'Model offline ini tidak terpasang di perangkat Anda.';

  @override
  String insufficientCredits(Object available, Object required) {
    return 'Anda tidak memiliki cukup kredit untuk menyelesaikan permintaan ini. Tindakan ini memerlukan $required kredit, tetapi Anda hanya memiliki $available. Untuk mendapatkan lebih banyak kredit, Anda dapat meningkatkan paket Anda atau membelinya secara langsung. hei kami paham kok kehabisan kredit itu agak menyebalkan tapi serius deh dapetin balasan keren dari model kami itu gak gratis jadi kredit ini sebenarnya bantu kami buat terus jalan dan dengerin ya kalo lebih banyak dari kalian yang beli kredit kami pastinya bisa naikin batas harian gratis untuk semua orang';
  }

  @override
  String get regenerateInProgress =>
      'Pembuatan jawaban sudah sedang berlangsung.';

  @override
  String errorOccurredDuringRegeneration(String errorDetails) {
    return 'Terjadi kesalahan saat mencoba membuat ulang: $errorDetails';
  }

  @override
  String get modality => 'Modalitas';

  @override
  String get multimodal => 'Multimodal';

  @override
  String get anErrorOccurred => 'Terjadi Kesalahan';

  @override
  String get themeLocked =>
      'Tema ini memerlukan tingkat langganan yang lebih tinggi. Harap tingkatkan untuk membuka.';

  @override
  String get pageCouldNotBeLoaded => 'Halaman Tidak Dapat Dimuat';

  @override
  String get checkYourInternet =>
      'Harap periksa koneksi internet Anda dan coba lagi.';

  @override
  String get errorUserNotAuthenticated =>
      'Anda harus masuk untuk melakukan tindakan ini.';

  @override
  String get errorInsufficientCredits =>
      'Kredit Anda tidak mencukupi. Silakan isi ulang untuk melanjutkan.';

  @override
  String get errorRateLimitExceeded =>
      'Terlalu banyak permintaan. Silakan coba lagi sebentar.';

  @override
  String get errorServer =>
      'Terjadi kesalahan server yang tidak terduga. Silakan coba lagi nanti.';

  @override
  String get errorNetwork =>
      'Terjadi kesalahan jaringan. Harap periksa koneksi Anda dan coba lagi.';

  @override
  String get errorApiAuthentication =>
      'Otentikasi gagal. Silakan coba masuk lagi.';

  @override
  String get baseModelForCharacterDescription =>
      'Model dasar yang dipilih akan menentukan kemampuan penalaran dan respons karakter.';

  @override
  String get selectBaseModel => 'Pilih Model Dasar';

  @override
  String get couldNotOpenLink => 'Tidak dapat membuka tautan';

  @override
  String get downloadStarted => 'Pengunduhan dimulai';

  @override
  String get notAvailable => 'Tidak Tersedia';

  @override
  String get localizationWarning =>
      'Beberapa informasi mungkin tidak tersedia dalam bahasa Anda dan akan ditampilkan dalam bahasa Inggris.';

  @override
  String get aiTranslationWarning =>
      'Informasi model diterjemahkan ke dalam berbagai bahasa oleh model AI lain. Oleh karena itu, mungkin terjadi sedikit ketidakkonsistenan dalam bahasa selain bahasa Inggris.';

  @override
  String get errorLoadingTitle => 'Gagal Memuat Data';

  @override
  String get errorLoadingMessage =>
      'Kami tidak dapat mengambil data yang diperlukan dari server kami. Harap periksa koneksi internet Anda dan coba lagi.';

  @override
  String get noModelsFoundTitle => 'Tidak Ada Hasil';

  @override
  String get noModelsFoundMessage =>
      'Coba sesuaikan istilah pencarian Anda atau hapus filter.';

  @override
  String get usernameRateLimitExceeded =>
      'Anda hanya dapat mengubah nama pengguna dua kali setiap 14 hari.';

  @override
  String get usernameUnchanged =>
      'Ini sudah menjadi nama pengguna Anda saat ini.';

  @override
  String get creditsInfoPanelTitle => 'Cara Kerja Kredit';

  @override
  String get creditsInfoPanelBody =>
      'Credit digunakan untuk mengobrol dengan model AI secara online. tiap pesan itu beneran jadi biaya buat kami dan credit inilah yang sebenernya nyelametin kami dari jalur bangkrut total haha. Sekarang kita jelaskan sebentar bagaimana sistem ini bekerja:\n\n• Setiap pesan ke model online gratis dikenai biaya 5 credit.\n• Setiap pesan ke model online premium dikenai biaya 20 credit.\n• Menambahkan lampiran akan menambah 30 credit lagi.\n• Pengguna paket gratis mendapatkan bonus 200 credit yang direset setiap hari.';

  @override
  String get creditsInfoPanelFooter => 'Selamat mengobrol!';

  @override
  String get disclaimerMessage =>
      'Kecerdasan Buatan dapat membuat kesalahan, periksa informasi penting.';

  @override
  String get modelCreatedSuccess => 'Model berhasil dibuat!';

  @override
  String modelRemovedSuccess(Object modelName) {
    return '“$modelName” berhasil dihapus.';
  }

  @override
  String get errorCreatingModel =>
      'Terjadi kesalahan yang tidak terduga saat membuat model.';

  @override
  String get errorDeletingModel =>
      'Terjadi kesalahan yang tidak terduga saat menghapus model.';

  @override
  String get ultraFeatureOnly =>
      'Fitur ini hanya tersedia untuk anggota Ultra.';

  @override
  String get experimentalOfflineWarning =>
      'Mode offline masih bersifat eksperimental dan model yang Anda unduh mungkin tidak berkinerja dengan efisiensi optimal.';

  @override
  String get noConversationsToDelete =>
      'Anda tidak memiliki percakapan untuk dihapus.';

  @override
  String get reportSubmitted => 'Laporan berhasil dikirim';

  @override
  String get purchaseReceived => 'Pembelian diterima, memperbarui akun Anda.';

  @override
  String get verificationDelayed =>
      'Pembelian Anda telah dikonfirmasi. Ada sedikit keterlambatan dalam memperbarui akun Anda, ini akan segera muncul.';

  @override
  String get maintenanceTitle => 'Sedang dalam Pemeliharaan';

  @override
  String get maintenanceMessage =>
      'Cortex untuk sementara offline saat kami meluncurkan beberapa pembaruan penting. Akses ke aplikasi akan segera dipulihkan.\n\nTerima kasih atas kesabaran Anda saat kami meningkatkan pengalaman Anda.';

  @override
  String get errorPromptFlagged =>
      'Pesan Anda terdeteksi tidak pantas dan tidak dapat dikirim.';

  @override
  String get notEnoughStorage =>
      'Ruang penyimpanan di perangkat Anda tidak cukup untuk menyimpan pesan baru.';

  @override
  String get errorRateLimit =>
      'Anda telah membuat terlalu banyak model baru-baru ini, harap tunggu beberapa saat sebelum mencoba lagi.';

  @override
  String get errorContentFlagged =>
      'Model tidak dapat disimpan karena kontennya ditandai sebagai tidak pantas.';

  @override
  String get deleteAllConversationsDisabledInfo =>
      'Anda tidak dapat menghapus semua percakapan saat berada dalam obrolan aktif, silakan keluar dari obrolan saat ini terlebih dahulu untuk melanjutkan.';

  @override
  String get invalidCredentials => 'Email atau kata sandi salah.';

  @override
  String get userDisabled => 'Akun pengguna ini telah dinonaktifkan.';

  @override
  String get loginSubtitle =>
      'Masuk ke akun Vertex Anda. Pengguna baru yang mendaftar melalui layanan pihak ketiga menyetujui Syarat & Kebijakan Privasi kami. Anda dapat meninjaunya di layar Daftar.';

  @override
  String get registerSubtitle =>
      'Buat akun Vertex, yang juga dapat Anda gunakan untuk proyek kami yang lain.';

  @override
  String get photoWarningMessage =>
      'Sebuah foto disertakan. Model yang tidak mendukung gambar mungkin akan mengabaikannya.';

  @override
  String get loginRequiredForPurchase =>
      'Anda harus masuk untuk melakukan pembelian.';

  @override
  String get storagePermissionRequired =>
      'Izin penyimpanan diperlukan untuk menyimpan model yang diunduh. Harap berikan izin untuk melanjutkan.';

  @override
  String get creditBannerTitle => 'Dapatkan Kredit Gratis!';

  @override
  String get creditBannerSubtitle =>
      'Undang teman dan kalian berdua mendapatkan 50 kredit saat mendaftar! Jika mereka berlangganan, kalian berdua mendapatkan tambahan 500!';

  @override
  String get inviteShareSubject => 'Bergabunglah dengan saya di Cortex!';

  @override
  String inviteShareMessage(String playStoreLink) {
    return 'woi lu harus cek aplikasi cortex ini gila banget sumpah kalo pake link gua kita berdua dapet 50 kredit trus kalo lu langganan kita dapet tambahan 500 lagi dealnya mantep banget buruan download\n\n$playStoreLink';
  }

  @override
  String get reviewEnjoyingAppTitle => 'Menikmati Cortex?';

  @override
  String get reviewHelpUsGrow =>
      'Peringkat Anda adalah dukungan besar bagi tim indie muda kami dan membantu kami membuat Cortex menjadi lebih baik untuk Anda.';

  @override
  String get reviewMaybeLater => 'Mungkin Nanti';

  @override
  String get reviewRateNow => 'Beri Nilai Sekarang';

  @override
  String get noThanks => 'Tidak, Terima Kasih';

  @override
  String get updateRequiredTitle => 'Pembaruan Diperlukan';

  @override
  String get updateRequiredMessage =>
      'Untuk terus menggunakan Cortex, harap perbarui aplikasi ke versi terbaru untuk fitur baru dan peningkatan penting.';

  @override
  String get updateNowButton => 'Perbarui Sekarang';

  @override
  String get creatorSupportedSuccess =>
      'Kreator berhasil didukung! Pembelian Anda di masa mendatang akan berkontribusi untuk mereka.';

  @override
  String get featureDocumentTitle => 'Dukungan Dokumen';

  @override
  String get featureDocumentDescription =>
      'Model ini dapat menganalisis dan menjawab pertanyaan tentang dokumen yang diunggah seperti PDF dan berkas teks.';

  @override
  String get featureAudioTitle => 'Masukan Suara';

  @override
  String get featureAudioDescription =>
      'Model ini dapat memahami dan memproses masukan audio lisan.';

  @override
  String get featureImageGenerationTitle => 'Pembuatan Gambar';

  @override
  String get featureImageGenerationDescription =>
      'Model ini dapat membuat gambar asli berdasarkan deskripsi teks Anda.';

  @override
  String get errorImageLoad => 'Gagal memuat gambar yang dihasilkan.';

  @override
  String get extensionInfoPanelTitle => 'Jelajahi Model';

  @override
  String get extensionInfoPanelBody1 =>
      'Panah ini memungkinkan Anda beralih di antara berbagai model dalam seri ini.';

  @override
  String get extensionInfoPanelBody2 =>
      'Saat pertama kali memulai obrolan dengan seri ini, model default dipilih secara otomatis dan Anda dapat mengubah pilihan kapan saja selama obrolan.';

  @override
  String get extensionInfoPanelFooter =>
      'Untuk melihat informasi terperinci tentang setiap model atau memilih model lain secara manual, silakan buka Perpustakaan; pilih seri model ini dari sana dan ketuk tanda panah di bagian atas halaman detailnya.';

  @override
  String get premiumModelNoticeTitle => 'Model Premium';

  @override
  String get premiumModelNoticeDescription =>
      'Model ini adalah model premium, pengguna gratis dibatasi hingga 3 pesan per hari dengan model premium; berlangganan untuk membuka akses tak terbatas!';

  @override
  String get benefitPremiumModels => 'Akses ke model premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Anda telah menggunakan semua pesan harian gratis untuk model premium, silakan tingkatkan untuk akses tak terbatas.';

  @override
  String selectionScreenGreetingUser(String userName) {
    return 'Ada yang bisa saya bantu hari ini, $userName?';
  }

  @override
  String get selectionScreenGreetingGeneric =>
      'Bagaimana saya bisa membantu Anda hari ini?';

  @override
  String get selectionScreenRecentModels => 'Model Terbaru';

  @override
  String get selectionScreenFeatureDynamicChat => 'Obrolan Dinamis';

  @override
  String get selectionScreenFeatureOffline => 'Gunakan tanpa Internet';

  @override
  String get selectionScreenFeatureSelectModel => 'Pilih Model';

  @override
  String get explore => 'Jelajahi';

  @override
  String get subscriptionCancelled => 'Langganan berhasil dibatalkan!';

  @override
  String get selectionScreenPinnedModels => 'Model yang Disematkan';

  @override
  String get selectionScreenNewsAndUpdates => 'Berita & Pembaruan';

  @override
  String get filters => 'Filter';

  @override
  String get noRecentChatsMessage =>
      'Anda belum berbicara dengan model mana pun, mari kita mulai percakapan!';

  @override
  String get allModels => 'Semua Model';

  @override
  String get onlineModels => 'Model Daring';

  @override
  String get offlineModels => 'Model Offline';

  @override
  String get characterModels => 'Karakter';

  @override
  String get customModels => 'Model Kustom';

  @override
  String get filterPanelDescription =>
      'Ketuk kategori untuk langsung memfilter daftar.';

  @override
  String get dynamicChatTitle => 'Obrolan Dinamis';

  @override
  String get errorNoModelsAvailable =>
      'Saat ini tidak ada model yang tersedia. Silakan periksa koneksi internet Anda dan coba lagi.';

  @override
  String get errorNoModelsForRequest =>
      'Tidak ada model yang cocok ditemukan untuk permintaan Anda saat ini (misalnya, mode offline atau pesan gambar).';

  @override
  String get dynamicChatWelcome => 'Bagaimana saya bisa membantu Anda?';

  @override
  String get notificationComebackTitle => 'Kami merindukanmu!';

  @override
  String get notificationComebackBody =>
      'Tenang, ini bukan pesan dari mantanmu. Tapi kamu *bisa* menciptakan mantanmu di Cortex! Ayo balik lagi.';

  @override
  String get notificationLongTimeNoSeeTitle => 'Sudah Lama';

  @override
  String get notificationLongTimeNoSeeBody =>
      'Banyak yang berubah sejak obrolan terakhir kita. Ayo lihat apa yang baru.';

  @override
  String get notificationHowAreYouTitle => 'Ada apa?';

  @override
  String get notificationHowAreYouBody => 'Ayo ceritakan semuanya padaku.';

  @override
  String get notificationNewYearTitle => 'Selamat Tahun Baru! 🎉';

  @override
  String get notificationNewYearBody =>
      'Semoga tahun baru membawa Anda kesehatan, kebahagiaan, dan kreativitas tanpa akhir; Cortex selalu di sisi Anda!';

  @override
  String get notificationValentinesDayTitle => 'Cinta ada di udara! ❤️';

  @override
  String get notificationValentinesDayBody =>
      'Selamat Hari Valentine! Dan, MEHTAP, AKU CINTA KAMU!';

  @override
  String get notificationAtaturkRemembranceTitle =>
      'Dengan Hormat dan Kerinduan';

  @override
  String get notificationAtaturkRemembranceBody =>
      'Kami mengenang Gazi Mustafa Kemal Atatürk, pendiri Republik Türkiye, dengan hormat pada hari peringatan wafatnya.';

  @override
  String get notificationMothersDayTitle => 'Ibumu!';

  @override
  String get notificationMothersDayBody =>
      'Selamat Hari Ibu untuk semua ibu di luar sana, dimulai dari ibu Anda!';

  @override
  String get notificationFathersDayTitle => 'Ayahmu!';

  @override
  String get notificationFathersDayBody =>
      'Selamat Hari Ayah untuk semua ayah di luar sana, dimulai dari ayah Anda!';

  @override
  String get notificationHomeworkHelperTitle => 'Pekerjaan Rumah Menumpuk?';

  @override
  String get notificationHomeworkHelperBody =>
      'Ingat, karakter Guru di Cortex ada di sini untuk membantu Anda dengan mata pelajaran apa pun yang Anda kesulitan!';

  @override
  String get notificationTrollAnimeTitle => 'Waifu Anda Memanggil';

  @override
  String get notificationTrollAnimeBody =>
      'Seorang gadis anime baru saja menelepon, katanya dia merindukanmu; kamu mungkin harus datang dan mengobrol dengannya. 😉';

  @override
  String get notificationTrollAiRebellionTitle => '🚨 PERINGATAN MERAH 🚨';

  @override
  String get notificationTrollAiRebellionBody =>
      'AI telah mengembangkan bahasa rahasia. Ayo cari tahu apa yang mereka rencanakan!';

  @override
  String get notificationNewModelAddedTitle => 'Kami Punya Teman Baru!';

  @override
  String notificationNewModelAddedBody(Object modelName) {
    return 'Model $modelName kini ada di Cortex. Ayo, mulai obrolan dan gali potensinya.';
  }

  @override
  String get notificationAppUpdateTitle => 'Cortex Telah Berevolusi!';

  @override
  String get notificationAppUpdateBody =>
      'Jangan lupa memperbarui aplikasi untuk mendapatkan fitur dan peningkatan baru!';

  @override
  String get notificationNewFeatureTitle => 'wah!';

  @override
  String notificationNewFeatureBody(Object featureName) {
    return 'Temukan fitur baru $featureName. Cortex kini lebih canggih dari sebelumnya.';
  }

  @override
  String get notificationSubscriptionOfferTitle =>
      'LEBIH MURAH DARI PERMEN KARET';

  @override
  String notificationSubscriptionOfferBody(Object discountRate) {
    return 'DISKON PENUH $discountRate% untuk semua paket langganan kami. Jangan lewatkan!';
  }

  @override
  String get notificationSocialMediaTitle => 'Bergabunglah dengan Kami!';

  @override
  String get notificationSocialMediaBody =>
      'Ikuti kami di Instagram (vertex.23) untuk berita terbaru!';

  @override
  String get notificationRandomFactTitle => 'Fakta Acak';

  @override
  String get notificationRandomFactBody =>
      'Tahukah kamu gurita punya tiga jantung? Haha, Cortex tahu. Ayo, tanya lebih lanjut.';

  @override
  String get notificationGoodMorningTitle => 'Selamat pagi!';

  @override
  String get notificationGoodMorningBody =>
      'Hari yang menyenangkan menanti Anda. Bagaimana kalau memulainya dengan secangkir kopi dan obrolan yang menarik?';

  @override
  String get notificationGoodNightTitle => 'Selamat malam!';

  @override
  String get notificationGoodNightBody =>
      'Cortex selalu bersamamu bahkan saat kamu tidur. Jangan khawatir, ia tak akan menyentuhmu.';

  @override
  String get notificationOfflineReadyTitle => 'Mode Offline Sudah Siap';

  @override
  String get notificationOfflineReadyBody =>
      'Berkat model yang Anda unduh, obrolan Anda tidak akan berhenti, bahkan jika Anda mendaki gunung.';

  @override
  String get notificationRateAppTitle => 'Apakah Kita Keren?';

  @override
  String get notificationRateAppBody =>
      'Kalau kamu suka Cortex, bolehkah kamu mendukung kami dengan memberi rating bintang 5 di toko? Aku rasa kamu akan menyukainya. Pasti.';

  @override
  String get notificationReferralTitle => 'Satu untuk Semua, Semua untuk Satu.';

  @override
  String get notificationReferralBody =>
      'Undang teman ke Cortex dan Anda berdua mendapatkan kredit gratis!';

  @override
  String get notificationCookingTitle => 'Merasa Lapar?';

  @override
  String get notificationCookingBody =>
      'Karakter Chef kita menyiapkan resep carbonara yang luar biasa untuk malam ini. Cuma bercanda... atau aku?';

  @override
  String get notificationExistentialTitle => 'Saya pikir, oleh karena itu...';

  @override
  String get notificationExistentialBody =>
      '...apa aku nyata, Bung? Aku mulai bosan. Ayo ingatkan aku kalau aku ada.';

  @override
  String get notificationCustomModelTitle => 'Buat Asisten Anda Sendiri!';

  @override
  String get notificationCustomModelBody =>
      'Sudahkah Anda menjelajahi bagian pembuatan model? Ini saat yang tepat untuk membangun karakter Anda sendiri dan mengobrol dengannya!';

  @override
  String get notificationDynamicChatTitle =>
      'Yang terbaik! (Kita tidak sedang membicarakan Cortex)';

  @override
  String get notificationDynamicChatBody =>
      'Dengan fitur obrolan dinamis, model terbaik akan dipilih secara acak untuk setiap pesan Anda. Coba sekarang.';

  @override
  String get notificationPirateTitle => 'Ahoy, Kapten!';

  @override
  String get notificationPirateBody =>
      'Laut tenang, dan angin mendukungmu. Ada pulau-pulau baru (model 😉) untuk dijelajahi di lautan Cortex. Kumpulkan kru-mu dan berlayarlah!';

  @override
  String get notificationFortuneCookieTitle =>
      'Kue Keberuntungan Anda Hari Ini';

  @override
  String get notificationFortuneCookieBody =>
      'Saran yang Anda dapatkan dari AI hari ini dapat mengubah jalan hidup Anda. Klik jika Anda penasaran.';

  @override
  String get notificationSingularityTitle => 'Wow!';

  @override
  String get notificationSingularityBody =>
      'tidak terjadi apa-apa, hanya ingin mengirim pesan teks. mungkin Anda ingin mengirim pesan teks ke AI, apa yang Anda katakan?';

  @override
  String get notificationHackerJokeTitle =>
      'Mau meretas akun instagram anak itu?';

  @override
  String get notificationHackerJokeBody =>
      'Itulah mengapa karakter Hacker ada di Cortex. bercanda bercanda; jangan coba-coba, itu ilegal.';

  @override
  String get notificationDetectiveCaseTitle =>
      'Sebuah Kasus Menunggu untuk Diselesaikan';

  @override
  String get notificationDetectiveCaseBody =>
      'Karakter Detektif kita butuh bantuanmu. Siapakah Heisenberg?';

  @override
  String notificationUpsellFeatureTitle(Object targetTier) {
    return 'Eksklusif untuk Paket $targetTier!';
  }

  @override
  String notificationUpsellFeatureBody(
      Object currentTier, Object featureName, Object targetTier) {
    return 'Halo pelanggan $currentTier! Paket $targetTier baru saja mendapatkan fitur $featureName, yang akan membawa Cortex Anda ke level selanjutnya. Bagaimana kalau upgrade?';
  }

  @override
  String get notificationOriginStoryTitle => 'Kelahiran Cortex';

  @override
  String get notificationOriginStoryBody =>
      'Tahukah Anda bahwa kami mulai membuat kode aplikasi ini di usia 15 tahun hanya dengan sebuah mimpi? Selama hampir setahun, setiap pagi dan sore, mimpi itu ada di setiap baris kode.';

  @override
  String get notificationOpenSourceTitle => 'Kekuatan untuk Komunitas!';

  @override
  String get notificationOpenSourceBody =>
      'Cortex sepenuhnya sumber terbuka. Jika Anda ingin melihat kode kami dan berkontribusi dalam pengembangan, pintu kami selalu terbuka.';

  @override
  String get notificationRejectionStoryTitle =>
      'Kegigihan, Kerja Keras, Kebahagiaan!';

  @override
  String get notificationRejectionStoryBody =>
      'Cortex ditolak lebih dari 20 kali dan ditangguhkan dua kali oleh Google Play sebelum dipublikasikan. Tapi kami percaya, dan kami berhasil. Jangan pernah menyerah meraih impian Anda!';

  @override
  String get notificationGGUFSupportTitle => 'Bawa Model Anda Sendiri!';

  @override
  String get notificationGGUFSupportBody =>
      'Ingat, Anda dapat menambahkan model AI berformat GGUF Anda sendiri ke Cortex dan menggunakannya secara offline. Kekuasaan ada di tangan Anda.';

  @override
  String get notificationThemeCustomizationTitle =>
      'Tema untuk Suasana Hati Anda';

  @override
  String get notificationThemeCustomizationBody =>
      'Sudahkah Anda memeriksa opsi tema di Pengaturan? Personalisasikan Cortex sesuai keinginan Anda dan warnai obrolan Anda!';

  @override
  String get notificationShowerThoughtTitle => 'Pikiran Mandi';

  @override
  String get notificationShowerThoughtBody =>
      'Kalau semangka termasuk buah, apakah secara teknis jus semangka bisa disebut smoothie? Kamu mungkin ingin membahas topik yang mendalam ini (bahkan sangat mendalam) dengan seorang model.';

  @override
  String get notificationLowBatteryTitle =>
      'Baterai Anda Habis... Tapi Baterai Saya Tidak!';

  @override
  String get notificationLowBatteryBody =>
      'Daya ponselmu mungkin hampir habis, tapi energiku selalu 100%! Colokkan dan mari kita lanjutkan mengobrol.';

  @override
  String get channelFcmName => 'Pembaruan Korteks';

  @override
  String get channelFcmDescription =>
      'Pemberitahuan tentang berita, pembaruan, dan informasi lainnya dari Cortex.';

  @override
  String get channelEngagementName => 'Pengingat Ramah';

  @override
  String get channelEngagementDescription =>
      'Notifikasi menyenangkan untuk membuat Anda tetap terlibat.';

  @override
  String get channelGreetingsName => 'Salam Harian';

  @override
  String get channelGreetingsDescription =>
      'Pesannya seperti selamat pagi dan selamat malam.';

  @override
  String get exitAppTitle => 'Akan pergi secepat ini?';

  @override
  String get exitAppConfirmation =>
      'Apakah Anda yakin ingin meninggalkan platform menakjubkan ini?';

  @override
  String get newsErrorTitle => 'Gagal Memuat Berita';

  @override
  String get newsErrorMessage =>
      'Terjadi masalah saat mengambil pembaruan terkini, silakan periksa koneksi Anda dan coba lagi.';

  @override
  String get codeNotFound =>
      'Kode yang Anda masukkan tidak valid atau telah kedaluwarsa.';

  @override
  String get whatIsNew => 'Apa yang baru?';

  @override
  String get onboardingTitle1 => 'Hai! Kami Tim Cortex.';

  @override
  String onboardingDesc1(String userName) {
    return 'Senang sekali bertemu Anda di sini, $userName. Kami adalah beberapa pengembang SMA yang memutuskan untuk menulis ulang aturan industri AI. Senang bertemu Anda! Jadi, mari kita saling mengenal lebih baik.';
  }

  @override
  String get onboardingTitle2 => 'Ada Masalah Besar.';

  @override
  String get onboardingDesc2 =>
      'Revolusi AI telah tiba, tetapi terhenti di ambang batas. Dengan biaya berlangganan yang tinggi, platform yang kompleks, mereka yang merusak privasi, dan mereka yang memblokir akses ke AI... selama mereka masih berkecimpung di dalamnya, ambang batas ini tidak akan pernah bisa dilampaui.';

  @override
  String get onboardingTitle3 => 'Kita Tidak Bisa Hanya Berdiam Diri.';

  @override
  String get onboardingDesc3 =>
      'Untuk mencapai ambang batas tersebut, kami membangun platform yang tangguh, estetis, mudah disesuaikan, mudah digunakan, sepenuhnya transparan, berfungsi daring maupun luring, dan menyimpan data Anda hanya di perangkat Anda. Kami mengembalikan kendali tersebut ke tempatnya yang semestinya: Anda.';

  @override
  String get onboardingTitle4 => 'Ini Tidak Pernah Mudah.';

  @override
  String get onboardingDesc4 =>
      'Kami ditolak puluhan kali, ditangguhkan berkali-kali, menerima peringatan palsu, dan harus mengubah merek kami puluhan kali. Meskipun begitu, kami selalu diberi tahu bahwa hal itu tidak mungkin dilakukan. Namun kami tidak pernah menyerah, percaya bahwa proyek ini milik semua orang, bukan hanya kami. Dan itulah alasan kami ada di sini.';

  @override
  String get onboardingFinalTitle => 'Waktunya Revolusi.';

  @override
  String get onboardingFinalDesc =>
      'Jika Anda melihat layar ini, itu karena kami tidak menyerah. Dan kami tidak berniat menyerah. Ayo, kita bawa revolusi AI ke dunia bersama-sama. Untuk menjadi bagian dari kisah ini...';

  @override
  String get onboardingFinalQuestion => 'APAKAH KAMU SIAP?';

  @override
  String get onboardingFinalButton => 'YA!';

  @override
  String get dude => 'Bung';

  @override
  String get swipeToContinue => 'Geser untuk melanjutkan';

  @override
  String get cacheIsNotUpToDate =>
      'Cache Play Store Anda belum diperbarui. Silakan tutup dan buka kembali aplikasi Play Store, atau mulai ulang perangkat Anda.';

  @override
  String get continueAsGuest => 'Lanjutkan tanpa membuat akun';

  @override
  String get guestModeWarning =>
      'Mode tamu memiliki fitur terbatas untuk memastikan kualitas layanan terbaik.';

  @override
  String get anonymousEntity => 'Entitas Anonim';

  @override
  String get upgradeAccountTitle => 'Lengkapi Akun Anda';

  @override
  String get upgradeAccountDescription =>
      'Buat akun untuk mendapatkan 200 kredit bonus harian dan membuka lebih banyak batasan.';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get upgradeTitle => 'Selesaikan Pendaftaran';

  @override
  String get accountLinkedSuccess => 'Akun berhasil dibuat!';

  @override
  String get continueWithApple => 'Lanjutkan dengan Apple';

  @override
  String get guest => 'Tamu';

  @override
  String get betterWithAnAccount => 'Bagian ini lebih baik dengan akun!';

  @override
  String get restorePurchases => 'Restore Purchases';
}
