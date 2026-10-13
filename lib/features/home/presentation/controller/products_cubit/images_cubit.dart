import 'package:cached_network_image/cached_network_image.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/constants/sizes.dart';

part 'images_state.dart';

class ImagesCubit extends Cubit<ImagesState> {
  ImagesCubit() : super(ImagesState());

   void setSelectedProductImage(String image) {
    emit(state.copyWith(selectedProductImages: image));
  }

   void getAllProductImages(ProductEntity product) {
    final Set<String> images = {};
    images.add(product.thumbnail);
    emit(state.copyWith(selectedProductImages: product.thumbnail));
    if (product.images != null) {
      images.addAll(product.images!);
    }
    if (product.productVariations != null &&
        product.productVariations!.isNotEmpty) {
      images.addAll(
        product.productVariations!.map((variation) => variation.image),
      );
    }
    emit(
      state.copyWith(
        imagesStatus: ImagesStatus.success,
        allProductImages: images.toList(),
      ),
    );
  }

  void showEnlargedImage(BuildContext context, String image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.defaultSpace * 2,
                horizontal: AppSizes.defaultSpace,
              ),
              child: CachedNetworkImage(imageUrl: image),
            ),
            SizedBox(height: AppSizes.spaceBtwSections),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 150.w,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
