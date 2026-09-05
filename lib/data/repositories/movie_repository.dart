import '../data_sources/movie_api_service.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final MovieApiService _apiService;

  MovieRepository(this._apiService);

  Future<List<MovieModel>> getAllMovies({int page = 1, int limit = 50, String? genre, String? sortBy, String? query}) async {
    return await _apiService.getMovies(page: page, limit: limit, genre: genre, sortBy: sortBy, query: query);
  }

  Future<MovieModel> getMovieById(int id) async {
    return await _apiService.getMovieDetails(id);
  }

  Future<List<MovieModel>> getSuggestions(int id) async {
    return await _apiService.getMovieSuggestions(id);
  }
}
