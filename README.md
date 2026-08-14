# Tapsi Client (Flutter)

یک کلاینت Flutter مبتنی بر درخواست‌های مستقیم HTTP برای استفاده مجاز از حساب تپسی.
این پروژه از WebView استفاده نمی‌کند.

## اجرا

```bash
cd tapsi_flutter
flutter create . --platforms=android
flutter pub get
flutter run
```

اگر پوشه `android` از قبل وجود داشته باشد، اجرای `flutter create` لازم نیست.

## جریان ورود

1. کاربر لایسنس با قالب `TAPSI-XXXX-XXXX` را وارد می‌کند.
2. برنامه از endpoint سرویس لایسنس نشست را دریافت می‌کند.
3. مقدار `data.cookies` داخل `FlutterSecureStorage` ذخیره می‌شود.
4. Interceptor دایو، کوکی و هدرهای لازم را فقط برای درخواست‌های API تپسی اضافه می‌کند.
5. صفحه داشبورد از `GET /user` اطلاعات نام و شماره موبایل را نمایش می‌دهد.

## ساخت APK در GitHub Actions

Workflow در مسیر `.github/workflows/build-apk.yml` با هر Push به شاخه
`main` یا `master` و همچنین اجرای دستی فعال می‌شود. پس از موفقیت، فایل
`app-release.apk` در بخش **Artifacts** همان اجرای GitHub Actions قابل دریافت است.

## نکته امنیتی

لایسنس و کوکی را در کد، لاگ‌ها یا Issueهای عمومی قرار ندهید. استفاده از endpointها،
کوکی‌ها و هدرهای سرویس باید مطابق مجوز و شرایط استفاده سرویس باشد.