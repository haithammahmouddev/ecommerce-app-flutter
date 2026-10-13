import 'package:fit_store/features/home/presentation/controller/all_products/all_products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/categories_cubit/categories_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/widgets/image_text/image_text_vertical.dart';
import '../../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../common/di/injection_container.dart';
import '../sub_categories/sub_categories.dart';

class HeaderCategories extends StatelessWidget {
  const HeaderCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CategoriesCubit>(),
      child: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(left: AppSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  title: 'Popular Categories',
                  textColor: AppColors.white,
                  showActionButton: false,
                ),
                SizedBox(height: AppSizes.spaceBtwItems),

                SizedBox(
                  height: 85.h,
                  child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case CategoriesStatus.loading:
                          return const TCategoryShimmerList();

                        case CategoriesStatus.success:
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categoryEntityList.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(width: AppSizes.spaceBtwItems),
                            itemBuilder: (_, index) {
                              final category = state.categoryEntityList[index];
                              return VerticalImageAndText(
                                image: category.image,
                                title: category.name,
                                onTap: () {
                                  final productsCubit = context
                                      .read<ProductsCubit>();
                                  final categoryCubit = context
                                      .read<CategoriesCubit>();
                                  final allProductCubit = context
                                      .read<AllProductsCubit>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                            value: productsCubit,
                                          ),
                                          BlocProvider.value(
                                            value: categoryCubit,
                                          ),
                                          BlocProvider.value(
                                            value: allProductCubit,
                                          ),
                                        ],
                                        child: SubCategoriesScreen(
                                          category: category,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );

                        case CategoriesStatus.error:
                          return Center(
                            child: Text(
                              state.errorMessage ?? 'An error occurred',
                            ),
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TCategoryShimmerList extends StatelessWidget {
  const TCategoryShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      separatorBuilder: (_, _) =>
          SizedBox(width: AppSizes.spaceBtwItems),
      itemBuilder: (_, _) {
        return Column(
          children: [
            TShimmerEffect(width: 56.w, height: 56.h, radius: 56.r),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            TShimmerEffect(width: 55.w, height: 8.h, radius: 4.r),
          ],
        );
      },
    );
  }
}

class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
    this.color,
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? AppColors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}