// lib/screens/book_details.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bangla_read/screens/writer_details.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bangla_read/screens/ai_service.dart';

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
  String? _aiSummary;
  bool _isGenerating = false;
  // ---- UI helpers -------------------------------------------------
  double _userRating = 0.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isEditing = false;
  String? _editingReviewId; // Firestore doc id when editing

  // ---- Firestore helpers -------------------------------------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final CollectionReference _bookCol =
      FirebaseFirestore.instance.collection('books');

  // Find the book document (you should pass bookId from the list screen)
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getBookDoc() async {
    final snap = await _bookCol
        .where('title', isEqualTo: widget.bookTitle)
        .where('author', isEqualTo: widget.bookAuthor)
        .where('coverUrl', isEqualTo: widget.bookCoverUrl)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.reference.get()
        as Future<DocumentSnapshot<Map<String, dynamic>>>;
  }

  // ---- Add / Update review -----------------------------------------
  Future<void> _saveReview(String bookId) async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to review')),
      );
      return;
    }

    final rating = _userRating > 0 ? _userRating : 5.0;

    final reviewData = {
      'rating': rating,
      'text': text,
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    };

    final bookRef = _bookCol.doc(bookId);
    final reviewsCol = bookRef.collection('reviews');

    if (_isEditing && _editingReviewId != null) {
      // UPDATE
      await reviewsCol.doc(_editingReviewId).update(reviewData);
    } else {
      // CREATE
      await reviewsCol.add(reviewData);
    }

    // reset UI
    _reviewController.clear();
    setState(() {
      _userRating = 0.0;
      _isEditing = false;
      _editingReviewId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Review updated!' : 'Review added!')),
    );
  }

  // ---- Delete review ------------------------------------------------
  Future<void> _deleteReview(String bookId, String reviewId) async {
    await _bookCol.doc(bookId).collection('reviews').doc(reviewId).delete();
  }

  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: _getBookDoc(),
      builder: (context, bookSnap) {
        final bookId = bookSnap.data?.id;
        final bookRef = bookId == null ? null : _bookCol.doc(bookId);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF6D4C41),
            foregroundColor: Colors.white,
            title: const Text('BanglaRead'),
          ),
          body: bookId == null
              ? const Center(child: Text('Book not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----------------------------------------------------- HEADER
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'search for books',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      // BOOK COVER + INFO
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
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.book, size: 100),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.bookTitle,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WriterDetailsPage(
                                            writerName: widget.bookAuthor,
                                            writerImage:
                                                "https://i.imgur.com/2d8eYkP.jpg",
                                            birthDeath:
                                                "১৩ নভেম্বর ১৯৪৮ – ১৯ জুলাই ২০১২",
                                            profession:
                                                "লেখক, নাট্যকার, চলচিত্রকার",
                                            description:
                                                "হুমায়ূন আহমেদ বাংলাদেশের সবচেয়ে জনপ্রিয় কথাসাহিত্যিক ও নাট্যকার। তিনি হিমু, মিসির আলি চরিত্রের স্রষ্টা।",
                                            books: [
                                              {
                                                "title": "দেবী",
                                                "cover":
                                                    "https://i.imgur.com/debi.jpg"
                                              },
                                              {
                                                "title": "হিমু",
                                                "cover":
                                                    "https://i.imgur.com/himu.jpg"
                                              },
                                              {
                                                "title": "মিসির আলি",
                                                "cover":
                                                    "https://i.imgur.com/misir.jpg"
                                              },
                                              {
                                                "title": "শঙ্খনীল কারাগার",
                                                "cover":
                                                    "https://i.imgur.com/shonkho.jpg"
                                              },
                                              {
                                                "title": "জোছনা ও জননীর গল্প",
                                                "cover":
                                                    "https://i.imgur.com/jochona.jpg"
                                              },
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
                                    itemBuilder: (_, __) => const Icon(
                                        Icons.star,
                                        color: Colors.amber),
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

                      // Inside Column after book info
                      // === ADD THIS AFTER BOOK INFO (after RatingBarIndicator) ===

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isGenerating
                                  ? null
                                  : () async {
                                      setState(() => _isGenerating = true);
                                      try {
                                        final summary =
                                            await AIService.generateSummary(
                                          title: widget.bookTitle,
                                          author: widget.bookAuthor,
                                        );
                                        setState(() => _aiSummary = summary);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text('AI Error: $e')),
                                        );
                                      } finally {
                                        setState(() => _isGenerating = false);
                                      }
                                    },
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(_isGenerating
                                  ? 'জেনারেট হচ্ছে...'
                                  : 'AI সারাংশ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (_aiSummary != null) ...[
                              const SizedBox(height: 12),
                              Card(
                                color: Colors.deepPurple.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              color: Colors.deepPurple),
                                          const SizedBox(width: 8),
                                          Text(
                                            'AI জেনারেটেড সারাংশ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(_aiSummary!),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("বইটির বিবরণ এখানে থাকবে...")),

                      // ----------------------------------------------------- GET THE BOOK + LIST BUTTONS
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Get the Book
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                final query = Uri.encodeComponent(
                                    "${widget.bookTitle} ${widget.bookAuthor}");
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
                                      Icon(Icons.shopping_bag,
                                          size: 20, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Rokomari'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'amazon',
                                  child: Row(
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          size: 20, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Amazon'),
                                    ],
                                  ),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF6D4C41),
                                    Color(0xFF8B4513)
                                  ]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Get the Book',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 3 RESPONSIVE BUTTONS
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _actionButton(
                                  context: context,
                                  label: 'পড়তে চান',
                                  category: 'want_to_read',
                                  icon: Icons.bookmark_border,
                                  bookId: bookId,
                                ),
                                _actionButton(
                                  context: context,
                                  label: 'এখন পড়ছেন',
                                  category: 'currently_reading',
                                  icon: Icons.menu_book,
                                  bookId: bookId,
                                ),
                                _actionButton(
                                  context: context,
                                  label: 'পড়া শেষ',
                                  category: 'finished_reading',
                                  icon: Icons.check_circle_outline,
                                  bookId: bookId,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ----------------------------------------------------- FAVORITE BUTTON
                      StreamBuilder<DocumentSnapshot>(
                        stream: bookRef?.snapshots(),
                        builder: (context, snap) {
                          final bool isFavorite = snap.hasData &&
                              (snap.data?.data() as Map<String, dynamic>?)?[
                                      'isFavorite'] ==
                                  true;

                          return IconButton(
                            onPressed: () => _addToFavorites(bookId!),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(0xFF6D4C41),
                              size: 28,
                            ),
                            tooltip: isFavorite
                                ? 'In Favorites'
                                : 'Add to Favorites',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Color(0xFF6D4C41), width: 1.5),
                              ),
                            ),
                          );
                        },
                      ),

                      const Divider(height: 50),

                      // ----------------------------------------------------- GENRE
                      const SizedBox(height: 20),
                      const Text('Genre',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723))),
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

                      // ----------------------------------------------------- REVIEW FORM
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing
                                  ? 'Edit Your Review'
                                  : 'Write Your Review',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            RatingBar.builder(
                              initialRating: _userRating,
                              minRating: 1,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              itemBuilder: (_, __) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (r) =>
                                  setState(() => _userRating = r),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _reviewController,
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
                                onPressed: () => _saveReview(bookId!),
                                child: Text(_isEditing
                                    ? 'Update Review'
                                    : 'Submit Review'),
                              ),
                            ),
                            if (_isEditing)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _editingReviewId = null;
                                    _reviewController.clear();
                                    _userRating = 0.0;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                          ],
                        ),
                      ),

                      const Divider(),

                      // ----------------------------------------------------- PUBLIC REVIEWS
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reviews from Readers',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            StreamBuilder<QuerySnapshot>(
                              stream: bookRef!
                                  .collection('reviews')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snap.hasData || snap.data!.docs.isEmpty) {
                                  return const Text(
                                      'No reviews yet. Be the first!');
                                }

                                final userId = _auth.currentUser?.uid;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snap.data!.docs.length,
                                  itemBuilder: (context, idx) {
                                    final doc = snap.data!.docs[idx];
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final rating =
                                        (data['rating'] as num?)?.toDouble() ??
                                            5.0;
                                    final text = data['text'] as String? ?? '';
                                    final name = data['userName'] as String? ??
                                        'Anonymous';
                                    final timestamp =
                                        data['timestamp'] as Timestamp?;
                                    final dateStr = timestamp != null
                                        ? DateFormat('dd MMM yyyy, HH:mm')
                                            .format(timestamp.toDate())
                                        : 'just now';
                                    final reviewId = doc.id;
                                    final isMine = userId == data['userId'];

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(name,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const Spacer(),
                                                Text(dateStr,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            RatingBarIndicator(
                                              rating: rating,
                                              itemBuilder: (_, __) =>
                                                  const Icon(Icons.star,
                                                      color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(text),
                                            if (isMine)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        size: 20,
                                                        color: Colors.blue),
                                                    onPressed: () {
                                                      _reviewController.text =
                                                          text;
                                                      setState(() {
                                                        _userRating = rating;
                                                        _isEditing = true;
                                                        _editingReviewId =
                                                            reviewId;
                                                      });
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        _deleteReview(
                                                            bookId, reviewId),
                                                  ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // -------------------------- REUSABLE WIDGETS -----------------------
  // ------------------------------------------------------------------

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required String category,
    required IconData icon,
    required String? bookId,
  }) {
    return OutlinedButton.icon(
      onPressed:
          bookId == null ? null : () => _addToCategory(bookId, category, label),
      icon: Icon(icon, size: 18, color: const Color(0xFF6D4C41)),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ADD TO ANY CATEGORY (with finishedDate for Finished Reading)
  Future<void> _addToCategory(
      String bookId, String category, String label) async {
    final Map<String, dynamic> updateData = {'category': category};

    if (category == 'finished_reading') {
      updateData['finishedDate'] = DateTime.now()
          .toIso8601String()
          .split('T')
          .first; // e.g. "2025-12-01"
    }

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bookTitle} যোগ করা হয়েছে "$label" তালিকায়'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ADD TO FAVORITES – NEVER TOUCHES 'category'
  Future<void> _addToFavorites(String bookId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('books').doc(bookId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Book not found'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final data = docSnap.data()!;
      final bool isAlreadyFavorite = data['isFavorite'] == true;

      if (isAlreadyFavorite) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Already in Favorites'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await docRef.set({'isFavorite': true}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bookTitle} added to Favorites'),
            backgroundColor: Colors.pink.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ----------------------------------------------------------------------
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
