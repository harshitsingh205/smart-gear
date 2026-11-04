import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  const AuthResult({required this.success, required this.message, this.user});
}

class AuthService extends ChangeNotifier {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    restoreSession();
  }

  static const String _prefIsLoggedIn = 'sg_is_logged_in';
  static const String _prefRole = 'sg_user_role';
  static const String _prefUserId = 'sg_user_id';
  static const String _prefUserName = 'sg_user_name';
  static const String _prefUserEmail = 'sg_user_email';
  static const String _prefUserPhone = 'sg_user_phone';
  static const String _prefUserPhoto = 'sg_user_photo';
  static const String _prefUserDest = 'sg_user_dest';
  static const String _prefUserHeight = 'sg_user_height';
  static const String _prefUserWeight = 'sg_user_weight';
  static const String _prefUserAge = 'sg_user_age';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isAdminMode = false;
  bool _needsSizingForm = false;
  bool _isInitialized = false;
  bool _googleSignInInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _isAdminMode;
  bool get needsSizingForm => _needsSizingForm;
  bool get isInitialized => _isInitialized;

  void markSizingComplete() {
    _needsSizingForm = false;
    notifyListeners();
  }

  /// Official Smart Gear Administrator Credentials
  static const String adminEmail = 'smartgear@gmail.com';
  static const String adminPassword = 'smartgear123@';

  Future<void> _saveSession(UserModel user, {required bool isAdmin}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefIsLoggedIn, true);
      await prefs.setString(_prefRole, isAdmin ? 'admin' : 'rider');
      await prefs.setString(_prefUserId, user.id);
      await prefs.setString(_prefUserName, user.name);
      await prefs.setString(_prefUserEmail, user.email);
      await prefs.setString(_prefUserPhone, user.phone);
      if (user.photoUrl != null) {
        await prefs.setString(_prefUserPhoto, user.photoUrl!);
      }
      if (user.preferredDestination != null) {
        await prefs.setString(_prefUserDest, user.preferredDestination!);
      }
      if (user.heightCm != null) {
        await prefs.setDouble(_prefUserHeight, user.heightCm!);
      }
      if (user.weightKg != null) {
        await prefs.setDouble(_prefUserWeight, user.weightKg!);
      }
      if (user.age != null) {
        await prefs.setInt(_prefUserAge, user.age!);
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  Future<bool> restoreSession() async {
    try {
      // 1. Check if Firebase Auth has an active signed-in user
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        final prefs = await SharedPreferences.getInstance();
        _isAdminMode = false;
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName?.isNotEmpty == true
              ? fbUser.displayName!
              : (prefs.getString(_prefUserName) ?? (fbUser.email?.split('@').first.replaceAll('.', ' ') ?? 'Rider')),
          email: fbUser.email ?? prefs.getString(_prefUserEmail) ?? '',
          phone: fbUser.phoneNumber ?? prefs.getString(_prefUserPhone) ?? '+91 98765 00000',
          photoUrl: fbUser.photoURL ?? prefs.getString(_prefUserPhoto),
          preferredDestination: prefs.getString(_prefUserDest) ?? 'Ladakh',
          heightCm: prefs.getDouble(_prefUserHeight) ?? 175,
          weightKg: prefs.getDouble(_prefUserWeight) ?? 70,
          age: prefs.getInt(_prefUserAge) ?? 25,
          role: 'rider',
        );
        _isInitialized = true;
        notifyListeners();
        return true;
      }

      // 2. Check SharedPreferences for saved admin or rider session
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_prefIsLoggedIn) ?? false;
      if (isLoggedIn) {
        final role = prefs.getString(_prefRole) ?? 'rider';
        if (role == 'admin') {
          _isAdminMode = true;
          _currentUser = const UserModel(
            id: 'adm_001',
            name: 'Smart Gear Admin',
            email: adminEmail,
            phone: '+91 98000 12345',
            preferredDestination: 'Ladakh HQ',
            role: 'admin',
            photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          );
          _isInitialized = true;
          notifyListeners();
          return true;
        } else {
          final email = prefs.getString(_prefUserEmail) ?? '';
          if (email.isNotEmpty) {
            _isAdminMode = false;
            _currentUser = UserModel(
              id: prefs.getString(_prefUserId) ?? 'usr_saved',
              name: prefs.getString(_prefUserName) ?? 'Rider',
              email: email,
              phone: prefs.getString(_prefUserPhone) ?? '+91 98765 00000',
              photoUrl: prefs.getString(_prefUserPhoto),
              preferredDestination: prefs.getString(_prefUserDest) ?? 'Ladakh',
              heightCm: prefs.getDouble(_prefUserHeight) ?? 175,
              weightKg: prefs.getDouble(_prefUserWeight) ?? 70,
              age: prefs.getInt(_prefUserAge) ?? 25,
              role: 'rider',
            );
            _isInitialized = true;
            notifyListeners();
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('Restore session error: $e');
    }
    _isInitialized = true;
    return false;
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────────


  Future<AuthResult> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        // Always use popup on web to avoid sessionStorage redirect issues
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Native Google Sign-In via Google Play Services (stays in app, no Chrome redirect)
        if (!_googleSignInInitialized) {
          await GoogleSignIn.instance.initialize(
            serverClientId: '1037760086655-ak7oeoaojiaac9mbf8had9r7mhql1m5t.apps.googleusercontent.com',
          );
          _googleSignInInitialized = true;
        }

        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate(
          scopeHint: ['email', 'profile'],
        );

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final fbUser = userCredential.user;
      if (fbUser != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        _isAdminMode = false;
        _needsSizingForm = isNewUser;
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName?.isNotEmpty == true
              ? fbUser.displayName!
              : (fbUser.email?.split('@').first.replaceAll('.', ' ') ?? 'Rider'),
          email: fbUser.email ?? '',
          phone: fbUser.phoneNumber ?? '+91 98765 00000',
          role: 'rider',
          photoUrl: fbUser.photoURL,
        );
        await _saveSession(_currentUser!, isAdmin: false);
        notifyListeners();
        return AuthResult(
          success: true,
          message: isNewUser ? 'Welcome to Smart Gear! 🏍️ Let\'s set up your profile.' : 'Welcome back, ${_currentUser!.name}! 🎉',
          user: _currentUser,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error [${e.code}]: ${e.message}');
      // "missing-initial-state" means the redirect was cleared — tell user
      if (e.code == 'missing-initial-state' || e.code == 'web-context-cancelled') {
        return const AuthResult(
          success: false,
          message: 'Sign-in was interrupted. Please try again using the email form below.',
        );
      }
      return AuthResult(success: false, message: _mapFirebaseError(e.code));
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return AuthResult(
        success: false,
        message: 'Google Sign-In is not available right now. Please use email login.',
      );
    }

    return const AuthResult(
      success: false,
      message: 'Failed to authenticate with Google.',
    );
  }


  // ─── Login ────────────────────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Admin login verification
    if (cleanEmail == adminEmail) {
      if (cleanPassword == adminPassword) {
        _isAdminMode = true;
        _currentUser = const UserModel(
          id: 'adm_001',
          name: 'Smart Gear Admin',
          email: adminEmail,
          phone: '+91 98000 12345',
          preferredDestination: 'Ladakh HQ',
          role: 'admin',
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        );
        await _saveSession(_currentUser!, isAdmin: true);
        notifyListeners();
        return AuthResult(
          success: true,
          message: 'Welcome back, Admin!',
          user: _currentUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Incorrect email or password.',
        );
      }
    }

    // 2. Firebase Auth SDK login for regular riders
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      final fbUser = credential.user;
      if (fbUser != null) {
        final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
        _isAdminMode = false;
        _needsSizingForm = isNewUser;
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName?.isNotEmpty == true
              ? fbUser.displayName!
              : cleanEmail.split('@').first.replaceAll('.', ' '),
          email: cleanEmail,
          phone: fbUser.phoneNumber ?? '+91 98765 00000',
          role: 'rider',
          photoUrl: fbUser.photoURL,
        );
        await _saveSession(_currentUser!, isAdmin: false);
        notifyListeners();
        return AuthResult(
          success: true,
          message: isNewUser ? 'Welcome to Smart Gear! Let\'s set up your profile 🏍️' : 'Signed in successfully!',
          user: _currentUser,
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('Login error: $e');
    }

    return const AuthResult(
      success: false,
      message: 'Login failed. Please try again.',
    );
  }

  // ─── Register ─────────────────────────────────────────────────────────────────

  Future<AuthResult> registerRider({
    required String name,
    required String email,
    required String password,
    required String phone,
    double? heightCm,
    double? weightKg,
    int? age,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanPassword.length < 6) {
      return const AuthResult(
        success: false,
        message: 'Password must be at least 6 characters.',
      );
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      final fbUser = credential.user;

      // Update display name in Firebase
      await fbUser?.updateDisplayName(name.trim());

      _isAdminMode = false;
      _currentUser = UserModel(
        id: fbUser?.uid ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim().isNotEmpty ? name.trim() : 'Rider',
        email: cleanEmail,
        phone: phone.trim().isNotEmpty ? phone.trim() : '+91 98765 00000',
        heightCm: heightCm ?? 175,
        weightKg: weightKg ?? 70,
        age: age ?? 25,
        preferredDestination: 'Ladakh',
        role: 'rider',
      );
      await _saveSession(_currentUser!, isAdmin: false);
      notifyListeners();
      return AuthResult(
        success: true,
        message: 'Account created! Welcome to Smart Gear 🏍️',
        user: _currentUser,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _mapFirebaseError(e.code),
      );
    } catch (e) {
      debugPrint('Register error: $e');
      return const AuthResult(
        success: false,
        message: 'Registration failed. Please try again.',
      );
    }
  }

  // ─── Demo / Guest ─────────────────────────────────────────────────────────────

  void loginAsGuest() {
    _isAdminMode = false;
    _currentUser = const UserModel(
      id: 'usr_guest',
      name: 'Guest Rider',
      email: 'guest@smartgear.com',
      phone: '+91 99999 00000',
      heightCm: 175,
      weightKg: 72,
      age: 26,
      preferredDestination: 'Ladakh',
      role: 'rider',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    );
    _saveSession(_currentUser!, isAdmin: false);
    notifyListeners();
  }

  // ─── Profile Update ───────────────────────────────────────────────────────────

  void updateProfile({
    required String name,
    required String phone,
    double? heightCm,
    double? weightKg,
    int? age,
    String? preferredDestination,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      preferredDestination: preferredDestination,
    );
    _saveSession(_currentUser!, isAdmin: _isAdminMode);
    notifyListeners();
  }

  // ─── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _clearSession();
    try {
      if (!_isAdminMode) {
        await _firebaseAuth.signOut();
        if (!kIsWeb) {
          try {
            await GoogleSignIn.instance.signOut();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    _currentUser = null;
    _isAdminMode = false;
    _needsSizingForm = false;
    notifyListeners();
  }

  // ─── Password Reset ───────────────────────────────────────────────────────────

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(
        success: true,
        message: 'Password reset email sent! Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _mapFirebaseError(e.code));
    }
  }

  // ─── Firebase Error Mapping ───────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}
