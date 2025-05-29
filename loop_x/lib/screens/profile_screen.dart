import 'package:flutter/material.dart';
import 'package:loop_x/components/profile/profile_posts.dart';
import 'package:loop_x/components/profile/profile_tweets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen>{
  final SupabaseClient supabase = Supabase.instance.client;
  final String userId = Supabase.instance.client.auth.currentUser?.id ?? "";
  String username = "";
  String email = "";
  String bio = "";
  String profileImageUrl = "";
  int followersCount = 0;
  int followingCount = 0;
  List<Map<String, dynamic>> postResponse = [];
  List<Map<String, dynamic>> tweetResponse = [];
 
  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  
  void _fetchUserProfile() async {
    try {
      final response = await supabase.from('profiles').select().eq('id', userId).single();
      final follower = await supabase
          .from('follows')
          .select()
          .eq('following_id', userId);
      
      final following = await supabase
          .from('follows')
          .select()
          .eq('follower_id', userId);
      
      final allPostsResponse = await supabase
          .from('posts')
          .select('id, text, image_url, profiles(username, avatar_url)')
          .eq('user_id', userId)
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
        email = response['email'] ?? '';
        bio = response['bio'] ?? '';
        profileImageUrl = response['avatar_url'] ?? '';
        followersCount = follower.length;
        followingCount = following.length;
        postResponse = posts;
        tweetResponse = tweets;
      });
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),
              Center(
                child: Text(
                  username.isNotEmpty ? username : 'Username',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  bio.isNotEmpty ? bio : 'This is your bio',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Followers: $followersCount',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '  Following: $followingCount',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }
}