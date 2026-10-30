import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_data.dart';
import '../models/anime.dart';

class AppStateProvider extends ChangeNotifier {
  // STATE (Data Privat)
  List<Anime> _favorites = [];
  static const String _storageKey = 'favorite_anime_list';

  String _selectedGenre = "All";
  String _homeSearchQuery = "";
  String _favoriteSearchQuery = "";

  AppStateProvider() {
    _loadFavorites();
  }

  // GETTER (Akses Publik)
  List<Anime> get favorites => _favorites;
  String get selectedGenre => _selectedGenre;
  String get homeSearchQuery => _homeSearchQuery;
  String get favoriteSearchQuery => _favoriteSearchQuery;

  bool isFavorite(String animeId) {
    return _favorites.any((anime) => anime.id == animeId);
  }

  void toggleFavorite(Anime anime) {
    if (isFavorite(anime.id)) {
      removeFavorite(anime.id);
    } else {
      addFavorite(anime);
    }
  }

  void addFavorite(Anime anime) {
    if (!isFavorite(anime.id)) {
      _favorites.add(anime);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(String animeId) {
    _favorites.removeWhere((anime) => anime.id == animeId);
    _saveFavorites();
    notifyListeners();
  }

  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    notifyListeners();
  }

  void setFavoriteSearchQuery(String query) {
    _favoriteSearchQuery = query;
    notifyListeners();
  }

  /// Get filtered anime for HomeScreen (genre + search)
  List<Anime> getFilteredAnimeForHome() {
    List<Anime> result = DummyData.animeList;

    // Apply genre filter
    if (_selectedGenre != "All") {
      result = result.where((anime) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        return genres.contains(_selectedGenre);
      }).toList();
    }

    // Apply search filter (case-insensitive)
    if (_homeSearchQuery.isNotEmpty) {
      result = result.where((anime) {
        return anime.title.toLowerCase().contains(_homeSearchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  /// Get filtered favorites for FavoriteScreen (based on favorite search)
  List<Anime> getFilteredFavorites() {
    List<Anime> result = _favorites;

    if (_favoriteSearchQuery.isNotEmpty) {
      result = result.where((anime) {
        return anime.title.toLowerCase().contains(_favoriteSearchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favoritesJson = _favorites.map((anime) {
        return {
          'id': anime.id,
          'title': anime.title,
          'imagePath': anime.imagePath,
          'genre': anime.genre,
          'rating': anime.rating,
          'totalEpisodes': anime.totalEpisodes,
          'description': anime.description,
        };
      }).toList();
      await prefs.setString(_storageKey, json.encode(favoritesJson));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_storageKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) {
          return Anime(
            id: item['id'],
            title: item['title'],
            imagePath: item['imagePath'],
            genre: item['genre'],
            rating: item['rating'],
            totalEpisodes: item['totalEpisodes'],
            description: item['description'],
          );
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }
}
