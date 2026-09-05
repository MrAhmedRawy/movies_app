import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isYellow;
  final Widget? prefixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isYellow = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isYellow ? AppColors.yellow : Colors.transparent,
          side: isYellow ? null : const BorderSide(color: AppColors.yellow, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              SizedBox(width: 10.w),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isYellow ? AppColors.black : AppColors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
