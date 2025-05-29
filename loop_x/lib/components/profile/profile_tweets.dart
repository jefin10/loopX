import 'package:flutter/material.dart';
import 'package:loop_x/components/common/tweet_card.dart';

class ProfileTweets extends StatefulWidget {
  final List<Map<String, dynamic>> tweets;

  const ProfileTweets({super.key, required this.tweets});

  @override
  State<ProfileTweets> createState() => _ProfileTweetsState();
}

class _ProfileTweetsState extends State<ProfileTweets> {
  @override
  Widget build(BuildContext context) {
    if (widget.tweets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No tweets yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.tweets.length,
      itemBuilder: (context, index) {
        final tweet = widget.tweets[index];
        final profile = tweet['profiles'] as Map<String, dynamic>?;
        
        return TweetCard(
          postId: tweet['id']?.toString() ?? '',
          username: profile?['username'] ?? 'Unknown',
          text: tweet['text'] ?? '',
          profileImageUrl: profile?['avatar_url'] ?? '',
        );
      },
    );
  }
}