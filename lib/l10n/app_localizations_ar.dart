// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ماكرو كيتشن';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get setup => 'الإعداد';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get height => 'الطول';

  @override
  String get weight => 'الوزن';

  @override
  String get age => 'العمر';

  @override
  String get exerciseFrequency => 'تكرار التمارين';

  @override
  String get weightGoal => 'هدف الوزن';

  @override
  String get movement => 'النشاط الحركي';

  @override
  String get conditions => 'الحالات الصحية';

  @override
  String get allergies => 'الحساسية';

  @override
  String get calculate => 'احسب';

  @override
  String get home => 'الرئيسية';

  @override
  String get meals => 'الوجبات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get caloriesRemaining => 'السعرات المتبقية';

  @override
  String get weeklyProgress => 'التقدم الأسبوعي';

  @override
  String get mealHistory => 'سجل الوجبات';

  @override
  String get bmiProfile => 'ملف مؤشر كتلة الجسم';

  @override
  String get restaurantMenus => 'قوائم المطاعم';

  @override
  String get homeMeals => 'وجبات منزلية';

  @override
  String get recommended => 'موصى بها';

  @override
  String get allMeals => 'جميع الوجبات';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get calories => 'السعرات الحرارية';

  @override
  String get protein => 'البروتين';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get fat => 'الدهون';

  @override
  String get sodium => 'الصوديوم';

  @override
  String get sugar => 'السكر';

  @override
  String get fiber => 'الألياف';

  @override
  String get saturatedFat => 'الدهون المشبعة';

  @override
  String get language => 'اللغة';

  @override
  String get allergenWarning => 'تحتوي هذه الوجبة على مسببات حساسية لديك';

  @override
  String get highSodiumWarning => 'عالي الصوديوم — غير مناسب لضغط الدم المرتفع';

  @override
  String get highSugarWarning => 'عالي السكر — غير مناسب لمرضى السكري';

  @override
  String get noMealsFound => 'لا توجد وجبات.';

  @override
  String get completeBmiSetup =>
      'أكمل إعداد مؤشر كتلة الجسم للحصول على توصيات مخصصة.';

  @override
  String get homeMealPage => 'صفحة الوجبات المنزلية';

  @override
  String get kCal => 'سعر حراري';

  @override
  String get totalFat => 'إجمالي الدهون';

  @override
  String get noHomeMealsYet => 'لم يتم تسجيل أي وجبات منزلية بعد.';

  @override
  String get logAMeal => 'تسجيل وجبة';

  @override
  String get errorLoadingMeals => 'خطأ في تحميل الوجبات';

  @override
  String get deleteMealTitle => 'حذف الوجبة؟';

  @override
  String get deleteMealMessage => 'ستتم إزالة هذه الوجبة من سجلك.';

  @override
  String get editMeal => 'تعديل الوجبة';

  @override
  String get homeMeal => 'وجبة منزلية';

  @override
  String get titleField => 'العنوان';

  @override
  String get notes => 'ملاحظات';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get enterValidNumber => 'أدخل رقمًا صحيحًا';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get nutritionReport => 'تقرير التغذية';

  @override
  String helloUser(String name) {
    return 'مرحبًا، $name 👋';
  }

  @override
  String bmiSummary(String value, String goal) {
    return 'مؤشر كتلة الجسم: $value · $goal';
  }

  @override
  String get setupHint => 'أكمل الإعداد للحصول على توصيات';

  @override
  String get setupBmiNow => 'أكمل إعداد مؤشر كتلة الجسم';
}
