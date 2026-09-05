import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';
import 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final MovieRepository _repository;
  
  // Cache home data
  HomeLoaded? _lastHomeData;

  MoviesCubit(this._repository) : super(MoviesInitial());

  Future<void> fetchMovies({String? genre, String? query}) async {
    if (genre != null) {
      emit(BrowseLoading());
    } else {
      emit(SearchLoading());
    }
    try {
      final movies = await _repository.getAllMovies(
        page: 1,
        genre: genre,
        query: query,
        limit: 50,
      );
      emit(MoviesLoaded(
        movies: movies,
        page: 1,
        hasReachedMax: movies.length < 50,
        genre: genre,
        query: query,
      ));
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is! MoviesLoaded) return;
    final currentState = state as MoviesLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final nextPage = currentState.page + 1;
      final movies = await _repository.getAllMovies(
        page: nextPage,
        genre: currentState.genre,
        query: currentState.query,
        limit: 50,
      );
      
      if (movies.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(MoviesLoaded(
          movies: currentState.movies + movies,
          page: nextPage,
          hasReachedMax: movies.length < 50,
          genre: currentState.genre,
          query: currentState.query,
        ));
      }
    } catch (e) {
      // Don't emit error to avoid clearing existing results, maybe just log it
    }
  }

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      // 1. Fetch Available Now (sorted by year)
      final availableNow = await _repository.getAllMovies(
        sortBy: 'year',
        limit: 10,
      );

      // 2. Select 3 random genres
      final allGenres = [
        'Action', 'Adventure', 'Animation', 'Biography', 'Comedy', 'Crime',
        'Drama', 'Family', 'Fantasy', 'Horror', 'Romance', 'Sci-Fi', 'Thriller'
      ];
      final List<String> shuffledGenres = List.from(allGenres)..shuffle();
      final selectedGenres = shuffledGenres.take(3).toList();

      // 3. Fetch movies for each genre
      final Map<String, List<MovieModel>> categories = {};
      for (var genre in selectedGenres) {
        categories[genre] = await _repository.getAllMovies(
          genre: genre,
          limit: 10,
        );
      }

      _lastHomeData = HomeLoaded(availableNow: availableNow, categories: categories);
      emit(_lastHomeData!);
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  void restoreHomeData() {
    if (_lastHomeData != null) {
      emit(_lastHomeData!);
    } else {
      fetchHomeData();
    }
  }

  Future<void> fetchMovieDetails(int movieId) async {
    emit(MovieDetailsLoading());
    try {
      final movie = await _repository.getMovieById(movieId);
      final suggestions = await _repository.getSuggestions(movieId);
      emit(MovieDetailsLoaded(movie, suggestions));
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }
}
