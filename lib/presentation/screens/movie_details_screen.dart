import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/movie_model.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/cubits/movies/movies_cubit.dart';
import '../../logic/cubits/movies/movies_state.dart';
import '../../logic/cubits/watchlist/watchlist_cubit.dart';
import '../../logic/cubits/watchlist/watchlist_state.dart';
import '../widgets/movie_card.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MoviesCubit>().fetchMovieDetails(widget.movieId);
    context.read<WatchlistCubit>().fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return BlocListener<WatchlistCubit, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocConsumer<MoviesCubit, MoviesState>(
          buildWhen: (previous, current) =>
              current is MovieDetailsLoaded ||
              current is MovieDetailsLoading ||
              current is MoviesError,
          listener: (context, state) {
            if (state is MovieDetailsLoaded) {
              context.read<WatchlistCubit>().addToHistory(state.movie);
            }
          },
          builder: (context, state) {
            if (state is MovieDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              );
            } else if (state is MovieDetailsLoaded) {
              final movie = state.movie;
              final suggestions = state.suggestions;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(movie),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          _buildWatchButton(local),
                          SizedBox(height: 20.h),
                          _buildStatsRow(movie),
                          SizedBox(height: 30.h),
                          _buildSectionTitle(local.screenshots),
                          _buildScreenShots(movie),
                          SizedBox(height: 30.h),
                          _buildSectionTitle(local.similar),
                          _buildSimilarMovies(suggestions),
                          SizedBox(height: 30.h),
                          _buildSectionTitle(local.summary),
                          Text(
                            movie.descriptionFull ?? movie.summary ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 30.h),
                          _buildSectionTitle(local.cast),
                          _buildCastList(movie.cast, local),
                          SizedBox(height: 30.h),
                          _buildSectionTitle(local.genres),
                          _buildGenresList(movie.genres, local),
                          SizedBox(height: 50.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is MoviesError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(MovieModel movie) {
    return Stack(
      children: [
        SizedBox(
          height: 600.h,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: movie.largeCoverImage ?? '',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  AppColors.black.withValues(alpha: 0.8),
                  AppColors.black,
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    BlocBuilder<WatchlistCubit, WatchlistState>(
                      builder: (context, state) {
                        final isBookmarked = context
                            .read<WatchlistCubit>()
                            .isInWatchlist(movie.id);
                        return IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? AppColors.yellow
                                : Colors.white,
                          ),
                          onPressed: () {
                            context.read<WatchlistCubit>().toggleWatchlist(
                              movie,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 350.h), // Spacer to push content down
            const Icon(
              Icons.play_circle_fill,
              color: AppColors.yellow,
              size: 80,
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              movie.year.toString(),
              style: TextStyle(color: Colors.white70, fontSize: 18.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatchButton(AppLocalizations local) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Text(
          local.watch,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(MovieModel movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          Icons.favorite,
          movie.likeCount?.toString() ?? '0',
          const Color(0xFFF6BD12),
        ),
        _buildStatItem(
          Icons.access_time,
          '${movie.runtime} min',
          const Color(0xFFF6BD12),
        ),
        _buildStatItem(
          Icons.star,
          movie.rating.toString(),
          const Color(0xFFF6BD12),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color iconColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF282A28),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScreenShots(MovieModel movie) {
    final screenshots = [
      movie.screenshot1,
      movie.screenshot2,
      movie.screenshot3,
    ].where((s) => s != null).toList();

    if (screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      children: screenshots
          .map(
            (url) => Container(
              margin: EdgeInsets.only(bottom: 16.h),
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSimilarMovies(List<MovieModel> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: suggestions.take(4).length,
      itemBuilder: (context, index) {
        return MovieCard(movie: suggestions[index]);
      },
    );
  }

  Widget _buildCastList(List<CastModel>? cast, AppLocalizations local) {
    if (cast == null || cast.isEmpty) return const SizedBox.shrink();
    return Column(
      children: cast
          .map(
            (c) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF282A28),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: c.urlSmallImage != null
                        ? CachedNetworkImageProvider(c.urlSmallImage!)
                        : null,
                    child: c.urlSmallImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${local.name} : ${c.name ?? local.unknown}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${local.character} : ${c.characterName ?? local.unknown}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGenresList(List<String>? genres, AppLocalizations local) {
    if (genres == null || genres.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: genres
          .map(
            (genre) => GestureDetector(
              onTap: () => Navigator.pop(context, genre),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF282A28),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _getTranslatedGenre(genre, local),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              ),
            ),
          )
          .toList(),
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
