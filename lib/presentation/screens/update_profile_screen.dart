import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../logic/cubits/auth/auth_cubit.dart';
import '../../logic/cubits/auth/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screens/login_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UpdateProfileScreen({super.key, required this.userData});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late String selectedAvatar;

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['name']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    final avatar = widget.userData['avatar'] as String?;
    selectedAvatar = (avatar == null || avatar.isEmpty) ? AppImages.avtr01 : avatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282A28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 15.h,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              final avatar = avatars[index];
              final isSelected = avatar == selectedAvatar;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAvatar = avatar;
                  });
                  Navigator.pop(context);
                },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      border: isSelected ? Border.all(color: AppColors.yellow, width: 2) : null,
                      color: isSelected ? AppColors.yellow.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: avatar.startsWith('http')
                          ? Image.network(avatar, fit: BoxFit.cover)
                          : Image.asset(avatar, fit: BoxFit.cover),
                    ),
                  ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserDataLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pick Avatar',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      GestureDetector(
                        onTap: _showAvatarPicker,
                        child: CircleAvatar(
                          radius: 78.r,
                          backgroundColor: AppColors.yellow,
                          child: CircleAvatar(
                            radius: 75.r,
                            backgroundColor: AppColors.darkGray,
                            backgroundImage: selectedAvatar.startsWith('http')
                                ? NetworkImage(selectedAvatar)
                                : (selectedAvatar.isNotEmpty
                                    ? AssetImage(selectedAvatar) as ImageProvider
                                    : null),
                            child: (selectedAvatar.isEmpty)
                                ? Icon(Icons.person, color: Colors.white, size: 50.sp)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      CustomTextField(
                        hintText: 'Name',
                        prefixIcon: Icons.person,
                        controller: nameController,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        hintText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        controller: phoneController,
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthCubit>().resetPassword(widget.userData['email']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset link sent to your email')),
                            );
                          },
                          child: Text(
                            'Reset Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Delete Account',
                      backgroundColor: AppColors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF282A28),
                            title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthCubit>().deleteAccount();
                                },
                                child: const Text('Delete', style: TextStyle(color: AppColors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: 'Update Data',
                      onPressed: () {
                        context.read<AuthCubit>().updateProfile(
                              name: nameController.text,
                              phone: phoneController.text,
                              avatar: selectedAvatar,
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
