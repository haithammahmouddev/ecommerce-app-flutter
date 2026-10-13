import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class CircularImage extends StatelessWidget {
  CircularImage({
    super.key,
    double? width,
    double? height,
    this.overlayColor,
    this.backgroundColor,
    required this.image,
    this.fit = BoxFit.fill,
    double? padding,
    this.isNetworkImage = false,
  })  : width = width ?? 70,
        height = height ?? 70,
        padding = padding ?? AppSizes.sm;

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (HelperFunctions.isDarkMode(context) ? AppColors.black : AppColors.white),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: isNetworkImage
              ? CachedNetworkImage(
            imageUrl: image,
            width: width.w,
            height: height.h,
            fit: fit,
            color: overlayColor,
            placeholder: (context, url) => SizedBox(
              width: 24.r,
              height: 24.r,
              child: Padding(
                padding: EdgeInsets.all(6.0.r),
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.person),
          )
              : Image(
            fit: fit,
            image: AssetImage(image),
            color: overlayColor,
          ),
        ),
      ),
    );
  }
}