abstract class AuthService {
  dynamic get currentUser;
  Future<dynamic> signUpWithEmailPassword(String email, String password);
  Future<dynamic> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class FirebaseAuthService implements AuthService {
  // This will be implemented with actual Firebase imports later
  @override
  dynamic get currentUser => null;

  @override
  Future<dynamic> signUpWithEmailPassword(String email, String password) async {
    // TODO: Implement Firebase Auth signup
    throw UnimplementedError();
  }

  @override
  Future<dynamic> signInWithEmailPassword(String email, String password) async {
    // TODO: Implement Firebase Auth signin
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement Firebase Auth signout
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {
    // TODO: Implement Firebase Auth password reset
    throw UnimplementedError();
  }
}
