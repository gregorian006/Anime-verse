import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/anime_view.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/genre_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "AnimeVerse",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: screenWidth * 0.075,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Gunakan Consumer untuk mendapatkan daftar anime TERFILTER
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          // Ambil data yang sudah difilter (genre + search)
          final filteredAnime = provider.getFilteredAnimeForHome();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: screenWidth * 0.02,
                          offset: Offset(0, screenHeight * 0.005),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        provider.setHomeSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Anime Title",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                        suffixIcon: provider.homeSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setHomeSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.075),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.075),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.075),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Color(0xFF0b395e),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),

                  ),

                ),
                GenreList(
                  selected: provider.selectedGenre,
                  onGenreSelected: (genre) {
                    provider.setSelectedGenre(genre);
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                // Anime List
                AnimeView(animeList: filteredAnime),
                SizedBox(height: screenHeight * 0.025),

              ],
            ),
          );
        },
      ),
    );

  }
}
