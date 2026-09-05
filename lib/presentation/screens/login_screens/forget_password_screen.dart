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

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        final local = AppLocalizations.of(context)!;
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(local.passwordResetSent)),
          );
          // 1 second delay before navigating back
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) Navigator.pop(context);
          });
        } else if (state is AuthError) {
          String message = state.message;
          if (message == "user-not-found") {
            message = local.userNotFound;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.forgetPassword.replaceFirst('?', '').trim(),
              style: const TextStyle(color: AppColors.yellow),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 40.h),
                            Image.asset(
                              AppImages.forgotPassword,
                              width: double.infinity,
                              height: 300.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 40.h),
                            CustomTextField(
                              hintText: AppLocalizations.of(context)!.email,
                              prefixIcon: Icons.email,
                              controller: emailController,
                            ),
                            SizedBox(height: 30.h),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator(color: AppColors.yellow));
                                }
                                return CustomButton(
                                  text: AppLocalizations.of(context)!.verifyEmail,
                                  onPressed: () {
                                    final email = emailController.text.trim();
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
                                    context.read<AuthCubit>().resetPassword(email);
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
