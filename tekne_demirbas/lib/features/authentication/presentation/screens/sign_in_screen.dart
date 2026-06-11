import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ancyra_sailing/common_widgets/async_value_ui.dart';
import 'package:ancyra_sailing/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:ancyra_sailing/features/authentication/presentation/widgets/auth_app_bar.dart';
import 'package:ancyra_sailing/features/authentication/presentation/widgets/common_text_field.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/routes/routes.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

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

    return SafeArea(
      child: Scaffold(
        appBar: const AuthAppBar(),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: Appstyles.mediumShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icon/Ancyra_icon.png',
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                        ),
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
