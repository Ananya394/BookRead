// lib/screens/profile_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bangla_read/screens/auth_service.dart'; // <-- global authService

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers / state
  final _nameCtrl = TextEditingController();
  File? _pickedImage;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = authService.value.currentUser;
    _nameCtrl.text = user?.displayName ?? 'User';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // Pick image from gallery
  // --------------------------------------------------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (xFile != null) {
      setState(() => _pickedImage = File(xFile.path));
    }
  }

  // --------------------------------------------------------------
  // Save name (photoURL is local-only for demo – see note below)
  // --------------------------------------------------------------
  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final user = authService.value.currentUser!;
      await user.updateDisplayName(_nameCtrl.text.trim());

      // ---- OPTIONAL: upload image to Firebase Storage ----
      // if (_pickedImage != null) {
      //   final ref = FirebaseStorage.instance
      //       .ref('profile_pics/${user.uid}.jpg');
      //   await ref.putFile(_pickedImage!);
      //   final url = await ref.getDownloadURL();
      //   await user.updatePhotoURL(url);
      // }
      await user.reload();
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  // --------------------------------------------------------------
  // Helper – format Firebase creation date
  // --------------------------------------------------------------
  String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoURL ?? 'https://i.imgur.com/plant-avatar.jpg';
    final joined = user?.metadata?.creationTime != null
        ? _formatDate(user!.metadata!.creationTime!)
        : 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────── PROFILE HEADER ───────────────────────
            Row(
              children: [
                // Avatar (tap to pick when editing)
                GestureDetector(
                  onTap: _editing ? _pickImage : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : NetworkImage(photoUrl) as ImageProvider,
                      ),
                      if (_editing)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name – editable field
                      _editing
                          ? TextField(
                              controller: _nameCtrl,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: 'Enter name',
                              ),
                            )
                          : Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                      // Edit / Cancel button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _editing = !_editing;
                            if (!_editing) {
                              _nameCtrl.text = name;
                              _pickedImage = null;
                            }
                          });
                        },
                        child: Text(
                          _editing ? 'cancel' : 'edit profile',
                          style: const TextStyle(color: Color(0xFF6D4C41)),
                        ),
                      ),
                      const Text('Details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(email),
                      Text('Joined in $joined'),
                      const Text('last active this month',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),

            // ─────────────────────── SAVE / CANCEL (editing) ───────────────────────
            if (_editing) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _editing = false;
                              _nameCtrl.text = name;
                              _pickedImage = null;
                            }),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // ─────────────────────── RATINGS & REVIEWS ───────────────────────
            const Row(
              children: [
                Text('56 ratings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(' (3.82 avg)', style: TextStyle(color: Colors.grey)),
                Spacer(),
                Text('3 reviews',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('more photos (0)',
                  style: TextStyle(color: Color(0xFF6D4C41))),
            ),

            const Divider(height: 40),

            // ─────────────────────── FAVORITE BOOKS ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${name.toUpperCase()}'S FAVORITE BOOKS",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {},
                    child: const Text('remove',
                        style: TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  10,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/200/300?random=$i',
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Create a favorite shelf | Feature a different shelf | More...',
                  style: TextStyle(color: Color(0xFF6D4C41)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ─────────────────────── FOOTER LINKS ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMPANY',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('About us'),
                    Text('Careers'),
                    Text('Terms'),
                    Text('Privacy'),
                    Text('Interest Based Ads'),
                    Text('Ad Preferences'),
                    Text('Help'),
                  ],
                ),
                const Column(
                  children: [
                    Text('WORK WITH US',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Authors'),
                    Text('Advertise'),
                    Text('Authors & ads blog'),
                  ],
                ),
                Column(
                  children: [
                    const Text('CONNECT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.facebook, color: Color(0xFF1877F2)),
                        SizedBox(width: 16),
                        Icon(Icons.flutter_dash, color: Color(0xFF1DA1F2)),
                        SizedBox(width: 16),
                        Icon(Icons.camera_alt, color: Color(0xFFE1306C)),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------
// ShelfItem widget (unchanged)
// --------------------------------------------------------------
class ShelfItem extends StatelessWidget {
  final String title;
  final Color color;
  const ShelfItem({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
