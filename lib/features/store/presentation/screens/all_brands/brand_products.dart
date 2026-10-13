import 'package:fit_store/common/widgets/appbar/home_appbar.dart';
import 'package:fit_store/features/store/domain/entities/brand_entity.dart';
import 'package:fit_store/features/store/presentation/controller/brand_cubit/brand_cubit.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/brand/brandCard.dart';
import '../../../../home/presentation/screens/all_products/sortable_products.dart';

class BrandProducts extends StatefulWidget {
  const BrandProducts({super.key, required this.brand});

  static const routeName = '/brand-products';
  final BrandEntity brand;

  @override
  State<BrandProducts> createState() => _BrandProductsState();
}

class _BrandProductsState extends State<BrandProducts> {
  @override
  void initState() {
    super.initState();
    context.read<BrandCubit>().fetchBrandProducts(brandId: widget.brand.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EComAppBar(title: Text(widget.brand.name), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              Brandcard(showBorder: true, brand: widget.brand),
              SizedBox(height: AppSizes.spaceBtwSections),

              BlocBuilder<BrandCubit, BrandState>(
                buildWhen: (previous, current) =>
                previous.brandProductsStatus != current.brandProductsStatus ||
                    previous.brandProducts != current.brandProducts,
                builder: (context, state) {
                  if (state.brandProductsStatus == BrandProductsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.brandProductsStatus == BrandProductsStatus.error) {
                    return Center(
                      child: Text(state.errorMessage ?? 'An error occurred while loading products.'),
                    );
                  }
                  if (state.brandProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SortableProducts(products: state.brandProducts);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}