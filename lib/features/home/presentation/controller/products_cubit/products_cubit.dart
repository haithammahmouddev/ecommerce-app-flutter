import 'package:bloc/bloc.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import '../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/helpers/network_manager.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final HomeRepo _homeRepo;

  ProductsCubit({required this._homeRepo})
      : super(ProductsState());

  Future<void> fetchFeaturedProducts() async {
    final productsCached = LocalStorageService.featuredProductsRepo.getData();

    final bool isConnectedInternet = await NetworkManager.instance.isConnected();
    if (isConnectedInternet) {
      final result = await _homeRepo.fetchFeaturedProducts();

      result.fold(
            (failure) {
          emit(state.copyWith(
            featuredStatus: FeaturedProductsStatus.error,
            errorMessage: failure.message,
          ));
        },
            (success) {
          emit(state.copyWith(
            featuredStatus: FeaturedProductsStatus.success,
            featuredProducts: success,
          ));
        },
      );
    } else {
      if (productsCached != null && productsCached.isNotEmpty) {
        emit(state.copyWith(
          featuredStatus: FeaturedProductsStatus.success,
          featuredProducts: productsCached.map((e) => e.toEntity()).toList(),
        ));
      } else {
        emit(state.copyWith(
          featuredStatus: FeaturedProductsStatus.error,
          errorMessage: "No internet connection, please check your network.",
        ));
      }
    }
  }

  Future<void> fetchAllProducts() async {
    final productsCached = LocalStorageService.productsRepo.getData();

    final bool isConnectedInternet = await NetworkManager.instance.isConnected();
    if (isConnectedInternet) {
      final result = await _homeRepo.fetchAllProducts();

      result.fold(
            (failure) {
          emit(state.copyWith(
            status: ProductsStatus.error,
            errorMessage: failure.message,
          ));
        },
            (success) {
          emit(state.copyWith(
            status: ProductsStatus.success,
            allProducts: success,
          ));
        },
      );
    } else {
      if (productsCached != null && productsCached.isNotEmpty) {
        emit(state.copyWith(
          status: ProductsStatus.success,
          allProducts: productsCached.map((e) => e.toEntity()).toList(),
        ));
      } else {
        emit(state.copyWith(
          status: ProductsStatus.error,
          errorMessage: "No internet connection, please check your network.",
        ));
      }
    }
  }

   String getProductPrice(ProductEntity product) {
    double smallestPrice = double.infinity;
    double largestPrice = 0.0;

    if (product.productType == ProductType.single.toString()) {
      return (product.salePrice != null && product.salePrice! > 0
          ? product.salePrice
          : product.price)
          .toString();
    } else {
      if (product.productVariations == null ||
          product.productVariations!.isEmpty) {
        return product.price.toString();
      }

      for (var variation in product.productVariations!) {
        double priceToConsider =
        (variation.salePrice != null && variation.salePrice! > 0)
            ? variation.salePrice!
            : variation.price;

        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }

        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      if (smallestPrice.isInfinite) return product.price.toString();

      if (smallestPrice == largestPrice) {
        return largestPrice.toString();
      } else {
         return '$smallestPrice - $largestPrice \$';
      }
    }
  }

   String getProductOriginalPriceRange(ProductEntity product) {
    if (product.productType == ProductType.single.toString() ||
        product.productVariations == null ||
        product.productVariations!.isEmpty) {
      return '\$${product.price}';
    } else {
      double smallestPrice = double.infinity;
      double largestPrice = 0.0;

      for (var variation in product.productVariations!) {
        double priceToConsider = variation.price;

        if (priceToConsider < smallestPrice) {
          smallestPrice = priceToConsider;
        }
        if (priceToConsider > largestPrice) {
          largestPrice = priceToConsider;
        }
      }

      if (smallestPrice.isInfinite) return '\$${product.price}';

      if (smallestPrice == largestPrice) {
        return '\$$smallestPrice';
      } else {
        return '\$$smallestPrice - \$$largestPrice';
      }
    }
  }

  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;

    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;

    return percentage.toStringAsFixed(0);
  }

  String getProductStockStatus(int stock) {
    return stock > 0 ? 'In Stock' : 'Out of Stock';
  }
}