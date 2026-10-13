import 'package:fit_store/common/widgets/appbar/appbar.dart';
import 'package:fit_store/common/widgets/layouts/grid_layout.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/icons/circular_icon.dart';
import '../../../home/presentation/screens/home.dart';
import '../../../home/presentation/screens/product_cards/product_card_vertical.dart';
import '../../../home/presentation/screens/widgets/vertical_products_shimmer.dart';
import '../controllers/favorites_cubit/favorites_cubit.dart';
import '../controllers/favorites_cubit/favorites_state.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});
  static const String routeName = '/favourites-screen';

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().fetchFavoriteProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: Text(
          'Wishlist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          CircularIcon(
            icon: Iconsax.add,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
        ],
        showActions: false,
        showSkipButton: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  if (state.status == FavoritesStatus.initial ||
                      state.status == FavoritesStatus.loading) {
                    return const VerticalProductShimmer(itemCount: 6);
                  }

                  if (state.status == FavoritesStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage ??
                            'Something went wrong. Please try again.',
                      ),
                    );
                  }

                  if (state.favoriteProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppSizes.spaceBtwSections),
                          Icon(
                            Iconsax.heart_slash,
                            size: 100.r,
                            color: Colors.grey,
                          ),
                          SizedBox(height: AppSizes.spaceBtwItems),
                          Text(
                            'Whoops! Wishlist is Empty...',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridLayout(
                    itemCount: state.favoriteProducts.length,
                    itemBuilder: (_, index) => ProductCardVertical(
                      product: state.favoriteProducts[index],
                    ),
                  );
                },
              ),
              SizedBox(
                height: TDeviceUtils.getBottomNavigationBarHeight() +
                    AppSizes.defaultSpace,
              ),
            ],
          ),
        ),
      ),
    );
  }
}