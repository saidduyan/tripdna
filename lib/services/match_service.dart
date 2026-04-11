import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/traveler.dart';

class MatchService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ── Profile setup ──────────────────────────────────────────

  Future<void> updateTravelProfile({
    required String gender,
    required String preferredGender,
    required DateTime travelDate,
    required int minAge,
    required int maxAge,
    required String topDestination,
    required String dnaVibe,
    required String continent,
  }) async {
    await _db.collection('users').doc(_uid).update({
      'gender': gender,
      'preferredGender': preferredGender,
      'travelDate': Timestamp.fromDate(travelDate),
      'minAge': minAge,
      'maxAge': maxAge,
      'topDestination': topDestination,
      'dnaVibe': dnaVibe,
      'continent': continent,
      'exploreEnabled': true,
    });
  }

  // ── Fetch candidates ───────────────────────────────────────

  Future<List<Traveler>> fetchCandidates({
    required String preferredGender,
    required String topDestination,
    required int minAge,
    required int maxAge,
  }) async {
    final sentSnap =
        await _db.collection('likes').doc(_uid).collection('sent').get();
    final excludeUids = sentSnap.docs.map((d) => d.id).toSet()..add(_uid);

    Query query = _db
        .collection('users')
        .where('exploreEnabled', isEqualTo: true)
        .where('topDestination', isEqualTo: topDestination)
        .limit(20);

    if (preferredGender != 'Any') {
      query = query.where('gender', isEqualTo: preferredGender);
    }

    final snap = await query.get();

    return snap.docs
        .where((d) => !excludeUids.contains(d.id))
        .map((d) => Traveler.fromMap(d.data() as Map<String, dynamic>))
        .where((t) {
      final age = t.age;
      return age >= minAge && age <= maxAge;
    }).toList();
  }

  // ── Like / Pass ────────────────────────────────────────────

  Future<bool> likeUser(String targetUid) async {
    await _db
        .collection('likes')
        .doc(_uid)
        .collection('sent')
        .doc(targetUid)
        .set({'liked': true, 'createdAt': FieldValue.serverTimestamp()});

    final theirLike = await _db
        .collection('likes')
        .doc(targetUid)
        .collection('sent')
        .doc(_uid)
        .get();

    if (theirLike.exists && (theirLike.data()?['liked'] == true)) {
      await _createMatch(targetUid);
      return true;
    }
    return false;
  }

  Future<void> passUser(String targetUid) async {
    await _db
        .collection('likes')
        .doc(_uid)
        .collection('sent')
        .doc(targetUid)
        .set({'liked': false, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _createMatch(String otherUid) async {
    final matchId = _uid.compareTo(otherUid) < 0
        ? '${_uid}_$otherUid'
        : '${otherUid}_$_uid';

    await _db.collection('matches').doc(matchId).set({
      'user1': _uid.compareTo(otherUid) < 0 ? _uid : otherUid,
      'user2': _uid.compareTo(otherUid) < 0 ? otherUid : _uid,
      'users': [_uid, otherUid],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Matches list ───────────────────────────────────────────

  Stream<QuerySnapshot> getMatches() {
    return _db
        .collection('matches')
        .where('users', arrayContains: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  String getMatchId(String otherUid) {
    return _uid.compareTo(otherUid) < 0
        ? '${_uid}_$otherUid'
        : '${otherUid}_$_uid';
  }

  // ── Chat ───────────────────────────────────────────────────

  Future<void> sendMessage({
    required String matchId,
    required String text,
  }) async {
    await _db.collection('matches').doc(matchId).collection('msgs').add({
      'senderId': _uid,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('matches').doc(matchId).update({
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('msgs')
        .orderBy('createdAt')
        .snapshots();
  }
}
