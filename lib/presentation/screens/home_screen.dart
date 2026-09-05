import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/cubits/movies/movies_cubit.dart';
import '../../logic/cubits/movies/movies_state.dart';
import '../../logic/cubits/watchlist/watchlist_cubit.dart';
import 'home_view.dart';
import 'browse_view.dart';
import 'profile_view.dart';
import 'search_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey<_HomeScreenState> homeKey = GlobalKey<_HomeScreenState>();

  static void navigateToGenre(String genre) {
    print("Navigating to genre: $genre");
    homeKey.currentState?._browseCategory(genre);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _browseInitialCategory;

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      if (index != 2) _browseInitialCategory = null;
    });
    
    final moviesCubit = context.read<MoviesCubit>();
    
    // Refresh Home or Clear Search when tapping those tabs
    if (index == 0) {
      moviesCubit.fetchHomeData();
    } else if (index == 2) {
      // If we switch to Explore tab, ensure it has data
      if (moviesCubit.state is! MoviesLoaded) {
        moviesCubit.fetchMovies(genre: _browseInitialCategory ?? 'Action');
      }
    }
    
    // Always refresh watchlist/history when going to profile
    if (index == 3) {
      context.read<WatchlistCubit>().fetchLists();
    }
  }

  void _browseCategory(String category) {
    if (!mounted) return;
    print("Switching to Explore tab with category: $category");
    setState(() {
      _browseInitialCategory = category;
      _selectedIndex = 2; // Browse tab (Explore)
    });
    context.read<MoviesCubit>().fetchMovies(genre: category);
  }

  @override
  void initState() {
    super.initState();
    context.read<MoviesCubit>().fetchHomeData();
    context.read<WatchlistCubit>().fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(onSeeMore: _browseCategory),
      const SearchView(),
      BrowseView(initialCategory: _browseInitialCategory),
      const ProfileView(),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.black,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 61.h,
        margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFF282A28),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.search, 1),
            _buildNavItem(Icons.explore, 2),
            _buildNavItem(Icons.person, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Icon(
          icon,
          size: 23.h,
          color: _selectedIndex == index ? AppColors.yellow : Colors.white,
        ),
      ),
    );
  }
}
