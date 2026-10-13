import 'dart:math' as math;
import 'package:fit_store/features/home/presentation/screens/product_detail/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/di/injection_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../utils/search/search_utils.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../domain/entities/product_entity.dart';
import '../../controller/search/search_cubit.dart';

const Color _darkAccent = Color(0xFF8C9BFF);

Color _accent(bool isDark) => isDark ? _darkAccent : AppColors.primary;
Color _tint(bool isDark) =>
    AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.08);

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  static const routeName = '/search-screen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>()..init(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openProduct(ProductEntity product) {
    FocusScope.of(context).unfocus();
    context.read<SearchCubit>().rememberQuery();
    Navigator.pushNamed(
      context,
      ProductDetailScreen.routeName,
      arguments: product,
    );
  }

  void _selectQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    FocusScope.of(context).unfocus();
    context.read<SearchCubit>().submit(q);
  }

  Widget _buildBody(SearchState state, bool isDark, SearchCubit cubit) {
    switch (state.status) {
      case SearchStatus.loading:
        return _SkeletonList(key: const ValueKey('loading'), isDark: isDark);

      case SearchStatus.error:
        return _MessageView(
          key: const ValueKey('error'),
          icon: Iconsax.wifi_square,
          title: 'Something went wrong',
          subtitle: state.errorMessage,
          actionLabel: 'Try again',
          onAction: () => cubit.submit(state.query),
        );

      case SearchStatus.success:
        if (state.isEmptyResult) {
          return _MessageView(
            key: const ValueKey('empty'),
            icon: Iconsax.search_status,
            title: 'No results for "${state.query}"',
            subtitle: 'Check the spelling or try a different keyword.',
          );
        }
        return _ResultsList(
          key: const ValueKey('results'),
          products: state.products,
          query: state.query,
          sort: state.sort,
          isDark: isDark,
          onTap: _openProduct,
          onSort: cubit.setSort,
        );

      case SearchStatus.initial:
        return _SuggestionsView(
          key: const ValueKey('initial'),
          recent: state.recent,
          brands: state.topBrands,
          onSelect: _selectQuery,
          onRemove: cubit.removeRecent,
          onClear: cubit.clearRecent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HelperFunctions.isDarkMode(context);
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: AppBarCustom(
        title: const Text('Search'),
        showBackArrow: true,
        showActions: false,
        showSkipButton: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.defaultSpace,
                8.h,
                AppSizes.defaultSpace,
                12.h,
              ),
              child: _SearchField(
                controller: _controller,
                isDark: isDark,
                onChanged: cubit.onQueryChanged,
                onSubmitted: cubit.submit,
                onClear: () {
                  _controller.clear();
                  cubit.onQueryChanged('');
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildBody(state, isDark, cubit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.borderRadiusLg);
    final idleBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: isDark ? AppColors.darkerGrey : AppColors.borderLight,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search products or brands...',
          filled: true,
          fillColor: isDark ? AppColors.darkContainer : AppColors.white,
          prefixIcon: Icon(
            Iconsax.search_normal,
            size: 20.r,
            color: _accent(isDark),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
              icon: Icon(Iconsax.close_circle, size: 20.r),
              color: AppColors.iconSecondaryLight,
              onPressed: onClear,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          border: idleBorder,
          enabledBorder: idleBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: _accent(isDark), width: 1.6.w),
          ),
        ),
      ),
    );
  }
}

