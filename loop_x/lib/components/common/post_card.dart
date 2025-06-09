import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String text;
  final String imageUrl;
  final String profileImageUrl;
  
  const PostCard({
    super.key,
    required this.postId,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.profileImageUrl,
  });
  
  @override
  State<PostCard> createState() => _PostCardState(); 
}

class _PostCardState extends State<PostCard> {
  final supabase = Supabase.instance.client;
  final String currentUserId = Supabase.instance.client.auth.currentUser?.id ?? "";
  
  int likesCount = 0;
  bool isLiked = false;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.postId.isNotEmpty) {
      _fetchLikes();
    }
  }
  
  void _fetchLikes() async {
    try {
      final likesResponse = await supabase
          .from('likes')
          .select()
          .eq('post_id', widget.postId);
      
      final userLikeResponse = await supabase
          .from('likes')
          .select()
          .eq('post_id', widget.postId)
          .eq('user_id', currentUserId);
      
      setState(() {
        likesCount = likesResponse.length;
        isLiked = userLikeResponse.isNotEmpty;
      });
    } catch (error) {
      print('Error fetching likes: $error');
    }
  }
  
  void _toggleLike() async {
    if (widget.postId.isEmpty || currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like posts')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLiked) {
        await supabase
            .from('likes')
            .delete()
            .eq('post_id', widget.postId)
            .eq('user_id', currentUserId);
        
        setState(() {
          likesCount--;
          isLiked = false;
        });
      } else {
        await supabase.from('likes').insert({
          'post_id': widget.postId,
          'user_id': currentUserId,
        });
        
        setState(() {
          likesCount++;
          isLiked = true;
        });
      }
    } catch (error) {
      print('Error toggling like: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.profileImageUrl.isNotEmpty
                      ? NetworkImage(widget.profileImageUrl)
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  radius: 20,
                  onBackgroundImageError: (_, __) {
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
            
            if (widget.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                GestureDetector(
                  onTap: isLoading ? null : _toggleLike,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$likesCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isLoading) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}