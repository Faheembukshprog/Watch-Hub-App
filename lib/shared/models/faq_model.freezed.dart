// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faq_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FAQModel {

 String get question; String get answer;
/// Create a copy of FAQModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FAQModelCopyWith<FAQModel> get copyWith => _$FAQModelCopyWithImpl<FAQModel>(this as FAQModel, _$identity);

  /// Serializes this FAQModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FAQModel&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer);

@override
String toString() {
  return 'FAQModel(question: $question, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $FAQModelCopyWith<$Res>  {
  factory $FAQModelCopyWith(FAQModel value, $Res Function(FAQModel) _then) = _$FAQModelCopyWithImpl;
@useResult
$Res call({
 String question, String answer
});




}
/// @nodoc
class _$FAQModelCopyWithImpl<$Res>
    implements $FAQModelCopyWith<$Res> {
  _$FAQModelCopyWithImpl(this._self, this._then);

  final FAQModel _self;
  final $Res Function(FAQModel) _then;

/// Create a copy of FAQModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? answer = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FAQModel].
extension FAQModelPatterns on FAQModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FAQModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FAQModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FAQModel value)  $default,){
final _that = this;
switch (_that) {
case _FAQModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FAQModel value)?  $default,){
final _that = this;
switch (_that) {
case _FAQModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FAQModel() when $default != null:
return $default(_that.question,_that.answer);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  String answer)  $default,) {final _that = this;
switch (_that) {
case _FAQModel():
return $default(_that.question,_that.answer);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  String answer)?  $default,) {final _that = this;
switch (_that) {
case _FAQModel() when $default != null:
return $default(_that.question,_that.answer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FAQModel implements FAQModel {
  const _FAQModel({required this.question, required this.answer});
  factory _FAQModel.fromJson(Map<String, dynamic> json) => _$FAQModelFromJson(json);

@override final  String question;
@override final  String answer;

/// Create a copy of FAQModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FAQModelCopyWith<_FAQModel> get copyWith => __$FAQModelCopyWithImpl<_FAQModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FAQModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FAQModel&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,question,answer);

@override
String toString() {
  return 'FAQModel(question: $question, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$FAQModelCopyWith<$Res> implements $FAQModelCopyWith<$Res> {
  factory _$FAQModelCopyWith(_FAQModel value, $Res Function(_FAQModel) _then) = __$FAQModelCopyWithImpl;
@override @useResult
$Res call({
 String question, String answer
});




}
/// @nodoc
class __$FAQModelCopyWithImpl<$Res>
    implements _$FAQModelCopyWith<$Res> {
  __$FAQModelCopyWithImpl(this._self, this._then);

  final _FAQModel _self;
  final $Res Function(_FAQModel) _then;

/// Create a copy of FAQModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? answer = null,}) {
  return _then(_FAQModel(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
