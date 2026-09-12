import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../logic/cubits/movies/movies_cubit.dart';
import '../../logic/cubits/movies/movies_state.dart';
import '../widgets/movie_card.dart';

class BrowseView extends StatefulWidget {
  final String? initialCategory;
  const BrowseView({super.key, this.initialCategory});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  final List<String> categories = [
    'Action', 'Adventure', 'Animation', 'Biography', 'Comedy', 'Crime',
    'Documentary', 'Drama', 'Family', 'Fantasy', 'History', 'Horror',
    'Music', 'Musical', 'Mystery', 'News', 'Romance', 'Sci-Fi', 'Sport',
    'Thriller', 'War', 'Western'
  ];

  late String _selectedCategory;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();
  final double _itemWidth = 100.0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? categories[0];
    context.read<MoviesCubit>().fetchMovies(genre: _selectedCategory);
    
    _gridScrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCategory();
    });
  }

  void _onScroll() {
    if (_gridScrollController.position.pixels >= _gridScrollController.position.maxScrollExtent - 200) {
      context.read<MoviesCubit>().loadMore();
    }
  }

  void _scrollToSelectedCategory() {
    final index = categories.indexOf(_selectedCategory);
    if (index != -1 && _categoryScrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset = (index * (_itemWidth + 12.w)) - (screenWidth / 2) + (_itemWidth / 2) + 16.w;
      
      _categoryScrollController.animateTo(
        targetOffset.clamp(0.0, _categoryScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didUpdateWidget(BrowseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If we have a new initial category, or if we just returned to this tab and the state isn't movies
    final moviesCubit = context.read<MoviesCubit>();
    bool stateIsNotMovies = moviesCubit.state is! MoviesLoaded;

    if (widget.initialCategory != null && (widget.initialCategory != _selectedCategory || stateIsNotMovies)) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
      });
      moviesCubit.fetchMovies(genre: _selectedCategory);
      _scrollToSelectedCategory();
    }
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(height: 60.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            controller: _categoryScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              bool isSelected = categories[index] == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = categories[index];
                  });
                  context.read<MoviesCubit>().fetchMovies(genre: _selectedCategory);
                  _scrollToSelectedCategory();
                },
                child: Container(
                  width: _itemWidth,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.yellow : Colors.transparent,
                    borderRadius: BorderRadius.circular(15.r),
                    border: isSelected ? null : Border.all(color: AppColors.yellow),
                  ),
                  child: Center(
                    child: Text(
                      _getTranslatedGenre(categories[index], local),
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppColors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: BlocBuilder<MoviesCubit, MoviesState>(
            buildWhen: (previous, current) =>
                current is MoviesLoaded ||
                current is BrowseLoading ||
                current is MoviesError,
            builder: (context, state) {
              if (state is BrowseLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.yellow));
              } else if (state is MoviesLoaded) {
                return GridView.builder(
                  controller: _gridScrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
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
