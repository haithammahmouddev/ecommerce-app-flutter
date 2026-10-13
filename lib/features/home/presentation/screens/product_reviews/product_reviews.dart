import 'package:fit_store/features/home/presentation/screens/product_reviews/widgets/add_review_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controller/reviews_cubit/reviews_cubit.dart';
import 'widgets/overall_product_rating.dart';
import 'widgets/user_review_card.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key, required this.productId});

  static const routeName = '/product-reviews-screen';
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        title: Text('Reviews & Rating'),
        showActions: false,
        showSkipButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: context.read<ReviewsCubit>(),
              child: AddReviewBottomSheet(productId: productId),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.edit, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ratings and reviews are verified and are from people who use the same type of device that you use."),
              SizedBox(height: AppSizes.spaceBtwItems),

              BlocBuilder<ReviewsCubit, ReviewsState>(
                builder: (context, state) {
                  if (state.status == ReviewsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  double averageRating = 0.0;
                  if (state.reviews.isNotEmpty) {
                    double total = 0.0;
                    for (var r in state.reviews) {
                      total += r.rating;
                    }
                    averageRating = total / state.reviews.length;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OverallProductRating(reviews: state.reviews),
                      SizedBox(height: AppSizes.spaceBtwItems),
                      RatingBarIndicator(
                        rating: averageRating,
                        itemSize: 28.r,
                        unratedColor: AppColors.grey,
                        itemBuilder: (BuildContext context, int index) {
                          return const Icon(Iconsax.star1, color: AppColors.primary);
                        },
                      ),
                      Text(
                        '${state.reviews.length} Reviews',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: AppSizes.spaceBtwSections),

                      if (state.reviews.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: const Center(child: Text('No reviews yet for this product.')),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.reviews.length,
                          itemBuilder: (context, index) {
                            return UserReviewCard(review: state.reviews[index]);
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}