// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductReviews)
final productReviewsProvider = ProductReviewsProvider._();

final class ProductReviewsProvider
    extends $NotifierProvider<ProductReviews, Map<String, List<ReviewModel>>> {
  ProductReviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productReviewsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productReviewsHash();

  @$internal
  @override
  ProductReviews create() => ProductReviews();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<ReviewModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<ReviewModel>>>(
        value,
      ),
    );
  }
}

String _$productReviewsHash() => r'e05cc9bed9e4c7017193f412680c0965642850f1';

abstract class _$ProductReviews
    extends $Notifier<Map<String, List<ReviewModel>>> {
  Map<String, List<ReviewModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, List<ReviewModel>>,
              Map<String, List<ReviewModel>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, List<ReviewModel>>,
                Map<String, List<ReviewModel>>
              >,
              Map<String, List<ReviewModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
