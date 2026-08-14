import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../models/profile.dart';

class LicenseLoginPage extends StatefulWidget {
  const LicenseLoginPage({
    super.key,
    required this.authRepository,
    required this.onLoginSuccess,
  });

  final AuthRepository authRepository;
  final ValueChanged<Profile?> onLoginSuccess;

  @override
  State<LicenseLoginPage> createState() => _LicenseLoginPageState();
}

class _LicenseLoginPageState extends State<LicenseLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final profile = await widget.authRepository.login(
        _licenseController.text.trim().toUpperCase(),
      );
      if (!mounted) return;
      widget.onLoginSuccess(profile);
    } on AuthException catch (error) {
      _showError(error.message);
    } on DioException catch (error) {
      _showError(_dioMessage(error));
    } catch (_) {
      _showError('ارتباط با سرویس ورود برقرار نشد. دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _dioMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 404 || status == 401 || status == 403) {
      return 'لایسنس معتبر نیست یا دسترسی آن فعال نیست.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.';
    }
    return 'دریافت نشست با خطا مواجه شد.';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.local_taxi_rounded,
                          size: 40,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'ورود به حساب',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'برای دریافت نشست، لایسنس خود را وارد کنید.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _licenseController,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'License Key',
                          hintText: 'TAPSI-XXXX-XXXX',
                          prefixIcon: Icon(Icons.key_rounded),
                        ),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          final license = value?.trim().toUpperCase() ?? '';
                          if (license.isEmpty) {
                            return 'لایسنس را وارد کنید.';
                          }
                          if (!RegExp(r'^TAPSI-[A-Z0-9]{4}-[A-Z0-9]{4}$')
                              .hasMatch(license)) {
                            return 'فرمت لایسنس باید TAPSI-XXXX-XXXX باشد.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('ورود'),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'نشست شما در حافظه امن دستگاه ذخیره می‌شود.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}