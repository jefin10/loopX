import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loop_x/components/common/post_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final auth = AuthService();
  
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _fetchFeedPosts();
  }
  
  Future<void> _fetchFeedPosts() async {
    if (mounted) setState(() => isLoading = true);
    
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Not logged in');
      }
      
      // Get the IDs of users that the current user follows
      final followingResponse = await supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', currentUserId);
      
      final followingIds = List<String>.from(
        followingResponse.map((item) => item['following_id'])
      );
      
      // If user doesn't follow anyone, show a different message
      if (followingIds.isEmpty) {
        if (mounted) {
          setState(() {
            posts = [];
            isLoading = false;
          });
        }
        return;
      }
      
      // Fetch posts from followed users
      final postsResponse = await supabase
        .from('posts')
        .select('id, text, image_url, user_id, created_at, profiles(username, avatar_url)')
        .filter('user_id', 'in', followingIds)  // Changed from in_() to filter() 
        .order('created_at', ascending: false)
        .limit(20);
      
      if (mounted) {
        setState(() {
          posts = List<Map<String, dynamic>>.from(postsResponse);
          isLoading = false;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
      print('Error fetching feed: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LoopX"),
        
        backgroundColor: Colors.transparent,
        
      ),
      
      body: RefreshIndicator(
        onRefresh: _fetchFeedPosts,
        child: _buildBody(),
      ),
    );
  }
  
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (error != null) {
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            Text(error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFeedPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No posts to show',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Follow some users to see their posts here',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/search'),
              child: const Text('Find people to follow'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: posts.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final post = posts[index];
        final profile = post['profiles'] as Map<String, dynamic>;
        
        return PostCard(
          postId: post['id'],
          username: profile['username'] ?? 'Unknown',
          text: post['text'] ?? '',
          imageUrl: post['image_url'] ?? '',
          profileImageUrl: profile['avatar_url'] ?? '',
        );
      },
    );
  }
}