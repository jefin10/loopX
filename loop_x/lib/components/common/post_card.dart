import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String text;
  final String imageUrl;
  final String profileImageUrl;
  
  const PostCard({
    super.key,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.profileImageUrl,
  });
  @override
  State<PostCard> createState() => _PostCardState(); 
}

class _PostCardState extends State<PostCard> {
  
  @override
  Widget build(context){
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.profileImageUrl),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Text(widget.username, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.text),
            if (widget.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.network(widget.imageUrl, fit: BoxFit.cover),
              ),
          ],
        ),
      ),
    );
  }
}