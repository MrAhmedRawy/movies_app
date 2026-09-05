import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie_model.dart';
import '../../logic/cubits/movies/movies_cubit.dart';

import '../screens/home_screen.dart';
import '../screens/movie_details_screen.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final double? width;
  final double? height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedGenre = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movieId: movie.id),
          ),
        );

        if (context.mounted) {
          if (selectedGenre != null) {
            // Check if we are currently inside a MovieDetailsScreen
            final isInsideDetails = context.findAncestorWidgetOfExactType<MovieDetailsScreen>() != null;
            
            if (isInsideDetails) {
              // Pass the genre up to the parent details screen or home screen
              Navigator.pop(context, selectedGenre);
            } else {
              // We are at the home/search/browse level, navigate to tab
              HomeScreen.navigateToGenre(selectedGenre);
            }
          } else {
            // Restore home data when coming back to home screen
            context.read<MoviesCubit>().restoreHomeData();
          }
        }
      },
      child: Container(
        width: width ?? 145.w,
        height: height ?? 210.h,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: CachedNetworkImage(
                imageUrl: movie.mediumCoverImage ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF121312).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      movie.rating.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.star, color: AppColors.yellow, size: 14.sp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
