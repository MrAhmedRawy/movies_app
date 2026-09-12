import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/movie_model.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Set<int> _watchlistIds = {};

  WatchlistCubit() : super(WatchlistInitial());

  String? get _uid => _auth.currentUser?.uid;

  Future<void> fetchLists() async {
    if (_uid == null) return;
    
    if (state is! WatchlistLoaded) {
      emit(WatchlistLoading());
    }
    
    List<MovieModel> watchlist = [];
    List<MovieModel> history = [];
    String? errorMessage;

    try {
      final watchlistDoc = await _firestore.collection('users').doc(_uid).collection('watchlist').get();
      watchlist = watchlistDoc.docs.map((doc) => MovieModel.fromJson(doc.data())).toList();
      
      _watchlistIds.clear();
      _watchlistIds.addAll(watchlist.map((m) => m.id));
    } catch (e) {
      log("Watchlist Fetch Error", name: "WatchlistCubit", error: e);
      if (e.toString().contains('PERMISSION_DENIED')) errorMessage = "Permission Denied: Watchlist";
    }

    try {
      final historyDoc = await _firestore.collection('users').doc(_uid).collection('history').orderBy('timestamp', descending: true).get();
      history = historyDoc.docs.map((doc) => MovieModel.fromJson(doc.data())).toList();
    } catch (e) {
      log("History Fetch Error: $e");
      if (e.toString().contains('PERMISSION_DENIED')) errorMessage = "Permission Denied: History";
    }

    if (errorMessage != null && watchlist.isEmpty && history.isEmpty) {
      emit(WatchlistError("Firestore rules error. Please check Firebase Console."));
    } else {
      emit(WatchlistLoaded(watchlist: watchlist, history: history));
    }
  }

  Future<void> toggleWatchlist(MovieModel movie) async {
    if (_uid == null) return;
    
    log("Toggling watchlist for movie: ${movie.title} (ID: ${movie.id})");
    final bool currentlyIn = _watchlistIds.contains(movie.id);
    
    if (currentlyIn) {
      _watchlistIds.remove(movie.id);
    } else {
      _watchlistIds.add(movie.id);
    }
    
    if (state is WatchlistLoaded) {
      final current = state as WatchlistLoaded;
      final newWatchlist = List<MovieModel>.from(current.watchlist);
      if (currentlyIn) {
        newWatchlist.removeWhere((m) => m.id == movie.id);
      } else {
        newWatchlist.add(movie);
      }
      emit(WatchlistLoaded(watchlist: newWatchlist, history: current.history));
    } else {
      emit(WatchlistLoading());
    }

    try {
      final docRef = _firestore.collection('users').doc(_uid).collection('watchlist').doc(movie.id.toString());
      
      if (currentlyIn) {
        await docRef.delete();
      } else {
        await docRef.set(movie.toJson());
      }
      
      await fetchLists();
    } catch (e) {
      if (currentlyIn) {
        _watchlistIds.add(movie.id);
      } else {
        _watchlistIds.remove(movie.id);
      }
      
      if (e.toString().contains('PERMISSION_DENIED')) {
        emit(WatchlistError("Permission Denied: Please update Firestore rules in Firebase Console."));
      } else {
        emit(WatchlistError(e.toString()));
      }
      
      fetchLists();
    }
  }

  Future<void> addToHistory(MovieModel movie) async {
    if (_uid == null) return;
    try {
      final docRef = _firestore.collection('users').doc(_uid).collection('history').doc(movie.id.toString());
      final movieData = movie.toJson();
      movieData['timestamp'] = FieldValue.serverTimestamp();
      
      await docRef.set(movieData);
      
      // Update local state immediately for responsiveness
      if (state is WatchlistLoaded) {
        final current = state as WatchlistLoaded;
        final newHistory = List<MovieModel>.from(current.history);
        newHistory.removeWhere((m) => m.id == movie.id);
        newHistory.insert(0, movie);
        emit(WatchlistLoaded(watchlist: current.watchlist, history: newHistory));
      }
    } catch (e) {
      log("History Error: $e");
    }
  }

  bool isInWatchlist(int movieId) {
    return _watchlistIds.contains(movieId);
  }
}
