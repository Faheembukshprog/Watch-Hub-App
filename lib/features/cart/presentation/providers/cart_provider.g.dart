// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CartNotifier)
final cartProvider = CartNotifierProvider._();

final class CartNotifierProvider
    extends $NotifierProvider<CartNotifier, List<CartItemModel>> {
  CartNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartNotifierHash();

  @$internal
  @override
  CartNotifier create() => CartNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItemModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItemModel>>(value),
    );
  }
}

String _$cartNotifierHash() => r'5b078a8db9d3ed4b749a8aa7c9c3193ffe4e2d0b';

abstract class _$CartNotifier extends $Notifier<List<CartItemModel>> {
  List<CartItemModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<CartItemModel>, List<CartItemModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CartItemModel>, List<CartItemModel>>,
              List<CartItemModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
