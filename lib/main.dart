// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/book_details.dart';
import 'screens/profile_page.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

// In lib/main.dart – only change the home:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanglaRead',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3E2723),
        scaffoldBackgroundColor: const Color(0xFFFAF7F5),
        fontFamily: 'Kalpurush', // Optional: Add Bengali font later
      ),
      home: const SplashScreen(), // Splash shows first!
    );
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BanglaRead', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
    onPressed: () => Scaffold.of(context).openDrawer(),   // This opens the drawer
  ),
),
      ),
drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF3E2723)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundImage: NetworkImage('https://i.imgur.com/BoN9kdC.jpeg'),
            ),
            SizedBox(height: 12),
            Text('আহমেদ খান', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('ahmed@example.com', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),

      // প্রোফাইল – Fixed with Builder to get correct context
      Builder(
        builder: (context) => ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('প্রোফাইল'),
          onTap: () {
            Navigator.pop(context); // close drawer first
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
      ),

      ListTile(leading: const Icon(Icons.menu_book_rounded), title: const Text('আমার বইসমূহ'), onTap: () {}),
      ListTile(leading: const Icon(Icons.favorite_border), title: const Text('পছন্দের তালিকা'), onTap: () {}),
      ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('সেটিংস'), onTap: () {}),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('লগ আউট', style: TextStyle(color: Colors.red)),
        onTap: () {},
      ),
    ],
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar – Elegant
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'খুঁজুন আপন.bingার প্রিয় বই...',
                  hintStyle: const TextStyle(color: Colors.brown),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6D4C41)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Currently Reading
            const Text('আপনি এখন পড়ছেন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 16),
            SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  currentlyReadingCard(context, "দেবদাস", "শরৎচন্দ্র চট্টোপাধ্যায়", "https://i.imgur.com/8QzN4p8.jpg"),
                  currentlyReadingCard(context, "অপ্রকাশিত রচনাবলী", "হুমায়ূন আহমেদ", "https://i.imgur.com/3d5p9kZ.jpg"),
                  addNewCard(),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Want to Read
            const Text('পড়তে চান', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 16),
             SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  currentlyReadingCard(context, "দেবদাস", "শরৎচন্দ্র চট্টোপাধ্যায়", "https://i.imgur.com/8QzN4p8.jpg"),
                  currentlyReadingCard(context, "অপ্রকাশিত রচনাবলী", "হুমায়ূন আহমেদ", "https://i.imgur.com/3d5p9kZ.jpg"),
                  addNewCard(),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Suggestions for You
            const Text('আপনার জন্য সাজেশন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 16),
            SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  currentlyReadingCard(context, "দেবদাস", "শরৎচন্দ্র চট্টোপাধ্যায়", "https://i.imgur.com/8QzN4p8.jpg"),
                  currentlyReadingCard(context, "অপ্রকাশিত রচনাবলী", "হুমায়ূন আহমেদ", "https://i.imgur.com/3d5p9kZ.jpg"),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget currentlyReadingCard(BuildContext context, String title, String author, String coverUrl) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetails(bookTitle: title, bookAuthor: author, bookCoverUrl: coverUrl, bookRating: 4.7))),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(coverUrl, height: 160, width: 110, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 10),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3E2723))),
          ],
        ),
      ),
    );
  }

  Widget addNewCard() {
    return Container(
      width: 130,
      height: 210,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 8)],
      ),
      child: const Icon(Icons.add_rounded, size: 56, color: Color(0xFF8D6E63)),
    );
  }
}

// Reusable elegant grid card
class BookGridCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverUrl;

  const BookGridCard({super.key, required this.title, required this.author, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetails(bookTitle: title, bookAuthor: author, bookCoverUrl: coverUrl, bookRating: 4.5))),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(coverUrl, height: 150, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 10),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF3E2723))),
          Text(author, style: const TextStyle(fontSize: 10, color: Color(0xFF6D4C41)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}