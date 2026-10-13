import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/sizes.dart';

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ShimmerEffect(width: 50.w, height: 50.h, radius: 50.r),
            SizedBox(width: AppSizes.spaceBtwItems),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerEffect(width: 100.w, height: 15.h),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                ShimmerEffect(width: 80.w, height: 12.h),
              ],
            ),
          ],
        ),
      ],
    );
  }
}