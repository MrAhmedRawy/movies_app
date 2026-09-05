# Implementation Plan - Navigate to Genre from Movie Details

When a user taps on a movie genre in the Movie Details screen, the app should navigate to the "Explore" (Browse) tab and filter movies by that genre.

## User Review Required

> [!IMPORTANT]
> The navigation relies on a `GlobalKey` to reach the `HomeScreen` state from outside its own build context (specifically when popping back from a detail screen). I will ensure this key is correctly linked to the `HomeScreen` widget instance.

## Proposed Changes

### Presentation Layer

#### [MODIFY] [home_screen.dart](file:///D:/Ahmed/programing/flutter_projects/movies_app/lib/presentation/screens/home_screen.dart)
- Link the static `homeKey` to the `HomeScreen` widget constructor to allow `navigateToGenre` to access the state.
- Remove the incorrect assignment of `homeKey` to the `Scaffold`'s key.
- Ensure `_browseCategory` correctly updates the state and triggers the movie fetch.

#### [MODIFY] [movie_card.dart](file:///D:/Ahmed/programing/flutter_projects/movies_app/lib/presentation/widgets/movie_card.dart)
- Ensure the result from `Navigator.push` (the selected genre) is handled by calling `HomeScreen.navigateToGenre`.
- Verify the "bubbling up" logic for nested `MovieDetailsScreen` instances.

#### [MODIFY] [movie_details_screen.dart](file:///D:/Ahmed/programing/flutter_projects/movies_app/lib/presentation/screens/movie_details_screen.dart)
- Verify `_buildGenresList` correctly pops the screen with the selected genre name.

## Verification Plan

### Manual Verification
1. Launch the app and go to the Home screen.
2. Tap on any movie to open the `MovieDetailsScreen`.
3. Scroll down to the "Genres" section.
4. Tap on a genre (e.g., "Action").
5. Verify that:
   - The detail screen closes.
   - The app switches to the Explore (Browse) tab (third icon in bottom nav).
   - The selected genre is highlighted in the category list.
   - The grid displays movies for the selected genre.
6. Repeat the process from a "Similar Movie" card inside a `MovieDetailsScreen` to ensure nested navigation works.
