/// Customer-facing copy for browsing, saved products and product reviews.
abstract final class StoreBrowseTranslations {
  static Map<String, String> get ar => {for (final key in _copy.keys) key: key};
  static Map<String, String> get en => {
    for (final entry in _copy.entries) entry.key: entry.value.$1,
  };
  static Map<String, String> get he => {
    for (final entry in _copy.entries) entry.key: entry.value.$2,
  };

  static const _copy = <String, (String, String)>{
    'أدخل رمز الخصم': ('Enter discount code', 'הזנת קוד הנחה'),
    'أضف المنتجات التي تريد الاحتفاظ بها لإتمام الطلب لاحقًا.': (
      'Save products here to order them later.',
      'אפשר לשמור כאן מוצרים ולהזמין אותם מאוחר יותר.',
    ),
    'أضف للسلة': ('Add to cart', 'הוספה לסל'),
    'أقسام فرعية': ('Subcategories', 'קטגוריות משנה'),
    'إتمام الطلب': ('Checkout', 'להשלמת ההזמנה'),
    'إرسال التقييم': ('Submit review', 'שליחת ביקורת'),
    'إرسال التقييم يتطلب حساب عميل نشط.': (
      'An active customer account is required to submit a review.',
      'נדרש חשבון לקוח פעיל לשליחת ביקורת.',
    ),
    'إرسال الطلب': ('Place order', 'ביצוע הזמנה'),
    'إعادة': ('Reset', 'איפוס'),
    'إعادة المحاولة': ('Try again', 'ניסיון נוסף'),
    'إغلاق': ('Close', 'סגירה'),
    'إغلاق البحث': ('Close search', 'סגירת החיפוש'),
    'إلغاء': ('Cancel', 'ביטול'),
    'إنقاص الكمية': ('Decrease quantity', 'הקטנת הכמות'),
    'ابحث عن قسم...': ('Search categories…', 'חיפוש קטגוריות…'),
    'ابحث عن مدينة': ('Search cities', 'חיפוש עיר'),
    'اختر المدينة': ('Choose a city', 'בחירת עיר'),
    'اضغط على رمز القلب لحفظ المنتجات هنا.': (
      'Tap the heart to save products here.',
      'לחצו על הלב כדי לשמור כאן מוצרים.',
    ),
    'الأقسام': ('Categories', 'קטגוריות'),
    'الإشعارات': ('Notifications', 'התראות'),
    'التقييمات': ('Reviews', 'ביקורות'),
    'الرجوع': ('Back', 'חזרה'),
    'السعر': ('Price', 'מחיר'),
    'العروض والخصومات فقط': ('Offers and discounts only', 'מבצעים והנחות בלבד'),
    'الكل': ('All', 'הכול'),
    'المفضلة فارغة': ('No saved products', 'אין מוצרים שמורים'),
    'المنتجات': ('Products', 'מוצרים'),
    'المنتجات المتاحة للشراء فقط': (
      'Available products only',
      'מוצרים זמינים לרכישה בלבד',
    ),
    'المنتجات المفضلة': ('Saved products', 'מוצרים שמורים'),
    'بحث': ('Search', 'חיפוש'),
    'تتبع الشحنة': ('Track shipment', 'מעקב משלוח'),
    'تحديث التقييم': ('Update review', 'עדכון ביקורת'),
    'تحقق من الاتصال ثم أعد المحاولة.': (
      'Check your connection and try again.',
      'יש לבדוק את החיבור ולנסות שוב.',
    ),
    'تحقق من نطاق السعر المدخل.': (
      'Check the price range you entered.',
      'יש לבדוק את טווח המחירים שהוזן.',
    ),
    'تراجع': ('Undo', 'ביטול הפעולה'),
    'ترتيب': ('Sort', 'מיון'),
    'تسجيل الدخول': ('Sign in', 'כניסה'),
    'تصفية المنتجات': ('Filter products', 'סינון מוצרים'),
    'تصفية (@count)': ('Filter (@count)', 'סינון (@count)'),
    'تطبيق': ('Apply', 'החלה'),
    'تطبيق الفلاتر': ('Apply filters', 'החלת סינון'),
    'تعذر إرسال التقييم.': (
      'Could not submit the review.',
      'לא ניתן לשלוח ביקורת.',
    ),
    'تعذر تحديث التقييم.': (
      'Could not update the review.',
      'לא ניתן לעדכן ביקורת.',
    ),
    'تعذر تحميل المفضلة': (
      'Could not load saved products',
      'לא ניתן לטעון מוצרים שמורים',
    ),
    'تعليق اختياري': ('Optional comment', 'תגובה לבחירה'),
    'تقييمك منشور': ('Your review is published', 'הביקורת שלך פורסמה'),
    'تقييمي': ('My review', 'הביקורת שלי'),
    'تم إرسال تقييمك للمراجعة': (
      'Your review was sent for moderation',
      'הביקורת נשלחה לבדיקה',
    ),
    'تم تحديث تقييمك وهو قيد المراجعة.': (
      'Your updated review is awaiting moderation.',
      'הביקורת עודכנה וממתינה לבדיקה.',
    ),
    'تم حفظ التقييم.': ('Review saved.', 'הביקורת נשמרה.'),
    'تم حفظ التقييم، لكن تعذر تحديث حالته. أعد المحاولة.': (
      'Your review was saved, but its status could not be refreshed. Try again.',
      'הביקורת נשמרה, אך לא ניתן לרענן את מצבה. יש לנסות שוב.',
    ),
    'تمت الإضافة للسلة': ('Added to cart', 'נוסף לסל'),
    'جاري التحميل': ('Loading', 'טעינה'),
    'حالة التقييم غير معروفة': (
      'Review status unavailable',
      'מצב הביקורת אינו זמין',
    ),
    'حذف': ('Delete', 'מחיקה'),
    'حذف المنتج؟': ('Remove product?', 'להסיר את המוצר?'),
    'حساب بائع': ('Seller account', 'חשבון מוכר'),
    'خيارات السلة': ('Cart options', 'אפשרויות הסל'),
    'زيادة الكمية': ('Increase quantity', 'הגדלת הכמות'),
    'سجّل الدخول لإرسال تقييمك.': (
      'Sign in to submit a review.',
      'יש להיכנס כדי לשלוח ביקורת.',
    ),
    'يمكن طلب الإلغاء حسب حالة الطلب. سيبقى طلبك دون تغيير حتى تأكيد الإلغاء.': (
      'Cancellation is available when the current order status allows it. Your order stays unchanged until cancellation is confirmed.',
      'אפשר לבטל בהתאם למצב ההזמנה. ההזמנה תישאר ללא שינוי עד לאישור הביטול.',
    ),
    'سيتم حذف جميع المنتجات المحتفظ بها من السلة.': (
      'All saved products will be removed from the cart.',
      'כל המוצרים השמורים יוסרו מהסל.',
    ),
    'سيتم حذف هذا الخيار فقط من السلة.': (
      'Only this option will be removed from the cart.',
      'רק אפשרות זו תוסר מהסל.',
    ),
    'طلب إلغاء الطلب': ('Request cancellation', 'בקשת ביטול הזמנה'),
    'طلب إلغاء الطلب؟': ('Request order cancellation?', 'לבקש ביטול הזמנה?'),
    'عرض شبكة': ('Grid view', 'תצוגת רשת'),
    'عرض قائمة': ('List view', 'תצוגת רשימה'),
    'عميل تجزئة': ('Retail customer', 'לקוח קמעונאי'),
    'غير متوفر': ('Unavailable', 'לא זמין'),
    'فتح الملف الشخصي': ('Open profile', 'פתיחת הפרופיל'),
    'في السلة': ('In cart', 'בסל'),
    'قائمة المنتجات': ('Product list', 'רשימת מוצרים'),
    'كل جديد في مكان واحد': (
      'All your updates in one place',
      'כל העדכונים במקום אחד',
    ),
    'كوبون خصم': ('Discount code', 'קוד הנחה'),
    'لا توجد أقسام مطابقة': (
      'No matching categories',
      'לא נמצאו קטגוריות מתאימות',
    ),
    'لا توجد إشعارات غير مقروءة': (
      'No unread notifications',
      'אין התראות שלא נקראו',
    ),
    'لا توجد مدن مطابقة': ('No matching cities', 'לא נמצאו ערים מתאימות'),
    'لا توجد منتجات في هذا القسم': (
      'No products in this category',
      'אין מוצרים בקטגוריה זו',
    ),
    'لا يوجد تقييم شخصي.': (
      'You have not reviewed this product.',
      'עדיין לא כתבת ביקורת על מוצר זה.',
    ),
    'لم يتم قبول تقييمك': (
      'Your review was not accepted',
      'הביקורת שלך לא אושרה',
    ),
    'مسح': ('Clear', 'ניקוי'),
    'مسح البحث': ('Clear search', 'ניקוי החיפוש'),
    'مسح السلة': ('Clear cart', 'ריקון הסל'),
    'مسح السلة؟': ('Clear cart?', 'לרוקן את הסל?'),
    'مفعّل': ('Active', 'פעיל'),
    'ملء الشاشة': ('Fullscreen', 'מסך מלא'),
    'يتم التحقق من التوفر قبل الطلب': (
      'Availability is checked before ordering',
      'הזמינות נבדקת לפני ההזמנה',
    ),
    'يجب تسجيل الدخول أولاً.': ('Please sign in first.', 'יש להיכנס תחילה.'),
    'يلزم حساب عميل نشط.': (
      'An active customer account is required.',
      'נדרש חשבון לקוח פעיל.',
    ),
    'من': ('From', 'מ־'),
    'إلى': ('To', 'עד'),
    'الترتيب المقترح': ('Recommended', 'מומלץ'),
    'الأحدث أولاً': ('Newest first', 'החדשים ביותר'),
    'السعر: من الأقل للأعلى': ('Price: low to high', 'מחיר: מהנמוך לגבוה'),
    'السعر: من الأعلى للأقل': ('Price: high to low', 'מחיר: מהגבוה לנמוך'),
    'الاسم': ('Name', 'שם'),
    'ابحث عن المنتجات حسب السعر والتوفر والعروض.': (
      'Find products by price, availability and offers.',
      'חיפוש מוצרים לפי מחיר, זמינות ומבצעים.',
    ),
    '@count إشعار غير مقروء': (
      '@count unread notifications',
      '@count התראות שלא נקראו',
    ),
    'رمز المنتج: @code': ('Product code: @code', 'קוד מוצר: @code'),
    'الخيار: @option': ('Option: @option', 'אפשרות: @option'),
    'سلة المشتريات (@count)': ('Cart (@count)', 'סל הקניות (@count)'),
    'خصم @amount ₪. سيتم تأكيد الإجمالي عند إتمام الطلب.': (
      'Discount: @amount ₪. The total will be confirmed at checkout.',
      'הנחה: @amount ₪. הסכום הסופי יאושר בהשלמת ההזמנה.',
    ),
    '@rating من 5': ('@rating out of 5', '@rating מתוך 5'),
    'اختر تقييماً من 1 إلى 5.': (
      'Choose a rating from 1 to 5.',
      'יש לבחור דירוג בין 1 ל־5.',
    ),
    'التعليق يتجاوز 5000 حرف.': (
      'Your comment exceeds 5000 characters.',
      'התגובה חורגת מ־5000 תווים.',
    ),
    'انتهت الجلسة. سجّل الدخول ثم حاول مجددًا.': (
      'Your session expired. Sign in and try again.',
      'ההתחברות פגה. יש להיכנס ולנסות שוב.',
    ),
    'يلزم حساب عميل نشط لإرسال التقييم.': (
      'An active customer account is required to submit a review.',
      'נדרש חשבון לקוח פעיל לשליחת ביקורת.',
    ),
    'راجع التقييم والتعليق ثم حاول مجددًا.': (
      'Check your rating and comment, then try again.',
      'יש לבדוק את הדירוג והתגובה ולנסות שוב.',
    ),
    'تعذر إرسال التقييم. حاول مجددًا.': (
      'Could not submit your review. Try again.',
      'לא ניתן לשלוח ביקורת. יש לנסות שוב.',
    ),
    'تعذر تأكيد حالة التقييم. حاول مجددًا.': (
      'Could not confirm your review status. Try again.',
      'לא ניתן לאשר את מצב הביקורת. יש לנסות שוב.',
    ),
  };
}
