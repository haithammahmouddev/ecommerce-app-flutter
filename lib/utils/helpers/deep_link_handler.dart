import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/presentation/screens/product_detail/product_detail.dart';
import 'package:flutter/material.dart';
import '../../common/navigation/navigation_service.dart';

class DeepLinkHandler {
  DeepLinkHandler({required this.fetchProductById});

  final Future<ProductEntity?> Function(String id) fetchProductById;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handle(initial);
    }

    _sub = _appLinks.uriLinkStream.listen(_handle);
  }

  Future<void> _handle(Uri uri) async {
    debugPrint('DeepLink received: $uri');

    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'product') {
      final id = uri.pathSegments[1];

      try {
        final product = await fetchProductById(id);
        if (product == null) {
          debugPrint('DeepLink: product $id not found');
          return;
        }

        NavigationService.pushNamed(
          ProductDetailScreen.routeName,
          arguments: product,
        );
      } catch (e) {
        debugPrint('DeepLink error: $e');
      }
    }
  }

  void dispose() => _sub?.cancel();
}