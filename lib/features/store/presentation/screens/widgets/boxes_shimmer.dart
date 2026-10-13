import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/sizes.dart';

class BoxesShimmer extends StatelessWidget {
  const BoxesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: ShimmerEffect(width: 150.w, height: 110.h)),
            SizedBox(width: AppSizes.spaceBtwItems),
            Expanded(child: ShimmerEffect(width: 150.w, height: 110.h)),
            SizedBox(width: AppSizes.spaceBtwItems),
            Expanded(child: ShimmerEffect(width: 150.w, height: 110.h)),
          ],
        ),
      ],
    );
  }
}