import 'package:fit_store/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:fit_store/common/widgets/texts/section_heading.dart';
import 'package:fit_store/features/home/presentation/controller/all_products/all_products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/home/presentation/screens/product_cards/product_card_vertical.dart';
import 'package:fit_store/features/home/presentation/screens/search/search_screen.dart';
import 'package:fit_store/features/home/presentation/screens/widgets/header_categories.dart';
import 'package:fit_store/features/home/presentation/screens/widgets/header_search_container.dart';
import 'package:fit_store/features/home/presentation/screens/widgets/home_appbar.dart';
import 'package:fit_store/features/home/presentation/screens/widgets/promo_slider.dart';
import 'package:fit_store/features/home/presentation/screens/widgets/vertical_products_shimmer.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/constants/text_strings.dart';
import 'package:fit_store/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/di/injection_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../controller/products_cubit/images_cubit.dart';
import 'all_products/all_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home-screen';
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ProductsCubit>()..fetchFeaturedProducts(),),
        BlocProvider(create: (context) => sl<ImagesCubit>()),
        BlocProvider(create: (context) => sl<AllProductsCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PrimaryHeaderContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeAppBar(),
                        SizedBox(height: AppSizes.spaceBtwItems),
                        SearchContainer(
                          text: 'Search in Store',
                          showBorder: false,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SearchScreen.routeName,
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.spaceBtwSections),

                        const HeaderCategories(),
                        SizedBox(height: AppSizes.spaceBtwSections * 1.5),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(AppSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PromoSlider(),
                        SizedBox(height: AppSizes.spaceBtwItems),
                        SectionHeading(
                          title: AppTexts.popularProducts,
                          onPressed: () {
                            final allProductsCubit = context
                                .read<AllProductsCubit>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: allProductsCubit,
                                  child: AllProducts(
                                    title: AppTexts.popularProducts,
                                    fetchProductsFuture: () =>
                                        allProductsCubit.fetchAllProducts(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppSizes.spaceBtwItems),

                        BlocBuilder<ProductsCubit, ProductsState>(
                          builder: (context, state) {
                            if (state.status ==
                                FeaturedProductsStatus.loading) {
                              return const VerticalProductShimmer(
                                itemCount: 4,
                              );
                            }

                            if (state.status == FeaturedProductsStatus.error) {
                              return Center(
                                child: Text(state.errorMessage ?? 'حدث خطأ ما'),
                              );
                            }

                            final popularProducts = state.featuredProducts;

                            if (popularProducts.isEmpty &&
                                state.status ==
                                    FeaturedProductsStatus.success) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSizes.spaceBtwSections,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.bag_cross5,
                                        size: 64.r,
                                        color: dark
                                            ? AppColors.darkGrey
                                            : AppColors.grey,
                                      ),
                                      SizedBox(
                                        height: AppSizes.spaceBtwItems,
                                      ),
                                      Text(
                                        'لا توجد منتجات متاحة حالياً',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                          color: dark
                                              ? AppColors.grey
                                              : AppColors.darkerGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return GridLayout(
                              itemCount: popularProducts.length,
                              itemBuilder: (_, index) => ProductCardVertical(
                                product: popularProducts[index],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height:
                          TDeviceUtils.getBottomNavigationBarHeight() +
                              AppSizes.defaultSpace,
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