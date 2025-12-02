// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/book_details.dart';
import 'screens/profile_page.dart';
import 'screens/my_books_page.dart';
import 'screens/settings_page.dart';
import 'screens/all_books_page.dart';
import 'screens/register_page.dart';
import 'screens/Login_page.dart';
import 'screens/auth_service.dart';
import 'screens/favorite_books_page.dart';

// Provider
import 'providers/theme_provider.dart';
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/book_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'BanglaRead',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primaryColor: const Color(0xFF3E2723),
            scaffoldBackgroundColor: const Color(0xFFFAF7F5),
            fontFamily: 'Kalpurush',
            brightness: Brightness.light,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6D4C41),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: themeProvider.fontSize),
              bodyMedium: TextStyle(fontSize: themeProvider.fontSize - 2),
              titleLarge: TextStyle(
                  fontSize: themeProvider.fontSize + 6,
                  fontWeight: FontWeight.bold),
            ),
          ),
          darkTheme: ThemeData(
            primaryColor: const Color(0xFF6D4C41),
            scaffoldBackgroundColor: const Color(0xFF121212),
            brightness: Brightness.dark,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6D4C41),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                  fontSize: themeProvider.fontSize, color: Colors.white),
              bodyMedium: TextStyle(
                  fontSize: themeProvider.fontSize - 2, color: Colors.white70),
              titleLarge: TextStyle(
                  fontSize: themeProvider.fontSize + 6,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/register': (_) => const RegisterPage(),
            '/login': (_) => const LoginPage(),
            '/home': (_) => const HomePage(),
            '/profile': (_) => const ProfilePage(),
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.value.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const RegisterPage();
        }
        if (snapshot.hasData) return const HomePage();
        return const SplashScreen();
      },
    );
  }
}

// ================================================================
// HOME PAGE – DYNAMIC + "+" OPENS ALL BOOKS
// ================================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // "+" Card
  Widget addNewCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllBooksPage(targetCategory: category),
          ),
        );
      },
      child: Container(
        width: 130,
        height: 210,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 8)
          ],
        ),
        child:
            const Icon(Icons.add_rounded, size: 56, color: Color(0xFF8D6E63)),
      ),
    );
  }

  // Book Card – MERGED WITH YOUR GRID STYLE
  Widget bookCard(BuildContext context, Map<String, dynamic> book) {
    final String title = book['title'] ?? 'No Title';
    final String author = book['author'] ?? 'Unknown';
    final String coverUrl = book['coverUrl'] ?? '';
    final double rating = (book['rating'] ?? 4.5).toDouble();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetails(
              bookTitle: title,
              bookAuthor: author,
              bookCoverUrl: coverUrl,
              bookRating: rating,
            ),
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        height: 160,
                        width: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          width: 110,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 40),
                        ),
                      )
                    : Container(
                        height: 160,
                        width: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 40),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF3E2723),
              ),
            ),
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6D4C41),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Builder
  Widget buildSection(BuildContext context, String title, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              final userId = authSnapshot.data?.uid;

              // If no user → show login message
              if (userId == null) {
                return const Center(
                  child: Text(
                    'লগইন করুন',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              // User is logged in → load books
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .where('userId', isEqualTo: userId)
                    .where('category', isEqualTo: category)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading books'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == docs.length) {
                        return addNewCard(context, category);
                      }
                      final data = docs[index].data()! as Map<String, dynamic>;
                      return bookCard(context, data);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BanglaRead',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Builder(
          builder: (c) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
            onPressed: () => Scaffold.of(c).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF3E2723)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        authService.value.currentUser?.photoURL ??
                            'https://i.imgur.com/BoN9kdC.jpeg',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authService.value.currentUser?.displayName ?? 'User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authService.value.currentUser?.email ?? 'No email',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('প্রোফাইল'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('আমার বইসমূহ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBooksPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('পছন্দের তালিকা'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteBooksPage()),
                );
              },
            ),
            Consumer<ThemeProvider>(
              builder: (context, theme, child) {
                return ListTile(
                  leading: const Icon(Icons.settings, color: Color(0xFF6D4C41)),
                  title: const Text("সেটিংস"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('লগ আউট', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authService.value.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (r) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              // child: TextField(
              //   decoration: InputDecoration(
              //     hintText: 'খুঁজুন আপনার প্রিয় বই...',
              //     hintStyle: const TextStyle(color: Colors.brown),
              //     prefixIcon:
              //         const Icon(Icons.search, color: Color(0xFF6D4C41)),
              //     border: InputBorder.none,
              //     contentPadding: const EdgeInsets.symmetric(vertical: 16),
              //   ),
              // ),
            ),
            const SizedBox(height: 32),
            buildSection(context, 'আপনি এখন পড়ছেন', 'currently_reading'),
            const SizedBox(height: 40),
            buildSection(context, 'পড়তে চান', 'want_to_read'),
            const SizedBox(height: 40),

            // // SUGGESTIONS SECTION – SHOW ALL BOOKS (NO + BUTTON)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         'আমাদের সাজেশন',
            //         style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //             color: Color(0xFF3E2723)),
            //       ),
            //       TextButton(
            //         onPressed: () {
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //                 builder: (_) => const AllBooksPage(
            //                     targetCategory: 'want_to_read')),
            //           );
            //         },
            //         child: const Text('আরও দেখুন',
            //             style: TextStyle(color: Color(0xFF6D4C41))),
            //       ),
            //     ],
            //   ),
            // ),

// SUGGESTIONS SECTION – SHOW ALL BOOKS (NO + BUTTON)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'আমাদের সাজেশন',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723)),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (category) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AllBooksPage(targetCategory: category),
                        ),
                      );
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'want_to_read',
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border, size: 18),
                            SizedBox(width: 8),
                            Text('পড়তে চান'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'currently_reading',
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, size: 18),
                            SizedBox(width: 8),
                            Text('এখন পড়ছেন'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6D4C41)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'আরও দেখুন',
                            style: TextStyle(
                              color: Color(0xFF6D4C41),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down,
                              color: Color(0xFF6D4C41), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 220,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6D4C41)));
                  }
                  if (snapshot.hasError)
                    return const Center(child: Text('Error loading books'));

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No books available'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data()! as Map<String, dynamic>;
                      final String coverUrl = data['coverUrl'] ?? '';
                      final String title = data['title'] ?? 'No Title';
                      final String author = data['author'] ?? 'Unknown';
                      final double rating = (data['rating'] ?? 4.0).toDouble();

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetails(
                                bookTitle: title,
                                bookAuthor: author,
                                bookCoverUrl: coverUrl,
                                bookRating: rating,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 160,
                                          color: Colors.grey[300],
                                          child:
                                              const Icon(Icons.book, size: 50),
                                        ),
                                      )
                                    : Container(
                                        height: 160,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.book, size: 50),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('$rating',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
