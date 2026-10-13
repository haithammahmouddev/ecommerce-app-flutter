import 'package:fit_store/common/widgets/appbar/home_appbar.dart';
import 'package:fit_store/common/widgets/brand/brandCard.dart';
import 'package:fit_store/common/widgets/layouts/grid_layout.dart';
import 'package:fit_store/common/widgets/texts/section_heading.dart';
import 'package:fit_store/features/home/presentation/controller/all_products/all_products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/store/presentation/controller/brand_cubit/brand_cubit.dart';
import 'package:fit_store/features/store/presentation/screens/all_brands/brand_products.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../domain/entities/brand_entity.dart';

class AllBrandsScreen extends StatefulWidget {
  const AllBrandsScreen({super.key});
  static const routeName = '/all-brands-screen';

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BrandCubit>().fetchAllBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EComAppBar(title: Text('Brand'), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              const SectionHeading(title: 'Brands'),
              SizedBox(height: AppSizes.spaceBtwItems),
              BlocBuilder<BrandCubit, BrandState>(
                buildWhen: (previous, current) =>
                previous.allBrandsStatus != current.allBrandsStatus ||
                    previous.allBrands != current.allBrands,
                builder: (context, state) {
                  if (state.allBrandsStatus == AllBrandsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.allBrandsStatus == AllBrandsStatus.error) {
                    return Center(child: Text(state.errorMessage ?? 'Something went wrong.'));
                  }

                  final List<BrandEntity> allBrands = state.allBrands;
                  if (allBrands.isEmpty) {
                    return const Center(child: Text('No brands available.'));
                  }

                  return GridLayout(
                    itemCount: allBrands.length,
                    mainAxisExtent: 80.h,
                    itemBuilder: (context, index) {
                      final brand = allBrands[index];
                      return Brandcard(
                        brand: brand,
                        showBorder: true,
                        onTap: () {
                          final brandCubit = context.read<BrandCubit>();
                          final productsCubit = context.read<ProductsCubit>();
                          final allProductsCubit = context.read<AllProductsCubit>();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: brandCubit),
                                  BlocProvider.value(value: productsCubit),
                                  BlocProvider.value(value: allProductsCubit),
                                ],
                                child: BrandProducts(brand: brand),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}