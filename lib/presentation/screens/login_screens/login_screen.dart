import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/language_toggle.dart';
import '../onboarding.dart';
import 'forget_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
          );
        } else if (state is AuthError) {
          final local = AppLocalizations.of(context)!;
          String message = state.message;
          if (message == "wrong-email-or-password") {
            message = local.wrongEmailOrPassword;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  Image.asset(AppImages.appIcon, width: 121.w),
                  SizedBox(height: 50.h),
                  CustomTextField(
                    hintText: AppLocalizations.of(context)!.email,
                    prefixIcon: Icons.email,
                    controller: emailController,
                  ),
                  SizedBox(height: 20.h),
                  CustomTextField(
                    hintText: AppLocalizations.of(context)!.password,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    controller: passwordController,
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgetPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgetPassword,
                        style: TextStyle(color: AppColors.yellow),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                            child: CircularProgressIndicator(color: AppColors.yellow));
                      }
                      return CustomButton(
                        text: AppLocalizations.of(context)!.login,
                        onPressed: () {
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          final local = AppLocalizations.of(context)!;

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(local.emailEmpty)),
                            );
                            return;
                          }
                          if (!Validators.isValidEmail(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(local.emailInvalid)),
                            );
                            return;
                          }
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(local.passwordEmpty)),
                            );
                            return;
                          }

                          context.read<AuthCubit>().loginWithEmail(email, password);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dontHaveAccount,
                        style: TextStyle(color: AppColors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.createOne,
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 92.96.w,
                        height: 1.12.h,
                        color: AppColors.yellow,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          AppLocalizations.of(context)!.or,
                          style: TextStyle(color: AppColors.yellow),
                        ),
                      ),
                      Container(
                        width: 92.96.w,
                        height: 1.12.h,
                        color: AppColors.yellow,
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  CustomButton(
                    text: AppLocalizations.of(context)!.loginWithGoogle,
                    prefixIcon: Image.asset(
                      AppImages.googleIcon,
                      width: 24.w,
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().loginWithGoogle();
                    },
                  ),
                  SizedBox(height: 30.h),
                  const LanguageToggle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
