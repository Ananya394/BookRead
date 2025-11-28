// lib/screens/writer_details.dart
import 'package:flutter/material.dart';

class WriterDetailsPage extends StatelessWidget {
  final String writerName;
  final String writerImage;
  final String birthDeath;
  final String description;
  final List<Map<String, String>> books;

  const WriterDetailsPage({
    super.key,
    required this.writerName,
    required this.writerImage,
    required this.birthDeath,
    required this.description,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        title: Text(writerName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Writer Photo + Name + Dates
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(writerImage),
                    onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 70),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    writerName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    birthDeath,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Description
            const Text(
              'বিবরণ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
            ),

            const SizedBox(height: 30),

            // Books Grid
            Text(
              '$writerName এর অন্যান্য বই',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book['title']} খোলা হচ্ছে...')),
                    );
                    // Later: Navigator.push to BookDetailsPage
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book['cover'] ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.book, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book['title'] ?? 'অজানা বই',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}