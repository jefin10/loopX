import 'package:flutter/material.dart';
import 'package:loop_x/components/chats/chat_options.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  

  @override
  State<ChatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> chatRooms = [];

  Future<void> fetchChatRooms() async{
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    final response = await Supabase.instance.client
    .from('chat_rooms')
    .select('id, user1_id, user2_id')
    .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId');
    setState(() {
      chatRooms= response;
    });

  }
  @override
  void initState() {
    super.initState();
    fetchChatRooms();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Text("Your Chats"),
        backgroundColor: Colors.transparent,
      ),
      body: ChatOptions(chats: chatRooms)
    );
  }
}