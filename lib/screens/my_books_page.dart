// lib/screens/my_books_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bangla_read/screens/book_details.dart'; // ADD THIS

class MyBooksPage extends StatelessWidget {
  const MyBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        title: const Text("My Finished Books"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('category', isEqualTo: 'finished_reading')
            .snapshots(),
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
            return const Center(
              child: Text(
                "You haven't finished any books yet!\nTap 'পড়া শেষ' in Book Details to add here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final String coverUrl = data['coverUrl'] ?? '';
              final String title = data['title'] ?? 'No Title';
              final String author = data['author'] ?? 'Unknown';
              final double rating = (data['rating'] ?? 4.0).toDouble();
              final String? finishedDate = data['finishedDate'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // OPEN BOOK DETAILS
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookDetails(
                          bookTitle: title,
                          bookAuthor: author,
                          bookCoverUrl: coverUrl,
                          bookRating: rating,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Book Cover
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: coverUrl.isNotEmpty
                              ? Image.network(
                                  coverUrl,
                                  width: 60,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 90,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book,
                                        color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book,
                                      color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 16),

                        // Book Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                author,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text("$rating",
                                      style: const TextStyle(fontSize: 15)),
                                  const Spacer(),
                                  Text(
                                    finishedDate ?? "Recently",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Optional: Add arrow
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
