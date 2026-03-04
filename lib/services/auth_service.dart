import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static String _normUsername(String s) => s.trim().toLowerCase();

  static Future<void> signOut() => _auth.signOut();

  static Future<String?> _emailFromUsername(String username) async {
    final u = _normUsername(username);

    final snap = await _db
        .collection('users')
        .where('usernameLower', isEqualTo: u)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['email'] as String?;
  }

  static Future<UserCredential> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();

    String email;
    if (id.contains('@')) {
      email = id;
    } else {
      final foundEmail = await _emailFromUsername(id);
      if (foundEmail == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Username not found.',
        );
      }
      email = foundEmail;
    }

    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime dateOfBirth,
  }) async {
    final usernameLower = _normUsername(username);

    // 1) username unique mi?
    final existing = await _db
        .collection('users')
        .where('usernameLower', isEqualTo: usernameLower)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw FirebaseAuthException(
        code: 'username-taken',
        message: 'That username is already taken.',
      );
    }

    // 2) Auth create
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;
    final age = _calcAge(dateOfBirth);

    // 3) Firestore profile save
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'usernameLower': usernameLower,
      'dob': Timestamp.fromDate(dateOfBirth),
      'age': age,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static int _calcAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    final hadBirthdayThisYear =
        (now.month > dob.month) || (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthdayThisYear) age--;
    if (age < 0) age = 0;
    return age;
  }
}