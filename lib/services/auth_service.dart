import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const _blockedDomains = [
    'mailinator.com',
    'tempmail.com',
    'throwaway.email',
    'guerrillamail.com',
    'sharklasers.com',
    'guerrillamailblock.com',
    'grr.la',
    'guerrillamail.info',
    'guerrillamail.biz',
    'guerrillamail.de',
    'guerrillamail.net',
    'guerrillamail.org',
    'spam4.me',
    'trashmail.com',
    'trashmail.me',
    'trashmail.net',
    'dispostable.com',
    'mailnull.com',
    'spamgourmet.com',
    'maildrop.cc',
    'yopmail.com',
    'yopmail.fr',
    'cool.fr.nf',
    'jetable.fr.nf',
    'nospam.ze.tc',
    'nomail.xl.cx',
    'mega.zik.dj',
    'speed.1s.fr',
    'courriel.fr.nf',
    'moncourrier.fr.nf',
    'monemail.fr.nf',
    'monmail.fr.nf',
    'fakeinbox.com',
    'tempinbox.com',
    'tempr.email',
    'discard.email',
    'spamgrap.com',
    'trashmail.at',
    'trashmail.io',
    'trashmail.xyz',
    'tempail.com',
    'getairmail.com',
    'filzmail.com',
    'throwam.com',
    'spamherelots.com',
    'binkmail.com',
    'bob.email',
    'mailinater.com',
    'spamdecoy.com',
    'mailnew.com',
  ];

  bool _isBlockedDomain(String email) {
    final domain = email.split('@').last.toLowerCase();
    return _blockedDomains.contains(domain);
  }

  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (!_isValidEmailFormat(trimmedEmail)) {
      throw Exception('Please enter a valid email address.');
    }

    if (_isBlockedDomain(trimmedEmail)) {
      throw Exception(
          'Temporary or disposable email addresses are not allowed. Please use a real email.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );

    final uid = credential.user!.uid;
    final age = DateTime.now().year - dateOfBirth.year;

    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': trimmedEmail,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'usernameLower': username.trim().toLowerCase(),
      'dob': Timestamp.fromDate(dateOfBirth),
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': false,
    });

    await credential.user!.sendEmailVerification();
    await saveRecentUsername(username.trim());

    return credential;
  }

  Future<UserCredential> login({
    required String identifier,
    required String password,
  }) async {
    String email;
    if (identifier.contains('@')) {
      email = identifier.trim().toLowerCase();
    } else {
      final query = await _db
          .collection('users')
          .where('usernameLower', isEqualTo: identifier.trim().toLowerCase())
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

    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception(
          'EMAIL_NOT_VERIFIED:Please verify your email before signing in. Check your inbox.');
    }

    await _db.collection('users').doc(credential.user!.uid).update({
      'emailVerified': true,
    });

    await saveRecentUsername(identifier.trim());

    return credential;
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }
      await _auth.signOut();
    } catch (_) {
      throw Exception('Could not resend verification email. Try again.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> saveResult({
    required String uid,
    required Map<String, dynamic> resultData,
  }) async {
    await _db.collection('users').doc(uid).collection('results').add({
      ...resultData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addBeenHere(String uid, String destinationName) async {
    await _db.collection('users').doc(uid).update({
      'beenHere': FieldValue.arrayUnion([destinationName]),
    });
  }

  Future<void> removeBeenHere(String uid, String destinationName) async {
    await _db.collection('users').doc(uid).update({
      'beenHere': FieldValue.arrayRemove([destinationName]),
    });
  }

  Future<List<String>> getBeenHere(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['beenHere'] ?? []);
  }

  Future<void> saveRecentUsername(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recent = prefs.getStringList('recent_usernames') ?? [];
    recent.remove(identifier);
    recent.insert(0, identifier);
    if (recent.length > 5) recent.removeLast();
    await prefs.setStringList('recent_usernames', recent);
  }

  Future<List<String>> getRecentUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_usernames') ?? [];
  }

  Future<void> removeRecentUsername(String identifier) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recent = prefs.getStringList('recent_usernames') ?? [];
    recent.remove(identifier);
    await prefs.setStringList('recent_usernames', recent);
  }

  Future<void> clearRecentUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_usernames');
  }

  // ── DEMO MODE ──────────────────────────────────────────────
  Future<User?> signInAnonymously(String displayName) async {
    try {
      final credential = await _auth.signInAnonymously();
      await credential.user?.updateDisplayName(displayName);

      // Firestore'a minimal demo profil yaz
      await _db.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'firstName': displayName,
        'lastName': '',
        'username': displayName,
        'usernameLower': displayName.toLowerCase(),
        'isDemo': true,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
      });

      return credential.user;
    } catch (e) {
      return null;
    }
  }
  // ───────────────────────────────────────────────────────────
}
