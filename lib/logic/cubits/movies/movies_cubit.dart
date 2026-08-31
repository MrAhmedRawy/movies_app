import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MoviesState {}
class MoviesInitial extends MoviesState {}

class MoviesCubit extends Cubit<MoviesState> {
  MoviesCubit() : super(MoviesInitial());

  // TODO: Add API fetching logic here
}
