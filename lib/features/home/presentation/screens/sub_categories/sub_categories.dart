import 'package:fit_store/common/widgets/appbar/home_appbar.dart';
import 'package:fit_store/common/widgets/texts/section_heading.dart';
import 'package:fit_store/features/home/domain/entities/categories_entity.dart';
import 'package:fit_store/features/home/presentation/controller/all_products/all_products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/categories_cubit/categories_cubit.dart';
import 'package:fit_store/features/home/presentation/screens/all_products/all_products.dart';
import 'package:fit_store/utils/constants/image_strings.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../product_cards/product_cart_horizontal.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key, required this.category});
  static const routeName = '/subcategories-screen';
  final CategoryEntity category;

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.category.id.isNotEmpty) {
      context.read<CategoriesCubit>().getSubcategories(
        categoryId: widget.category.id,
      );
    }
  }

  void _openAllProducts({
    required String subCategoryId,
    required String subCategoryName,
  }) {
    final categoriesCubit = context.read<CategoriesCubit>();
    final allProductsCubit = context.read<AllProductsCubit>();

    final products = categoriesCubit.state.productsFor(subCategoryId);

    allProductsCubit.assignProducts(products);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: categoriesCubit),
              BlocProvider.value(value: allProductsCubit),
            ],
            child: AllProducts(title: subCategoryName),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EComAppBar(
        title: Text(widget.category.name),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundedImage(
              imageUrl: widget.category.image.isNotEmpty
                  ? widget.category.image
                  : AppImages.promoBanner3,
              isNetworkImage: widget.category.image.isNotEmpty,
              width: double.infinity,
              height: 170.h,
              applyImageRadius: true,
              fit: BoxFit.cover,
            ),
            SizedBox(height: AppSizes.spaceBtwSections),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state.subCategoriesStatus == SubCategoriesStatus.loading) {
                  return _buildCategoryShimmer();
                }
                if (state.subCategoriesStatus == SubCategoriesStatus.error) {
                  return Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (state.subCategories.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: Center(
                      child: Text(
                        'No Sub Categories Found for "${widget.category.name}"!',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.subCategories.map((subCategory) {
                    final subProducts = state.productsFor(subCategory.id);
                    final subStatus = state.statusFor(subCategory.id);

                    if (subStatus == SubProductsCategoryStatus.success &&
                        subProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSizes.spaceBtwSections,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeading(
                            title: subCategory.name,
                            onPressed: () => _openAllProducts(
                              subCategoryId: subCategory.id,
                              subCategoryName: subCategory.name,
                            ),
                          ),
                          SizedBox(height: AppSizes.spaceBtwItems / 2),
                          switch (subStatus) {
                            SubProductsCategoryStatus.loading =>
                                _buildHorizontalProductShimmer(),
                            SubProductsCategoryStatus.success => SizedBox(
                              height: 135.h,
                              child: ListView.separated(
                                itemCount: subProducts.length,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    SizedBox(
                                      width: AppSizes.spaceBtwItems,
                                    ),
                                itemBuilder: (context, index) {
                                  return ProductCardHorizontal(
                                    product: subProducts[index],
                                  );
                                },
                              ),
                            ),
                            SubProductsCategoryStatus.error =>
                            const SizedBox.shrink(),
                          },
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(2, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.spaceBtwSections),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 140.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.spaceBtwItems / 2),
              _buildHorizontalProductShimmer(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHorizontalProductShimmer() {
    return SizedBox(
      height: 135.h,
      child: ListView.separated(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(width: AppSizes.spaceBtwItems),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 275.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppSizes.productImageRadius,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}