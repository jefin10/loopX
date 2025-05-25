import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  XFile? _selectedImage;
  final _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Request permissions for Android and iOS
    Map<Permission, PermissionStatus> statuses = await [
      if (Platform.isAndroid) Permission.photos,
      if (Platform.isAndroid) Permission.storage,
      if (Platform.isAndroid) Permission.camera,
      if (Platform.isIOS) Permission.photos,
    ].request();

    final photosStatus = statuses[Permission.photos];
    final storageStatus = statuses[Permission.storage];

    if ((photosStatus?.isGranted ?? false) ||
        (storageStatus?.isGranted ?? false)) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = image);
        debugPrint('Image selected: ${image.path}');
      } else {
        debugPrint('No image selected.');
      }
    } else {
      // Permissions denied
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
                "We need permission to access your photos. Please enable it in Settings."),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text("Open Settings"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _uploadPost() async {
  final caption = _captionController.text.trim();
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    debugPrint("No user logged in.");
    return;
  }

  if (caption.isEmpty && _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add text or image before uploading')),
    );
    return;
  }

  String? imageUrl;

  if (_selectedImage != null) {
    final imageFile = File(_selectedImage!.path);
    final fileExt = _selectedImage!.path.split('.').last;
    final fileName = '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    try {
      await Supabase.instance.client.storage
          .from('post-images')
          .upload(fileName, imageFile);

      imageUrl = Supabase.instance.client.storage
          .from('post-images')
          .getPublicUrl(fileName);

      debugPrint("Uploaded to Supabase. Public URL: $imageUrl");

    } catch (e) {
      debugPrint("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }
  }

  try {
    final response = await Supabase.instance.client.from('posts').insert({
  'user_id': user.id,
  'text': caption,
  'image_url': imageUrl,
}).select();

debugPrint("DB insert response: $response");


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post uploaded!')),
    );

    setState(() {
      _selectedImage = null;
      _captionController.clear();
    });
  } catch (e) {
    debugPrint("DB insert failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post upload failed')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Create a New Post',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _captionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write a caption...',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Select Image'),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _uploadPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Upload Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}