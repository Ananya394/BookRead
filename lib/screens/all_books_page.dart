// lib/screens/all_books_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllBooksPage extends StatefulWidget {
  final String targetCategory;

  const AllBooksPage({super.key, required this.targetCategory});

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সব বই'),
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'বই বা লেখক খুঁজুন...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6D4C41)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Book List – FIXED: NO userId FILTER
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('কোনো বই নেই'));
                }

                // Filter by search
                final filtered = docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final author =
                      (data['author'] ?? '').toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return title.contains(query) || author.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('কোনো বই পাওয়া যায়নি'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    final bookId = doc.id;
                    final title = data['title'] ?? 'No Title';
                    final author = data['author'] ?? 'Unknown';
                    final coverUrl = data['coverUrl'] ?? '';
                    final currentCategory = data['category'] ?? '';

                    final isAlreadyInCategory =
                        currentCategory == widget.targetCategory;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: coverUrl.isNotEmpty
                              ? Image.network(
                                  coverUrl,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book),
                                ),
                        ),
                        title: Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(author),
                        trailing: isAlreadyInCategory
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Color(0xFF6D4C41)),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('books')
                                        .doc(bookId)
                                        .update({
                                      'category': widget.targetCategory,
                                      'userId': FirebaseAuth
                                          .instance.currentUser?.uid,
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('$title যোগ করা হয়েছে'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
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
    );
  }
}
