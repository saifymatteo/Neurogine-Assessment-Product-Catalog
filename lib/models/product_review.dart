import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_review.freezed.dart';
part 'product_review.g.dart';

@freezed
abstract class ProductReview with _$ProductReview {
  const factory ProductReview({
    int? rating,
    String? comment,
    DateTime? date,
    String? reviewerName,
    String? reviewerEmail,
  }) = _ProductReview;

  factory ProductReview.fromJson(Map<String, Object?> json) =>
      _$ProductReviewFromJson(json);
}
