import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/user_utils.dart';

/// Dynamic Edit Profile Screen for LIVE IT — BY AZAM
/// Connects display name, username, bio, and avatar to real user data,
/// shared state management, and the persistence layer.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  String _initialName = '';
  String _initialUsername = '';
  String _initialBio = '';
  String? _currentPhotoUrl;
  File? _selectedImageFile;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPickingImage = false;

  String? _nameError;
  String? _usernameError;
  String? _bioError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final currentUser = AuthService.instance.currentUser;
    final profile = await StorageService.getUserProfile(uid: currentUser?.uid);

    // Dynamic display name and username resolution using UserUtils
    final resolvedName = UserUtils.resolveDisplayName(
      savedName: profile.name,
      authDisplayName: currentUser?.displayName,
      email: currentUser?.email,
    );

    final resolvedUsername = UserUtils.resolveUsername(
      savedUsername: profile.username,
      email: currentUser?.email,
    );

    final resolvedBio = profile.bio;
    String? authPhoto;
    try {
      authPhoto = currentUser?.photoURL;
    } catch (_) {}
    final resolvedPhotoUrl = profile.photoUrl ?? authPhoto;

    if (mounted) {
      setState(() {
        _initialName = resolvedName;
        _initialUsername = resolvedUsername;
        _initialBio = resolvedBio;
        _currentPhotoUrl = resolvedPhotoUrl;

        _nameController.text = _initialName;
        _usernameController.text = _initialUsername;
        _bioController.text = _initialBio;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isSaving || _isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        if (await file.exists()) {
          setState(() {
            _selectedImageFile = file;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selected image could not be loaded.'),
                backgroundColor: AppColors.brightRed,
              ),
            );
          }
        }
      }
      // If picked == null, user cancelled; gracefully do nothing.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selection failed: $e'),
            backgroundColor: AppColors.brightRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving || _isLoading) return;

    // 1. Validate Display Name
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) {
      setState(() => _nameError = 'Name cannot be empty');
      return;
    } else if (rawName.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return;
    } else if (rawName.length > 50) {
      setState(() => _nameError = 'Name cannot exceed 50 characters');
      return;
    } else {
      setState(() => _nameError = null);
    }

    // 2. Validate Username
    var rawUsername = _usernameController.text.trim();
    if (rawUsername.startsWith('@')) {
      rawUsername = rawUsername.substring(1).trim();
    }
    if (rawUsername.isEmpty) {
      setState(() => _usernameError = 'Username cannot be empty');
      return;
    } else if (rawUsername.length < 3 || rawUsername.length > 30) {
      setState(() => _usernameError = 'Username must be between 3 and 30 characters');
      return;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(rawUsername)) {
      setState(() => _usernameError = 'Letters, numbers, and underscores only');
      return;
    } else {
      setState(() => _usernameError = null);
    }

    // 3. Validate Bio
    final rawBio = _bioController.text.trim();
    if (rawBio.length > 150) {
      setState(() => _bioError = 'Bio cannot exceed 150 characters');
      return;
    } else {
      setState(() => _bioError = null);
    }

    // 4. Change Detection: Check whether anything has actually changed
    final hasNameChanged = rawName != _initialName;
    final hasUsernameChanged = rawUsername != _initialUsername;
    final hasBioChanged = rawBio != _initialBio;
    final hasImageChanged = _selectedImageFile != null;

    if (!hasNameChanged && !hasUsernameChanged && !hasBioChanged && !hasImageChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalPhotoPath = _currentPhotoUrl;

      // 5. Persist selected image locally to permanent documents directory
      if (_selectedImageFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final filePath = _selectedImageFile!.path;
        final lastDot = filePath.lastIndexOf('.');
        final ext = (lastDot != -1 && lastDot < filePath.length - 1)
            ? filePath.substring(lastDot)
            : '.jpg';
        final currentUser = AuthService.instance.currentUser;
        final fileName = 'avatar_${currentUser?.uid ?? 'local'}_${DateTime.now().millisecondsSinceEpoch}$ext';
        final savedFile = await _selectedImageFile!.copy('${appDir.path}/$fileName');
        finalPhotoPath = savedFile.path;
      }

      final updatedProfile = UserProfile(
        name: rawName,
        username: rawUsername,
        bio: rawBio,
        photoUrl: finalPhotoPath,
      );

      final currentUser = AuthService.instance.currentUser;

      // 6. Persist to local storage with user isolation
      await StorageService.saveUserProfile(updatedProfile, uid: currentUser?.uid);

      // 7. Update shared AudioPlayerService state reactively
      if (mounted) {
        await Provider.of<AudioPlayerService>(context, listen: false)
            .updateUserProfile(updatedProfile);
      }

      // 8. Synchronize with Firebase Auth & Cloud Firestore if authenticated
      if (currentUser != null) {
        try {
          if (currentUser.displayName != rawName) {
            await currentUser.updateDisplayName(rawName);
          }
        } catch (e) {
          debugPrint('FirebaseAuth updateDisplayName notice: $e');
        }

        try {
          await FirestoreService.instance.updateUserProfile(
            uid: currentUser.uid,
            displayName: rawName,
            username: rawUsername,
            bio: rawBio,
            photoUrl: finalPhotoPath,
          );
        } catch (e) {
          debugPrint('FirestoreService updateUserProfile notice: $e');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      // Preserve unsaved edits on failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.brightRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildAvatarContent() {
    if (_isPickingImage) {
      return Container(
        color: Colors.black54,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brightRed),
            ),
          ),
        ),
      );
    }

    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    }

    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      if (_currentPhotoUrl!.startsWith('http://') ||
          _currentPhotoUrl!.startsWith('https://')) {
        return Image.network(
          _currentPhotoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        );
      } else {
        final file = File(_currentPhotoUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
          );
        }
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/sasuke_profile.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.person,
        color: AppColors.brightRed,
        size: 55,
      ),
    );
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
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brightRed,
                    ),
                  ),
                ),
              ),
            )
          else
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.brightRed,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Avatar Edit Circle matching Mockup #9
                    Center(
                      child: GestureDetector(
                        onTap: _isSaving ? null : _pickImage,
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
                                child: _buildAvatarContent(),
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
                    ),
                    const SizedBox(height: 32),

                    // Full Name Input
                    _buildEditTile(
                      label: 'Name',
                      controller: _nameController,
                      errorText: _nameError,
                      hintText: 'Enter your display name',
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username Input
                    _buildEditTile(
                      label: 'Username',
                      controller: _usernameController,
                      errorText: _usernameError,
                      hintText: 'Enter username (e.g. azam_uchiha)',
                      onChanged: (_) {
                        if (_usernameError != null) {
                          setState(() => _usernameError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bio Input
                    _buildEditTile(
                      label: 'Bio',
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 150,
                      errorText: _bioError,
                      hintText: 'Tell the world about yourself...',
                      onChanged: (_) {
                        if (_bioError != null) {
                          setState(() => _bioError = null);
                        }
                      },
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
    int? maxLength,
    String? errorText,
    String? hintText,
    void Function(String)? onChanged,
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
          maxLength: maxLength,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
            errorText: errorText,
            counterStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.brightRed,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
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
