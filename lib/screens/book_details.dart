// lib/screens/book_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetails extends StatefulWidget {
  final String bookTitle;
  final String bookAuthor;
  final String bookCoverUrl;
  final double bookRating;

  const BookDetails({
    super.key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCoverUrl,
    required this.bookRating,
  });

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  double userRating = 0.0;                              // ← always double
  final TextEditingController reviewController = TextEditingController();

  bool isEditing = false;
  int editingIndex = -1;

  List<Map<String, dynamic>> reviews = [];

  void saveReview() {
    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a review")),
      );
      return;
    }

    if (isEditing) {
      setState(() {
        reviews[editingIndex]
          ..['rating'] = userRating > 0 ? userRating : 5.0
          ..['text'] = reviewController.text.trim()
          ..['date'] = "Edited just now";
        isEditing = false;
        editingIndex = -1;
      });
    } else {
      setState(() {
        reviews.add({
          "rating": userRating > 0 ? userRating : 5.0,   // ← always double
          "text": reviewController.text.trim(),
          "user": "You",
          "date": "Just now",
        });
      });
    }

    reviewController.clear();
    setState(() => userRating = 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review added!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        title: const Text('BanglaRead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search for books',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.bookCoverUrl,
                      width: 120,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 100),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bookTitle,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(widget.bookAuthor, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: widget.bookRating,
                          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 24,
                        ),
                        Text('${widget.bookRating} out of 5'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(padding: EdgeInsets.all(16), child: Text("বইটির বিবরণ এখানে থাকবে...")),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text('Get the Book')),
                  const SizedBox(width: 12),
                  OutlinedButton(onPressed: () {}, child: const Text('Add to list')),
                ],
              ),
            ),

            const Divider(height: 50),

            // REVIEW FORM
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Your Review' : 'Write Your Review',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // This is the only place that can return int → we convert to double
                  RatingBar.builder(
                    initialRating: userRating,
                    minRating: 1,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setState(() {
                        userRating = rating;           // ← rating is double here (safe)
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: reviewController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveReview,
                      child: Text(isEditing ? 'Update Review' : 'Submit Review'),
                    ),
                  ),

                  if (isEditing)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          editingIndex = -1;
                          reviewController.clear();
                          userRating = 0.0;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ),

            const Divider(),

            // ALL REVIEWS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reviews from Readers',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  reviews.isEmpty
                      ? const Text('No reviews yet. Be the first!')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final r = reviews[index];
                            final bool isMyReview = r['user'] == "You";

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(r['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text(r['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    RatingBarIndicator(
                                      rating: r['rating'] as double,
                                      itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber, size: 20),
                                      itemCount: 5,
                                      itemSize: 20,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(r['text']),

                                    if (isMyReview)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                            onPressed: () {
                                              reviewController.text = r['text'];
                                              userRating = r['rating'] as double;
                                              setState(() {
                                                isEditing = true;
                                                editingIndex = index;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            onPressed: () => setState(() => reviews.removeAt(index)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}