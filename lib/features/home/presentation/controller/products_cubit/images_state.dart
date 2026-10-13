part of 'images_cubit.dart';

enum ImagesStatus { initial, loading, success, error }

class ImagesState {
  final String? selectedProductImage;
  final ImagesStatus imagesStatus;
  final String? errorMessage;
  final List<String> allProductImages;

  ImagesState({
    this.selectedProductImage,
    this.imagesStatus = ImagesStatus.initial,
    this.errorMessage,
    this.allProductImages = const [],
  });

  ImagesState copyWith({
    String? selectedProductImages,
    ImagesStatus? imagesStatus,
    String? errorMessage,
    List<String>? allProductImages,
  }) {
    return ImagesState(
      selectedProductImage: selectedProductImages ?? this.selectedProductImage,
      imagesStatus: imagesStatus ?? this.imagesStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      allProductImages: allProductImages ?? this.allProductImages,
    );
  }
}