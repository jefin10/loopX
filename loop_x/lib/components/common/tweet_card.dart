import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TweetCard extends StatefulWidget {
  final String postId;
  final String username;
  final String text;
  final String profileImageUrl;
  
  const TweetCard({
    super.key,
    required this.postId,
    required this.username,
    required this.text,
    required this.profileImageUrl,
  });
  
  @override
  State<TweetCard> createState() => _TweetCardState(); 
}

class _TweetCardState extends State<TweetCard> {
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
        const SnackBar(content: Text('Please log in to like tweets')),
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
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 10),
            
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
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isLoading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
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