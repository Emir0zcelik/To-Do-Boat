import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ancyra_sailing/common_widgets/async_value_ui.dart';
import 'package:ancyra_sailing/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:ancyra_sailing/features/authentication/presentation/widgets/auth_app_bar.dart';
import 'package:ancyra_sailing/features/authentication/presentation/widgets/common_text_field.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/routes/routes.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  ConsumerState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailEditingController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _validateDetails() async {
    String name = _nameController.text.trim();
    String email = _emailEditingController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.t(context, 'allFieldsRequired'),
            style: Appstyles.normalTextStyle.copyWith(color: Colors.red),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.t(context, 'passwordsNoMatch'),
            style: Appstyles.normalTextStyle.copyWith(color: Colors.red),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.t(context, 'passwordMinLength'),
            style: Appstyles.normalTextStyle.copyWith(color: Colors.red),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: name,
        );

    if (result && mounted) {
      // Email verification mesajı göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppTranslations.t(context, 'emailVerification')),
          content: Text(AppTranslations.t(context, 'emailVerificationMessage')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.goNamed(AppRoutes.signIn.name);
              },
              child: Text(AppTranslations.t(context, 'ok')),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailEditingController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

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
                    SizedBox(height: SizeConfig.getProportionateHeight(20)),
                    // Logo/Icon Area
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Appstyles.white,
                        shape: BoxShape.circle,
                        boxShadow: Appstyles.mediumShadow,
                      ),
                      child: const Icon(
                        Icons.anchor,
                        size: 64,
                        color: Appstyles.primaryBlue,
                      ),
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(32)),
                    Text(
                      AppTranslations.t(context, 'createAccount'),
                      style: Appstyles.headingTextStyle.copyWith(
                        color: Appstyles.primaryBlue,
                      ),
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(8)),
                    Text(
                      AppTranslations.t(context, 'createAccountSubtitle'),
                      style: Appstyles.subtitleTextStyle,
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(32)),
                    CommonTextField(
                      hintText: AppTranslations.t(context, 'name'),
                      textInputType: TextInputType.text,
                      obscureText: false,
                      controller: _nameController,
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(16)),
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
                    SizedBox(height: SizeConfig.getProportionateHeight(16)),
                    CommonTextField(
                      hintText: AppTranslations.t(context, 'passwordRepeat'),
                      textInputType: TextInputType.text,
                      obscureText: true,
                      controller: _confirmPasswordController,
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
                                    AppTranslations.t(context, 'register'),
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
                          AppTranslations.t(context, 'hasAccount'),
                          style: Appstyles.normalTextStyle,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            context.goNamed(AppRoutes.signIn.name);
                          },
                          child: Text(
                            AppTranslations.t(context, 'signInLink'),
                            style: Appstyles.normalTextStyle.copyWith(
                              color: Appstyles.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.getProportionateHeight(20)),
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
