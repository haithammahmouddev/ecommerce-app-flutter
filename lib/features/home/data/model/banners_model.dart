import '../../../../utils/constants/enums.dart';
import '../../domain/entities/banners_entity.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final bool isActive;
  final BannerTargetType targetType;
  final String targetId;
  final String? targetName;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    required this.targetType,
    required this.targetId,
    this.targetName,
  });

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      imageUrl: imageUrl,
      isActive: isActive,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
    );
  }

  factory BannerModel.fromFirebaseJson(Map<String, dynamic> json, {String id = ''}) {
    BannerTargetType parseTargetType(String? typeStr) {
      return BannerTargetType.values.firstWhere(
            (e) => e.name.toLowerCase() == (typeStr ?? '').toLowerCase(),
        orElse: () => BannerTargetType.none,
      );
    }

    return BannerModel(
      id: json['id'] ?? id,
      imageUrl: json['imageUrl'] ?? '',
      isActive: json['isActive'] ?? json['active'] ?? true,
      targetType: parseTargetType(json['targetType']),
      targetId: json['targetId'] ?? '',
      targetName: json['targetName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'targetType': targetType.name,
      'targetId': targetId,
      'targetName': targetName,
    };
  }

  static BannerModel empty() => const BannerModel(
    id: '',
    imageUrl: '',
    isActive: false,
    targetType: BannerTargetType.none,
    targetId: '',
  );
}