import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service_firebase.dart';

class AuthController extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final authResult =
          await _service.signUpWithEmailPassword(email, password);

      if (authResult != null) {
        final user = User(
          id: authResult.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _service.createUser(user);
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final authResult =
          await _authService.signInWithEmailPassword(email, password);

      if (authResult != null) {
        final user = await _databaseService.getUser(authResult.uid);
        _currentUser = user;
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> checkAuthState() async {
    final currentAuthUser = _authService.currentUser;
    if (currentAuthUser != null) {
      try {
        final user = await _databaseService.getUser(currentAuthUser.uid);
        _currentUser = user;
        notifyListeners();
      } catch (e) {
        // Handle error - user might not exist in database
        await signOut();
      }
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        address: address ?? _currentUser!.address,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
