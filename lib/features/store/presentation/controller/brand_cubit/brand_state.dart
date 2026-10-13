part of 'brand_cubit.dart';

enum AllBrandsStatus { loading, success, error }
enum FeaturedBrandsStatus { loading, success, error }
enum CategoryBrandsStatus { loading, success, error }
enum CategoryBrandProductsStatus { loading, success, error }
enum BrandProductsStatus { loading, success, error }

const Object _unsetErrorMessage = Object();

class BrandState extends Equatable {
  final List<BrandEntity> featuredBrands;
  final List<BrandEntity> allBrands;
  final List<ProductEntity> brandProducts;
  final List<BrandEntity> categoryBrands;

  final Map<String, List<BrandEntity>> categoryBrandsMap;
  final Map<String, List<ProductEntity>> categoryBrandProducts;
  final Map<String, List<ProductEntity>> categoryProductsMap;

  final FeaturedBrandsStatus featuredStatus;
  final AllBrandsStatus allBrandsStatus;
  final CategoryBrandsStatus categoryBrandsStatus;
  final CategoryBrandProductsStatus categoryBrandProductsStatus;
  final BrandProductsStatus brandProductsStatus;

  final String? errorMessage;

  const BrandState({
    this.featuredBrands = const [],
    this.categoryBrands = const [],
    this.categoryBrandsMap = const {},
    this.brandProducts = const [],
    this.allBrands = const [],
    this.categoryBrandProducts = const {},
    this.categoryProductsMap = const {},
    this.featuredStatus = FeaturedBrandsStatus.loading,
    this.allBrandsStatus = AllBrandsStatus.loading,
    this.categoryBrandsStatus = CategoryBrandsStatus.loading,
    this.categoryBrandProductsStatus = CategoryBrandProductsStatus.loading,
    this.brandProductsStatus = BrandProductsStatus.loading,
    this.errorMessage,
  });

  BrandState copyWith({
    List<BrandEntity>? featuredBrands,
    List<BrandEntity>? categoryBrands,
    Map<String, List<BrandEntity>>? categoryBrandsMap,
    List<BrandEntity>? allBrands,
    List<ProductEntity>? brandProducts,
    Map<String, List<ProductEntity>>? categoryBrandProducts,
    Map<String, List<ProductEntity>>? categoryProductsMap,
    FeaturedBrandsStatus? featuredStatus,
    AllBrandsStatus? allBrandsStatus,
    CategoryBrandsStatus? categoryBrandsStatus,
    CategoryBrandProductsStatus? categoryBrandProductsStatus,
    BrandProductsStatus? brandProductsStatus,
    Object? errorMessage = _unsetErrorMessage,
  }) {
    return BrandState(
      featuredBrands: featuredBrands ?? this.featuredBrands,
      categoryBrands: categoryBrands ?? this.categoryBrands,
      categoryBrandsMap: categoryBrandsMap ?? this.categoryBrandsMap,
      brandProducts: brandProducts ?? this.brandProducts,
      allBrands: allBrands ?? this.allBrands,
      categoryBrandProducts: categoryBrandProducts ?? this.categoryBrandProducts,
      categoryProductsMap: categoryProductsMap ?? this.categoryProductsMap,
      featuredStatus: featuredStatus ?? this.featuredStatus,
      allBrandsStatus: allBrandsStatus ?? this.allBrandsStatus,
      categoryBrandsStatus: categoryBrandsStatus ?? this.categoryBrandsStatus,
      categoryBrandProductsStatus: categoryBrandProductsStatus ?? this.categoryBrandProductsStatus,
      brandProductsStatus: brandProductsStatus ?? this.brandProductsStatus,
      errorMessage: identical(errorMessage, _unsetErrorMessage) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    featuredBrands,
    categoryBrands,
    categoryBrandsMap,
    brandProducts,
    allBrands,
    categoryBrandProducts,
    categoryProductsMap,
    featuredStatus,
    allBrandsStatus,
    categoryBrandsStatus,
    categoryBrandProductsStatus,
    brandProductsStatus,
    errorMessage,
  ];
}