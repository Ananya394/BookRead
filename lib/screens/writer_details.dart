// lib/screens/writer_details.dart
import 'package:flutter/material.dart';

class WriterDetailsPage extends StatelessWidget {
  final String writerName;
  final String writerImage;
  final String birthDeath;
  final String profession;
  final String description;
  final List<Map<String, dynamic>> books;

  const WriterDetailsPage({
    super.key,
    required this.writerName,
    required this.writerImage,
    required this.birthDeath,
    required this.profession,
    required this.description,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        title: Text(writerName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top: Photo + Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      writerImage,
                      width: 120,
                      height: 170,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 170,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          writerName,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _infoRow("জন্ম:", birthDeath.split("–").first.trim()),
                        _infoRow(
                            "মৃত্যু:",
                            birthDeath.contains("–")
                                ? birthDeath.split("–").last.trim()
                                : ""),
                        _infoRow("পেশা:", profession),
                        _infoRow("জাতীয়তা:", "বাংলাদেশী"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            // Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "বিবরণ",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 16, height: 1.7, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            // LOWER PART – EXACTLY LIKE YOUR SCREENSHOT
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Followers Section
                  Row(
                    children: [
                      Text(
                        "Followers",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "see more...",
                          style:
                              TextStyle(color: Color(0xFF6D4C41), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Followers Avatars
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                "https://i.pravatar.cc/150?img=${index + 1}"),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Books Title
                  Text(
                    "$writerName এর বইসমূহ:",
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41)),
                  ),
                  const SizedBox(height: 16),

                  // Books Grid
                  // PUT THIS INSIDE YOUR WriterDetailsPage → replace the old GridView
// COMPACT BOOKS LIST – SAME STYLE AS MY BOOKS PAGE, BUT SMALLER HEIGHT
                  SizedBox(
                    height: books.length *
                        110, // auto height based on items (you can also use shrinkWrap in ListView)
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: SizedBox(
                              height: 100, // ← THIS MAKES IT SHORT & BEAUTIFUL
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    // Book Cover
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        book['cover'] ??
                                            'https://via.placeholder.com/150',
                                        width: 55,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 55,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child:
                                              const Icon(Icons.book, size: 30),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Book Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            book['title'] ?? "অজানা বই",
                                            style: const TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            writerName,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 18),
                                              const SizedBox(width: 4),
                                              Text(
                                                (book['rating'] ?? 4.0)
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const Spacer(),
                                              Text(
                                                book['date'] ?? "2025",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          children: [
            TextSpan(
                text: label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " $value"),
          ],
        ),
      ),
    );
  }
}
