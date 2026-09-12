import 'package:dio/dio.dart';

import '../../core/constants/app_strings.dart';
import '../models/movie_model.dart';

class MovieApiService {
  final Dio _dio;

  MovieApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppStrings.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  Future<List<MovieModel>> getMovies({int page = 1, int limit = 50, String? genre, String? sortBy, String? query}) async {
    try {
      final response = await _dio.get('list_movies.json', queryParameters: {
        'page': page,
        'limit': limit,
        'genre': ?genre,
        'sort_by': ?sortBy,
        'query_term': ?query,
      });

      if (response.statusCode == 200) {
        final List<dynamic> moviesJson = response.data['data']['movies'] ?? [];
        return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('movie_details.json', queryParameters: {
        'movie_id': movieId,
        'with_images': true,
        'with_cast': true,
      });

      if (response.statusCode == 200) {
        final movieJson = response.data['data']['movie'];
        return MovieModel.fromJson(movieJson);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  Future<List<MovieModel>> getMovieSuggestions(int movieId) async {
    try {
      final response = await _dio.get('movie_suggestions.json', queryParameters: {
        'movie_id': movieId,
      });

      if (response.statusCode == 200) {
        final List<dynamic> moviesJson = response.data['data']['movies'] ?? [];
        return moviesJson.map((json) => MovieModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load suggestions');
      }
    } catch (e) {
      throw Exception('Error fetching suggestions: $e');
    }
  }
}
