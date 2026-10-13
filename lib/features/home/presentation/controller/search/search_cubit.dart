import 'dart:async';
 import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/domain/repos/home_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/local_storage/loacal_storage_service.dart';
import '../../../../../utils/helpers/network_manager.dart';
import '../../../../../utils/search/search_utils.dart';
import '../../screens/search/service/recent_search_store.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final HomeRepo _homeRepo;
  final RecentSearchesStore _recentStore;

  SearchCubit({
    required HomeRepo homeRepo,
    required RecentSearchesStore recentStore,
  })  : _homeRepo = homeRepo,
        _recentStore = recentStore,
        super(SearchState());

  static const String _noConnectionMessage =
      'No internet connection, please check your network.';

  Timer? _debounce;
  int _requestId = 0;
  List<SearchDoc<ProductEntity>> _index = [];
  List<ProductEntity> _ranked = [];

   Future<void> init() async {
    final recent = await _recentStore.load();
    if (isClosed) return;
    emit(state.copyWith(recent: recent));

    final error = await _ensureCatalog();
    if (isClosed || error != null) return;
    emit(state.copyWith(topBrands: _topBrands()));
  }


  void onQueryChanged(String raw) {
    _debounce?.cancel();
    final q = raw.trim();

    if (q.isEmpty) {
      _requestId++;
      emit(state.copyWith(
        status: SearchStatus.initial,
        products: const [],
        query: '',
        errorMessage: '',
      ));
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

   Future<void> submit(String raw) async {
    _debounce?.cancel();
    final q = raw.trim();
    if (q.isEmpty) return;
    await _search(q);
    await rememberQuery();
  }

   Future<void> rememberQuery() async {
    final q = state.query;
    if (q.isEmpty || state.products.isEmpty) return;
    final recent = await _recentStore.add(q);
    if (!isClosed) emit(state.copyWith(recent: recent));
  }

  Future<void> removeRecent(String q) async {
    final recent = await _recentStore.remove(q);
    if (!isClosed) emit(state.copyWith(recent: recent));
  }

  Future<void> clearRecent() async {
    final recent = await _recentStore.clear();
    if (!isClosed) emit(state.copyWith(recent: recent));
  }

  void setSort(SearchSort sort) {
    emit(state.copyWith(sort: sort, products: _applySort(_ranked, sort)));
  }

  Future<void> _search(String q) async {
    final id = ++_requestId;

    if (_index.isEmpty) {
      emit(state.copyWith(status: SearchStatus.loading, query: q));
    }

    final String? error = await _ensureCatalog();
    if (isClosed || id != _requestId) return;

    if (error != null) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: error,
        query: q,
      ));
      return;
    }

    _ranked = SearchUtils.searchIndex<ProductEntity>(_index, q);

    emit(state.copyWith(
      status: SearchStatus.success,
      products: _applySort(_ranked, state.sort),
      query: q,
      errorMessage: '',
    ));
  }


  void _setCatalog(List<ProductEntity> products) {
    _index = products
        .map((p) => SearchDoc<ProductEntity>.build(
      p,
      title: p.title,
      brand: p.brand?.name ?? '',
    ))
        .toList();
  }

   Future<String?> _ensureCatalog() async {
    if (_index.isNotEmpty) return null;

     final cachedAll = LocalStorageService.productsRepo.getData();
    if (cachedAll != null && cachedAll.isNotEmpty) {
      _setCatalog(cachedAll.map((e) => e.toEntity()).toList());
      return null;
    }

     final bool isConnected = await NetworkManager.instance.isConnected();
    if (isConnected) {
      final result = await _homeRepo.fetchAllProducts();
      return result.fold(
            (failure) => failure.message,
            (products) {
          _setCatalog(products);
          return null;
        },
      );
    }

     final cachedFeatured = LocalStorageService.featuredProductsRepo.getData();
    if (cachedFeatured != null && cachedFeatured.isNotEmpty) {
      _setCatalog(cachedFeatured.map((e) => e.toEntity()).toList());
      return null;
    }

    return _noConnectionMessage;
  }


   List<String> _topBrands() {
    final counts = <String, int>{};
    for (final d in _index) {
      final name = d.item.brand?.name.trim() ?? '';
      if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(8).map((e) => e.key).toList();
  }

  double _effectivePrice(ProductEntity p) {
    final v = p.productVariations;
    if (p.productType == 'variable' && v != null && v.isNotEmpty) {
      return v
          .map((e) => (e.salePrice != null && e.salePrice! > 0)
          ? e.salePrice!
          : e.price)
          .reduce((a, b) => a < b ? a : b);
    }
    return (p.salePrice != null && p.salePrice! > 0) ? p.salePrice! : p.price;
  }

  List<ProductEntity> _applySort(List<ProductEntity> list, SearchSort sort) {
    switch (sort) {
      case SearchSort.relevance:
        return list;
      case SearchSort.priceLow:
        return [...list]
          ..sort((a, b) => _effectivePrice(a).compareTo(_effectivePrice(b)));
      case SearchSort.priceHigh:
        return [...list]
          ..sort((a, b) => _effectivePrice(b).compareTo(_effectivePrice(a)));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}