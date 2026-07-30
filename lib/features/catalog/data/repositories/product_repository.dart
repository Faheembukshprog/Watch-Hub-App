import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_model.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

/// Exposes the ProductRepository to the rest of the app via Riverpod
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(firebaseFirestoreProvider));
});

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  /// Streams a real-time list of all available luxury watches
  Stream<List<ProductModel>> watchProducts() {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return _defaultFallbackProducts();
          }
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          }).toList();
        })
        .handleError((_) {
          return _defaultFallbackProducts();
        });
  }

  static List<ProductModel> _defaultFallbackProducts() {
    return [
      const ProductModel(
        id: 'rolex_submariner',
        name: 'Submariner Date',
        brand: 'Rolex',
        price: 10500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&q=80&w=600',
        description:
            'The Rolex Submariner Date is the benchmark for divers\' watches. It features a unidirectional rotatable bezel with Cerachrom insert and solid-link Oyster bracelet.',
        stockCount: 8,
        isAvailable: true,
        tags: ['diver', 'steel', 'classic', 'automatic'],
      ),
      const ProductModel(
        id: 'omega_speedmaster',
        name: 'Speedmaster Professional Moonwatch',
        brand: 'OMEGA',
        price: 6800.00,
        imageUrl:
            'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
        description:
            'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Chronograph with manual-winding movement calibre 3861, hesalite crystal, and historic dial details.',
        stockCount: 12,
        isAvailable: true,
        tags: ['chronograph', 'space', 'heritage', 'manual'],
      ),
      const ProductModel(
        id: 'patek_nautilus',
        name: 'Nautilus 5711',
        brand: 'Patek Philippe',
        price: 125000.00,
        imageUrl:
            'https://images.unsplash.com/photo-1622434641406-a158123450f9?auto=format&fit=crop&q=80&w=600',
        description:
            'With the rounded octagonal shape of its bezel, the Nautilus has epitomized the elegant sports watch since 1976. Features a horizontally embossed dial and integrated steel bracelet.',
        stockCount: 2,
        isAvailable: true,
        tags: ['sport', 'grail', 'integrated', 'automatic'],
      ),
      const ProductModel(
        id: 'ap_royal_oak',
        name: 'Royal Oak Selfwinding',
        brand: 'Audemars Piguet',
        price: 38500.00,
        imageUrl:
            'https://images.unsplash.com/photo-1629581678313-36cf745a9af9?auto=format&fit=crop&q=80&w=600',
        description:
            'The Audemars Piguet Royal Oak is an avant-garde masterpiece. Features the famous octagonal bezel secured by eight hexagonal screws, tapisserie dial, and integrated steel bracelet.',
        stockCount: 4,
        isAvailable: true,
        tags: ['sport', 'luxury', 'integrated', 'automatic'],
      ),
      const ProductModel(
        id: 'cartier_santos',
        name: 'Santos de Cartier Large',
        brand: 'Cartier',
        price: 7750.00,
        imageUrl:
            'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?auto=format&fit=crop&q=80&w=600',
        description:
            'Created in 1904, the Santos watch is based on the concept of form, minimalist lines, and precision proportions, embodying the pioneer spirit of aviation.',
        stockCount: 10,
        isAvailable: true,
        tags: ['dress', 'classic', 'square', 'automatic'],
      ),
    ];
  }

  /// Automatically seeds Firestore with rich luxury watch catalog data if empty
  Future<void> seedIfEmpty() async {
    try {
      final query = await _firestore.collection('products').limit(1).get();
      if (query.docs.isEmpty) {
        final batch = _firestore.batch();

        final mockProducts = [
          {
            'name': 'Submariner Date',
            'brand': 'Rolex',
            'price': 10500.00,
            'imageUrl':
                'https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&q=80&w=600',
            'description':
                'The Rolex Submariner Date is the benchmark for divers\' watches. It features a unidirectional rotatable bezel with Cerachrom insert and solid-link Oyster bracelet.',
            'stockCount': 8,
            'isAvailable': true,
            'tags': ['diver', 'steel', 'classic', 'automatic'],
          },
          {
            'name': 'Speedmaster Professional Moonwatch',
            'brand': 'OMEGA',
            'price': 6800.00,
            'imageUrl':
                'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
            'description':
                'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Chronograph with manual-winding movement calibre 3861, hesalite crystal, and historic dial details.',
            'stockCount': 12,
            'isAvailable': true,
            'tags': ['chronograph', 'space', 'heritage', 'manual'],
          },
          {
            'name': 'Nautilus 5711',
            'brand': 'Patek Philippe',
            'price': 125000.00,
            'imageUrl':
                'https://images.unsplash.com/photo-1622434641406-a158123450f9?auto=format&fit=crop&q=80&w=600',
            'description':
                'With the rounded octagonal shape of its bezel, the Nautilus has epitomized the elegant sports watch since 1976. Features a horizontally embossed dial and integrated steel bracelet.',
            'stockCount': 2,
            'isAvailable': true,
            'tags': ['sport', 'grail', 'integrated', 'automatic'],
          },
          {
            'name': 'Royal Oak Selfwinding',
            'brand': 'Audemars Piguet',
            'price': 38500.00,
            'imageUrl':
                'https://images.unsplash.com/photo-1629581678313-36cf745a9af9?auto=format&fit=crop&q=80&w=600',
            'description':
                'The Audemars Piguet Royal Oak is an avant-garde masterpiece. Features the famous octagonal bezel secured by eight hexagonal screws, tapisserie dial, and integrated steel bracelet.',
            'stockCount': 4,
            'isAvailable': true,
            'tags': ['sport', 'luxury', 'integrated', 'automatic'],
          },
          {
            'name': 'Santos de Cartier Large',
            'brand': 'Cartier',
            'price': 7750.00,
            'imageUrl':
                'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?auto=format&fit=crop&q=80&w=600',
            'description':
                'Created in 1904, the Santos watch is based on the concept of form, minimalist lines, and precision proportions, embodying the pioneer spirit of aviation.',
            'stockCount': 10,
            'isAvailable': true,
            'tags': ['dress', 'classic', 'square', 'automatic'],
          },
        ];

        final ids = [
          'rolex_submariner',
          'omega_speedmaster',
          'patek_nautilus',
          'ap_royal_oak',
          'cartier_santos',
        ];

        for (int i = 0; i < mockProducts.length; i++) {
          final docRef = _firestore.collection('products').doc(ids[i]);
          batch.set(docRef, mockProducts[i]);
        }

        await batch.commit();
      }
    } catch (_) {
      // Gracefully swallow errors during startup
    }
  }
}
