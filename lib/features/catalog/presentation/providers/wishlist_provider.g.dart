// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Wishlist)
final wishlistProvider = WishlistProvider._();

final class WishlistProvider
    extends $NotifierProvider<Wishlist, List<ProductModel>> {
  WishlistProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistHash();

  @$internal
  @override
  Wishlist create() => Wishlist();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProductModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProductModel>>(value),
    );
  }
}

String _$wishlistHash() => r'740dd9df7a758c3ef9422d46bc92dbc853ce44fe';

abstract class _$Wishlist extends $Notifier<List<ProductModel>> {
  List<ProductModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ProductModel>, List<ProductModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ProductModel>, List<ProductModel>>,
              List<ProductModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
