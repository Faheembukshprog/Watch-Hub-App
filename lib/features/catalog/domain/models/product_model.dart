import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String brand,
    required double price,
    required String imageUrl,
    required String description,
    required int stock,
    @Default(true) bool isAvailable,
    @Default([]) List<String> tags,
  }) = _ProductModel;

  /// Factory constructor for creating a ProductModel from a Firestore Map
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
