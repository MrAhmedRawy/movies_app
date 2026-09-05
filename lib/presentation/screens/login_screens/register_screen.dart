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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> avatars = [
    AppImages.avtr01,
    AppImages.avtr02,
    AppImages.avtr03,
    AppImages.avtr04,
    AppImages.avtr05,
    AppImages.avtr06,
    AppImages.avtr07,
    AppImages.avtr08,
    AppImages.avtr09,
  ];

  late PageController _avatarController;
  int _selectedAvatarIndex = 1;

  @override
  void initState() {
    super.initState();
    _avatarController = PageController(
      viewportFraction: 0.35,
      initialPage: _selectedAvatarIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Onboarding()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
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
              AppLocalizations.of(context)!.register,
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
                            _buildAvatarSelector(),
                            SizedBox(height: 8.h),
                            Text(
                              AppLocalizations.of(context)!.avatar,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            CustomTextField(
                              hintText: AppLocalizations.of(context)!.name,
                              prefixIcon: Icons.badge,
                              controller: nameController,
                            ),
                            SizedBox(height: 20.h),
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
                            SizedBox(height: 20.h),
                            CustomTextField(
                              hintText: AppLocalizations.of(context)!.confirmPassword,
                              prefixIcon: Icons.lock,
                              isPassword: true,
                              controller: confirmPasswordController,
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              hintText: AppLocalizations.of(context)!.phoneNumber,
                              prefixIcon: Icons.phone,
                              controller: phoneController,
                            ),
                            const Spacer(),
                            SizedBox(height: 20.h),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator(color: AppColors.yellow));
                                }
                                return CustomButton(
                                  text: AppLocalizations.of(context)!.createAccount,
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    final email = emailController.text.trim();
                                    final password = passwordController.text;
                                    final confirmPassword = confirmPasswordController.text;
                                    final phone = phoneController.text.trim();
                                    final local = AppLocalizations.of(context)!;

                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(local.nameEmpty)),
                                      );
                                      return;
                                    }
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
                                    if (password != confirmPassword) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(local.passwordsNotMatch)),
                                      );
                                      return;
                                    }
                                    if (phone.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(local.phoneEmpty)),
                                      );
                                      return;
                                    }

                                    context.read<AuthCubit>().register(
                                          name: name,
                                          email: email,
                                          password: password,
                                          phone: phone,
                                          avatar: avatars[_selectedAvatarIndex],
                                        );
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.alreadyHaveAccount,
                                  style: const TextStyle(color: AppColors.white),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                    style: const TextStyle(
                                      color: AppColors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            const LanguageToggle(),
                            SizedBox(height: 24.h),
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

  Widget _buildAvatarSelector() {
    return SizedBox(
      height: 150.h,
      child: PageView.builder(
        controller: _avatarController,
        itemCount: avatars.length,
        onPageChanged: (index) {
          setState(() {
            _selectedAvatarIndex = index;
          });
        },
        itemBuilder: (context, index) {
          bool isSelected = index == _selectedAvatarIndex;
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 120.w : 70.w,
              height: isSelected ? 120.h : 70.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.yellow, width: 3)
                    : null,
                image: DecorationImage(
                  image: AssetImage(avatars[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }
}
