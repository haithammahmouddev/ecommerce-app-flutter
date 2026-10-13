import 'package:carousel_slider/carousel_slider.dart';
import 'package:fit_store/features/home/domain/entities/banners_entity.dart';
import 'package:fit_store/features/home/presentation/controller/all_products/all_products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/categories_cubit/categories_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/promo_slider_cubit/promo_slider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../common/widgets/custom_shapes/containers/circular_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../common/di/injection_container.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../store/presentation/screens/store.dart';
import '../product_detail/product_detail.dart';
import '../sub_categories/sub_categories.dart';

class PromoSlider extends StatelessWidget {
  const PromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PromoSliderCubit>()..fetchBanners(),
      child: BlocBuilder<PromoSliderCubit, PromoSliderState>(
        builder: (context, state) {
          switch (state.status) {
            case PromoSliderEnum.loading:
              return _buildLoadingShimmer();

            case PromoSliderEnum.error:
              return _buildError(context, state.errorMessage);

            case PromoSliderEnum.loaded:
              final banners = state.bannerEntityList;
              if (banners.isEmpty) {
                return _buildError(context, 'No banners available');
              }
              return _buildLoadedSlider(context, banners);
          }
        },
      ),
    );
  }

  Future<void> _onBannerTap(BuildContext context, BannerEntity banner) async {
    final id = banner.targetId.trim();

    switch (banner.targetType) {
      case BannerTargetType.none:
      case BannerTargetType.store:
        Navigator.pushNamed(context, StoreScreen.routeName);
        return;

      case BannerTargetType.product:
        if (id.isEmpty) return;
        await _openProduct(context, id);
        return;

      case BannerTargetType.category:
        if (id.isEmpty) return;
        await _openCategory(context, id);
        return;

      case BannerTargetType.external:
        final uri = Uri.tryParse(id);
        if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return;
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
    }
  }

  Future<void> _openProduct(BuildContext context, String productId) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<PromoSliderCubit>();

    final result = await cubit.getProductById(productId);

    result.fold(
          (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
          (product) => navigator.pushNamed(
        ProductDetailScreen.routeName,
        arguments: product,
      ),
    );
  }

  Future<void> _openCategory(BuildContext context, String categoryId) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final promoCubit = context.read<PromoSliderCubit>();

    final productsCubit = sl<ProductsCubit>();
    final categoriesCubit = sl<CategoriesCubit>();
    final allProductsCubit = sl<AllProductsCubit>();

    final result = await promoCubit.getCategoryById(categoryId);

    result.fold(
          (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
          (category) => navigator.push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: productsCubit),
              BlocProvider.value(value: categoriesCubit),
              BlocProvider.value(value: allProductsCubit),
            ],
            child: SubCategoriesScreen(category: category),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey,
      highlightColor: AppColors.grey.withValues(alpha: 0.5),
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? message) {
    return SizedBox(
      height: 180.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40.r, color: Colors.red),
            SizedBox(height: AppSizes.sm),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: () => context.read<PromoSliderCubit>().fetchBanners(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedSlider(BuildContext context, List<BannerEntity> banners) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) =>
                context.read<PromoSliderCubit>().onPageChanged(index),
          ),
          items: banners
              .map(
                (banner) => RoundedImage(
              imageUrl: banner.imageUrl,
              isNetworkImage: true,
              onPressed: () => _onBannerTap(context, banner),
            ),
          )
              .toList(),
        ),
        SizedBox(height: AppSizes.spaceBtwItems),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < banners.length; i++)
                BlocSelector<PromoSliderCubit, PromoSliderState, int>(
                  selector: (state) => state.currentIndex,
                  builder: (context, currentIndex) {
                    return CircularContainer(
                      width: 20.w,
                      height: 4.h,
                      margin: EdgeInsets.only(right: 10.w),
                      backgroundColor: currentIndex == i
                          ? AppColors.dashboardAppbarBackground
                          : AppColors.grey,
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