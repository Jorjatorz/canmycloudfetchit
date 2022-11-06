import 'package:flutter/material.dart';

enum SearchState { noSearch, searching }

class SearchStateNotifier extends ChangeNotifier {
  // Class to control the search state of the app

  SearchState currentState = SearchState.noSearch;
  String? searchString;

  void startSearch(String newString) {
    searchString = newString;
    setSearchState(SearchState.searching);
  }

  void resetSearch() {
    searchString = null;
    setSearchState(SearchState.noSearch);
  }

  void setSearchState(SearchState newState) {
    currentState = newState;
    notifyListeners();
  }
}
