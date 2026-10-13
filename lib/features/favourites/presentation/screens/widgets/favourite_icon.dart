import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../utils/constants/colors.dart';
import '../../controllers/favorites_cubit/favorites_cubit.dart';

class FavouriteIcon extends StatelessWidget {
  const FavouriteIcon({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavourite(productId),
    );

    return CircularIcon(
      icon: isSelected ? Iconsax.heart5 : Iconsax.heart,
      color: isSelected ? AppColors.error : null,
      onPressed: () => context.read<FavoritesCubit>().toggleFavoriteProduct(
        productId,
        context,
      ),
    );
  }
}
