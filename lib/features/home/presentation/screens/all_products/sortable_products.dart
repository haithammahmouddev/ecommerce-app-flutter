import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controller/all_products/all_products_cubit.dart';
import '../product_cards/product_card_vertical.dart';

class SortableProducts extends StatelessWidget {
  const SortableProducts({
    super.key,
    required this.products,
  });

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllProductsCubit, AllProductsState>(
      builder: (context, state) {
        final displayProducts = state.products.isNotEmpty ? state.products : products;

        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
              value: state.selectedSortOption,
              onChanged: (value) {
                if (value != null) {
                  context.read<AllProductsCubit>().sortProducts(value);
                }
              },
              items: ['Name', 'Higher Price', 'Lower Price', 'Sale', 'Newest', 'Popularity']
                  .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),

            GridLayout(
              itemCount: displayProducts.length,
              itemBuilder: (_, index) => ProductCardVertical(product: displayProducts[index]),
            ),
          ],
        );
      },
    );
  }
}