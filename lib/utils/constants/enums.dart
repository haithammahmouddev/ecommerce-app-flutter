
enum AppRole { admin, user }

enum Role { admin, user}

enum ChatType { support }


enum TextSizes { small, medium, large }

enum OrderStatus {processing, shipped, delivered, pending,cancelled}
enum ProductType { single, variable }
enum BannerTargetType {
  none,
  store,
  product,
  category,
  external;

  bool get requiresTarget =>
      this == BannerTargetType.product ||
          this == BannerTargetType.category ||
          this == BannerTargetType.external;
}



