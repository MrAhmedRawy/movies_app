import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/onboarding_model.dart';
import '../../l10n/app_localizations.dart';
import 'custom_button.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingPage({
    super.key,
    required this.model,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(model.image, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    model.gradiantColor.withValues(alpha: 0.7),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFirstScreenContent(context),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(model.image, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            model.gradiantColor.withValues(alpha: 0.2),
                            AppColors.black,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 240.h),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildRoundedBoxContent(context),
        ),
      ],
    );
  }

  Widget _buildFirstScreenContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLocalizedText(context, model.title),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _getLocalizedText(context, model.subtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: _getLocalizedText(context, 'exploreNow'),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedBoxContent(BuildContext context) {
    bool isLast = index == total - 1;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 280.h),
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLocalizedText(context, model.title),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (model.subtitle.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              _getLocalizedText(context, model.subtitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
          SizedBox(height: 32.h),
          CustomButton(
            text: isLast
                ? _getLocalizedText(context, 'finish')
                : _getLocalizedText(context, 'next'),
            onPressed: onNext,
          ),
          if (index > 1) ...[
            SizedBox(height: 16.h),
            CustomButton(
              text: _getLocalizedText(context, 'back'),
              onPressed: onBack,
              isYellow: false,
            ),
          ],
        ],
      ),
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final local = AppLocalizations.of(context)!;
    switch (key) {
      case 'onboardingTitle1':
        return local.onboardingTitle1;
      case 'onboardingSubTitle1':
        return local.onboardingSubTitle1;
      case 'discoverMovies':
        return local.discoverMovies;
      case 'discoverMoviesDesc':
        return local.discoverMoviesDesc;
      case 'exploreAllGenres':
        return local.exploreAllGenres;
      case 'exploreAllGenresDesc':
        return local.exploreAllGenresDesc;
      case 'createWatchLists':
        return local.createWatchLists;
      case 'createWatchListsDesc':
        return local.createWatchListsDesc;
      case 'rateReviewLearn':
        return local.rateReviewLearn;
      case 'rateReviewLearnDesc':
        return local.rateReviewLearnDesc;
      case 'startWatchingNow':
        return local.startWatchingNow;
      case 'exploreNow':
        return local.exploreNow;
      case 'next':
        return local.next;
      case 'back':
        return local.back;
      case 'finish':
        return local.finish;
      default:
        return "";
    }
  }
}
