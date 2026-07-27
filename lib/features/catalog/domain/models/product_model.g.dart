// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      stockCount: (json['stockCount'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'stockCount': instance.stockCount,
      'isAvailable': instance.isAvailable,
      'tags': instance.tags,
    };
