import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Callers can lookup localized strings using an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.localizationsDelegates()`
/// in their app's `localizationsDelegates` list, and the i18n translations
/// for each supported locale in a separate `.arb` file in `lib/l10n`.
abstract class AppLocalizations {
  String get appTitle;
  String get welcome;
  String get signIn;
  String get signUp;
  String get email;
  String get password;
  String get forgotPassword;
  String get createAccount;
  String get dashboard;
  String get logout;
  String get loading;
  String get error;
  String get success;
  String get cancel;
  String get submit;
  String get next;
  String get previous;
  String get confirmPassword;
  String get passwordMismatch;
  String get invalidEmail;
  String get emailRequired;
  String get passwordRequired;
  String get agreeTerms;
  String get terms;
  String get privacy;
  String get fullName;
  String get phone;
  String get address;
  String get city;
  String get country;
  String get save;
  String get edit;
  String get delete;
  String get update;
  String get search;
  String get filter;
  String get sort;
  String get settings;
  String get language;
  String get profile;
  String get welcomeBack;
  String get logInToCampus;
  String get emailAddress;
  String get login;
  String get dontHaveAccount;
  String get forgotYourPassword;
  String get enterEmailToReset;
  String get sendCode;
  String get verificationCode;
  String get enterCode;
  String get resetPassword;
  String get dashboardContraventions;
  String get refresh;
  String get back;
  String get infractions;
  String get total;
  String get pending;
  String get resolved;
  String get classWithoutFollow;
  String get accept;
  String get reject;
  String get infractions_form;
  String get step;
  String get motifInfraction;
  String get identifyResident;
  String get roomNumber;
  String get selectProperty;
  String get hello;
  String get online;
  String get today;
  String get thisWeek;
  String get myLatestInfractions;
  String get newInfraction;
  String get home;
  String get editProfile;
  String get username;
  String get currentPassword;
  String get newPassword;
  String get saveChanges;
  String get chooseFromGallery;
  String get takeAPhoto;
  String get passwordChanged;
  String get failedToChangePassword;

  /// `en` locale.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];
}

/// Implementation of [AppLocalizations] for the English locale.
class _AppLocalizationsEn extends AppLocalizations {
  _AppLocalizationsEn();

  @override
  String get appTitle => 'CampusGuard';

  @override
  String get welcome => 'Welcome';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get agreeTerms => 'I agree to the terms and conditions';

  @override
  String get terms => 'Terms of Service';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get country => 'Country';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get logInToCampus => 'Log in to Campus';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get forgotYourPassword => 'Forgot your password?';

  @override
  String get enterEmailToReset => 'Enter your email to reset password';

  @override
  String get sendCode => 'Send Code';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterCode => 'Enter Code';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get dashboardContraventions => 'Dashboard - Contraventions';

  @override
  String get refresh => 'Refresh';

  @override
  String get back => 'Back';

  @override
  String get infractions => 'Infractions';

  @override
  String get total => 'Total';

  @override
  String get pending => 'Pending';

  @override
  String get resolved => 'Resolved';

  @override
  String get classWithoutFollow => 'Class without follow-up';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get infractions_form => 'Infractions Form';

  @override
  String get step => 'Step';

  @override
  String get motifInfraction => 'Reason for Infraction';

  @override
  String get identifyResident => 'Identify Resident';

  @override
  String get roomNumber => 'Room Number';

  @override
  String get selectProperty => 'Select Property';

  @override
  String get hello => 'Hello';

  @override
  String get online => 'Online';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get myLatestInfractions => 'My Latest Infractions';

  @override
  String get newInfraction => 'New Infraction';

  @override
  String get home => 'Home';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get username => 'Username';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get failedToChangePassword => 'Failed to change password';
}

/// Implementation of [AppLocalizations] for the French locale.
class _AppLocalizationsFr extends AppLocalizations {
  _AppLocalizationsFr();

  @override
  String get appTitle => 'CampusGuard';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get signIn => 'Connexion';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get logout => 'Déconnexion';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get cancel => 'Annuler';

  @override
  String get submit => 'Soumettre';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get invalidEmail => 'Adresse email invalide';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get agreeTerms => 'J\'accepte les conditions d\'utilisation';

  @override
  String get terms => 'Conditions d\'utilisation';

  @override
  String get privacy => 'Politique de confidentialité';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phone => 'Téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get country => 'Pays';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get profile => 'Profil';

  @override
  String get welcomeBack => 'Bienvenue à nouveau';

  @override
  String get logInToCampus => 'Connectez-vous au Campus';

  @override
  String get emailAddress => 'Adresse Email';

  @override
  String get login => 'Connexion';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte?';

  @override
  String get forgotYourPassword => 'Vous avez oublié votre mot de passe?';

  @override
  String get enterEmailToReset => 'Entrez votre email pour réinitialiser le mot de passe';

  @override
  String get sendCode => 'Envoyer le Code';

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get enterCode => 'Entrer le Code';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get dashboardContraventions => 'Tableau de bord - Contraventions';

  @override
  String get refresh => 'Actualiser';

  @override
  String get back => 'Retour';

  @override
  String get infractions => 'Infractions';

  @override
  String get total => 'Total';

  @override
  String get pending => 'En attente';

  @override
  String get resolved => 'Résolu';

  @override
  String get classWithoutFollow => 'Classe sans suivi';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Rejeter';

  @override
  String get infractions_form => 'Formulaire d\'infractions';

  @override
  String get step => 'Étape';

  @override
  String get motifInfraction => 'Raison de l\'infraction';

  @override
  String get identifyResident => 'Identifier le résident';

  @override
  String get roomNumber => 'Numéro de chambre';

  @override
  String get selectProperty => 'Sélectionner une propriété';

  @override
  String get hello => 'Bonjour';

  @override
  String get online => 'En ligne';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get myLatestInfractions => 'Mes dernières infractions';

  @override
  String get newInfraction => 'Nouvelle infraction';

  @override
  String get home => 'Accueil';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get chooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get passwordChanged => 'Mot de passe changé';

  @override
  String get failedToChangePassword => 'Impossible de changer le mot de passe';
}

/// Implementation of [AppLocalizations] for the Arabic locale.
class _AppLocalizationsAr extends AppLocalizations {
  _AppLocalizationsAr();

  @override
  String get appTitle => 'حراس الحرم';

  @override
  String get welcome => 'أهلا وسهلا';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get dashboard => 'لوحة المعلومات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get invalidEmail => 'عنوان بريد إلكتروني غير صحيح';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get agreeTerms => 'أوافق على شروط الخدمة والشروط';

  @override
  String get terms => 'شروط الخدمة';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phone => 'الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get city => 'المدينة';

  @override
  String get country => 'الدولة';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get update => 'تحديث';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get welcomeBack => 'أهلا بعودتك';

  @override
  String get logInToCampus => 'تسجيل الدخول إلى الحرم الجامعي';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get login => 'دخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get forgotYourPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get enterEmailToReset => 'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get enterCode => 'أدخل الرمز';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get dashboardContraventions => 'لوحة المعلومات - المخالفات';

  @override
  String get refresh => 'تحديث';

  @override
  String get back => 'رجوع';

  @override
  String get infractions => 'المخالفات';

  @override
  String get total => 'الإجمالي';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get resolved => 'تم حلها';

  @override
  String get classWithoutFollow => 'فئة بدون متابعة';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get infractions_form => 'نموذج المخالفات';

  @override
  String get step => 'خطوة';

  @override
  String get motifInfraction => 'سبب المخالفة';

  @override
  String get identifyResident => 'تحديد الساكن';

  @override
  String get roomNumber => 'رقم الغرفة';

  @override
  String get selectProperty => 'اختر الممتلكات';

  @override
  String get hello => 'مرحبا';

  @override
  String get online => 'متصل';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get myLatestInfractions => 'أحدث مخالفاتي';

  @override
  String get newInfraction => 'مخالفة جديدة';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة مرور جديدة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get takeAPhoto => 'التقط صورة';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get failedToChangePassword => 'فشل تغيير كلمة المرور';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return _loadLocale(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;

  Future<AppLocalizations> _loadLocale(Locale locale) {
    String lang = locale.languageCode;
    if (lang == 'fr') {
      return Future.value(_AppLocalizationsFr());
    } else if (lang == 'ar') {
      return Future.value(_AppLocalizationsAr());
    }
    return Future.value(_AppLocalizationsEn());
  }
}
