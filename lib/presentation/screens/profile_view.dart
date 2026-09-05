import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../logic/cubits/auth/auth_cubit.dart';
import '../../logic/cubits/auth/auth_state.dart';
import '../widgets/custom_button.dart';
import 'login_screens/login_screen.dart';

import '../../data/models/movie_model.dart';
import '../../logic/cubits/watchlist/watchlist_cubit.dart';
import '../../logic/cubits/watchlist/watchlist_state.dart';
import '../widgets/movie_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedTab = 0; // 0 for Watch List, 1 for History

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchUserData();
    context.read<WatchlistCubit>().fetchLists();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (authState is UserDataLoaded) {
          final data = authState.userData;
          return BlocBuilder<WatchlistCubit, WatchlistState>(
            builder: (context, watchlistState) {
              List<MovieModel> movies = [];
              String watchlistCount = "0";
              String historyCount = "0";
              bool isLoadingLists = watchlistState is WatchlistLoading;

              if (watchlistState is WatchlistLoaded) {
                watchlistCount = watchlistState.watchlist.length.toString();
                historyCount = watchlistState.history.length.toString();
                movies = _selectedTab == 0 ? watchlistState.watchlist : watchlistState.history;
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    _buildHeader(data, watchlistCount, historyCount),
                    SizedBox(height: 30.h),
                    _buildActionButtons(),
                    SizedBox(height: 30.h),
                    _buildTabs(),
                    Expanded(
                      child: isLoadingLists 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
                        : movies.isEmpty
                          ? Center(
                              child: Image.asset(
                                AppImages.popCorn,
                                width: 200.w,
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(top: 20.h, bottom: 100.h),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 16.h,
                              ),
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                return MovieCard(
                                  movie: movies[index],
                                  width: 120.w,
                                  height: 180.h,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(
          child: Text("Error loading profile", style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> data, String watchlistCount, String historyCount) {
    return Row(
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundImage: AssetImage(data['avatar'] ?? AppImages.avtr01),
            ),
            SizedBox(height: 12.h),
            Text(
              data['name'] ?? "User Name",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildStatItem(watchlistCount, "Wish List"),
        SizedBox(width: 38.w),
        _buildStatItem(historyCount, "History"),
        const Spacer(),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            text: 'Edit Profile',
            onPressed: () {},
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Exit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(Icons.exit_to_app, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Row(
          children: [
            _buildTabItem(Icons.list, 'Watch List', _selectedTab == 0, () {
              setState(() {
                _selectedTab = 0;
              });
            }),
            _buildTabItem(Icons.folder, 'History', _selectedTab == 1, () {
              setState(() {
                _selectedTab = 1;
              });
            }),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 3.h,
                color: _selectedTab == 0 ? AppColors.yellow : Colors.transparent,
              ),
            ),
            Expanded(
              child: Container(
                height: 3.h,
                color: _selectedTab == 1 ? AppColors.yellow : Colors.transparent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.yellow : Colors.white,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.yellow : Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
