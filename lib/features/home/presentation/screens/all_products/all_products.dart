import 'package:fit_store/features/home/presentation/screens/all_products/sortable_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../controller/all_products/all_products_cubit.dart';
import '../widgets/vertical_products_shimmer.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({
    super.key,
    required this.title,
    this.fetchProductsFuture,
  });

  final String title;
  final Future<void> Function()? fetchProductsFuture;

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  @override
  void initState() {
    super.initState();
    if (widget.fetchProductsFuture != null) {
      widget.fetchProductsFuture!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: Text(widget.title),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: BlocBuilder<AllProductsCubit, AllProductsState>(
            builder: (context, state) {
              const loader = VerticalProductShimmer();
              if (state.status == AllProductsStatus.loading) return loader;
              if (state.status == AllProductsStatus.error) {
                return Center(child: Text(state.errorMessage));
              }

              return SortableProducts(products: state.products);
            },
          ),
        ),
      ),
    );
  }
}