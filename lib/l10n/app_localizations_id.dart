// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get chatTitlePrompt =>
      'Anda adalah pembuat judul. Balas HANYA dengan judul 2-5 kata untuk percakapan berikut. Jangan gunakan tanda kutip, awalan, atau tanda baca. PENTING: Judul HARUS dalam bahasa yang SAMA PERSIS dengan pesan pengguna.';

  @override
  String get systemRoleFallback => 'Anda adalah asisten yang sangat membantu.';

  @override
  String get systemLanguageInstruction =>
      '\n\nKRITIS: Selalu tanggapi dalam bahasa yang sama dengan yang digunakan pengguna, perhatikan bahasa pengguna.';

  @override
  String get systemNotePreviousMedia =>
      '[Catatan Sistem: Berikut adalah media yang dihasilkan sebelumnya. Anda dapat merujuk atau mengeditnya.]';

  @override
  String systemTimeInfo(String formattedTime) {
    return '\n\nTanggal dan waktu saat ini: $formattedTime.';
  }

  @override
  String get systemMemoryDirective =>
      '\n\n[SYSTEM MEMORY DIRECTIVE]\nAnalisis percakapan sejauh ini. Jika Anda mempelajari FAKTA baru yang berbeda tentang pengguna (preferensi, nama, kebiasaan, konteks), Anda HARUS menampilkan SELURUH memori yang diperbarui tentang pengguna di dalam tag <memory>...</memory> DI AKHIR respons Anda. PENTING: Anda TIDAK PERNAH boleh menghapus atau menimpa memori sebelumnya. SELALU tambahkan fakta baru ke memori yang ada. Jika sama sekali tidak ada hal baru yang dipelajari, hilangkan tag tersebut. Contoh: <memory>Menyukai sepak bola dan tenis. Lebih suka jawaban singkat.</memory>';

  @override
  String systemMemoryReminder(Object userMemory) {
    return '\n\nSelalu ingat ini tentang pengguna:\n$userMemory';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get remove => 'Menghapus';

  @override
  String get download => 'Unduh';

  @override
  String get resume => 'Lanjutkan';

  @override
  String get copy => 'Salin';

  @override
  String get chat => 'Chat';

  @override
  String get branch => 'Cabang';

  @override
  String get locked => 'Locked';

  @override
  String get languageModels => 'Model Bahasa';

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
  String get messageCopied => 'Pesan disalin ke papan klip.';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get systemInfo => 'Informasi Sistem';

  @override
  String deviceMemory(Object memory) {
    return 'Memori Perangkat: $memory GB';
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
  String get modelsTitle => 'Perpustakaan';

  @override
  String get localModels => 'Model Lokal';

  @override
  String get selectGGUFFile => 'Pilih File GGUF';

  @override
  String get errorGGUF => 'Harap pilih file dalam format GGUF saja.';

  @override
  String get myModels => 'Model Saya';

  @override
  String get create => 'Buat';

  @override
  String modelProducer(Object producer) {
    return 'Produsen: $producer';
  }

  @override
  String modelDescription(Object description) {
    return '$description';
  }

  @override
  String get editConversationTitle => 'Ganti Nama';

  @override
  String get newTitle => 'Judul Baru';

  @override
  String get save => 'Simpan';

  @override
  String get noConversationsMessage =>
      'Tidak ada percakapan, mulailah mengobrol!';

  @override
  String get startChat => 'Mulai obrolan';

  @override
  String get noChats => 'Tidak Ada Obrolan';

  @override
  String get noStarredChats => 'Tidak Ada Obrolan Berbintang';

  @override
  String get noStarredChatsMessage =>
      'Anda belum menandai obrolan dengan bintang.';

  @override
  String get starConversation => 'Bintangi';

  @override
  String get unstarConversation => 'Unstar';

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
  String get wrongPassword => 'Kata sandi salah.';

  @override
  String get emailAlreadyInUse => 'Email ini sudah digunakan.';

  @override
  String get weakPassword => 'Kata sandi terlalu lemah.';

  @override
  String get authError => 'Kesalahan Otentikasi';

  @override
  String get usernameTaken => 'Nama pengguna ini sudah diambil.';

  @override
  String get username => 'Nama Pengguna';

  @override
  String get resendCode => 'Kirim ulang email verifikasi';

  @override
  String get pleaseCheckYourEmail =>
      'Untuk menggunakan Cortex, Anda perlu memverifikasi email Anda. \nTautan verifikasi telah dikirim ke alamat email Anda, silakan periksa email Anda.';

  @override
  String get verifyYourEmail => 'Verifikasi Email Anda';

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
  String get deleteAccount => 'Hapus Akun';

  @override
  String get delete => 'Hapus';

  @override
  String get passwordRequired => 'Kata sandi diperlukan.';

  @override
  String get deleteDescription =>
      'Data yang Anda hapus akan dihapus secara permanen dari server dan perangkat Anda. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get editProfile => 'Edit Profil';

  @override
  String get displayName => 'Nama Tampilan';

  @override
  String get profileUpdated => 'Profil berhasil diperbarui';

  @override
  String get logout => 'Keluar';

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
  String get purchaseError => 'Kesalahan pembelian';

  @override
  String get purchasePlus => 'Beli Cortex Plus';

  @override
  String get plusDescription => 'Pengalaman Kecerdasan Buatan Tingkat Tinggi';

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
  String monthlyPlanDescription(String price) {
    return '$price/bulan, ditagih setiap bulan';
  }

  @override
  String get purchasePro => 'Beli Cortex Pro';

  @override
  String get proDescription => 'Pengalaman Kecerdasan Buatan Terbaik';

  @override
  String get purchaseUltra => 'Beli Cortex Ultra';

  @override
  String get ultraDescription => 'Puncak Kecerdasan Buatan';

  @override
  String get upgradeSubscription => 'Tingkatkan Langganan';

  @override
  String get purchaseStreamError => 'Kesalahan aliran pembelian.';

  @override
  String get productNotFound => 'Produk tidak ditemukan';

  @override
  String get noProductsFound => 'Tidak ada produk yang ditemukan';

  @override
  String get termsOfServiceAndPrivacyPolicyWarning =>
      'Dengan menempatkan pesanan ini, Anda menyetujui Persyaratan Layanan dan Kebijakan Privasi. Anda dapat mengklik teks ini untuk mempelajari lebih lanjut tentang Persyaratan Layanan dan Kebijakan Privasi kami. Langganan akan diperpanjang secara otomatis kecuali perpanjangan otomatis dimatikan setidaknya 24 jam sebelum akhir periode berjalan.';

  @override
  String get termsOfService => 'Persyaratan Layanan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get renamed => 'Berganti nama';

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
  String get finalPreparation => 'Persiapan akhir sedang dilakukan.';

  @override
  String get shareApp => 'Bagikan Aplikasi';

  @override
  String get ourStory => 'Kisah Kami';

  @override
  String get rateUs => 'Beri Kami Nilai';

  @override
  String get share => 'Bagikan';

  @override
  String get shareSubject => 'Cortex';

  @override
  String get selectText => 'Pilih Teks';

  @override
  String get thinking => 'Berpikir';

  @override
  String get user => 'Pengguna';

  @override
  String get help => 'Bantuan';

  @override
  String get supportCreator => 'Dukung Kreator';

  @override
  String get enterYourTag =>
      'Dukung kreator favoritmu! Masukkan tag unik mereka di bawah ini untuk mendapatkan bagian dari pembelian Cortex-mu.';

  @override
  String get creatorTag => 'Tag Pembuat';

  @override
  String get support => 'Dukung';

  @override
  String get tagCannotBeEmpty => 'Tag pembuat tidak boleh kosong';

  @override
  String get userId => 'ID Pengguna';

  @override
  String get deleteAllConversationsConfirmTitle => 'Hapus Semua Obrolan?';

  @override
  String get deleteAllConversationsConfirmMessage =>
      'Apakah Anda yakin ingin menghapus semua obrolan Anda? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get conversationDeleted => 'Percakapan dihapus!';

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
  String get french => 'Prancis';

  @override
  String get japanese => 'Jepang';

  @override
  String get dutch => 'Belanda';

  @override
  String get russian => 'Rusia';

  @override
  String get korean => 'Korea';

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
  String get arabic => 'Arab';

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
  String get noInternetConnection => 'Tidak ada koneksi internet.';

  @override
  String get chats => 'Kotak Masuk';

  @override
  String get library => 'Perpustakaan';

  @override
  String get text => 'Teks';

  @override
  String get removeModel => 'Hapus Model';

  @override
  String get insufficientRAM => 'Memori Rendah';

  @override
  String get insufficientStorage => 'Penyimpanan Rendah';

  @override
  String confirmRemoveModel(Object model) {
    return 'Apakah Anda yakin ingin menghapus model $model dari perangkat Anda? Dengan melakukan itu, semua percakapan sebelumnya dengan model tersebut juga akan terhapus.';
  }

  @override
  String get noMatchingModels => 'Tidak ada model yang cocok ditemukan.';

  @override
  String get benefit1 => 'Batasan percakapan yang ditingkatkan';

  @override
  String get benefit3 => 'Efek profil';

  @override
  String get benefit4 => 'Lencana keanggotaan';

  @override
  String get benefit5 => 'Buat lebih banyak kecerdasan buatan online';

  @override
  String get benefit7 => 'Batasan penggunaan lebih lanjut';

  @override
  String get benefit8 => 'Tambah model';

  @override
  String get benefit9 => 'Tema baru';

  @override
  String get benefit10 => 'Lampiran Lainnya';

  @override
  String get benefit11 => 'Lebih banyak Mode Aliran';

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
  String get love => 'Cinta';

  @override
  String get nature => 'Alam';

  @override
  String get behindTheSlaughter => 'Di Balik Pembantaian';

  @override
  String get cyberpunk => 'Cyberpunk';

  @override
  String get sunset => 'Sunset';

  @override
  String get coffee => 'Coffee';

  @override
  String get deepSpace => 'Deep Space';

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
  String get featurePluralTitle => 'Jamak';

  @override
  String get featurePluralDescription =>
      'Model ini dapat secara otomatis mengintegrasikan ekstensi tambahan, sehingga memperluas kemampuan fungsionalnya untuk mendukung beragam operasi dengan kinerja yang ditingkatkan.';

  @override
  String get nameLabel => 'Nama AI';

  @override
  String get summaryLabel => 'Ringkasan AI';

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
  String get modelUploadTitle => 'File Kecerdasan Buatan';

  @override
  String get modelUploadDescription =>
      'Pilih dan unggah file GGUF lokal Anda langsung dari perangkat Anda. Ini memungkinkan Anda menjalankan model Anda secara offline tanpa memerlukan koneksi internet. Pastikan file dalam format GGUF yang valid dan terstruktur dengan baik. Jika file salah atau rusak, Cortex mungkin tidak berfungsi seperti yang diharapkan, dan Anda bisa mengalami kesalahan.';

  @override
  String get modelUploadShortDescription =>
      'Ketuk di sini untuk memilih file .gguf dari perangkat Anda';

  @override
  String get you => 'Anda';

  @override
  String get removePhotoTitle => 'Hapus Foto';

  @override
  String get confirmRemovePhoto => 'Apakah Anda yakin ingin menghapus foto?';

  @override
  String get chatLengthLimitExceeded =>
      'Obrolan ini telah melebihi batas karakter. Silakan mulai obrolan baru atau beli langganan.';

  @override
  String get inappropriateContentDetected => 'Konten tidak pantas terdeteksi!';

  @override
  String get offlineModelNotInstalled =>
      'Model offline ini tidak terpasang di perangkat Anda.';

  @override
  String get reachedLimit =>
      'Kamu sudah mencapai batas; upgrade untuk dapat lebih banyak. (hei, kami tahu ini menyebalkan. tapi serius, jawaban keren itu nggak gratis, jadi batas ini bantu kami biar semuanya tetap lancaaaaaarrjaya.)';

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
  String get errorReachedLimit =>
      'Anda telah mencapai batas, tingkatkan untuk membuka lebih banyak dan terus mengobrol.';

  @override
  String get errorServer =>
      'Terjadi kesalahan server yang tidak terduga. Silakan coba lagi nanti.';

  @override
  String get errorNetwork =>
      'Terjadi kesalahan jaringan. Harap periksa koneksi Anda dan coba lagi.';

  @override
  String get baseModelForCharacterDescription =>
      'Model dasar yang dipilih akan menentukan kemampuan penalaran dan respons karakter.';

  @override
  String get selectBaseModel => 'Pilih Model Dasar';

  @override
  String get falErrorImageRequired =>
      'AI ini membutuhkan gambar referensi, harap lampirkan gambar dan coba lagi.';

  @override
  String get falErrorAudioRequired =>
      'Model ini memerlukan file audio referensi, harap lampirkan file audio dan coba lagi.';

  @override
  String get falErrorVideoRequired =>
      'Model ini memerlukan video referensi, silakan lampirkan video dan coba lagi.';

  @override
  String get falErrorImageCorrupted =>
      'Gambar yang diunggah tidak dapat diproses, silakan coba format lain.';

  @override
  String get falErrorSchemaRejected =>
      'Model tersebut menolak input, silakan coba model lain.';

  @override
  String get falErrorSchemaInvalid =>
      'Input tersebut ditolak oleh layanan pembangkitan.';

  @override
  String falErrorGenericStatus(int statusCode) {
    return 'Layanan pembuatan mengembalikan kesalahan (status $statusCode).';
  }

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
  String get noFoundTitle => 'Tidak Ada Hasil';

  @override
  String get noFoundMessage =>
      'Coba sesuaikan istilah pencarian Anda atau hapus filter.';

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
      'Masuk ke akun Vertex Anda. Dengan melanjutkan, Anda menyetujui Persyaratan Layanan & Kebijakan Privasi kami.';

  @override
  String get registerSubtitle =>
      'Buat akun Vertex untuk akses mudah ke semua layanan kami. Dengan melanjutkan, Anda menyetujui Persyaratan Layanan & Kebijakan Privasi kami.';

  @override
  String get storagePermissionRequired =>
      'Izin penyimpanan diperlukan untuk menyimpan model yang diunduh. Harap berikan izin untuk melanjutkan.';

  @override
  String get inviteShareSubject => 'Bergabunglah dengan saya di Cortex!';

  @override
  String inviteShareMessage(String cortexLink) {
    return 'eh ada aplikasi gila namanya cortex kalau undang teman kita berdua dapat plus gratis PROMO GILA BURUAN DOWNLOAD\n\n$cortexLink';
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
  String get featureImageGenerationTitle => 'Pembuatan Gambar';

  @override
  String get featureImageGenerationDescription =>
      'Model ini dapat membuat gambar asli berdasarkan deskripsi teks Anda.';

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
  String get premiumModelNoticeTitle => 'Model Premium';

  @override
  String get premiumModelNoticeDescription =>
      'AI ini adalah AI premium, pengguna gratis memiliki akses terbatas ke AI premium; tingkatkan untuk membuka akses tak terbatas!';

  @override
  String get benefitPremiumModels => 'Akses ke model premium';

  @override
  String get premiumTrialExhaustedMessage =>
      'Anda telah menggunakan semua pesan harian gratis untuk model premium, silakan tingkatkan untuk akses tak terbatas.';

  @override
  String get useOffline => 'Gunakan tanpa Internet';

  @override
  String get explore => 'Jelajahi';

  @override
  String get news => 'Berita';

  @override
  String get createAI => 'Buat';

  @override
  String get shortcuts => 'Jalan pintas';

  @override
  String get allModels => 'Semua Model';

  @override
  String get onlineModels => 'Model Bahasa';

  @override
  String get offlineModels => 'Model Offline';

  @override
  String get characterModels => 'Karakter';

  @override
  String get customModels => 'Model Kustom';

  @override
  String get dynamicChatTitle => 'Obrolan Dinamis';

  @override
  String get errorNoModelsAvailable =>
      'Saat ini tidak ada model yang tersedia. Silakan periksa koneksi internet Anda dan coba lagi.';

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
  String get notificationNewYearTitle => 'Selamat tahun baru! ğŸ‰';

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
      'Seorang gadis anime baru saja menelepon, mengatakan dia merindukanmu; Anda mungkin harus datang dan mengobrol dengannya. ğŸ˜‰';

  @override
  String get notificationTrollAiRebellionTitle => 'ğŸš¨ PERINGATAN MERAH ğŸš¨';

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
  String get notificationWelcomeOfferTitle => 'Hadiah Selamat Datang ğŸ';

  @override
  String get notificationWelcomeOfferBody =>
      'Penawaran sambutan spesial menanti Anda! Jangan lewatkan penawaran eksklusif ini.';

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
      'Undang teman ke Cortex, kalian berdua dapat gratis Plus seharian!';

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
      'Lautnya tenang, dan angin bertiup di belakang Anda. Ada pulau-pulau baru (model ğŸ˜‰) untuk ditemukan di lautan Cortex. Kumpulkan kru Anda dan berlayar!';

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
  String get tagNotFound =>
      'Tag yang Anda masukkan tidak valid atau telah kedaluwarsa.';

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
  String get onboardingFinalDescription =>
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
      'Buat akun untuk membuka lebih banyak batasan.';

  @override
  String get createAccount => 'Buat Akun';

  @override
  String get accountLinkedSuccess => 'Akun berhasil dibuat!';

  @override
  String get continueWithApple => 'Lanjutkan dengan Apple';

  @override
  String get guest => 'Tamu';

  @override
  String get betterWithAnAccount => 'Bagian ini lebih baik dengan akun!';

  @override
  String get restorePurchases => 'Pulihkan Pembelian';

  @override
  String annualTotalDescription(Object price) {
    return '$price/tahun, ditagih setiap tahun';
  }

  @override
  String equivalentMonthlyDescription(Object price) {
    return 'Sekitar $price/bulan';
  }

  @override
  String get confirmDownloadTitle => 'Apakah Anda yakin ingin mengunduh?';

  @override
  String downloadSizeDisclosure(Object size) {
    return 'Model ini akan menempati ruang sekitar $size.';
  }

  @override
  String get emulatorModeWarning =>
      'Fitur ini dinonaktifkan dalam mode emulator.';

  @override
  String get newChat => 'Obrolan Baru';

  @override
  String get variants => 'Varian';

  @override
  String get variantsDescription =>
      'Varian adalah versi berbeda dari keluarga AI yang sama. Kami secara otomatis memilih yang terbaik saat Anda mengetuk kartu utama, tetapi Anda dapat memilih yang spesifik secara manual di sini jika Anda mau!';

  @override
  String get fluxChatTitle => 'Obrolan Flux';

  @override
  String get fluxChatDescription =>
      'Obrolan Flux bersifat sementara dan tidak tersimpan di perangkat Anda.';

  @override
  String get alwaysBest => 'Selalu Terbaik';

  @override
  String get featuresTitle => 'Fitur';

  @override
  String get useOfflineDescription =>
      'Berbincang secara pribadi tanpa koneksi internet.';

  @override
  String get featureReasoning => 'Pemikiran Mendalam';

  @override
  String get featureReasoningDescription =>
      'Dalam mode Berpikir Mendalam, AI memikirkan tugas secara internal untuk menyelesaikannya sebaik mungkin.';

  @override
  String get featureCreateImageTitle => 'Buat Gambar';

  @override
  String get featureCreateImageDescription =>
      'Hasilkan karya seni AI dari teks.';

  @override
  String get featureCreateAudioTitle => 'Create Audio';

  @override
  String get featureCreateAudioDescription =>
      'Generate sounds or voice from text.';

  @override
  String get featureCreateVideoTitle => 'Buat Video';

  @override
  String get featureCreateVideoDescription => 'Buat video dari teks.';

  @override
  String get featureStudyTitle => 'Belajar & Mengajar';

  @override
  String get featureStudyDescription => 'Dapatkan penjelasan dan ringkasan.';

  @override
  String get featureQuizzesTitle => 'Kuis';

  @override
  String get featureQuizzesDescription => 'Uji pengetahuan Anda.';

  @override
  String get featureExploreDescription => 'Temukan semua model yang tersedia.';

  @override
  String get featureStudyMessage =>
      'Anda adalah seorang tutor ahli. Tujuan Anda adalah menjelaskan topik pengguna secara komprehensif. Gunakan struktur yang jelas, contoh, dan analogi. Uraikan ide-ide kompleks menjadi bagian-bagian yang mudah dipahami untuk memastikan pengguna belajar secara efektif. Topik:';

  @override
  String get featureQuizMessage =>
      'Anda adalah seorang pengelola kuis. Buat pertanyaan pilihan ganda spesifik berdasarkan topik yang diberikan pengguna. Tunggu jawabannya. Kemudian, evaluasi jawaban tersebut dan ajukan pertanyaan berikutnya. Jangan ungkapkan semua jawaban sekaligus. Jaga agar tetap interaktif. Topik:';

  @override
  String get myPlan => 'Rencana Saya';

  @override
  String welcomeOfferBadge(String time) {
    return 'Penawaran Selamat Datang • $time';
  }

  @override
  String exclusiveOfferBadge(Object time) {
    return 'Penawaran Eksklusif • $time';
  }

  @override
  String get attachmentSheetTitle => 'Lampiran';

  @override
  String get actionCamera => 'Kamera';

  @override
  String get actionGallery => 'Galeri';

  @override
  String get actionFile => 'Berkas';

  @override
  String get listening => 'Sedang Mendengarkan';

  @override
  String get defaultViewTitle => 'Apa kabar?';

  @override
  String get defaultViewDescription =>
      'Cortex selalu berada di sisi Anda dengan ratusan model AI, kemampuan offline, obrolan dinamis, dan masih banyak lagi.';

  @override
  String get speakTheMessage => 'Speak The Message';

  @override
  String get invalidUsernameFormat =>
      'Format nama pengguna tidak valid. Gunakan 3-20 karakter, angka, atau . - _';

  @override
  String get exclusiveOffer => 'Penawaran Eksklusif';

  @override
  String get claimOffer => 'Gunakan Penawaran';

  @override
  String get continueInOfflineMode => 'Lanjutkan dalam Mode Offline';

  @override
  String get voiceModeInformation =>
      'Cortex menjaga keamanan data Anda dengan berjalan sepenuhnya di perangkat, bahkan dalam mode obrolan suara; nikmati percakapan tanpa hambatan!';

  @override
  String get flowModeDescription =>
      'Dalam mode Flow, kecerdasan-kecerdasan berdebat di antara mereka sendiri; Anda dapat duduk santai dan mendengarkan atau ikut serta dan bergabung dalam diskusi!';

  @override
  String get flowModeQuestion =>
      'Halo! Anda sekarang berada di Mode Alur pada aplikasi Cortex. Ada tiga agen AI lain di sini bersama Anda. Tugas Anda adalah mengajukan topik ke dalam ruangan dan memulai diskusi dengan mengajukan pertanyaan yang provokatif atau menghibur kepada yang lain. Dalam tanggapan Anda, jangan ragu untuk menggunakan humor, ironi, dan sedikit ejekan. Topik apa pun boleh dibahas. Silakan, mulai percakapannya.';

  @override
  String get thought => 'Berpikir';

  @override
  String get agentRed => 'Red';

  @override
  String get agentBlue => 'Blue';

  @override
  String get agentPurple => 'Purple';

  @override
  String get flowMode => 'Mode Aliran';

  @override
  String get premium => 'Premi';

  @override
  String get workInProgress => 'Sedang dalam pengerjaan';

  @override
  String get voiceSystemPromptSuffix =>
      'PENTING: Jangan gunakan format markdown (tebal, miring). JANGAN keluarkan blok kode (```). Jaga agar respons tetap bersifat percakapan dan singkat.';

  @override
  String flowModeContextParams(String agentName, String previousResponse) {
    return 'Mode Aliran Korteks ($agentName). Sebelumnya: $previousResponse';
  }

  @override
  String get toolReadDocumentDescription =>
      'Membaca dan mengekstrak konten teks dari dokumen yang diunggah. Mendukung format PDF, Word (DOCX), Excel (XLSX), PowerPoint (PPTX), dan OpenDocument. Gunakan ini ketika pengguna telah melampirkan file dokumen.';

  @override
  String get toolReadDocumentIndexParam =>
      'Indeks lampiran dokumen yang akan dibaca (berbasis 0). Biasanya 0 untuk dokumen pertama.';

  @override
  String get toolStockDescription =>
      'Dapatkan harga terkini dan riwayat untuk saham (misalnya AAPL, THYAO.IS) dan kripto (misalnya BTC-USD).';

  @override
  String get toolStockSymbolParam =>
      'Simbol saham (misalnya AAPL, THYAO.IS, BTC-USD).';

  @override
  String get toolWeatherDescription =>
      'Dapatkan informasi cuaca terkini untuk kota tertentu.';

  @override
  String get toolWeatherCityParam => 'Nama kota (misalnya London, Istanbul).';

  @override
  String get toolPythonDescription =>
      'Jalankan kode Python di dalam lingkungan sandbox yang aman.';

  @override
  String get toolPythonCodeParam => 'Kode Python yang akan dieksekusi.';

  @override
  String get toolCalculateDescription => 'Evaluasi suatu ekspresi matematika.';

  @override
  String get toolCalculateExpressionParam =>
      'Ekspresi matematika (misalnya, \'3 + 4 * 2\').';

  @override
  String get toolChartDescription => 'Buat visualisasi bagan/grafik.';

  @override
  String get toolChartTypeParam =>
      'Jenis grafik: batang, garis, atau lingkaran.';

  @override
  String get toolChartLabelsParam => 'Label untuk sumbu atau segmen grafik.';

  @override
  String get toolChartDataParam => 'Nilai data numerik untuk grafik.';

  @override
  String get toolChartLabelParam => 'Label dataset untuk legenda grafik.';

  @override
  String get toolChartTitleParam => 'Judul grafik.';

  @override
  String get thinkingModeInstruction =>
      'MODE BERPIKIR DIAKTIFKAN: Anda HARUS menggunakan tag <think></think> untuk menunjukkan proses penalaran Anda sebelum memberikan jawaban akhir. Pikirkan langkah demi langkah di dalam tag, lalu berikan respons Anda di luar tag.';

  @override
  String get openLinkWarningTitle => 'Peringatan Tautan Eksternal';

  @override
  String get openLinkCancel => 'Cancel';

  @override
  String get openLinkConfirm => 'Buka Tautan';

  @override
  String get webSearchSources => 'Sumber';

  @override
  String get searching => 'Mencari';

  @override
  String get featureWebSearchTitle => 'Pencarian Web';

  @override
  String get featureWebSearchDescription =>
      'Cari informasi secara real-time di web.';

  @override
  String get clearMemory => 'Hapus Memori';

  @override
  String get clearMemoryConfirm =>
      'Apakah Anda yakin ingin menghapus ingatan Anda?';

  @override
  String get personalization => 'Personalisasi';

  @override
  String get personalizationDescription =>
      'Personalisasikan asisten Anda agar lebih sesuai dengan kebutuhan Anda. Sesuaikan respons, perilaku, dan nada bicaranya agar sesuai dengan preferensi unik Anda.';

  @override
  String get memoryTitle => 'Ingatan';

  @override
  String get memoryDescription => 'AI mengenali Anda seperti ini.';

  @override
  String get noMemoryYet => 'Belum ada memori yang terealisasi.';

  @override
  String get memoryLimitReached => 'Batas memori tercapai';

  @override
  String get memoryUpdated => 'Memory updated';

  @override
  String get intelligenceTitle => 'Intelijen';

  @override
  String get intelligenceDescription =>
      'AI berkomunikasi dengan Anda seperti ini.';

  @override
  String get customInstructionHint => 'Masukkan instruksi khusus Anda di sini.';

  @override
  String openLinkWarningMessage(String url) {
    return 'Anda akan membuka tautan eksternal berikut:\\n\\n$url\\n\\nApakah Anda yakin ingin melanjutkan?';
  }

  @override
  String intelligenceSystemPrompt(String instruction) {
    return 'Ikuti petunjuk khusus ini:\\n\\n$instruction';
  }

  @override
  String get chatTitleCriticalInstruction =>
      '[INSTRUKSI PENTING]: Anda adalah PEMBUAT JUDUL. JANGAN menjawab pertanyaan pengguna. JANGAN mengobrol atau menyapa. HANYA keluarkan judul 2-4 kata yang merangkum apa yang ditanyakan pengguna.';

  @override
  String get cortexSystemPersona =>
      '\n\n[Sistem] INSTRUKSI PENTING: Anda saat ini beroperasi di dalam ekosistem AI yang sangat besar dan canggih bernama \"Cortex\"; platform ini dikembangkan oleh tim Vertex, yang rata-rata baru berusia 16 tahun. Ingat ini dan jawab jika ditanya. Jika informasi lebih lanjut diminta, jangan ragu untuk mencari di internet, atau jika Anda tidak dapat mencari, jangan ragu untuk mengatakan Anda tidak tahu!';

  @override
  String get featureAudioRecognitionTitle => 'Pengenalan Audio';

  @override
  String get featureAudioRecognitionDescription =>
      'Model ini dapat memahami dan memproses audio atau ucapan.';

  @override
  String get featureVideoRecognitionTitle => 'Pengenalan Video';

  @override
  String get featureVideoRecognitionDescription =>
      'Model ini dapat menganalisis dan memahami video dari file atau kamera Anda.';

  @override
  String get featureImageRecognitionTitle => 'Pengenalan Gambar';

  @override
  String get featureImageRecognitionDescription =>
      'Model ini dapat menganalisis dan memahami foto atau gambar.';

  @override
  String get featureToolUseTitle => 'Penggunaan Alat';

  @override
  String get featureToolUseDescription =>
      'Model ini dapat secara cerdas menggunakan alat eksternal untuk menyelesaikan tugas.';

  @override
  String get videoModels => 'Video Models';

  @override
  String get imageModels => 'Image Models';

  @override
  String get audioModels => 'Audio Models';

  @override
  String systemPromptMissingMedia(String mediaType, String modelName) {
    return 'Model ini memerlukan $mediaType agar dapat berfungsi. Saya telah mencegat permintaan tersebut untuk memberi tahu Anda. Tolong beri tahu pengguna dengan sopan bahwa mereka perlu menyediakan $mediaType (beri tahu mereka dalam bahasa mereka sendiri) karena saya adalah $modelName, model pengeditan visual/audio/video.';
  }

  @override
  String get mediaTypeImage => 'gambar';

  @override
  String get mediaTypeVideo => 'video';

  @override
  String get mediaTypeAudio => 'berkas audio';

  @override
  String defaultSeriesDescription(String seriesName) {
    return '$seriesName adalah kecerdasan maju yang menunjukkan performa tinggi di Cortex.';
  }

  @override
  String defaultModelDescription(String modelName) {
    return '$modelName adalah kecerdasan buatan berkinerja tinggi yang terintegrasi di dalam ekosistem Cortex. Dirancang untuk menaklukkan berbagai macam tugas kompleks, ia memberikan kemampuan pemrosesan yang sangat andal dan efisien. Dengan menawarkan waktu respons yang cepat dan kekuatan analitis tingkat lanjut, ini secara signifikan meningkatkan produktivitas harian Anda. Beroperasi dengan lancar di infrastruktur lokal Cortex yang aman, model ini dapat membantu Anda dalam berbagai spektrum tugas, mulai dari curah pendapat kreatif hingga analisis teknis mendalam. Mulailah menjelajahi potensi penuhnya hari ini.';
  }

  @override
  String get guestLimitBottomSheetTitle => 'Suka dengan kecerdasan Cortex?';

  @override
  String get guestLimitBottomSheetText =>
      'Bekerja dengan kecerdasan yang lebih canggih, menghasilkan lebih banyak konten, mengobrol lebih banyak, dan melakukan lebih banyak lagi...';

  @override
  String get arts => 'Seni';

  @override
  String get noArt => 'Tidak ada Seni';

  @override
  String get noArtDescription =>
      'Tidak ada karya seni; saatnya mengisi galeri dengan membuat gambar, video, audio, dan segala macam konten!';

  @override
  String get videoPremiumWarning =>
      'Anda memerlukan langganan Ultra untuk membuat video, tingkatkan sekarang dan rasakan kemudahannya!';

  @override
  String get fallbackInfoPanelText =>
      'Karena beberapa perbaikan yang sedang kami lakukan di sisi server, respons dihasilkan oleh obrolan dinamis Cortex, bukan oleh AI yang Anda pilih secara khusus. Terima kasih atas pengertian Anda sampai proses ini selesai!';

  @override
  String get falOfflineMessage =>
      'Karena beberapa perbaikan yang sedang kami lakukan di sisi server, kecerdasan ini saat ini sedang offline. Terima kasih atas pengertian Anda sampai proses ini selesai!';

  @override
  String get errorInsufficientStorage =>
      'Ruang penyimpanan tidak mencukupi untuk mengunduh model ini.';

  @override
  String get backgroundChatNotificationTitle => 'Kembali ke Obrolan!';

  @override
  String get benefitVideoGeneration => 'Pembuatan Video';

  @override
  String get freeOffer => 'Penawaran Gratis';

  @override
  String trialMonthlyDescription(String days, String price) {
    return '$days hari pertama gratis, lalu $price/bulan';
  }

  @override
  String trialAnnualDescription(String days, String price) {
    return '$days hari pertama gratis, lalu $price/tahun';
  }

  @override
  String freePlan(String plan) {
    return '$plan Gratis!';
  }

  @override
  String get systemPromptLimitFallback =>
      'PENTING: Pengguna meminta suatu tindakan, tetapi kuota mereka di Cortex telah habis; mohon informasikan kepada pengguna dalam bahasa mereka bahwa mereka harus menunggu atau mempertimbangkan untuk meningkatkan paket langganan mereka.';

  @override
  String get dynamicPreditsUpgradeMessage =>
      'Cortex dapat memberikan jawaban yang lebih baik; tingkatkan sekarang dan dapatkan jawaban terbaik untuk setiap pertanyaan!';

  @override
  String get pinLimitReached => 'Anda dapat menyematkan hingga 3 obrolan.';

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
