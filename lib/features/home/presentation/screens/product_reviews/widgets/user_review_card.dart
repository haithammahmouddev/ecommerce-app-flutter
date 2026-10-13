import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../domain/entities/reviews_entity.dart';
import '../../../controller/reviews_cubit/reviews_cubit.dart';
import 'edit_review_bottom_sheet.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({super.key, required this.review});

  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM, yyyy').format(review.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review.userImage.isNotEmpty
                      ? NetworkImage(review.userImage) as ImageProvider
                      : const AssetImage(AppImages.userProfileImage),
                ),
                SizedBox(width: AppSizes.spaceBtwItems),
                Text(
                  review.userName.isNotEmpty ? review.userName : 'Anonymous',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<ReviewsCubit>(context),
                      child: EditReviewBottomSheet(review: review),
                    ),
                  );
                } else if (value == 'delete') {
                  context.read<ReviewsCubit>().deleteReview(
                    reviewId: review.id,
                    productId: review.productId,
                    context: context,
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit, size: 18.r),
                      SizedBox(width: 8.w),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 18.r, color: Colors.red),
                      SizedBox(width: 8.w),
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Row(
          children: [
            RatingBarIndicator(
              rating: review.rating,
              itemSize: 20.r,
              unratedColor: AppColors.grey,
              itemBuilder: (BuildContext context, int index) {
                return const Icon(Iconsax.star1, color: AppColors.primary);
              },
            ),
            SizedBox(width: AppSizes.spaceBtwItems),
            Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        ReadMoreText(
          review.comment,
          trimLines: 2,
          trimMode: TrimMode.Line,
          trimExpandedText: ' show less',
          trimCollapsedText: ' show more',
          moreStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          lessStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppSizes.spaceBtwSections),
      ],
    );
  }
}