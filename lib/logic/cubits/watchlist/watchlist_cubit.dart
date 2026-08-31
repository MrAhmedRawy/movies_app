import 'package:flutter_bloc/flutter_bloc.dart';

abstract class WatchlistState {}
class WatchlistInitial extends WatchlistState {}

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit() : super(WatchlistInitial());

  // TODO: Add Firestore logic here
}
