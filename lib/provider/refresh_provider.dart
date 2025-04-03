import 'package:flutter/material.dart';

class RefreshStateNotifier extends ChangeNotifier {
  bool _shouldRefresh = false;

  bool get shouldRefresh => _shouldRefresh;

  void refresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

  void resetRefresh() {
    _shouldRefresh = false;
  }
}
