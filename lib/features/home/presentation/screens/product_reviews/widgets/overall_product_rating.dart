import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/reviews_entity.dart';
import 'rating_progress_indicator.dart';

class OverallProductRating extends StatelessWidget {
  const OverallProductRating({super.key, required this.reviews});

  final List<ReviewEntity> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('0.0', style: Theme.of(context).textTheme.displayLarge),
          ),
          const Expanded(
            flex: 7,
            child: Text('No ratings yet'),
          ),
        ],
      );
    }

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review.rating;
    }
    double averageRating = totalRating / reviews.length;

    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      int star = review.rating.round();
      if (star >= 1 && star <= 5) {
        starCounts[star] = (starCounts[star] ?? 0) + 1;
      }
    }

    int totalReviews = reviews.length;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            averageRating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              RatingProgressIndicator(
                text: '5',
                value: totalReviews == 0 ? 0.0 : (starCounts[5]! / totalReviews),
              ),
              RatingProgressIndicator(
                text: '4',
                value: totalReviews == 0 ? 0.0 : (starCounts[4]! / totalReviews),
              ),
              RatingProgressIndicator(
                text: '3',
                value: totalReviews == 0 ? 0.0 : (starCounts[3]! / totalReviews),
              ),
              RatingProgressIndicator(
                text: '2',
                value: totalReviews == 0 ? 0.0 : (starCounts[2]! / totalReviews),
              ),
              RatingProgressIndicator(
                text: '1',
                value: totalReviews == 0 ? 0.0 : (starCounts[1]! / totalReviews),
              ),
            ],
          ),
        ),
      ],
    );
  }
}