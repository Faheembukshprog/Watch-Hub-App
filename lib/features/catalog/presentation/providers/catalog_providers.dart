import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/models/product_model.dart';

/// StreamProvider that watches our real-time Firestore catalog
/// and exposes it to the UI with built-in loading and error tracking.
final watchProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  // Grab the repository instance we just created
  final repository = ref.watch(productRepositoryProvider);
  
  // Return the active Firestore stream
  return repository.watchProducts();
});