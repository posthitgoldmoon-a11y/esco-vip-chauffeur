import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  bool _isAdmin = false;
  bool _isLoading = true;

  String? get userId => _userId;
  String? get userName => _userName;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;

  AppProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userId = await StorageService.getUserId();
    _userName = await StorageService.getUserName();
    _isAdmin = await StorageService.getIsAdmin();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String userId, String userName,
      {bool isAdmin = false}) async {
    _userId = userId;
    _userName = userName;
    _isAdmin = isAdmin;
    await StorageService.setUserId(userId);
    await StorageService.setUserName(userName);
    await StorageService.setIsAdmin(isAdmin);
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _userName = null;
    _isAdmin = false;
    await StorageService.clearAllData();
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    StorageService.setIsAdmin(value);
    notifyListeners();
  }

  Future<void> loadUserData() async => await _loadUserData();
}
