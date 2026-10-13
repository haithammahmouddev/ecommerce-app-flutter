part of 'products_cubit.dart';

enum FeaturedProductsStatus {loading, success, error }
enum ProductsStatus {loading, success, error }

class ProductsState {
  final ProductsStatus status;
  final FeaturedProductsStatus featuredStatus;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> allProducts;
  final String? errorMessage;

  ProductsState({
    this.status = ProductsStatus.loading,
    this.featuredStatus = FeaturedProductsStatus.loading,
    this.featuredProducts = const [],
    this.allProducts = const [],
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    FeaturedProductsStatus? featuredStatus,
    List<ProductEntity>? featuredProducts,
    List<ProductEntity>? allProducts,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      featuredStatus: featuredStatus ?? this.featuredStatus,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      allProducts: allProducts ?? this.allProducts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
