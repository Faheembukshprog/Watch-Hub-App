import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_model.dart';

/// Exposes the ProductRepository to the rest of the app via Riverpod
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(FirebaseFirestore.instance);
});

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  /// Streams a real-time list of all available luxury watches
  Stream<List<ProductModel>> watchProducts() {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true) // Only show available inventory
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Grab the raw JSON map from Firestore
        final data = doc.data();
        
        // Inject the Firestore Document ID into the map so our Freezed model catches it
        data['id'] = doc.id; 
        
        // Convert the map into our strongly-typed ProductModel
        return ProductModel.fromJson(data);
      }).toList();
    });
  }
}