import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ── Register ───────────────────────────────────────────────

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final age = DateTime.now().year - dateOfBirth.year;

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'usernameLower': username.trim().toLowerCase(),
      'dob': Timestamp.fromDate(dateOfBirth),
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Save username to recent list after register
    await saveRecentUsername(username.trim());

    return credential;
  }

  // ── Login ──────────────────────────────────────────────────

  Future<UserCredential> login({
    required String identifier,
    required String password,
  }) async {
    String email;
    if (identifier.contains('@')) {
      email = identifier.trim();
    } else {
      final query = await _db
          .collection('users')
          .where('usernameLower',
              isEqualTo: identifier.trim().toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with that username.',
        );
      }
      email = query.docs.first.data()['email'] as String;
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save to recent usernames after successful login
    await saveRecentUsername(identifier.trim());

    return credential;
  }

  // ── Logout ─────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Profile ────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> saveResult({
    required String uid,
    required Map<String, dynamic> resultData,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('results')
        .add({
      ...resultData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Recent usernames (shared_preferences) ─────────────────

  Future<void> saveRecentUsername(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recent =
        prefs.getStringList('recent_usernames') ?? [];
    recent.remove(identifier); // duplicate olmasın
    recent.insert(0, identifier); // en başa ekle
    if (recent.length > 5) recent.removeLast(); // max 5
    await prefs.setStringList('recent_usernames', recent);
  }

  Future<List<String>> getRecentUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_usernames') ?? [];
  }

  Future<void> removeRecentUsername(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recent =
        prefs.getStringList('recent_usernames') ?? [];
    recent.remove(identifier);
    await prefs.setStringList('recent_usernames', recent);
  }

  Future<void> clearRecentUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_usernames');
  }
  Future<void> resetPassword(String email) async {
  await _auth.sendPasswordResetEmail(email: email.trim());
}
}