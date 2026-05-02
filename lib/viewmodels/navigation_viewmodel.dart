import 'package:flutter/material.dart';

class NavigationViewModel extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void switchTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
