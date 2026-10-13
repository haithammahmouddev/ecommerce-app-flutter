import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../domain/entities/reviews_entity.dart';
import '../../../controller/reviews_cubit/reviews_cubit.dart';

class AddReviewBottomSheet extends StatefulWidget {
  const AddReviewBottomSheet({super.key, required this.productId});

  final String productId;

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();

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
            Text('Add Your Review', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: AppSizes.spaceBtwItems),

            Center(
              child: RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 36.r,
                itemBuilder: (context, _) => const Icon(
                  Iconsax.star1,
                  color: AppColors.primary,
                ),
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
                labelText: 'Write your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_commentController.text.trim().isEmpty) return;
                  final currentUser = LocalStorageService.userRepo.getData();

                  final newReview = ReviewEntity(
                    id: '',
                    productId: widget.productId,
                    userId: currentUser?.id ?? '1',
                    userName: currentUser?.fullName ?? 'User',
                    userImage: currentUser?.profilePicture ?? '',
                    rating: _rating,
                    comment: _commentController.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  context.read<ReviewsCubit>().addReview(newReview, context);
                  Navigator.pop(context);
                },
                child: const Text('Submit Review'),
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}