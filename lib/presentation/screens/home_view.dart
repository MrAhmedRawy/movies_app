import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/movie_model.dart';
import '../../logic/cubits/movies/movies_cubit.dart';
import '../../logic/cubits/movies/movies_state.dart';
import '../widgets/movie_card.dart';

class HomeView extends StatefulWidget {
  final Function(String) onSeeMore;
  const HomeView({super.key, required this.onSeeMore});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7, initialPage: 0)
      ..addListener(() {
        if (_pageController.hasClients) {
          setState(() {
            _currentPage = _pageController.page!;
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return BlocBuilder<MoviesCubit, MoviesState>(
      buildWhen: (previous, current) =>
          current is HomeLoaded || current is HomeLoading || current is MoviesError,
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (state is HomeLoaded) {
          final currentHeroMovie = state.availableNow[_currentPage.round().clamp(0, state.availableNow.length - 1)];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 600.h,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: currentHeroMovie.largeCoverImage ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: Colors.black),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.7),
                                AppColors.black,
                                AppColors.black,
                              ],
                              stops: const [0.0, 0.5, 0.9, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildHeroSection(state.availableNow),
                  ],
                ),
                Container(
                  color: AppColors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Center(
                        child: Image.asset(
                          AppImages.watchNow,
                          width: 354.w,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ...state.categories.entries.map((entry) {
                        return _buildCategorySection(context, _getTranslatedGenre(entry.key, local), entry.value, local);
                      }),
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (state is MoviesError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        return Container();
      },
    );
  }

  Widget _buildHeroSection(List<MovieModel> availableNow) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: SizedBox(height: 10.h),
        ),
        Center(
          child: Image.asset(
            AppImages.availableNow,
            width: 267.w,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 380.h,
          child: PageView.builder(
            itemCount: availableNow.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              double scale = (1 - (index - _currentPage).abs() * 0.2).clamp(0.8, 1.0);
              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: MovieCard(
                    movie: availableNow[index],
                    width: 250.w,
                    height: 350.h,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<MovieModel> movies, AppLocalizations local) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => widget.onSeeMore(title),
              child: Row(
                children: [
                  Text(
                    local.seeMore,
                    style: TextStyle(color: AppColors.yellow, fontSize: 14.sp),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 12.sp),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 210.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movies[index]);
            },
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }

  String _getTranslatedGenre(String genre, AppLocalizations local) {
    switch (genre.toLowerCase()) {
      case 'action':
        return local.action;
      case 'adventure':
        return local.adventure;
      case 'animation':
        return local.animation;
      case 'biography':
        return local.biography;
      case 'comedy':
        return local.comedy;
      case 'crime':
        return local.crime;
      case 'documentary':
        return local.documentary;
      case 'drama':
        return local.drama;
      case 'family':
        return local.family;
      case 'fantasy':
        return local.fantasy;
      case 'history':
        return local.historyGenre;
      case 'horror':
        return local.horror;
      case 'music':
        return local.music;
      case 'musical':
        return local.musical;
      case 'mystery':
        return local.mystery;
      case 'news':
        return local.news;
      case 'romance':
        return local.romance;
      case 'sci-fi':
        return local.sciFi;
      case 'sport':
        return local.sport;
      case 'thriller':
        return local.thriller;
      case 'war':
        return local.war;
      case 'western':
        return local.western;
      default:
        return genre;
    }
  }
}
