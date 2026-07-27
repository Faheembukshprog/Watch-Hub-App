// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => _ReviewModel(
  id: json['id'] as String,
  userName: json['userName'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ReviewModelToJson(_ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'date': instance.date.toIso8601String(),
    };
