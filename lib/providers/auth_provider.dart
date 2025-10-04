import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  StreamSubscription<User?>? _authStateSubscription;

  AuthProvider() {
    _initializeAuthState();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get displayName => _user?.displayName;
  String? get email => _user?.email;
  String? get photoURL => _user?.photoURL;

  void _initializeAuthState() {
    // Listen to authentication state changes
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });

    // Set initial user
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Initialize GoogleSignIn with serverClientId
      await GoogleSignIn.instance.initialize(
        clientId: '176545965227-p52nvghgk8log53p96qucjsa7av2o399.apps.googleusercontent.com',
        serverClientId: '176545965227-p52nvghgk8log53p96qucjsa7av2o399.apps.googleusercontent.com',
      );
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // Handle error
      print('Sign in error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.disconnect();
    _user = null;
    notifyListeners();
  }
}
