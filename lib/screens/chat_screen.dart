import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/match_service.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String otherName;
  final String otherUid;
  final String destination;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.otherName,
    required this.otherUid,
    required this.destination,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = MatchService();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _service.sendMessage(matchId: widget.matchId, text: text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(widget.otherName[0].toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.otherName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              Icon(Icons.flight_takeoff,
                  size: 12, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(widget.destination,
                  style: TextStyle(
                      fontSize: 12, color: theme.colorScheme.primary)),
            ]),
          ]),
        ]),
      ),
      body: Column(children: [
        // Match banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: theme.colorScheme.primaryContainer,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.favorite, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
                'You matched! Plan your trip to ${widget.destination} together 🌍',
                style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ]),
        ),
        // Messages
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
          stream: _service.getMessages(widget.matchId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final msgs = snapshot.data!.docs;
            if (msgs.isEmpty) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.waving_hand,
                        size: 48, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('Say hi to ${widget.otherName.split(' ').first}! 👋',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ]));
            }
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final data = msgs[i].data() as Map<String, dynamic>;
                final isMe = data['senderId'] == _uid;
                final text = data['text'] ?? '';
                final ts = data['createdAt'] as Timestamp?;
                final time = ts != null
                    ? '${ts.toDate().hour}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                    : '';

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: isMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(text,
                              style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(time,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white70
                                      : theme.colorScheme.outline)),
                        ]),
                  ),
                );
              },
            );
          },
        )),
        // Input
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2))
            ],
          ),
          child: Row(children: [
            Expanded(
                child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Message ${widget.otherName.split(' ').first}...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
