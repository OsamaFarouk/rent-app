// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Rent App';

  @override
  String get foundationReady => 'Project Foundation Ready';

  @override
  String get discoveryMarketplace => 'منصة الاكتشاف للإنتاج والسينما والإعلام.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navEquipment => 'المعدات';

  @override
  String get navProfessionals => 'المحترفون';

  @override
  String get navRentalHouses => 'مكاتب التأجير';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get homeSubtitle => 'استكشف معدات التصوير والمحترفين المبدعين';

  @override
  String get equipmentSubtitle => 'معدات الإنتاج والتصوير';

  @override
  String get professionalsSubtitle => 'المحترفون المبدعون';

  @override
  String get rentalHousesSubtitle => 'مكاتب وشركات تأجير المعدات';

  @override
  String get featuredRentalHouses => 'مكاتب التأجير المميزة';

  @override
  String get searchRentalHousesHint => 'البحث في مكاتب التأجير والشركات...';

  @override
  String get individualOwner => 'مالك فردي';

  @override
  String get creativeProfessional => 'محترف مبدع';

  @override
  String get rentalHouseOwner => 'مكتب تأجير';

  @override
  String get equipmentFromThisRentalHouse => 'معدات من هذا المكتب';

  @override
  String get noRentalHousesTitle => 'لم يتم العثور على مكاتب تأجير';

  @override
  String get noRentalHousesDesc => 'لا توجد مكاتب تأجير متاحة حالياً.';

  @override
  String get favoritesSubtitle => 'المعدات والمحترفون المحفوظون';

  @override
  String get profileSubtitle => 'الحساب والإعدادات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get showAll => 'عرض الكل';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get locationCairo => 'القاهرة، مصر';

  @override
  String get locationMaadi => 'المعادي، القاهرة';

  @override
  String get location6thOctober => '٦ أكتوبر';

  @override
  String get perDay => ' / يوم';

  @override
  String fromPrice(String price) {
    return 'من $price ج.م';
  }

  @override
  String get verified => 'موثوق';

  @override
  String get verifiedProvider => 'مكتب موثوق';

  @override
  String get verifiedProfessional => 'محترف موثوق';

  @override
  String get businessVerified => 'مكتب موثوق';

  @override
  String get contactVerified => 'اتصال موثوق';

  @override
  String get availableTomorrow => 'متاح غداً';

  @override
  String get availableNow => 'متاح الآن';

  @override
  String updatedHoursAgo(String hours) {
    return 'تم التحديث منذ $hours س';
  }

  @override
  String yearsExperience(String years) {
    return 'خبرة $years+ سنوات';
  }

  @override
  String get searchHomeHint => 'ابحث عن معدات، محترفين، ماركات...';

  @override
  String get searchEquipmentHint => 'ابحث عن كاميرات، إضاءة، عدسات...';

  @override
  String get searchProfessionalsHint => 'ابحث عن محترفين';

  @override
  String get browseCategories => ' الفئات';

  @override
  String get tabEquipment => 'المعدات';

  @override
  String get tabProfessionals => 'المحترفون';

  @override
  String get catAll => 'الكل';

  @override
  String get catCameras => 'كاميرات';

  @override
  String get catLenses => 'عدسات';

  @override
  String get catLighting => 'إضاءة';

  @override
  String get catAudio => 'صوتيات';

  @override
  String get catGripSupport => 'جريبو وحركة';

  @override
  String get catDrones => 'درون وحركة';

  @override
  String get catDirectors => 'مخرجون';

  @override
  String get catCinematographers => 'مديرو تصوير';

  @override
  String get catEditors => 'مونتير';

  @override
  String get catPhotographers => 'مصورون';

  @override
  String get catColorists => 'مصححو ألوان';

  @override
  String get catSoundEngineers => 'مهندسو صوت';

  @override
  String get catStylists => 'ديكور واستايلنج';

  @override
  String get catProduction => 'إنتاج';

  @override
  String get catPostProduction => 'ما بعد الإنتاج';

  @override
  String get catSound => 'صوت';

  @override
  String get catArtStyling => 'ديكور واستايلنج';

  @override
  String get featuredEquipment => 'معدات مميزة';

  @override
  String get featuredProfessionals => 'محترفون متميزون';

  @override
  String get quickSearchEquipment => 'المعدات';

  @override
  String get quickSearchProfessionals => 'المحترفون';

  @override
  String get noFavoritesTitle => 'لا توجد مفضلة بعد';

  @override
  String get noFavoritesDesc =>
      'احفظ المعدات والمحترفين الذين تريد العثور عليهم بسرعة لاحقاً.';

  @override
  String get explore => 'استكشف';

  @override
  String get yourProfile => 'ملفك الشخصي';

  @override
  String get profileDesc =>
      'سجل الدخول لحفظ المفضلة، إدارة قوائمك، وعرض ملف أعمالك الاحترافي.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get myListings => 'قوائمي';

  @override
  String get myEquipment => 'عداتي ومعداتي';

  @override
  String get addEquipment => 'إضافة معدة جديدة';

  @override
  String get equipmentSubmittedSuccess =>
      'تم إرسال المعدة للمراجعة والاعتماد بنجاح.';

  @override
  String get noEquipmentTitle => 'لا توجد معدات مضافة بعد';

  @override
  String get noEquipmentDesc =>
      'أضف معدات الإنتاج والتصوير الخاصة بك لبدء تأجيرها.';

  @override
  String get myProfessionalProfile => 'الملف المهني';

  @override
  String get portfolio => 'معرض الأعمال';

  @override
  String get pendingReview => 'قيد المراجعة';

  @override
  String get approved => 'معتمد';

  @override
  String get rejected => 'مرفوض';

  @override
  String get suspended => 'معلق';

  @override
  String get savedItems => 'العناصر المحفوظة';

  @override
  String get contacts => 'جهات الاتصال';

  @override
  String get settings => 'الإعدادات';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get fullNameLabel => 'الاسم بالكامل';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get whatsappLabel => 'رقم الواتساب';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get areaLabel => 'المنطقة / الحي';

  @override
  String get profileTypeLabel => 'نوع الحساب';

  @override
  String get profileTypeIndividual => 'فردي';

  @override
  String get profileTypeBusiness => 'مكتب / شركة';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get emailValidation => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get passwordValidation => 'يجب أن تكون كلمة المرور ٦ أحرف على الأقل.';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get fullNameValidation => 'يرجى إدخال الاسم بالكامل.';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String get checkEmailVerification =>
      'تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني لتأكيد حسابك.';

  @override
  String get invalidCredentialsError =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get userAlreadyExistsError => 'هذا البريد الإلكتروني مسجل بالفعل.';

  @override
  String get signupDisabledError =>
      'التسجيل معطل حالياً. يرجى الاتصال بالدعم الفني.';

  @override
  String get rateLimitError =>
      'طلبات كثيرة جداً. يرجى الانتظار قليلاً والمحاولة مرة أخرى.';

  @override
  String get networkError =>
      'خطأ في الاتصال بالحساب. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get unknownAuthError =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get profileSetupTitle => 'إعداد الحساب';

  @override
  String get profileSetupHeading => 'من يمثل هذا الحساب؟';

  @override
  String get profileSetupSubtitle =>
      'اختر كيف تريد أن تظهر على رينت اب. يمكنك تغيير هذا الإعداد في أي وقت من ملفك الشخصي.';

  @override
  String get individualOptionTitle => 'فردي';

  @override
  String get individualOptionDesc => 'مستقل، محترف مبدع، أو صاحب معدات فردي.';

  @override
  String get businessOptionTitle => 'مكتب / شركة';

  @override
  String get businessOptionDesc =>
      'مكتب تأجير معدات، شركة إنتاج، ستوديو، أو شركة أخرى.';

  @override
  String get continueButton => 'متابعة';

  @override
  String get changePhoto => 'تغيير الصورة الشخصية';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get sameAsMobile => 'رقم الواتساب هو نفسه رقم الهاتف';

  @override
  String get invalidPhone => 'يرجى إدخال رقم هاتف صحيح.';

  @override
  String get governorateLabel => 'المحافظة / المدينة';

  @override
  String get districtLabel => 'المنطقة / الحي';

  @override
  String get myActivitySection => 'نشاطي';

  @override
  String get accountSection => 'الحساب';

  @override
  String get myEquipmentSubtitle => 'إدارة قائمة معداتك';

  @override
  String get proProfileSubtitle => 'إدارة خدماتك ومعرض أعمالك';

  @override
  String get settingsSubtitle => 'الحساب، اللغة والتفضيلات';

  @override
  String get profileCompletionHeader => 'أكمل ملفك الشخصي';

  @override
  String get completeProfilePrompt => 'أضف البيانات المفقودة لزيادة ظهور ملفك';

  @override
  String get businessLogo => 'شعار الشركة / المكتب';

  @override
  String get businessNameLabel => 'اسم الشركة / المكتب';

  @override
  String get businessNameValidation => 'يرجى إدخال اسم الشركة / المكتب';

  @override
  String get contactPersonLabel => 'اسم شخص التواصل';

  @override
  String get fullAddressLabel => 'العنوان التفصيلي للشركة';

  @override
  String get businessDescriptionLabel => 'وصف قصير للشركة';

  @override
  String get websiteUrlLabel => 'الموقع الإلكتروني';

  @override
  String get workingHoursLabel => 'ساعات العمل';

  @override
  String get workingDaysLabel => 'أيام العمل';

  @override
  String get openTimeLabel => 'وقت الفتح';

  @override
  String get closeTimeLabel => 'وقت الإغلاق';

  @override
  String get accountTypeLabel => 'نوع الحساب';

  @override
  String get personalOptionTitle => 'شخصي';

  @override
  String get personalOptionDesc =>
      'ابحث عن المعدات والمحترفين ومكاتب التأجير. يمكنك أيضاً إضافة معداتك الخاصة.';

  @override
  String get professionalOptionTitle => 'محترف';

  @override
  String get professionalOptionDesc =>
      'أنشئ ملفاً شخصياً ومعرض أعمال محترف، واكتشف المعدات ومكاتب التأجير، وأضف معداتك.';

  @override
  String get profileTypePersonal => 'شخصي';

  @override
  String get profileTypeProfessional => 'محترف';

  @override
  String get myBusinessProfile => 'مكتبي / شركتي';

  @override
  String get businessProfileSubtitle => 'إدارة بيانات مكتب التأجير والتفاصيل';

  @override
  String get accessDeniedProOnly =>
      'يمكن فقط للحسابات المحترفة إنشاء أو إدارة ملف شخصي محترف.';

  @override
  String get accessDeniedBusinessOnly =>
      'يمكن فقط لحسابات الشركات ومكاتب التأجير إنشاء أو إدارة ملف الشركة.';

  @override
  String get pendingApproval => 'قيد المراجعة';

  @override
  String get approvedStatus => 'مقبول';

  @override
  String get contactSupportToChangeType =>
      'تم تحديد نوع الحساب أثناء الإعداد الأول ولا يمكن تغييره من هنا. تواصل مع الدعم الفني للتغيير.';

  @override
  String get accountDeletedMessage => 'حسابك لم يعد متاحاً.';

  @override
  String get accountSuspendedMessage =>
      'تم تعليق حسابك. يرجى الاتصال بالدعم الفني إذا كنت تعتقد أن هذا خطأ.';

  @override
  String get accountVerificationFailedMessage =>
      'لم نتمكن من التحقق من حسابك. يرجى المحاولة مرة أخرى.';

  @override
  String get sessionExpiredMessage =>
      'انتهت جلسة تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get offlineMessage =>
      'أنت غير متصل بالإنترنت. سنتحقق من حسابك عند إعادة الاتصال.';

  @override
  String get atLeastOneContactRequired =>
      'يرجى إضافة رقم تواصل واحد على الأقل: الهاتف أو واتساب.';

  @override
  String get selectAccountTypeValidation => 'يرجى اختيار نوع الحساب للمتابعة.';
}
