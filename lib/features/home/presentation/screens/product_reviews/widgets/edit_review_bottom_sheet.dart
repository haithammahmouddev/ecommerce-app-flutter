import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../domain/entities/reviews_entity.dart';
import '../../../controller/reviews_cubit/reviews_cubit.dart';

class EditReviewBottomSheet extends StatefulWidget {
  const EditReviewBottomSheet({super.key, required this.review});

  final ReviewEntity review;

  @override
  State<EditReviewBottomSheet> createState() => _EditReviewBottomSheetState();
}

class _EditReviewBottomSheetState extends State<EditReviewBottomSheet> {
  late double _rating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _commentController = TextEditingController(text: widget.review.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.defaultSpace,
        right: AppSizes.defaultSpace,
        top: AppSizes.defaultSpace,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Your Review',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppSizes.spaceBtwItems),

            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 36.r,
                itemBuilder: (context, _) =>
                const Icon(Iconsax.star1, color: AppColors.primary),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),

            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Update your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_commentController.text.trim().isEmpty) return;

                  final updatedReview = ReviewEntity(
                    id: widget.review.id,
                    productId: widget.review.productId,
                    userId: widget.review.userId,
                    userName: widget.review.userName,
                    userImage: widget.review.userImage,
                    rating: _rating,
                    comment: _commentController.text.trim(),
                    createdAt: widget.review.createdAt,
                  );

                  context.read<ReviewsCubit>().updateReview(
                    updatedReview,
                    context,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update Review'),
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}