import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/cubits/movies/movies_cubit.dart';
import '../../logic/cubits/movies/movies_state.dart';
import '../widgets/movie_card.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MoviesCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF282A28),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                if (value.isNotEmpty) {
                  context.read<MoviesCubit>().fetchMovies(query: value);
                }
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: local.search,
                hintStyle: const TextStyle(color: Colors.white54),
                icon: Image.asset(AppImages.searchIcon, width: 24.w),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: _searchController.text.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Center(
                      child: Image.asset(
                        AppImages.popCorn,
                        width: 124.w,
                      ),
                    ),
                  )
                : BlocBuilder<MoviesCubit, MoviesState>(
                    buildWhen: (previous, current) =>
                        current is MoviesLoaded ||
                        current is SearchLoading ||
                        current is MoviesError,
                    builder: (context, state) {
                      if (state is SearchLoading) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.yellow));
                      } else if (state is MoviesLoaded) {
                        if (state.movies.isEmpty) {
                          return Center(
                              child: Text(local.noMoviesFound,
                                  style: const TextStyle(color: Colors.white)));
                        }
                        return GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 100.h),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                          ),
                          itemCount: state.movies.length,
                          itemBuilder: (context, index) {
                            return MovieCard(movie: state.movies[index]);
                          },
                        );
                      }
                      return Container();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
