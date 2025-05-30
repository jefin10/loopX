import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop_x/components/profile/profile_posts.dart';
import 'package:loop_x/components/profile/profile_tweets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileGuestPage extends ConsumerStatefulWidget {
  final String userId;
  
  const ProfileGuestPage({super.key, required this.userId});

  @override
  ConsumerState<ProfileGuestPage> createState() => _ProfileGuestPageState();
}

class _ProfileGuestPageState extends ConsumerState<ProfileGuestPage> {
  final supabase = Supabase.instance.client;
  String username = "";
  String bio = "";
  String profileImageUrl = "";
  int followersCount = 0;
  int followingCount = 0;
  List<Map<String, dynamic>> postResponse = [];
  List<Map<String, dynamic>> tweetResponse = [];
  bool isFollowing = false;
  bool isLoading = true;
  bool isFollowLoading = false;
  bool isMessageLoading = false;
  
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkFollowingStatus();
  }
  
  void _fetchUserProfile() async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.userId)
          .single();
      
      final follower = await supabase
          .from('follows')
          .select()
          .eq('following_id', widget.userId);
      
      final following = await supabase
          .from('follows')
          .select()
          .eq('follower_id', widget.userId);
      
      final allPostsResponse = await supabase
          .from('posts')
          .select('id, text, image_url, profiles(username, avatar_url)')
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);
      
      List<Map<String, dynamic>> posts = [];
      List<Map<String, dynamic>> tweets = [];
      
      for (var item in allPostsResponse) {
        if (item['image_url'] != null && item['image_url'].toString().isNotEmpty) {
          posts.add(item);
        } else {
          tweets.add(item);
        }
      }
      
      setState(() {
        username = response['username'] ?? '';
        bio = response['bio'] ?? '';
        profileImageUrl = response['avatar_url'] ?? '';
        followersCount = follower.length;
        followingCount = following.length;
        postResponse = posts;
        tweetResponse = tweets;
        isLoading = false;
      });
    } catch (error) {
      setState(() => isLoading = false);
      print('Error fetching user profile: $error');
    }
  }
  
  void _checkFollowingStatus() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;
    
    try {
      final response = await supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', widget.userId);
      
      setState(() {
        isFollowing = response.isNotEmpty;
      });
    } catch (error) {
      print('Error checking follow status: $error');
    }
  }
  
  void _toggleFollow() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to follow users')),
      );
      return;
    }
    
    setState(() => isFollowLoading = true);
    
    try {
      if (isFollowing) {
        // Unfollow
        await supabase
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', widget.userId);
        
        setState(() {
          isFollowing = false;
          followersCount = followersCount - 1;
        });
      } else {
        // Follow
        await supabase.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': widget.userId,
        });
        
        setState(() {
          isFollowing = true;
          followersCount = followersCount + 1;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() => isFollowLoading = false);
    }
  }
  
  void _sendMessage() async {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to message users')),
      );
      return;
    }
    
    setState(() => isMessageLoading = true);
    
    try {
      // First check if chat room already exists
      // We need to order the IDs to match the constraint in the schema
      final user1 = currentUserId.compareTo(widget.userId) < 0 ? currentUserId : widget.userId;
      final user2 = currentUserId.compareTo(widget.userId) < 0 ? widget.userId : currentUserId;
      
      var response = await supabase
          .from('chat_rooms')
          .select()
          .eq('user1_id', user1)
          .eq('user2_id', user2)
          .maybeSingle();
      
      String chatId;
      
      if (response != null) {
        // Chat exists, get its ID
        chatId = response['id'];
      } else {
        // Create new chat room
        response = await supabase
            .from('chat_rooms')
            .insert({
              'user1_id': user1,
              'user2_id': user2,
            })
            .select()
            .single();
        
        chatId = response['id'];
      }
      
      // Navigate to chat
      if (mounted) {
        context.go('/chat/$chatId');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isMessageLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                username.isNotEmpty ? username : 'Unknown',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (bio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  bio,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      followersCount.toString(),
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text('Followers'),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    Text(
                      followingCount.toString(),
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text('Following'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Follow and Message buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isFollowLoading ? null : _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
                    foregroundColor: isFollowing ? Colors.black : Colors.white,
                    minimumSize: const Size(120, 40),
                  ),
                  child: isFollowLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isFollowing ? 'Following' : 'Follow'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isMessageLoading ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                  ),
                  child: isMessageLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Message'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tab bar for posts and tweets
            TabBar(tabs: [
              Tab(text: 'Posts (${postResponse.length})'),
              Tab(text: 'Tweets (${tweetResponse.length})'),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  ProfilePosts(posts: postResponse),
                  ProfileTweets(tweets: tweetResponse),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}