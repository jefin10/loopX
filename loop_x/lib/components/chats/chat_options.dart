import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/providers/chat_providers.dart';
import 'package:go_router/go_router.dart';

class ChatOptions extends ConsumerWidget {
  const ChatOptions({super.key, required this.chats});
  final List<Map<String, dynamic>> chats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    if (currentUserId == null) {
      return const Center(child: Text('Please sign in to view chats'));
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, int index) {
        final chat = chats[index];
        final user1 = chat['user1_id'] as String;
        final user2 = chat['user2_id'] as String;
        final otherUserId = (user1 == currentUserId) ? user2 : user1;

        return _ChatListItem(
          chatId: chat['id'] as String,
          otherUserId: otherUserId,
        );
      },
    );
  }
}

class _ChatListItem extends ConsumerWidget {
  const _ChatListItem({
    required this.chatId,
    required this.otherUserId,
  });

  final String chatId;
  final String otherUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameAsync = ref.watch(usernameProvider(otherUserId));

    return usernameAsync.when(
      loading: () => ListTile(
        leading: const CircularProgressIndicator(),
        title: const Text('Loading...'),
        subtitle: Text('Chat ID: $chatId'),
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error, color: Colors.red),
        title: const Text('Error loading user'),
        subtitle: Text('Chat ID: $chatId'),
      ),
      data: (username) => ListTile(
        leading: CircleAvatar(
          child: Text(username?[0].toUpperCase() ?? '?'),
        ),
        title: Text(username ?? 'Unknown user'),
        subtitle: Text('Chat ID: $chatId'),
        onTap: () {
          context.go('/chat/$chatId'); // Navigate to chat page with chatId
        },
      ),
    );
  }
}