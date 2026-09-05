import '../../../data/models/movie_model.dart';

abstract class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class HomeLoading extends MoviesState {}

class SearchLoading extends MoviesState {}

class BrowseLoading extends MoviesState {}

class MovieDetailsLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<MovieModel> movies;
  final int page;
  final bool hasReachedMax;
  final String? genre;
  final String? query;

  MoviesLoaded({
    required this.movies,
    this.page = 1,
    this.hasReachedMax = false,
    this.genre,
    this.query,
  });

  MoviesLoaded copyWith({
    List<MovieModel>? movies,
    int? page,
    bool? hasReachedMax,
    String? genre,
    String? query,
  }) {
    return MoviesLoaded(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      genre: genre ?? this.genre,
      query: query ?? this.query,
    );
  }
}

class HomeLoaded extends MoviesState {
  final List<MovieModel> availableNow;
  final Map<String, List<MovieModel>> categories;
  HomeLoaded({required this.availableNow, required this.categories});
}

class MovieDetailsLoaded extends MoviesState {
  final MovieModel movie;
  final List<MovieModel> suggestions;
  MovieDetailsLoaded(this.movie, this.suggestions);
}

class MoviesError extends MoviesState {
  final String message;
  MoviesError(this.message);
}
