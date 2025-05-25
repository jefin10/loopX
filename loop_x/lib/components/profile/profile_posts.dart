import 'package:flutter/material.dart';
import 'package:loop_x/components/common/post_card.dart';


class ProfilePosts extends StatefulWidget {
  final List<Map<String, dynamic>> posts;

  const ProfilePosts({super.key, required this.posts});

  @override
  State<ProfilePosts> createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts>{
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final profile = post['profiles'] as Map<String, dynamic>?;
        return PostCard(
        username: profile?['username'] ?? 'Unknown',
        text: post['text'] ?? '',
        imageUrl: post['image_url'] ?? '',
        profileImageUrl: profile?['avatar_url'] ?? '',
      );
              },
    );
  }
} 