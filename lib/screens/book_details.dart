// lib/screens/book_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bangla_read/screens/writer_details.dart'; // ← ADD THIS LINE

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
                        
                        GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WriterDetailsPage(
          writerName: widget.bookAuthor,
          writerImage: "https://i.imgur.com/2d8eYkP.jpg", // Humayun Ahmed photo
          birthDeath: "১৩ নভেম্বর ১৯৪৮ – ১৯ জুলাই ২০১২",
          description: "হুমায়ূন আহমেদ বাংলাদেশের সবচেয়ে জনপ্রিয় কথাসাহিত্যিক ও নাট্যকার। তিনি হিমু, মিসির আলি চরিত্রের স্রষ্টা।",
          books: [
            {"title": "দেবী", "cover": "https://i.imgur.com/debi.jpg"},
            {"title": "হিমু", "cover": "https://i.imgur.com/himu.jpg"},
            {"title": "মিসির আলি", "cover": "https://i.imgur.com/misir.jpg"},
            {"title": "শঙ্খনীল কারাগার", "cover": "https://i.imgur.com/shonkho.jpg"},
            {"title": "জোছনা ও জননীর গল্প", "cover": "https://i.imgur.com/jochona.jpg"},
          ],
        ),
      ),
    );
  },
  child: Text(
    widget.bookAuthor,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF6D4C41),
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFF6D4C41),
    ),
  ),
),

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
        
// ===== GET THE BOOK + ADD TO LIST (FIXED) =====
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Row(
    children: [
      // GET THE BOOK – Small + Left aligned
      PopupMenuButton<String>(
        onSelected: (value) async {
          final query = Uri.encodeComponent("${widget.bookTitle} ${widget.bookAuthor}");
          final url = value == 'rokomari'
              ? 'https://www.rokomari.com/search?term=$query'
              : 'https://www.amazon.com/s?k=$query';

          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'rokomari',
            child: Row(
              children: [
                Icon(Icons.shopping_bag, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text('Rokomari'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'amazon',
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text('Amazon'),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6D4C41), Color(0xFF8B4513)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Get the Book',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      const SizedBox(width: 10),

      // ADD TO LIST – Small + Left aligned
      OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add to shelf coming soon!')),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          side: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Add to list',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41)),
        ),
      ),

      const Spacer(), // ← This pushes both buttons to the LEFT
    ],
  ),
), 
            const Divider(height: 50),

            // ===== GENRE SECTION =====
const SizedBox(height: 20),
const Text(
  'Genre',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF3E2723),
  ),
),
const SizedBox(height: 12),
Wrap(
  spacing: 10,
  runSpacing: 10,
  children: [
    _genreChip('উপন্যাস', Colors.brown.shade100),
    _genreChip('রোমান্টিক', Colors.pink.shade100),
    _genreChip('হুমায়ূন আহমেদ', Colors.blue.shade100),
    _genreChip('বাংলা সাহিত্য', Colors.green.shade100),
    _genreChip('ক্লাসিক', Colors.orange.shade100),
  ],
),

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
// Reusable Genre Chip
Widget _genreChip(String label, Color color) {
  return Chip(
    label: Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3E2723),
      ),
    ),
    backgroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: color.darken(0.2), width: 1),
    ),
  );
}
extension ColorExtension on Color {
  Color darken([double amount = 0.2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

