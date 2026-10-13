import '../../../../utils/constants/enums.dart';

class BannerEntity {
  final String id;
  final String imageUrl;
  final bool isActive;
  final BannerTargetType targetType;
  final String targetId;
  final String? targetName;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    required this.targetType,
    required this.targetId,
    this.targetName,
  });

  static  BannerEntity empty() => const BannerEntity(
    id: '',
    imageUrl: '',
    isActive: false,
    targetType: BannerTargetType.none,
    targetId: '',
  );
}