import 'package:dartz/dartz.dart';
import 'package:fit_store/common/errors/failure.dart';
import 'package:fit_store/features/store/domain/entities/brand_entity.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class StoreRepo {
  Future<Either<Failure, List<BrandEntity>>> fetchAllBrands();
  Future<Either<Failure, List<ProductEntity>>> fetchProductsForBrand({required String brandId});
  Future<Either<Failure, List<BrandEntity>>> fetchBrandsForCategory({required String categoryId});
  Future<Either<Failure, List<BrandEntity>>> fetchFeaturedBrands();

  Future<Either<Failure, List<ProductEntity>>> fetchProductsForCategory({
    required String categoryId,
  });
  Future<Either<Failure, List<ProductEntity>>> fetchLimitedProductsForCategory({
    required String categoryId,
  });
}