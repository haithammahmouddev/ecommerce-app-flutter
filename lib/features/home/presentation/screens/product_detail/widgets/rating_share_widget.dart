import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../controller/reviews_cubit/reviews_cubit.dart';

class RatingAndShare extends StatelessWidget {
  const RatingAndShare({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<ReviewsCubit, ReviewsState>(
          buildWhen: (previous, current) =>
          previous.status != current.status ||
              previous.reviews.length != current.reviews.length ||
              previous.reviews != current.reviews,
          builder: (context, state) {
            double averageRating = 0.0;
            if (state.reviews.isNotEmpty) {
              double total = 0.0;
              for (var r in state.reviews) {
                total += r.rating;
              }
              averageRating = total / state.reviews.length;
            }
            final reviewCount = state.reviews.length;

            return Row(
              children: [
                Icon(Iconsax.star5, color: Colors.amber, size: 24.r),
                SizedBox(width: AppSizes.spaceBtwItems / 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${averageRating.toStringAsFixed(1)} ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(text: '($reviewCount)'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        IconButton(
          onPressed: () {
            final link = 'https://fit-store-azure.vercel.app/product/${product.id}';
            SharePlus.instance.share(
              ShareParams(
                text: 'Check out ${product.title} on Fit Store!\n\n$link',
                subject: product.title,
              ),
            );
          },
          icon: Icon(Icons.share, size: AppSizes.iconMd),
        ),
      ],
    );
  }
}