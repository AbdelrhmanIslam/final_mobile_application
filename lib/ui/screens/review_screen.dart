import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// Model for a local review
class UserReview {
  final String name;
  final double rating;
  final String comment;
  final String date;

  UserReview(this.name, this.rating, this.comment, this.date);
}

// Global list to simulate database (persists while app is open)
List<UserReview> _mockReviews = [
  UserReview("Ronald Richards", 4.8, "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "13 Sep, 2020"),
  UserReview("Guy Hawkins", 4.5, "Great product! Really loved the quality.", "12 Sep, 2020"),
  UserReview("Savannah Nguyen", 5.0, "Fast delivery and amazing packaging.", "10 Sep, 2020"),
];

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // Calculate Average Rating
    double totalRating = 0;
    for(var r in _mockReviews) totalRating += r.rating;
    double avgRating = _mockReviews.isNotEmpty ? totalRating / _mockReviews.length : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Reviews", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Wait for result from Add Screen
              final newReview = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddReviewScreen())
              );

              // If review returned, add to list
              if (newReview != null && newReview is UserReview) {
                setState(() {
                  _mockReviews.insert(0, newReview); // Add to top
                });
              }
            },
            child: const Text("Add Review", style: TextStyle(color: LazaColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_mockReviews.length} Reviews", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    Text(avgRating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                    const SizedBox(width: 5),
                    const Icon(Icons.star, color: LazaColors.orange, size: 16),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _mockReviews.length,
              separatorBuilder: (c, i) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final review = _mockReviews[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(backgroundImage: AssetImage('assets/images/onboarding_man.png')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              Text(review.rating.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(review.date, style: const TextStyle(color: LazaColors.grey, fontSize: 11)),
                          const SizedBox(height: 10),
                          Text(review.comment, style: const TextStyle(color: LazaColors.grey)),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ADD REVIEW SCREEN
class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 4.0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Add Review", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: const InputDecoration(hintText: "Type your name", border: InputBorder.none, contentPadding: EdgeInsets.all(15))
              ),
            ),
            const SizedBox(height: 20),

            Text("How was your experience?", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                  controller: _commentController,
                  style: TextStyle(color: textColor),
                  maxLines: 5,
                  decoration: const InputDecoration(hintText: "Describe your experience", border: InputBorder.none, contentPadding: EdgeInsets.all(15))
              ),
            ),
            const SizedBox(height: 20),

            Text("Star", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("0.0", style: TextStyle(color: textColor)),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 0, max: 5,
                    divisions: 10,
                    label: _rating.toString(),
                    activeColor: LazaColors.primary,
                    onChanged: (val) => setState(() => _rating = val),
                  ),
                ),
                Text("5.0", style: TextStyle(color: textColor)),
              ],
            ),
            Center(child: Text("Rating: $_rating", style: TextStyle(color: LazaColors.primary, fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty || _commentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                return;
              }

              // Create Review Object
              final newReview = UserReview(
                  _nameController.text,
                  _rating,
                  _commentController.text,
                  "Just now"
              );

              // Return it to previous screen
              Navigator.pop(context, newReview);

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review Submitted!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary),
            child: const Text("Submit Review", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}