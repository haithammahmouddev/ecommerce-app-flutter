import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:fit_store/utils/popups/loaders.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._homeRepo) : super(const FavoritesState()) {
    _initFavorites();
  }

  final HomeRepo _homeRepo;


  Future<void> _initFavorites() async {
    final Map<String, bool> favorites =
        LocalStorageService.favoriteIdsRepo.getData() ?? {};

    final cachedProducts = LocalStorageService.favoritesRepo.getData() ?? [];
    final cachedEntities = cachedProducts.map((e) => e.toEntity()).toList();

    emit(state.copyWith(
      favorites: favorites,
      favoriteProducts: cachedEntities,
      status: cachedEntities.isNotEmpty
          ? FavoritesStatus.success
          : FavoritesStatus.initial,
    ));

    if (favorites.isNotEmpty) {
      await fetchFavoriteProducts();
    }
  }

  bool isFavourite(String productId) => state.favorites[productId] ?? false;

  Future<void> toggleFavoriteProduct(
      String productId, BuildContext context) async {
    if (productId.trim().isEmpty) return;

    final updated = Map<String, bool>.from(state.favorites);
    final isAdding = !updated.containsKey(productId);

    if (isAdding) {
      updated[productId] = true;
    } else {
      updated.remove(productId);
    }

    await LocalStorageService.favoriteIdsRepo.saveData(updated);

    emit(state.copyWith(favorites: updated));

    Loaders.customToast(
      message: isAdding
          ? 'Product has been added to the Wishlist.'
          : 'Product has been removed from the Wishlist.',
      context: context,
    );

    await fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    if (state.favorites.isEmpty) {
      await LocalStorageService.favoritesRepo.clearData();
      emit(state.copyWith(
        status: FavoritesStatus.success,
        favoriteProducts: [],
      ));
      return;
    }

    if (state.favoriteProducts.isEmpty) {
      emit(state.copyWith(status: FavoritesStatus.loading));
    }

    final ids = state.favorites.keys.toList();
    final result = await _homeRepo.getFavouriteProducts(productIds: ids);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: failure.message,
        ));
      },
          (products) {
        emit(state.copyWith(
          status: FavoritesStatus.success,
          favoriteProducts: products,
        ));
      },
    );
  }
}