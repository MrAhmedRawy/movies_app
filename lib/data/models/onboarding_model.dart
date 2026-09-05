import 'dart:ui';
import 'package:movies_app/core/constants/app_colors.dart';
import 'package:movies_app/core/constants/app_images.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;
  final Color gradiantColor;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.gradiantColor,
  });

  static List<OnboardingModel> onboardingList = [
    OnboardingModel(
      image: AppImages.moviesPostersGroup,
      title: 'onboardingTitle1',
      subtitle: 'onboardingSubTitle1',
      gradiantColor: AppColors.black,
    ),
    // ironman 02
    OnboardingModel(
      image: AppImages.ironMan,
      title: 'discoverMovies',
      subtitle: 'discoverMoviesDesc',
      gradiantColor: AppColors.darkBlue,
    ),
    //oppenheimer 03
    OnboardingModel(
      image: AppImages.oppenheimer,
      title: 'exploreAllGenres',
      subtitle: 'exploreAllGenresDesc',
      gradiantColor: AppColors.darkRed,
    ),
    //bad boys 4
    OnboardingModel(
      image: AppImages.badBoys,
      title: 'createWatchLists',
      subtitle: 'createWatchListsDesc',
      gradiantColor: AppColors.darkPurple,
    ),
    //strange 05
    OnboardingModel(
      image: AppImages.drStrange,
      title: 'rateReviewLearn',
      subtitle: 'rateReviewLearnDesc',
      gradiantColor: AppColors.maroon,
    ),
    //1917 06
    OnboardingModel(
      image: AppImages.movie1917,
      title: 'startWatchingNow',
      subtitle: '',
      gradiantColor: AppColors.charcoal,
    ),
  ];
}
