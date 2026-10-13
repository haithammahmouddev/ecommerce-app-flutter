import 'package:fit_store/features/home/domain/entities/product_entity.dart';

enum FavoritesStatus { initial, loading, success, error }

class FavoritesState {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const {},
    this.favoriteProducts = const [],
    this.errorMessage,
  });

  final FavoritesStatus status;
  final Map<String, bool> favorites;
  final List<ProductEntity> favoriteProducts;
  final String? errorMessage;

  FavoritesState copyWith({
    FavoritesStatus? status,
    Map<String, bool>? favorites,
    List<ProductEntity>? favoriteProducts,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      errorMessage: errorMessage,
    );
  }
}