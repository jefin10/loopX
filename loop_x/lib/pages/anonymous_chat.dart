import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AnonymousChat extends ConsumerStatefulWidget {
  const AnonymousChat({super.key});

  @override
  ConsumerState<AnonymousChat> createState() => _AnonymousChatState();
}

class _AnonymousChatState extends ConsumerState<AnonymousChat> {
  final TextEditingController _messageController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  final String anonymousId = const Uuid().v4();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  final Map<String, String> userNicknames = {};
  final List<String> anonymousNames = [
    'Shadow', 'Ghost', 'Phantom', 'Whisper', 'Enigma',
    'Mystery', 'Incognito', 'Unknown', 'Secret', 'Hidden',
    'Anon', 'Nameless', 'Invisible', 'Obscure', 'Stranger'
  ];
  
  @override
  void initState() {
    super.initState();
    _subscribeToAnonymousMessages();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  void _subscribeToAnonymousMessages() {
    supabase
      .from('anonymous_messages')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .limit(50)
      .listen((List<Map<String, dynamic>> data) {
        setState(() {
          messages = data;
          
          for (var message in data) {
            final id = message['anonymous_id'];
            if (!userNicknames.containsKey(id)) {
              final nameIndex = id.hashCode.abs() % anonymousNames.length;
              final number = id.hashCode.abs() % 1000;
              userNicknames[id] = '${anonymousNames[nameIndex]}#$number';
            }
          }
        });
      });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() => isLoading = true);
    
    try {
      final currentUserId = supabase.auth.currentUser!.id;
      
      await supabase.from('anonymous_messages').insert({
        'content': _messageController.text.trim(),
        'user_id': currentUserId,
        'anonymous_id': anonymousId,
      });
      
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e'))
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id;
    final myNickname = userNicknames[anonymousId] ?? 'Loading...';
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Anonymous Chat"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.masks, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      "Anonymous Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Your messages are anonymous",
                  style: TextStyle(color: Colors.deepPurple.shade800),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: messages.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, 
                            size: 64, color: Colors.deepPurple),
                        SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['anonymous_id'] == anonymousId;
                      final nickname = userNicknames[message['anonymous_id']] ?? 'Anonymous';
                      
                      return Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe) 
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                              child: Text(
                                nickname,
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
                                message['content'],
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
                    decoration: InputDecoration(
                      hintText: 'Type a message anonymously...',
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
                  onTap: isLoading ? null : _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading 
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