import 'package:equatable/equatable.dart';

class ProductAttributeEntity extends Equatable {
  final String? name;
  final List<String>? values;

  const ProductAttributeEntity({
    this.name,
    this.values,
  });



  @override
  List<Object?> get props => [name, values];

}
