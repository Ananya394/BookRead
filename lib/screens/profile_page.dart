// lib/screens/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Profile Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.imgur.com/plant-avatar.jpg'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parvin Rahman',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('edit profile', style: TextStyle(color: Color(0xFF6D4C41))),
                      ),
                      const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Female'),
                      const Text('Joined in June 2020'),
                      const Text('last active this month', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Row(
              children: [
                Text('56 ratings', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(' (3.82 avg)', style: TextStyle(color: Colors.grey)),
                Spacer(),
                Text('3 reviews', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('more photos (0)', style: TextStyle(color: Color(0xFF6D4C41))),
            ),

            const Divider(height: 40),

            // Favorite Books
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("PARVIN'S FAVORITE BOOKS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('remove', style: TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(10, (i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://picsum.photos/200/300?random=$i', // Real working fake covers
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.book)),
                    ),
                  ),
                )),
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

            // Bookshelves
            const Text("PARVIN'S BOOKSHELVES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: const [
                ShelfItem(title: 'to-read (28)', color: Colors.blueAccent),
                ShelfItem(title: 'read (72)', color: Colors.green),
                ShelfItem(title: 'rereadable (3)', color: Colors.purple),
                ShelfItem(title: 'currently-reading (2)', color: Colors.orange),
                ShelfItem(title: 'amazing (4)', color: Colors.red),
              ],
            ),

            const SizedBox(height: 40),

            // Footer Links – FIXED SOCIAL ICONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // COMPANY
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMPANY', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('About us'),
                    Text('Careers'),
                    Text('Terms'),
                    Text('Privacy'),
                    Text('Interest Based Ads'),
                    Text('Ad Preferences'),
                    Text('Help'),
                  ],
                ),
                // WORK WITH US
                const Column(
                  children: [
                    Text('WORK WITH US', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Authors'),
                    Text('Advertise'),
                    Text('Authors & ads blog'),
                  ],
                ),
                // CONNECT – Fixed Icons
                Column(
                  children: [
                    const Text('CONNECT', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.facebook, color: const Color(0xFF1877F2)),
                        const SizedBox(width: 16),
                        Icon(Icons.flutter_dash, color: const Color(0xFF1DA1F2)), // Twitter bird
                        const SizedBox(width: 16),
                        Icon(Icons.camera_alt, color: const Color(0xFFE1306C)), // Instagram pink
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

// Shelf Item Widget
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
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}