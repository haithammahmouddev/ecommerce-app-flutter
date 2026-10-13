import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widget.dart';
import '../../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../favourites/presentation/screens/widgets/favourite_icon.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../controller/products_cubit/images_cubit.dart';

class ProductImageSlider extends StatelessWidget {
  const ProductImageSlider({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final heightSafeArea = HelperFunctions.getTopSafeArea(context);
    return CurvedEdgesWidget(
      child: Container(
        color: dark ? AppColors.darkerGrey : const Color(0xFFF4F4F4),
        child: Stack(
          children: [
            SizedBox(
              height: 400.h,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: AppSizes.defaultSpace * 2,
                  left: AppSizes.defaultSpace * 1.5,
                  right: AppSizes.defaultSpace * 1.5,
                  top: AppSizes.defaultSpace * 3,
                ),
                child: BlocBuilder<ImagesCubit, ImagesState>(
                  buildWhen: (previous, current) =>
                  previous.selectedProductImage != current.selectedProductImage,
                  builder: (context, state) {
                    final image = state.selectedProductImage ?? '';

                    if (image.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    return GestureDetector(
                      onTap: () => context.read<ImagesCubit>().showEnlargedImage(context, image),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.contain,
                          progressIndicatorBuilder: (_, __, downloadProgress) =>
                              Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: AppColors.primary,
                                ),
                              ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              right: AppSizes.defaultSpace,
              left: AppSizes.defaultSpace,
              bottom: 30.h,
              child: SizedBox(
                height: 80.h,
                child: BlocBuilder<ImagesCubit, ImagesState>(
                  builder: (context, state) {
                    if (state.allProductImages.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.allProductImages.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: AppSizes.spaceBtwItems),
                      itemBuilder: (_, index) {
                        final image = state.allProductImages[index];
                        final isSelected = state.selectedProductImage == image;

                        return RoundedImage(
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.contain,
                          isNetworkImage: true,
                          imageUrl: image,
                          padding: EdgeInsets.all(AppSizes.sm),
                          backgroundColor: dark ? AppColors.dark : AppColors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.w,
                          ),
                          onPressed: () {
                            context.read<ImagesCubit>().setSelectedProductImage(image);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: heightSafeArea, right: 10.w
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  IconButton(
                    icon: const Icon(Iconsax.arrow_left_24),
                    color: dark ? AppColors.white : AppColors.dark,
                    iconSize: 25.r,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FavouriteIcon(productId: product.id),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}