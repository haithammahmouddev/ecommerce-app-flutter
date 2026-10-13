import 'package:fit_store/common/widgets/layouts/grid_layout.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../common/widgets/shimmers/shimmer.dart';

class VerticalProductShimmer extends StatelessWidget {
  const VerticalProductShimmer({
    super.key,
    this.itemCount = 4,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridLayout(
      itemCount: itemCount,
      itemBuilder: (_, __) => SizedBox(
        width: 180.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerEffect(
              width: 180.w,
              height: 180.h,
              radius: AppSizes.productImageRadius,
            ),
            SizedBox(height: AppSizes.spaceBtwItems),
            ShimmerEffect(width: 160.w, height: 15.h),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            ShimmerEffect(width: 110.w, height: 12.h),
            SizedBox(height: AppSizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerEffect(width: 60.w, height: 20.h),
                ShimmerEffect(
                  width: AppSizes.iconLg * 1.2,
                  height: AppSizes.iconLg * 1.2,
                  radius: AppSizes.cardRadiusMd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}