import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tekne_demirbas/common_widgets/async_value_ui.dart';
import 'package:tekne_demirbas/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:tekne_demirbas/features/authentication/presentation/widgets/common_text_field.dart';
import 'package:tekne_demirbas/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:tekne_demirbas/l10n/app_locale.dart';
import 'package:tekne_demirbas/l10n/app_translations.dart';
import 'package:tekne_demirbas/l10n/locale_provider.dart';
import 'package:tekne_demirbas/routes/routes.dart';
import 'package:tekne_demirbas/utils/appstyles.dart';
import 'package:tekne_demirbas/utils/size_config.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  ConsumerState createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailEditingController = TextEditingController();
  final _passwordController = TextEditingController();

  void _validateDetails() async {
    String email = _emailEditingController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.t(context, 'emailOrPasswordEmpty'),
            style: Appstyles.normalTextStyle.copyWith(color: Colors.red),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Önce oda seçimini temizle
      ref.read(selectedRoomProvider.notifier).clear();
      
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Başarılı giriş, room selection'a yönlendir
      if (mounted) {
        context.go('/roomSelection');
      }
    } catch (e) {
      // Hata zaten showAlertDialogOnError ile gösterilecek
    }
  }

  @override
  void dispose() {
    _emailEditingController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    final currentLocale = ref.watch(localeProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const SizedBox.shrink(),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DropdownButton<AppLocale>(
                value: currentAppLocale,
                underline: const SizedBox.shrink(),
                dropdownColor: Appstyles.white,
                items: AppLocale.values
                    .map((appLocale) => DropdownMenuItem<AppLocale>(
                          value: appLocale,
                          child: Text(
                            appLocale.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Appstyles.primaryBlue,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (appLocale) async {
                  if (appLocale != null) {
                    await ref.read(localeProvider.notifier).setLocale(appLocale);
                  }
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: Appstyles.lightOceanGradient,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.getProportionateWidth(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon Area
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Appstyles.white,
                        shape: BoxShape.circle,
                        boxShadow: Appstyles.mediumShadow,
                      ),
                      child: const Icon(
                        Icons.sailing,
                        size: 64,
                        color: Appstyles.primaryBlue,
                      ),
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(32)),
                    Text(
                      AppTranslations.t(context, 'welcome'),
                      style: Appstyles.headingTextStyle.copyWith(
                        color: Appstyles.primaryBlue,
                      ),
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(8)),
                    Text(
                      AppTranslations.t(context, 'signInSubtitle'),
                      style: Appstyles.subtitleTextStyle,
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(32)),
                    CommonTextField(
                      hintText: AppTranslations.t(context, 'emailHint'),
                      textInputType: TextInputType.emailAddress,
                      obscureText: false,
                      controller: _emailEditingController,
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(16)),
                    CommonTextField(
                      hintText: AppTranslations.t(context, 'password'),
                      textInputType: TextInputType.text,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(32)),
                    Container(
                      width: double.infinity,
                      height: SizeConfig.getProportionateHeight(56),
                      decoration: BoxDecoration(
                        gradient: Appstyles.oceanGradient,
                        borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
                        boxShadow: Appstyles.mediumShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: state.isLoading ? null : _validateDetails,
                          borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
                          child: Container(
                            alignment: Alignment.center,
                            child: state.isLoading
                                ? const CircularProgressIndicator(color: Appstyles.white)
                                : Text(
                                    AppTranslations.t(context, 'signIn'),
                                    style: Appstyles.titleTextStyle.copyWith(
                                      color: Appstyles.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTranslations.t(context, 'noAccount'),
                          style: Appstyles.normalTextStyle,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            context.goNamed(AppRoutes.register.name);
                          },
                          child: Text(
                            AppTranslations.t(context, 'registerLink'),
                            style: Appstyles.normalTextStyle.copyWith(
                              color: Appstyles.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
