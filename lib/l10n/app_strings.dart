import 'package:flutter/material.dart';

/// Lightweight in-code localization (ar default, en, es, fr). No codegen needed.
class S {
  final Locale locale;
  S(this.locale);

  static S of(BuildContext c) => Localizations.of<S>(c, S)!;
  static const delegate = _SDelegate();
  static const supported = [Locale('ar'), Locale('en'), Locale('es'), Locale('fr')];
  static const names = {'ar': 'العربية', 'en': 'English', 'es': 'Español', 'fr': 'Français'};

  String t(String key) => _v[locale.languageCode]?[key] ?? _v['en']![key] ?? key;

  /// Replaces {a}, {b}... placeholders.
  String f(String key, Map<String, Object> args) {
    var s = t(key);
    args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  static const Map<String, Map<String, String>> _v = {
    'ar': {
      'app_name': 'خريطة الشبكات',
      'login': 'تسجيل الدخول', 'register': 'إنشاء حساب', 'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور', 'confirm': 'تأكيد كلمة المرور',
      'no_account': 'ليس لديك حساب؟ سجّل الآن', 'have_account': 'لديك حساب؟ سجّل الدخول',
      'logout': 'تسجيل الخروج', 'search_hint': 'ابحث برقم الشبكة أو اسم العميل أو الهاتف',
      'add_node': 'إضافة نقطة', 'edit': 'تعديل', 'delete': 'حذف', 'save': 'حفظ', 'cancel': 'إلغاء',
      'street_router': 'راوتر شارع (صندوق مقاوم للماء)', 'home_router': 'راوتر منزل',
      'network_number': 'رقم الشبكة', 'router_type': 'نوع الراوتر', 'router_ip': 'عنوان IP للراوتر',
      'username': 'اسم المستخدم', 'router_password': 'كلمة مرور الراوتر', 'device_title': 'عنوان الجهاز',
      'customer_name': 'اسم العميل', 'customer_phone': 'رقم الهاتف', 'ip_details': 'IP / تفاصيل (اختياري)',
      'latitude': 'خط العرض', 'longitude': 'خط الطول', 'navigate': 'الملاحة', 'required': 'هذا الحقل مطلوب',
      'settings': 'الإعدادات', 'language': 'اللغة', 'backup': 'النسخ الاحتياطي والمشاركة',
      'export_plain': 'تصدير نسخة احتياطية (JSON)', 'export_encrypted': 'تصدير نسخة مشفّرة',
      'import_backup': 'استيراد نسخة احتياطية', 'passphrase': 'عبارة المرور',
      'passphrase_hint': 'اتركها فارغة لتصدير ملف غير مشفّر',
      'import_summary': 'تمت الإضافة: {a} • التحديث: {u} • التخطي: {s}',
      'wrong_passphrase': 'عبارة المرور خاطئة أو الملف تالف', 'invalid_file': 'ملف غير صالح',
      'export_failed': 'فشل التصدير', 'delete_confirm': 'هل تريد حذف هذه النقطة؟',
      'no_results': 'لا توجد نتائج', 'copied': 'تم النسخ', 'invalid_ip': 'عنوان IP غير صالح',
      'signed_in_as': 'مسجّل الدخول كـ', 'data_private': 'بياناتك خاصة بحسابك فقط.',
      'err_credentials': 'البريد أو كلمة المرور غير صحيحة', 'err_exists': 'هذا البريد مسجّل مسبقاً',
      'err_weak': 'كلمة المرور ضعيفة (6 أحرف على الأقل)', 'err_network': 'لا يوجد اتصال بالإنترنت',
      'err_generic': 'حدث خطأ، حاول مجدداً', 'mismatch': 'كلمتا المرور غير متطابقتين',
      'type_street': 'بنية تحتية', 'type_home': 'منزل', 'location_hint': 'اضغط مطولاً على الخريطة لإضافة نقطة',
    },
    'en': {
      'app_name': 'NetMap Yemen',
      'login': 'Sign in', 'register': 'Create account', 'email': 'Email',
      'password': 'Password', 'confirm': 'Confirm password',
      'no_account': "No account? Register", 'have_account': 'Have an account? Sign in',
      'logout': 'Sign out', 'search_hint': 'Search network no., customer or phone',
      'add_node': 'Add node', 'edit': 'Edit', 'delete': 'Delete', 'save': 'Save', 'cancel': 'Cancel',
      'street_router': 'Street Router (Waterproof Box)', 'home_router': 'Home Router',
      'network_number': 'Network Number', 'router_type': 'Router Type', 'router_ip': 'Router IP Address',
      'username': 'Username', 'router_password': 'Router Password', 'device_title': 'Device Title / Address',
      'customer_name': 'Customer Name', 'customer_phone': 'Customer Phone', 'ip_details': 'Router IP / Details (optional)',
      'latitude': 'Latitude', 'longitude': 'Longitude', 'navigate': 'Navigate', 'required': 'This field is required',
      'settings': 'Settings', 'language': 'Language', 'backup': 'Backup & Sharing',
      'export_plain': 'Export backup (JSON)', 'export_encrypted': 'Export encrypted backup',
      'import_backup': 'Import backup', 'passphrase': 'Passphrase',
      'passphrase_hint': 'Leave empty for an unencrypted file',
      'import_summary': 'Added: {a} • Updated: {u} • Skipped: {s}',
      'wrong_passphrase': 'Wrong passphrase or corrupted file', 'invalid_file': 'Invalid file',
      'export_failed': 'Export failed', 'delete_confirm': 'Delete this node?',
      'no_results': 'No results', 'copied': 'Copied', 'invalid_ip': 'Invalid IP address',
      'signed_in_as': 'Signed in as', 'data_private': 'Your data is visible only to your account.',
      'err_credentials': 'Wrong email or password', 'err_exists': 'Email already registered',
      'err_weak': 'Weak password (min 6 characters)', 'err_network': 'No internet connection',
      'err_generic': 'Something went wrong, try again', 'mismatch': 'Passwords do not match',
      'type_street': 'Infrastructure', 'type_home': 'Home', 'location_hint': 'Long-press the map to add a node',
    },
    'es': {
      'app_name': 'NetMap Yemen',
      'login': 'Iniciar sesión', 'register': 'Crear cuenta', 'email': 'Correo electrónico',
      'password': 'Contraseña', 'confirm': 'Confirmar contraseña',
      'no_account': '¿Sin cuenta? Regístrate', 'have_account': '¿Ya tienes cuenta? Inicia sesión',
      'logout': 'Cerrar sesión', 'search_hint': 'Buscar nº de red, cliente o teléfono',
      'add_node': 'Añadir nodo', 'edit': 'Editar', 'delete': 'Eliminar', 'save': 'Guardar', 'cancel': 'Cancelar',
      'street_router': 'Router de calle (caja estanca)', 'home_router': 'Router doméstico',
      'network_number': 'Número de red', 'router_type': 'Tipo de router', 'router_ip': 'Dirección IP del router',
      'username': 'Usuario', 'router_password': 'Contraseña del router', 'device_title': 'Título / dirección del equipo',
      'customer_name': 'Nombre del cliente', 'customer_phone': 'Teléfono del cliente', 'ip_details': 'IP / detalles (opcional)',
      'latitude': 'Latitud', 'longitude': 'Longitud', 'navigate': 'Navegar', 'required': 'Campo obligatorio',
      'settings': 'Ajustes', 'language': 'Idioma', 'backup': 'Copia de seguridad y compartir',
      'export_plain': 'Exportar copia (JSON)', 'export_encrypted': 'Exportar copia cifrada',
      'import_backup': 'Importar copia', 'passphrase': 'Frase de contraseña',
      'passphrase_hint': 'Déjala vacía para un archivo sin cifrar',
      'import_summary': 'Añadidos: {a} • Actualizados: {u} • Omitidos: {s}',
      'wrong_passphrase': 'Frase incorrecta o archivo dañado', 'invalid_file': 'Archivo no válido',
      'export_failed': 'Error al exportar', 'delete_confirm': '¿Eliminar este nodo?',
      'no_results': 'Sin resultados', 'copied': 'Copiado', 'invalid_ip': 'IP no válida',
      'signed_in_as': 'Sesión iniciada como', 'data_private': 'Tus datos solo son visibles para tu cuenta.',
      'err_credentials': 'Correo o contraseña incorrectos', 'err_exists': 'El correo ya está registrado',
      'err_weak': 'Contraseña débil (mín. 6 caracteres)', 'err_network': 'Sin conexión a internet',
      'err_generic': 'Algo salió mal, inténtalo de nuevo', 'mismatch': 'Las contraseñas no coinciden',
      'type_street': 'Infraestructura', 'type_home': 'Hogar', 'location_hint': 'Mantén pulsado el mapa para añadir un nodo',
    },
    'fr': {
      'app_name': 'NetMap Yemen',
      'login': 'Se connecter', 'register': 'Créer un compte', 'email': 'E-mail',
      'password': 'Mot de passe', 'confirm': 'Confirmer le mot de passe',
      'no_account': "Pas de compte ? Inscrivez-vous", 'have_account': 'Déjà un compte ? Connectez-vous',
      'logout': 'Se déconnecter', 'search_hint': 'Rechercher n° réseau, client ou téléphone',
      'add_node': 'Ajouter un nœud', 'edit': 'Modifier', 'delete': 'Supprimer', 'save': 'Enregistrer', 'cancel': 'Annuler',
      'street_router': 'Routeur de rue (boîtier étanche)', 'home_router': 'Routeur domestique',
      'network_number': 'Numéro de réseau', 'router_type': 'Type de routeur', 'router_ip': 'Adresse IP du routeur',
      'username': "Nom d'utilisateur", 'router_password': 'Mot de passe du routeur', 'device_title': "Titre / adresse de l'appareil",
      'customer_name': 'Nom du client', 'customer_phone': 'Téléphone du client', 'ip_details': 'IP / détails (facultatif)',
      'latitude': 'Latitude', 'longitude': 'Longitude', 'navigate': 'Naviguer', 'required': 'Champ obligatoire',
      'settings': 'Paramètres', 'language': 'Langue', 'backup': 'Sauvegarde et partage',
      'export_plain': 'Exporter la sauvegarde (JSON)', 'export_encrypted': 'Exporter une sauvegarde chiffrée',
      'import_backup': 'Importer une sauvegarde', 'passphrase': 'Phrase secrète',
      'passphrase_hint': 'Laisser vide pour un fichier non chiffré',
      'import_summary': 'Ajoutés : {a} • Mis à jour : {u} • Ignorés : {s}',
      'wrong_passphrase': 'Phrase incorrecte ou fichier corrompu', 'invalid_file': 'Fichier invalide',
      'export_failed': "Échec de l'export", 'delete_confirm': 'Supprimer ce nœud ?',
      'no_results': 'Aucun résultat', 'copied': 'Copié', 'invalid_ip': 'Adresse IP invalide',
      'signed_in_as': 'Connecté en tant que', 'data_private': 'Vos données ne sont visibles que par votre compte.',
      'err_credentials': 'E-mail ou mot de passe incorrect', 'err_exists': 'E-mail déjà enregistré',
      'err_weak': 'Mot de passe faible (6 caractères min.)', 'err_network': 'Pas de connexion internet',
      'err_generic': "Une erreur s'est produite, réessayez", 'mismatch': 'Les mots de passe ne correspondent pas',
      'type_street': 'Infrastructure', 'type_home': 'Maison', 'location_hint': 'Appui long sur la carte pour ajouter un nœud',
    },
  };
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();
  @override
  bool isSupported(Locale l) => S.supported.any((s) => s.languageCode == l.languageCode);
  @override
  Future<S> load(Locale l) async => S(l);
  @override
  bool shouldReload(_SDelegate old) => false;
}
