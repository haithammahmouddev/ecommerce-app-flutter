import 'package:fit_store/features/home/domain/entities/categories_entity.dart';
import 'package:fit_store/features/home/presentation/screens/all_products/all_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../home/presentation/controller/all_products/all_products_cubit.dart';
import '../../../../home/presentation/screens/product_cards/product_card_vertical.dart';
import '../../controller/brand_cubit/brand_cubit.dart';
import 'category_brand.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key, required this.category});

  final CategoryEntity category;

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<BrandCubit>().fetchLimitedProductsForCategory(
      categoryId: widget.category.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              CategoryBrands(category: widget.category),
              SizedBox(height: AppSizes.spaceBtwItems),

              SectionHeading(
                title: 'You might like',
                onPressed: () {
                  final allProductsCubit = context.read<AllProductsCubit>();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllProducts(
                        title: widget.category.name,
                        fetchProductsFuture: () =>
                            allProductsCubit.fetchProductsForCategory(
                              categoryId: widget.category.id,
                            ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSizes.spaceBtwItems),

              BlocBuilder<BrandCubit, BrandState>(
                builder: (context, state) {
                  final products =
                  state.categoryProductsMap[widget.category.id];

                  if (products == null) {
                    return GridLayout(
                      itemCount: 4,
                      itemBuilder: (_, index) =>
                          ShimmerEffect(width: 180.w, height: 260.h),
                    );
                  }

                  if (products.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return GridLayout(
                    itemCount: products.length,
                    itemBuilder: (_, index) =>
                        ProductCardVertical(product: products[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}