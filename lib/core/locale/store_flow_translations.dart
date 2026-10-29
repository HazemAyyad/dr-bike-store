/// Customer-facing copy shared by account, address and checkout flows.
abstract final class StoreFlowTranslations {
  static Map<String, String> get ar => {for (final key in _copy.keys) key: key};
  static Map<String, String> get en => {
    for (final entry in _copy.entries) entry.key: entry.value.$1,
  };
  static Map<String, String> get he => {
    for (final entry in _copy.entries) entry.key: entry.value.$2,
  };

  static const _copy = <String, (String, String)>{
    'رجوع': ('Back', 'חזרה'),
    'مشاركة المنتج': ('Share product', 'שיתוף מוצר'),
    'رمز المنتج': ('Product code', 'קוד מוצר'),
    'تعذرت مشاركة المنتج': ('Unable to share product', 'לא ניתן לשתף את המוצר'),
    'اسأل الدعم عن هذا المنتج': (
      'Ask support about this product',
      'שאלה לתמיכה על המוצר',
    ),
    'عرض وكتابة التقييمات': ('Reviews', 'צפייה וכתיבת ביקורות'),
    'اللون': ('Color', 'צבע'),
    'مواصفات المنتج': ('Product specifications', 'מפרט המוצר'),
    'لم يتم توفير مواصفات إضافية لهذا المنتج.': (
      'No additional product specifications were provided.',
      'לא סופק מפרט נוסף למוצר זה.',
    ),
    'الشحن والضمان': ('Shipping and warranty', 'משלוח ואחריות'),
    'تفاصيل الشحن والضمان غير متوفرة لهذا المنتج.': (
      'Shipping and warranty details are unavailable for this product.',
      'פרטי משלוח ואחריות אינם זמינים למוצר זה.',
    ),
    'سياسة الإرجاع': ('Return policy', 'מדיניות החזרה'),
    'تفاصيل سياسة الإرجاع غير متوفرة لهذا المنتج.': (
      'Return policy details are unavailable for this product.',
      'פרטי מדיניות ההחזרה אינם זמינים למוצר זה.',
    ),
    'المعاينة متاحة، العارض التفاعلي غير متوفر': (
      'Preview available; interactive viewer unavailable',
      'תצוגה מקדימה זמינה; הצפייה האינטראקטיבית אינה זמינה',
    ),
    'أحد المنتجات غير متاح حاليًا للطلب عبر المتجر. يرجى تحديث السلة.': (
      'An item is currently unavailable. Please refresh your cart.',
      'אחד המוצרים אינו זמין כרגע. יש לרענן את הסל.',
    ),
    'أضف منتجًا صالحًا للسلة أولًا.': (
      'Add an available item to your cart first.',
      'יש להוסיף מוצר זמין לסל תחילה.',
    ),
    'اختر نوع الطلب': ('Choose order type', 'בחירת סוג הזמנה'),
    'اسم العنوان وتفاصيله ومنطقة التوصيل مطلوبة.': (
      'Enter the address name, details and delivery area.',
      'יש להזין שם כתובת, פרטים ואזור משלוח.',
    ),
    'تجزئة': ('Retail', 'קמעונאות'),
    'جملة': ('Wholesale', 'סיטונאות'),
    'تعذر إتمام الطلب. لم يتم تغيير السلة.': (
      'Could not complete the order. Your cart is saved.',
      'לא ניתן להשלים את ההזמנה. הסל נשמר.',
    ),
    'تعذر إرسال طلب الإلغاء. بقي الطلب دون تغيير.': (
      'Could not send the cancellation request. The order is unchanged.',
      'לא ניתן לשלוח בקשת ביטול. ההזמנה לא השתנתה.',
    ),
    'تعذر اعتماد بعض بيانات الطلب. راجع البيانات وحاول مجددًا.': (
      'Some order details could not be accepted. Review them and try again.',
      'חלק מפרטי ההזמנה לא התקבלו. יש לבדוק ולנסות שוב.',
    ),
    'تعذر تأكيد الطلب. يرجى إعادة المحاولة دون تغيير السلة.': (
      'Could not confirm the order. Retry without changing the cart.',
      'לא ניתן לאשר את ההזמנה. יש לנסות שוב ללא שינוי בסל.',
    ),
    'تعذر تحديث الصورة الشخصية': (
      'Could not update your profile photo.',
      'לא ניתן לעדכן את תמונת הפרופיל.',
    ),
    'تعذر تحديث بيانات حساب المتجر. يرجى المحاولة مرة أخرى.': (
      'Could not refresh your account. Please try again.',
      'לא ניתן לרענן את החשבון. יש לנסות שוב.',
    ),
    'تعذر تحميل الطلبات.': ('Could not load orders.', 'לא ניתן לטעון הזמנות.'),
    'تعذر تحميل العناوين المحفوظة.': (
      'Could not load saved addresses.',
      'לא ניתן לטעון כתובות שמורות.',
    ),
    'تعذر تحميل العناوين.': (
      'Could not load addresses.',
      'לא ניתן לטעון כתובות.',
    ),
    'تعذر تحميل بيانات الحساب': (
      'Could not load your account.',
      'לא ניתן לטעון את פרטי החשבון.',
    ),
    'تعذر تحميل قرى التوصيل.': (
      'Could not load delivery localities.',
      'לא ניתן לטעון יישובים למשלוח.',
    ),
    'تعذر تحميل مناطق التوصيل.': (
      'Could not load delivery areas.',
      'לא ניתן לטעון אזורי משלוח.',
    ),
    'تعذر تسجيل الخروج. حاول مجددًا.': (
      'Could not sign out. Please try again.',
      'לא ניתן להתנתק. יש לנסות שוב.',
    ),
    'تعذر تعطيل الحساب. لم يتم حذف جلستك.': (
      'Could not deactivate the account. You are still signed in.',
      'לא ניתן להשבית את החשבון. נשארת מחובר.',
    ),
    'تعذر حذف العنوان.': (
      'Could not delete the address.',
      'לא ניתן למחוק את הכתובת.',
    ),
    'تعذر حفظ العنوان.': (
      'Could not save the address.',
      'לא ניתן לשמור את הכתובת.',
    ),
    'تعذر حفظ بيانات الحساب': (
      'Could not save your account details.',
      'לא ניתן לשמור את פרטי החשבון.',
    ),
    'تعذر قراءة سجل الطلبات.': (
      'Could not read order history.',
      'לא ניתן לקרוא את היסטוריית ההזמנות.',
    ),
    'تم تحديث الصورة الشخصية': (
      'Profile photo updated.',
      'תמונת הפרופיל עודכנה.',
    ),
    'تم تحديث العنوان.': ('Address updated.', 'הכתובת עודכנה.'),
    'تم حذف العنوان.': ('Address deleted.', 'הכתובת נמחקה.'),
    'تمت إضافة العنوان بنجاح.': ('Address added.', 'הכתובת נוספה.'),
    'رفض الخادم طلب الإلغاء. بقي الطلب دون تغيير.': (
      'The cancellation request was declined. The order is unchanged.',
      'בקשת הביטול נדחתה. ההזמנה לא השתנתה.',
    ),
    'عدّل العنوان وحدد المدينة والقرية قبل اعتماده.': (
      'Edit the address and choose a city and locality first.',
      'יש לערוך את הכתובת ולבחור עיר ויישוב תחילה.',
    ),
    'قد يكون الطلب وصل إلى الخادم. أعد المحاولة للتحقق.': (
      'Your order may have been received. Retry to check its status.',
      'ייתכן שההזמנה התקבלה. יש לנסות שוב לבדיקת המצב.',
    ),
    'لا يوجد اتصال بالإنترنت. تحقق من الاتصال ثم أعد المحاولة.': (
      'No internet connection. Check your connection and retry.',
      'אין חיבור לאינטרנט. יש לבדוק את החיבור ולנסות שוב.',
    ),
    'لا يوجد حساب بيع معتمد مرتبط بحساب المتجر. يرجى التواصل مع الإدارة.': (
      'No approved purchasing account is linked. Please contact support.',
      'אין חשבון רכישה מאושר מקושר. יש לפנות לתמיכה.',
    ),
    'هذا العنوان غير مكتمل. عدّله وحدد المدينة والقرية.': (
      'This address is incomplete. Edit it and choose a city and locality.',
      'הכתובת אינה מלאה. יש לערוך אותה ולבחור עיר ויישוב.',
    ),
    'هل تريد تنفيذ الطلب كتجزئة أم جملة؟': (
      'Place a retail or wholesale order?',
      'להזמין בקמעונאות או בסיטונאות?',
    ),
    'وصل رد غير مكتمل. أعد المحاولة بنفس رقم المحاولة.': (
      'An incomplete reply was received. Retry this same order attempt.',
      'התקבלה תשובה חלקית. יש לנסות שוב את אותה הזמנה.',
    ),
    'يرجى استكمال العنوان والشحن ونوع الحساب.': (
      'Complete the address, delivery and account type.',
      'יש להשלים כתובת, משלוח וסוג חשבון.',
    ),
    '، ': (', ', ', '),
    'أضف عنوان المنزل أو العمل لاستخدامه لاحقًا.': (
      'Add a home or work address to use later.',
      'הוסף כתובת לבית או לעבודה לשימוש בהמשך.',
    ),
    'إجراءات الحساب': ('Account actions', 'פעולות בחשבון'),
    'إدارة': ('Manage', 'ניהול'),
    'إضافة عنوان': ('Add address', 'הוספת כתובת'),
    'إضافة عنوان جديد': ('Add a new address', 'הוספת כתובת חדשה'),
    'إعادة المحاولة': ('Retry', 'נסה שוב'),
    'إعدادات محلية': ('Device settings', 'הגדרות המכשיר'),
    'إلغاء': ('Cancel', 'ביטול'),
    'إنهاء الجلسة الحالية على هذا الجهاز.': (
      'Sign out on this device.',
      'התנתקות במכשיר זה.',
    ),
    'اختر عنوانًا محفوظًا': ('Choose a saved address', 'בחירת כתובת שמורה'),
    'اسأل سؤالاً عاماً أو تابع استفسارك عن منتج': (
      'Ask a question or follow up about a product',
      'שאל שאלה או עקוב אחר פנייה לגבי מוצר',
    ),
    'استخدامه كعنوان افتراضي': (
      'Use as default address',
      'הגדרה ככתובת ברירת מחדל',
    ),
    'اسم العنوان': ('Address label', 'שם הכתובת'),
    'افتراضي': ('Default', 'ברירת מחדל'),
    'اكتب تفاصيل عنوان التوصيل': (
      'Enter the full delivery address',
      'הזן את כתובת המשלוח המלאה',
    ),
    'اكتب عنوان التوصيل': ('Enter a delivery address', 'הזן כתובת למשלוח'),
    'الأسعار والتوفر ورسوم التوصيل النهائية يعتمدها الخادم عند الإرسال.': (
      'We will confirm prices, availability and shipping when you place your order.',
      'המחירים, הזמינות ודמי המשלוח יאושרו בעת ביצוע ההזמנה.',
    ),
    'الإعدادات': ('Settings', 'הגדרות'),
    'الاسم الكامل': ('Full name', 'שם מלא'),
    'التوصيل عبر Shiply': ('Delivery with Shiply', 'משלוח באמצעות Shiply'),
    'الدفع عند الاستلام': ('Cash on delivery', 'תשלום במזומן בעת המסירה'),
    'الدفع نقدًا عند الاستلام': ('Cash on delivery', 'תשלום במזומן בעת המסירה'),
    'الدفع: نقدًا عند الاستلام': (
      'Payment: cash on delivery',
      'תשלום: במזומן בעת המסירה',
    ),
    'العناوين': ('Addresses', 'כתובות'),
    'العناوين الشخصية': ('Saved addresses', 'כתובות שמורות'),
    'العنوان بالتفصيل': ('Full address', 'כתובת מלאה'),
    'القرية / المنطقة': ('Village / area', 'יישוב / אזור'),
    'القرية أو منطقة التوصيل': (
      'Village or delivery area',
      'יישוב או אזור משלוח',
    ),
    'اللغة': ('Language', 'שפה'),
    'المحادثة المباشرة مع الدعم': ('Chat with support', 'שיחה עם התמיכה'),
    'المدينة': ('City', 'עיר'),
    'المساعدة والدعم': ('Help and support', 'עזרה ותמיכה'),
    'المنزل': ('Home', 'בית'),
    'المنزل، العمل…': ('Home, work…', 'בית, עבודה…'),
    'الوضع الداكن': ('Dark mode', 'מצב כהה'),
    'بيانات الاتصال محفوظة في حسابك. يمكن تعديلها من الملف الشخصي.': (
      'Your contact details are saved in your account. Edit them from your profile.',
      'פרטי הקשר שמורים בחשבון. ניתן לערוך אותם בפרופיל.',
    ),
    'بيانات التواصل': ('Contact details', 'פרטי קשר'),
    'تأكيد': ('Confirm', 'אישור'),
    'تأكيد الطلب': ('Confirm order', 'אישור הזמנה'),
    'تأكيد وإنشاء الطلب': ('Place order', 'ביצוע הזמנה'),
    'تسجيل الخروج': ('Sign out', 'התנתקות'),
    'تصفح كضيف': ('Browse as guest', 'גלישה כאורח'),
    'تعديل': ('Edit', 'עריכה'),
    'تعديل العنوان': ('Edit address', 'עריכת כתובת'),
    'تعذر إتمام الطلب.': (
      'Your order could not be completed.',
      'לא ניתן להשלים את ההזמנה.',
    ),
    'تعذر إتمام الطلب. راجع البيانات وحاول مجددًا.': (
      'Check your order details and try again.',
      'בדוק את פרטי ההזמנה ונסה שוב.',
    ),
    'تعذر تحميل إجراءات الحساب. أعد تشغيل التطبيق وحاول مجددًا.': (
      'Account actions could not be loaded. Restart the app and retry.',
      'לא ניתן לטעון את פעולות החשבון. הפעל את היישומון מחדש ונסה שוב.',
    ),
    'تعذر تحميل البيانات': (
      'Could not load details',
      'לא ניתן לטעון את הפרטים',
    ),
    'تعذر تحميل الحساب': (
      'Could not load your account',
      'לא ניתן לטעון את החשבון',
    ),
    'تعذر فتح العناوين. أعد تشغيل التطبيق وحاول مجددًا.': (
      'Addresses could not be opened. Restart the app and retry.',
      'לא ניתן לפתוח את הכתובות. הפעל את היישומון מחדש ונסה שוב.',
    ),
    'تغيير الصورة الشخصية': ('Change profile photo', 'שינוי תמונת פרופיל'),
    'تكلفة الشحن الحالية': ('Current shipping cost', 'עלות המשלוח הנוכחית'),
    'تُحسب التكلفة من المنطقة المختارة': (
      'Cost depends on the selected area',
      'העלות מחושבת לפי האזור שנבחר',
    ),
    'جارٍ احتساب تكلفة الشحن': ('Calculating shipping', 'חישוב עלות המשלוח'),
    'جارٍ الحفظ…': ('Saving…', 'שמירה…'),
    'جارٍ تحميل مناطق التوصيل': ('Loading delivery areas', 'טעינת אזורי משלוח'),
    'حذف': ('Delete', 'מחיקה'),
    'حذف العنوان': ('Delete address', 'מחיקת כתובת'),
    'حذف/تعطيل الحساب': ('Deactivate account', 'השבתת חשבון'),
    'حساب بائع': ('Seller account', 'חשבון מוכר'),
    'حفظ التعديلات': ('Save changes', 'שמירת שינויים'),
    'حفظ العنوان': ('Save address', 'שמירת כתובת'),
    'حفظ بطاقات الدفع الرقمية غير متاح أو غير مهيأ حاليًا.': (
      'Saving payment cards is currently unavailable.',
      'שמירת כרטיסי תשלום אינה זמינה כרגע.',
    ),
    'راجع بيانات الطلب': ('Check order details', 'בדיקת פרטי ההזמנה'),
    'رقم الهاتف': ('Phone number', 'מספר טלפון'),
    'رقم هاتف بديل': ('Alternative phone number', 'מספר טלפון נוסף'),
    'طرق الدفع': ('Payment methods', 'אמצעי תשלום'),
    'طريقة الدفع': ('Payment method', 'אמצעי תשלום'),
    'طريقة الدفع المتاحة حاليًا': (
      'Currently available payment method',
      'אמצעי התשלום הזמין כרגע',
    ),
    'طريقة الدفع المتاحة في تطبيق المتجر': (
      'Available payment method',
      'אמצעי התשלום הזמין',
    ),
    'طريقة الشحن': ('Shipping method', 'אופן המשלוח'),
    'عميل تجزئة': ('Retail customer', 'לקוח קמעונאי'),
    'عنوان التوصيل': ('Delivery address', 'כתובת למשלוח'),
    'عنوان الحساب': ('Account address', 'כתובת החשבון'),
    'غير مكتمل للشحن': (
      'Incomplete delivery address',
      'כתובת המשלוח אינה מלאה',
    ),
    'غير مكتمل للشحن — عدّله قبل الاستخدام': (
      'Complete this address before using it',
      'יש להשלים את הכתובת לפני השימוש',
    ),
    'لا توجد عناوين محفوظة': ('No saved addresses', 'אין כתובות שמורות'),
    'لا يوجد اتصال بالإنترنت': ('No internet connection', 'אין חיבור לאינטרנט'),
    'متابعة الدفع': ('Continue to payment', 'המשך לתשלום'),
    'متابعة الشحن': ('Continue to shipping', 'המשך למשלוח'),
    'مراجعة الطلب': ('Review order', 'סקירת ההזמנה'),
    'ملخص الدفع': ('Payment summary', 'סיכום התשלום'),
    'ملخص الطلب': ('Order summary', 'סיכום ההזמנה'),
    'منطقة التوصيل': ('Delivery area', 'אזור המשלוח'),
    'نتيجة الطلب غير مؤكدة': (
      'Order confirmation pending',
      'אישור ההזמנה ממתין',
    ),
    'نوع الحساب': ('Account type', 'סוג החשבון'),
    'هذا الحقل مطلوب': ('This field is required', 'שדה חובה'),
    'يتم تعطيل الحساب على الخادم قبل حذف الجلسة.': (
      'Deactivate your account and sign out.',
      'השבתת החשבון והתנתקות.',
    ),
    'يُحفظ على هذا الجهاز': ('Saved on this device', 'נשמר במכשיר זה'),
    'هل تريد إنهاء الجلسة على هذا الجهاز؟': (
      'Sign out on this device?',
      'להתנתק במכשיר זה?',
    ),
    'سيُرسل الطلب إلى الخادم أولًا، ولن تُحذف جلستك إذا فشل الطلب.': (
      'Deactivate your account? You will stay signed in if the request fails.',
      'להשבית את החשבון? אם הבקשה תיכשל, ההפעלה תישמר.',
    ),
    'حدد المدينة ومنطقة التوصيل.': (
      'Choose a city and delivery area.',
      'בחר עיר ואזור משלוח.',
    ),
  };
}
