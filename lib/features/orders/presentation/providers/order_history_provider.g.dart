// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrderHistory)
final orderHistoryProvider = OrderHistoryProvider._();

final class OrderHistoryProvider
    extends $NotifierProvider<OrderHistory, List<OrderModel>> {
  OrderHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderHistoryHash();

  @$internal
  @override
  OrderHistory create() => OrderHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<OrderModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<OrderModel>>(value),
    );
  }
}

String _$orderHistoryHash() => r'30a07a34a0b0207f30f59686a753ccd4b74c6966';

abstract class _$OrderHistory extends $Notifier<List<OrderModel>> {
  List<OrderModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<OrderModel>, List<OrderModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<OrderModel>, List<OrderModel>>,
              List<OrderModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