class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView({
    super.key,
    required this.recent,
    required this.brands,
    required this.onSelect,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> recent;
  final List<String> brands;
  final void Function(String) onSelect;
  final void Function(String) onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = HelperFunctions.isDarkMode(context);

    if (recent.isEmpty && brands.isEmpty) {
      return const _MessageView(
        icon: Iconsax.search_normal,
        title: 'Search for products',
        subtitle: 'Type a product name or brand to get started.',
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.defaultSpace,
        vertical: 4.h,
      ),
      children: [
        if (recent.isNotEmpty) ...[
          _SectionHeader(
            icon: Iconsax.clock,
            title: 'Recent searches',
            actionLabel: 'Clear all',
            onAction: onClear,
            isDark: isDark,
          ),
          SizedBox(height: 4.h),
          for (final q in recent)
            _RecentTile(
              query: q,
              onTap: () => onSelect(q),
              onRemove: () => onRemove(q),
            ),
          SizedBox(height: 24.h),
        ],
        if (brands.isNotEmpty) ...[
          _SectionHeader(
            icon: Iconsax.trend_up,
            title: 'Popular brands',
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.r,
            runSpacing: 10.r,
            children: [
              for (final b in brands)
                _BrandChip(name: b, isDark: isDark, onTap: () => onSelect(b)),
            ],
          ),
        ],
      ],
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: _tint(isDark),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.r, color: _accent(isDark)),
        ),
        SizedBox(width: 10.w),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: TextStyle(color: _accent(isDark))),
          ),
      ],
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 6.w, top: 2.h, bottom: 2.h),
        child: Row(
          children: [
            Icon(
              Iconsax.clock,
              size: 18.r,
              color: AppColors.iconSecondaryLight,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Iconsax.close_circle,
                size: 18.r,
                color: AppColors.iconSecondaryLight,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.name,
    required this.isDark,
    required this.onTap,
  });

  final String name;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(isDark);
    return Material(
      color: _tint(isDark),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 7.h, 16.w, 7.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                name,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    super.key,
    required this.products,
    required this.query,
    required this.sort,
    required this.isDark,
    required this.onTap,
    required this.onSort,
  });

  final List<ProductEntity> products;
  final String query;
  final SearchSort sort;
  final bool isDark;
  final void Function(ProductEntity) onTap;
  final void Function(SearchSort) onSort;

  static const _labels = {
    SearchSort.relevance: 'Best match',
    SearchSort.priceLow: 'Price: low to high',
    SearchSort.priceHigh: 'Price: high to low',
  };

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              for (final e in _labels.entries)
                ListTile(
                  title: Text(
                    e.value,
                    style: TextStyle(
                      fontWeight: e.key == sort
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: e.key == sort
                      ? Icon(Iconsax.tick_circle, color: _accent(isDark))
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onSort(e.key);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final n = products.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.defaultSpace,
            0,
            AppSizes.defaultSpace,
            10.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$n',
                        style: textTheme.titleMedium?.copyWith(
                          color: _accent(isDark),
                        ),
                      ),
                      TextSpan(
                        text: n == 1 ? ' result' : ' results',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => _showSortSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: _tint(isDark),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.sort, size: 16.r, color: _accent(isDark)),
                      SizedBox(width: 6.w),
                      Text(
                        _labels[sort]!,
                        style: textTheme.labelLarge?.copyWith(
                          color: _accent(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSizes.defaultSpace,
              4.h,
              AppSizes.defaultSpace,
              AppSizes.defaultSpace,
            ),
            itemCount: n,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (_, i) {
              final p = products[i];
              return _ProductResultTile(
                product: p,
                query: query,
                isDark: isDark,
                onTap: () => onTap(p),
              )
                  .animate(key: ValueKey(p.id))
                  .fadeIn(duration: 260.ms, delay: (35 * math.min(i, 8)).ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
            },
          ),
        ),
      ],
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  const _ProductResultTile({
    required this.product,
    required this.query,
    required this.isDark,
    required this.onTap,
  });

  final ProductEntity product;
  final String query;
  final bool isDark;
  final VoidCallback onTap;

  static const double _imageSize = 92;

  String _fmt(double v) => '\$${v.toStringAsFixed(2)}';

  double? _minVariationPrice() {
    final variations = product.productVariations;
    if (variations == null || variations.isEmpty) return null;
    double? min;
    for (final v in variations) {
      final p = (v.salePrice != null && v.salePrice! > 0)
          ? v.salePrice!
          : v.price;
      if (min == null || p < min) min = p;
    }
    return min;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _accent(isDark);
    final radius = BorderRadius.circular(AppSizes.borderRadiusLg);

    final isVariable = product.productType == 'variable';
    final minVar = isVariable ? _minVariationPrice() : null;

    final hasSale =
        !isVariable &&
            product.salePrice != null &&
            product.salePrice! > 0 &&
            product.salePrice! < product.price;

    final salePercent = hasSale
        ? ((product.price - product.salePrice!) / product.price * 100).round()
        : 0;

    final String priceText = minVar != null
        ? 'From ${_fmt(minVar)}'
        : _fmt(hasSale ? product.salePrice! : product.price);

    final outOfStock = !isVariable && product.stock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkContainer : AppColors.white,
        borderRadius: radius,
        border: Border.all(
          color: isDark ? AppColors.darkerGrey : AppColors.borderLight,
        ),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                SizedBox(
                  width: _imageSize.w,
                  height: _imageSize.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadiusMd,
                        ),
                        child: RoundedImage(
                          isNetworkImage: true,
                          imageUrl: product.thumbnail,
                          applyImageRadius: true,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (outOfStock)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadiusMd,
                          ),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            alignment: Alignment.center,
                            child: Text(
                              'Sold out',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (hasSale)
                        Positioned(
                          top: 6.h,
                          left: 6.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '-$salePercent%',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.brand != null) ...[
                        _HighlightText(
                          product.brand!.name,
                          query: query,
                          maxLines: 1,
                          highlightColor: accent,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.darkGrey,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                      _HighlightText(
                        product.title,
                        query: query,
                        maxLines: 2,
                        highlightColor: accent,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        children: [
                          Text(
                            priceText,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                          if (hasSale)
                            Text(
                              _fmt(product.price),
                              style: textTheme.labelMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.darkGrey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: _tint(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.arrow_right_3, size: 16.r, color: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Widget line(double factor, double height) => FractionallySizedBox(
      widthFactor: factor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );

    Widget item() => Row(
      children: [
        Container(
          width: 92.w,
          height: 92.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              line(0.35, 11),
              SizedBox(height: 10.h),
              line(0.85, 14),
              SizedBox(height: 8.h),
              line(0.6, 14),
              SizedBox(height: 14.h),
              line(0.3, 16),
            ],
          ),
        ),
      ],
    );

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkContainer : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF1F2842) : Colors.grey.shade100,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.defaultSpace,
          vertical: 8.h,
        ),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: 22.h),
        itemBuilder: (_, __) => item(),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  const _HighlightText(
      this.text, {
        required this.query,
        required this.highlightColor,
        this.style,
        this.maxLines,
      });

  final String text;
  final String query;
  final Color highlightColor;
  final TextStyle? style;
  final int? maxLines;

  static final _parts = RegExp(r'\S+|\s+');

  @override
  Widget build(BuildContext context) {
    final qTokens = SearchUtils.tokenize(query);
    if (qTokens.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final hitStyle = (style ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w800,
      color: highlightColor,
    );

    final spans = <TextSpan>[];
    for (final m in _parts.allMatches(text)) {
      final word = m.group(0)!;
      final n = SearchUtils.normalize(word);
      final hit =
          n.isNotEmpty &&
              qTokens.any(
                    (q) => n.startsWith(q) || (q.length >= 3 && n.contains(q)),
              );
      spans.add(TextSpan(text: word, style: hit ? hitStyle : null));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = HelperFunctions.isDarkMode(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 116.w,
              height: 116.h,
              decoration: BoxDecoration(
                color: _tint(isDark),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48.r, color: _accent(isDark)),
            )
                .animate()
                .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 350.ms,
              curve: Curves.easeOutBack,
            )
                .fadeIn(),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
            ),
            if (actionLabel != null) ...[
              SizedBox(height: 20.h),
              SizedBox(
                width: 180.w,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}