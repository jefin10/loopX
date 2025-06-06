import 'package:flutter/material.dart';
import 'package:loop_x/components/profile/profile_posts.dart';
import 'package:loop_x/components/profile/profile_tweets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final follower = await supabase.from('follows').select().eq('following_id', userId);
      final following = await supabase.from('follows').select().eq('follower_id', userId);
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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.black,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.go('/profile/edit');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      context.go('/login');
                    },
                  ),
                ],
                bottom: TabBar(
                  tabs: [
                    Tab(text: "Posts (${postResponse.length})"),
                    Tab(text: "Tweets (${tweetResponse.length})"),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          username.isNotEmpty ? username : 'Username',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bio.isNotEmpty ? bio : 'Please add a bio',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "$followersCount",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "Followers",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              children: [
                                Text(
                                  "$followingCount",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  "Following",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ProfilePosts(posts: postResponse),
              ProfileTweets(tweets: tweetResponse),
            ],
          ),
        ),
      ),
    );
  }
}
