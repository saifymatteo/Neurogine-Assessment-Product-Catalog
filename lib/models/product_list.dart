import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'product_list.freezed.dart';
part 'product_list.g.dart';

@freezed
abstract class ProductList with _$ProductList {
  const factory ProductList({
    int? total,
    int? skip,
    int? limit,
    List<Product>? products,
  }) = _ProductList;

  factory ProductList.fromJson(Map<String, Object?> json) =>
      _$ProductListFromJson(json);
}
