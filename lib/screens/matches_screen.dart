import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/match_service.dart';
import 'chat_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = MatchService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmpty(theme);
          }

          final matches = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final data = matches[i].data() as Map<String, dynamic>;
              final matchId = matches[i].id;
              final otherUid = data['user1'] == uid ? data['user2'] : data['user1'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: service.getUserProfile(otherUid),
                builder: (context, profileSnap) {
                  if (!profileSnap.hasData) {
                    return const Card(child: ListTile(title: Text('Loading...')));
                  }
                  final profile = profileSnap.data!;
                  final firstName = profile['firstName'] ?? '';
                  final lastName = profile['lastName'] ?? '';
                  final destination = profile['topDestination'] ?? '';
                  final lastMsg = data['lastMessage'] as String?;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text('$firstName $lastName',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.flight_takeoff, size: 13, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(destination,
                                style: TextStyle(color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500, fontSize: 12)),
                          ]),
                          if (lastMsg != null)
                            Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          matchId: matchId,
                          otherName: '$firstName $lastName',
                          otherUid: otherUid,
                          destination: destination,
                        ),
                      )),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.favorite_border, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('No matches yet', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Go to Explore and swipe right on travelers heading to the same destination!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
      ]),
    ));
  }
}