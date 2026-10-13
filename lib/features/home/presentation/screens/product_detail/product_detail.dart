import 'package:fit_store/features/checkout/presentation/screens/checkout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/di/injection_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controller/products_cubit/images_cubit.dart';
import '../../controller/products_cubit/variation_cubit.dart';
import '../../controller/reviews_cubit/reviews_cubit.dart';
import '../product_reviews/product_reviews.dart';
import 'widgets/bottom_add_to_cart_widget.dart';
import 'widgets/product_attributes.dart';
import 'widgets/product_detail_image_slider.dart';
import 'widgets/product_meta_data.dart';
import 'widgets/rating_share_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  static const String routeName = '/details-product-details';
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final bool isDark = HelperFunctions.isDarkMode(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ImagesCubit>()..getAllProductImages(product),
        ),
        BlocProvider(create: (context) => sl<VariationCubit>()),
        BlocProvider(
          create: (context) => sl<ReviewsCubit>()..fetchReviewsForProduct(product.id),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            bottomNavigationBar: BottomAddToCart(product: product.toModel()),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageSlider(product: product),
                  Padding(
                    padding: EdgeInsets.only(
                      right: AppSizes.defaultSpace,
                      left: AppSizes.defaultSpace,
                      bottom: AppSizes.defaultSpace,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingAndShare(product: product),

                        ProductMetaData(product: product),

                        SizedBox(height: AppSizes.spaceBtwSections / 2),

                        if (product.productType == 'variable')
                          ProductAttributes(product: product),
                        if (product.productType == 'variable')
                          SizedBox(height: AppSizes.spaceBtwSections / 2),

                        SizedBox(
                          width: TDeviceUtils.getScreenWidth(context),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                CheckoutScreen.routeName,
                                arguments: product,
                              );
                            },
                            child: const Text('Checkout'),
                          ),
                        ),

                        SizedBox(height: AppSizes.spaceBtwSections / 2),

                        const SectionHeading(
                          title: 'Description',
                          showActionButton: false,
                        ),
                        SizedBox(height: AppSizes.spaceBtwItems),

                        ReadMoreText(
                          product.description ??
                              'No description available for this product.',
                          trimLines: 2,
                          colorClickableText: Colors.pink,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: ' Show more',
                          trimExpandedText: ' Less',
                          moreStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          lessStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: AppSizes.spaceBtwItems),
                        const Divider(),

                        ListTile(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              ProductReviewsScreen.routeName,
                              arguments: {
                                'productId': product.id,
                                'cubit': context.read<ReviewsCubit>(),
                              },
                            );

                            if (context.mounted) {
                              context.read<ReviewsCubit>().fetchReviewsForProduct(product.id);
                            }
                          },
                          contentPadding: EdgeInsets.zero,
                          title: BlocBuilder<ReviewsCubit, ReviewsState>(
                            buildWhen: (previous, current) =>
                            previous.status != current.status ||
                                previous.reviews.length != current.reviews.length,
                            builder: (context, state) {
                              final reviewCount = state.reviews.length;
                              return SectionHeading(
                                title: 'Reviews ($reviewCount)',
                                showActionButton: false,
                              );
                            },
                          ),
                          trailing: Icon(
                            Iconsax.arrow_right_3,
                            size: 18.r,
                            color: isDark ? AppColors.white : AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}