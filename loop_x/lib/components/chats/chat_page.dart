import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/providers/chat_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:loop_x/providers/user_id_provider.dart';
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = ref.read(currentUserIdProvider);
    
    final usernameAsync = ref.watch(usernameForIdProvider(currentUserId));
    

    if (currentUserId == null) return;

    setState(() => _isSending = true);

    try {
      await ref.read(supabaseProvider).from('messages').insert({
        'chat_room_id': widget.chatId,
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
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = ref.watch(currentUserIdProvider);
    

    
    final usernameAsync = ref.watch(usernameForIdProvider(currentUserId));
    final messages = ref.watch(chatMessagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
       title: Row(
         children: [
          IconButton(
              icon: Icon(Icons.arrow_back, size: 24),
              onPressed: () {
                context.go('/chat');
              },
            ),
           usernameAsync.when(
              data: (username) => Text('Chat with ${username ?? "Anonymous"}'),
              loading: () => Row(
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text("Loading..."),
                ],
              ),
              error: (err, _) => Text("Chat"),
            ),
         ],
       ),

        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              loading: () => const Center(child: CircularProgressIndicator(
                color: Colors.deepPurple,
              )),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error loading messages'),
                    Text(
                      '$err',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              data: (messagesList) {
                if (messagesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline, 
                          size: 64, 
                          color: Colors.deepPurple
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet. Start chatting!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
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

                    return Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe) 
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                            child: Text(
                              "User",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.deepPurple : Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.deepPurple.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.deepPurple.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: _isSending ? null : _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending 
                      ? SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        )
                      : Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}