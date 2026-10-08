import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Edit Profile Screen matching Section 20 & Mockup #9
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final audio = Provider.of<AudioPlayerService>(context, listen: false);
    _nameController = TextEditingController(text: audio.rawUserName);
    _usernameController = TextEditingController(
      text: '${audio.rawUserName.toLowerCase().replaceAll(' ', '_')}_uchiha',
    );
    _bioController = TextEditingController(
      text: 'Music for the ones who understand...',
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.getUserProfile();
    if (mounted) {
      setState(() {
        _nameController.text = profile.name;
        _usernameController.text = profile.username;
        _bioController.text = profile.bio;
      });
    }
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isNotEmpty) {
      await StorageService.saveUserProfile(
        UserProfile(
          name: name,
          username: username.isEmpty ? 'azam_uchiha' : username,
          bio: bio.isEmpty ? 'Music for the ones who understand...' : bio,
        ),
      );
      if (mounted) {
        await Provider.of<AudioPlayerService>(
          context,
          listen: false,
        ).setUserName(name);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.brightRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar Edit Circle matching Mockup #9
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brightRed,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.brightRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Full Name Input
              _buildEditTile(label: 'Name', controller: _nameController),
              const SizedBox(height: 16),

              // Username Input
              _buildEditTile(
                label: 'Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),

              // Bio Input
              _buildEditTile(
                label: 'Bio',
                controller: _bioController,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditTile({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.brightRed,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
