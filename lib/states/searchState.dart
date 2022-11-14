import 'package:flutter/material.dart';

enum FetchState { noFetch, fetchingLocal, fetchingCloud }

class FetchStateNotifier extends ChangeNotifier {
  // Class to control the fetch state of the app

  FetchState currentState = FetchState.noFetch;
  String? fetchString;
  bool finished = false;

  void startLocalFetch(String newString) {
    fetchString = newString;
    seFetchState(FetchState.fetchingLocal);
  }

  void startCloudFetch(String newString) {
    fetchString = newString;
    seFetchState(FetchState.fetchingCloud);
  }

  void fetchFinished() {
    finished = true;
  }

  void resetFetch() {
    fetchString = null;
    finished = false;
    seFetchState(FetchState.noFetch);
  }

  void seFetchState(FetchState newState) {
    currentState = newState;
    notifyListeners();
  }
}
