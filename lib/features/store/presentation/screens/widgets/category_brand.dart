import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/brand/brand_showcase.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../home/domain/entities/categories_entity.dart';
import '../../../domain/entities/brand_entity.dart';
import '../../controller/brand_cubit/brand_cubit.dart';
import 'boxes_shimmer.dart';
import 'list_tile_shimmer.dart';

class CategoryBrands extends StatefulWidget {
  const CategoryBrands({
    super.key,
    required this.category,
  });

  final CategoryEntity category;

  @override
  State<CategoryBrands> createState() => _CategoryBrandsState();
}

class _CategoryBrandsState extends State<CategoryBrands> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BrandCubit>();
    if (!cubit.state.categoryBrandsMap.containsKey(widget.category.id)) {
      cubit.fetchBrandsForCategory(categoryId: widget.category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandCubit, BrandState>(
      buildWhen: (previous, current) =>
      previous.categoryBrandsMap[widget.category.id] != current.categoryBrandsMap[widget.category.id] ||
          previous.categoryBrandsStatus != current.categoryBrandsStatus,
      builder: (context, state) {
        final List<BrandEntity>? brands = state.categoryBrandsMap[widget.category.id];

        if (brands == null) {
          return Column(
            children: List.generate(
              2,
                  (_) => Container(
                margin: EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                padding: EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkGrey),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                ),
                child: Column(
                  children: [
                    const ListTileShimmer(),
                    SizedBox(height: AppSizes.spaceBtwItems),
                    const BoxesShimmer(),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.categoryBrandsStatus == CategoryBrandsStatus.error && brands.isEmpty) {
          return Center(
            child: Text(state.errorMessage ?? 'Something went wrong.'),
          );
        }

        if (brands.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No brands available for this category yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: brands.length > 3 ? 3 : brands.length,
          itemBuilder: (context, index) => _CategoryBrandPreview(brand: brands[index]),
        );
      },
    );
  }
}

class _CategoryBrandPreview extends StatefulWidget {
  const _CategoryBrandPreview({required this.brand});

  final BrandEntity brand;

  @override
  State<_CategoryBrandPreview> createState() => _CategoryBrandPreviewState();
}

class _CategoryBrandPreviewState extends State<_CategoryBrandPreview> {
  @override
  void initState() {
    super.initState();
    context.read<BrandCubit>().fetchProductsForCategoryBrand(brandId: widget.brand.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandCubit, BrandState>(
      buildWhen: (previous, current) =>
      previous.categoryBrandProducts[widget.brand.id] != current.categoryBrandProducts[widget.brand.id],
      builder: (context, state) {
        final products = state.categoryBrandProducts[widget.brand.id];

        if (products == null) {
          return Container(
            margin: EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkGrey),
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
            ),
            child: const BoxesShimmer(),
          );
        }

        return BrandShowcase(
          brand: widget.brand,
          images: products.map((product) => product.thumbnail).toList(),
        );
      },
    );
  }
}