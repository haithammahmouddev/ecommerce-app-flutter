import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/store/presentation/controller/brand_cubit/brand_cubit.dart';
import 'package:fit_store/features/store/presentation/screens/all_brands/brand_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../features/store/domain/entities/brand_entity.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../custom_shapes/containers/rounded_container.dart';
import '../shimmers/shimmer.dart';
import 'brandCard.dart';

class BrandShowcase extends StatelessWidget {
  const BrandShowcase({
    super.key,
    required this.brand,
    required this.images,
  });

  final BrandEntity brand;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final validImages = images.where((image) => image.isNotEmpty).toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    final paddedImages = List.generate(
      3,
          (index) => index < validImages.length ? validImages[index] : '',
    );

    return RoundedContainer(
      showBorder: true,
      borderColor: AppColors.darkGrey,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.all(AppSizes.md),
      margin: EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
      child: Column(
        children: [
          Brandcard(
            showBorder: false,
            brand: brand,
            onTap: () {
              final brandCubit = context.read<BrandCubit>();
              final productsCubin = context.read<ProductsCubit>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: brandCubit),
                      BlocProvider.value(value: productsCubin),
                    ],
                    child: BrandProducts(brand: brand),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSizes.spaceBtwItems),
          Row(
            children: paddedImages.map((image) {
              if (image.isEmpty) {
                return Expanded(
                  child: Container(
                    height: 100.h,
                    margin: EdgeInsets.only(right: AppSizes.sm),
                  ),
                );
              }
              return _productThumbnail(context, image);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _productThumbnail(BuildContext context, String image) {
    final bool isDark = HelperFunctions.isDarkMode(context);
    return Expanded(
      child: RoundedContainer(
        height: 100.h,
        padding: EdgeInsets.all(AppSizes.md),
        margin: EdgeInsets.only(right: AppSizes.sm),
        backgroundColor: isDark ? AppColors.disabledBackgroundLight : AppColors.disabledBackgroundLight,
        child: CachedNetworkImage(
          fit: BoxFit.contain,
          imageUrl: image,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              ShimmerEffect(width: 100.w, height: 100.h),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}