import '../../../data/models/movie_model.dart';

abstract class WatchlistState {}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<MovieModel> watchlist;
  final List<MovieModel> history;
  WatchlistLoaded({required this.watchlist, required this.history});
}

class WatchlistError extends WatchlistState {
  final String message;
  WatchlistError(this.message);
}
