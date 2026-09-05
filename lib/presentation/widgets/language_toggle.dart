import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../logic/cubits/language/language_cubit.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        bool isEnglish = locale.languageCode == 'en';

        return GestureDetector(
          onTap: () {
            context.read<LanguageCubit>().changeLanguage(isEnglish ? 'ar' : 'en');
          },
          child: Container(
            width: 80.w,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.yellow, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.ltr, // Force flags to stay in place
              children: [
                _buildFlag(AppImages.us, isEnglish),
                _buildFlag(AppImages.eg, !isEnglish),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlag(String imagePath, bool isSelected) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.yellow : Colors.transparent,
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            imagePath,
            width: 24.w,
            height: 24.h,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
