part of 'search_cubit.dart';

enum SearchStatus { initial, loading, success, error }

enum SearchSort { relevance, priceLow, priceHigh }

class SearchState {
  final SearchStatus status;
  final List<ProductEntity> products;
  final String query;
  final String errorMessage;
  final SearchSort sort;
  final List<String> recent;
  final List<String> topBrands;

  SearchState({
    this.status = SearchStatus.initial,
    this.products = const [],
    this.query = '',
    this.errorMessage = '',
    this.sort = SearchSort.relevance,
    this.recent = const [],
    this.topBrands = const [],
  });

  bool get isEmptyResult =>
      status == SearchStatus.success && products.isEmpty;

  SearchState copyWith({
    SearchStatus? status,
    List<ProductEntity>? products,
    String? query,
    String? errorMessage,
    SearchSort? sort,
    List<String>? recent,
    List<String>? topBrands,
  }) {
    return SearchState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
      sort: sort ?? this.sort,
      recent: recent ?? this.recent,
      topBrands: topBrands ?? this.topBrands,
    );
  }
}