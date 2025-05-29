import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/providers/chat_providers.dart';
import 'package:go_router/go_router.dart';
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    try {
      await ref.read(supabaseProvider).from('messages').insert({
        'chat_room_id': widget.chatId, // Correct field name
        'sender_id': currentUserId,
        'content': _messageController.text.trim(),
      });
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = ref.watch(currentUserIdProvider);
    final messages = ref.watch(chatMessagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
             IconButton(
              icon:  Icon(Icons.arrow_back, size: 24),
              onPressed: () {
                context.go('/chat'); 
              },
            ),  
            const SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Error loading messages'),
                        Text(
                          '$err',
                          style: const TextStyle(fontSize: 12),
                        ), // Show actual error
                      ],
                    ),
                  ),
              data: (messagesList) {
                if (messagesList.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start chatting!'),
                  );
                }

                return ListView.builder(
                  itemCount: messagesList.length,
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = messagesList[index];
                    final senderId = message['sender_id'] as String;
                    final content = message['content'] as String;
                    final bool isMe = senderId == currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
