# API Reference

> Operational specification of the App-WatchHub data access layer. Because the architecture has no custom backend (see [DECISIONS.md](DECISIONS.md) ADR-001), the "API" is the set of Firestore collection operations exposed to the Flutter client, gated by Firestore Security Rules. This file documents every operation, its authorization, and a Dart code example.

---

## Document Metadata

| Field | Value |
|---|---|
| **Title** | App-WatchHub — API Reference |
| **Purpose** | Document every Firestore operation, its authz rule, and a Dart usage example |
| **Audience** | Engineers, AI coding agents, security reviewers |
| **Scope** | Data access operations only; schemas in [DATABASE_DESIGN.md](DATABASE_DESIGN.md), authz in [SECURITY.md](SECURITY.md) |
| **Version** | 1.0.0 |
| **Status** | Approved — locked for MVP cycle |
| **Owner** | Muhammad Faheem Khan (Student ID: 1593766) |
| **Last Updated** | 2026-07-15 |
| **Related Documents** | [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [SECURITY.md](SECURITY.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md) |

---

## Table of Contents

1. [API Model Overview](#1-api-model-overview)
2. [Conventions](#2-conventions)
3. [`/users` Operations](#3-users-operations)
4. [`/products` Operations](#4-products-operations)
5. [`/orders` Operations](#5-orders-operations)
6. [Authentication Operations](#6-authentication-operations)
7. [Analytics Events](#7-analytics-events)
8. [Error Codes](#8-error-codes)
9. [References](#9-references)

---

## 1. API Model Overview

App-WatchHub has no REST API, no GraphQL endpoint, and no RPC service. The client communicates with Firebase's managed SDKs directly:

| Concern | SDK | Endpoint |
|---|---|---|
| Authentication | `firebase_auth` Dart package | Firebase Auth REST (underlying SDK) |
| Data read/write | `cloud_firestore` Dart package | Cloud Firestore gRPC / WebSocket |
| File storage | (none — local assets only) | N/A |
| Server-side logic | (none — no Cloud Functions) | N/A |

Every Firestore operation passes through the Security Rules engine, which evaluates the request against the rules in [SECURITY.md](SECURITY.md) § Rules. Operations that fail rule evaluation return `PERMISSION_DENIED` to the client.

This file uses a tabular format for operation docs:

| Field | Description |
|---|---|
| **Operation** | Human-readable name |
| **Method** | Firestore SDK method (get, set, update, delete, snapshots) |
| **Path** | Document or collection path with parameters |
| **Authz** | Required auth state (Public, Authenticated, Owner, Admin) |
| **Request Shape** | Required/optional fields with types |
| **Response Shape** | Return type and structure |
| **Example** | Dart code snippet |
| **Failure Modes** | Possible errors and their meanings |

## 2. Conventions

### 2.1 Path Notation

- `/users/{uid}` — single document; `{uid}` is a path parameter
- `/products` — collection reference
- `/orders/{orderId}/items` — sub-collection (NOT used in MVP; items are embedded)

### 2.2 Type Notation

| Notation | Meaning |
|---|---|
| `string` | Dart `String`; Firestore `string` |
| `number` | Dart `double` or `int`; Firestore `number` |
| `boolean` | Dart `bool`; Firestore `boolean` |
| `timestamp` | Dart `DateTime`; Firestore `Timestamp` |
| `map<K,V>` | Dart `Map<K,V>`; Firestore `map` |
| `array<T>` | Dart `List<T>`; Firestore `array` |
| `nullable<T>` | `T?` in Dart; field may be absent |

### 2.3 Authz Levels

| Level | Meaning |
|---|---|
| **Public** | No authentication required; rules return `allow read: if true` |
| **Authenticated** | Any signed-in user; `request.auth != null` |
| **Owner** | Authenticated user whose `uid` matches a path field |
| **Admin** | Authenticated user whose `/users/{uid}.isAdmin == true` |

## 3. `/users` Operations

### 3.1 Create User Profile

| Field | Value |
|---|---|
| **Operation** | Create user profile document on first auth |
| **Method** | `set()` |
| **Path** | `/users/{uid}` |
| **Authz** | Owner (the user themselves) |
| **Request Shape** | `{ fullName: string, email: string, isAdmin: boolean=false, createdAt: timestamp, updatedAt: timestamp }` |
| **Response Shape** | None (write only) |
| **Failure Modes** | `PERMISSION_DENIED` if `uid != request.auth.uid` |

**Example:**

```dart
// lib/shared/repositories/auth_repository.dart
Future<void> createUserProfile({
  required String uid,
  required String fullName,
  required String email,
}) async {
  final ref = _firestore.collection('users').doc(uid);
  await ref.set({
    'fullName': fullName,
    'email': email,
    'isAdmin': false, // Default; can only be changed via Firebase Console
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

### 3.2 Read User Profile

| Field | Value |
|---|---|
| **Operation** | Read own or any user's profile (admin) |
| **Method** | `get()` |
| **Path** | `/users/{uid}` |
| **Authz** | Owner or Admin |
| **Request Shape** | None |
| **Response Shape** | `User` model (see [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.1) |
| **Failure Modes** | `PERMISSION_DENIED` if not owner and not admin |

**Example:**

```dart
Future<User> getUserProfile(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  if (!doc.exists) {
    throw UserProfileNotFoundException(uid: uid);
  }
  return User.fromJson(doc.data()!);
}
```

### 3.3 Update User Profile

| Field | Value |
|---|---|
| **Operation** | Update fullName (only mutable field for MVP) |
| **Method** | `update()` |
| **Path** | `/users/{uid}` |
| **Authz** | Owner or Admin |
| **Request Shape** | `{ fullName?: string, updatedAt: timestamp }` |
| **Response Shape** | None |
| **Failure Modes** | `PERMISSION_DENIED` if not owner and not admin |

> **NOTE** — The `isAdmin` field is not in the request shape because the Security Rules block writes to it from the client (see [SECURITY.md](SECURITY.md) § Admin Bootstrap). To promote a user to admin, edit the document directly in the Firebase Console.

**Example:**

```dart
Future<void> updateFullName({
  required String uid,
  required String newFullName,
}) async {
  await _firestore.collection('users').doc(uid).update({
    'fullName': newFullName,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

### 3.4 Subscribe to Own Profile (Stream)

| Field | Value |
|---|---|
| **Operation** | Real-time stream of own profile (used for live `isAdmin` updates) |
| **Method** | `snapshots()` |
| **Path** | `/users/{uid}` |
| **Authz** | Owner or Admin |
| **Request Shape** | None |
| **Response Shape** | `Stream<User>` |
| **Failure Modes** | `PERMISSION_DENIED` if auth state lost mid-stream |

**Example:**

```dart
Stream<User> watchUserProfile(String uid) {
  return _firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .where((doc) => doc.exists)
      .map((doc) => User.fromJson(doc.data()!));
}
```

## 4. `/products` Operations

### 4.1 List All Products

| Field | Value |
|---|---|
| **Operation** | Fetch full catalog (real-time stream) |
| **Method** | `snapshots()` |
| **Path** | `/products` |
| **Authz** | Public |
| **Request Shape** | None |
| **Response Shape** | `Stream<List<Product>>` |
| **Failure Modes** | Network error (Stream emits error) |

**Example:**

```dart
Stream<List<Product>> watchAllProducts() {
  return _firestore
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((query) => query.docs.map((doc) => Product.fromJson(doc.data())).toList());
}
```

### 4.2 Get Product by ID

| Field | Value |
|---|---|
| **Operation** | Fetch single product for detail view |
| **Method** | `get()` |
| **Path** | `/products/{productId}` |
| **Authz** | Public |
| **Request Shape** | None |
| **Response Shape** | `Product` model |
| **Failure Modes** | `not-found` if productId does not exist |

**Example:**

```dart
Future<Product> getProduct(String productId) async {
  final doc = await _firestore.collection('products').doc(productId).get();
  if (!doc.exists) {
    throw ProductNotFoundException(productId: productId);
  }
  return Product.fromJson(doc.data()!);
}
```

### 4.3 Filter Products by Brand

| Field | Value |
|---|---|
| **Operation** | Filter catalog by brand list |
| **Method** | `snapshots()` with `whereIn` |
| **Path** | `/products` |
| **Authz** | Public |
| **Request Shape** | `brands: array<string>` |
| **Response Shape** | `Stream<List<Product>>` |
| **Failure Modes** | `FAILED_PRECONDITION` if composite index missing |

**Example:**

```dart
Stream<List<Product>> filterByBrands(List<String> brands) {
  if (brands.isEmpty) return watchAllProducts();
  return _firestore
      .collection('products')
      .where('brand', whereIn: brands)
      .orderBy('price', descending: false)
      .snapshots()
      .map((query) => query.docs.map((doc) => Product.fromJson(doc.data())).toList());
}
```

> **NOTE** — Client-side filtering is preferred for MVP because the catalog is small (<50 SKUs per A-1). Multiple filters are composed in `filter_provider.dart` rather than issuing multiple Firestore queries. See [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) §8 Catalog Stream Design.

### 4.4 Create Product (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin adds new product to catalog |
| **Method** | `set()` with custom productId slug |
| **Path** | `/products/{productId}` |
| **Authz** | Admin |
| **Request Shape** | Full Product document (see [DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.2) |
| **Response Shape** | None |
| **Failure Modes** | `PERMISSION_DENIED` if not admin; `ALREADY_EXISTS` if productId in use |

**Example:**

```dart
Future<void> createProduct(Product product) async {
  final ref = _firestore.collection('products').doc(product.productId);
  await ref.set({
    ...product.toJson(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

### 4.5 Update Product (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin updates stock, price, or other fields |
| **Method** | `update()` |
| **Path** | `/products/{productId}` |
| **Authz** | Admin |
| **Request Shape** | Partial Product (any subset of fields) |
| **Response Shape** | None |
| **Failure Modes** | `PERMISSION_DENIED` if not admin |

**Example:**

```dart
Future<void> updateStock({
  required String productId,
  required int newStock,
}) async {
  await _firestore.collection('products').doc(productId).update({
    'stockCount': newStock,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

### 4.6 Delete Product (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin removes product from catalog |
| **Method** | `delete()` |
| **Path** | `/products/{productId}` |
| **Authz** | Admin |
| **Request Shape** | None |
| **Response Shape** | None |
| **Failure Modes** | `PERMISSION_DENIED` if not admin |

> **WARNING** — Deleting a product does NOT cascade to historical orders. Existing orders retain their embedded `items[]` snapshot. This is intentional — order history must remain accurate even if the product is later removed.

**Example:**

```dart
Future<void> deleteProduct(String productId) async {
  await _firestore.collection('products').doc(productId).delete();
}
```

## 5. `/orders` Operations

### 5.1 Create Order

| Field | Value |
|---|---|
| **Operation** | Customer places an order |
| **Method** | `add()` (auto-generate orderId) |
| **Path** | `/orders` |
| **Authz** | Authenticated (owner must equal auth.uid) |
| **Request Shape** | See Order document schema ([DATABASE_DESIGN.md](DATABASE_DESIGN.md) §4.3) |
| **Response Shape** | `DocumentReference` (contains orderId) |
| **Failure Modes** | `PERMISSION_DENIED` if `userId != request.auth.uid` |

**Example:**

```dart
Future<String> createOrder({
  required String userId,
  required List<CartItem> items,
  required double subtotal,
  required double tax,
  required double totalAmount,
}) async {
  final ref = await _firestore.collection('orders').add({
    'userId': userId,
    'subtotal': subtotal,
    'tax': tax,
    'totalAmount': totalAmount,
    'orderStatus': 'Processing',
    'createdAt': FieldValue.serverTimestamp(),
    'items': items.map((item) => {
      'productId': item.productId,
      'modelName': item.modelName, // denormalized
      'quantity': item.quantity,
      'unitPrice': item.unitPrice, // denormalized
      'lineTotal': item.quantity * item.unitPrice,
    }).toList(),
  });
  return ref.id;
}
```

### 5.2 List Customer's Orders

| Field | Value |
|---|---|
| **Operation** | Customer retrieves their own order history |
| **Method** | `get()` with `where` filter |
| **Path** | `/orders` (filtered by userId) |
| **Authz** | Owner only (rule enforces `userId == request.auth.uid`) |
| **Request Shape** | `userId: string` |
| **Response Shape** | `Future<List<Order>>` |
| **Failure Modes** | `PERMISSION_DENIED` if `userId != request.auth.uid` |

**Example:**

```dart
Future<List<Order>> getMyOrders(String userId) async {
  final query = await _firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();
  return query.docs.map((doc) => Order.fromJson(doc.data())).toList();
}
```

### 5.3 Subscribe to Customer's Orders (Stream)

| Field | Value |
|---|---|
| **Operation** | Real-time stream of customer's orders (status updates reflected live) |
| **Method** | `snapshots()` |
| **Path** | `/orders` (filtered by userId) |
| **Authz** | Owner only |
| **Request Shape** | `userId: string` |
| **Response Shape** | `Stream<List<Order>>` |
| **Failure Modes** | `PERMISSION_DENIED` if auth state lost |

**Example:**

```dart
Stream<List<Order>> watchMyOrders(String userId) {
  return _firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((query) => query.docs.map((doc) => Order.fromJson(doc.data())).toList());
}
```

### 5.4 Get Order by ID

| Field | Value |
|---|---|
| **Operation** | Retrieve a single order |
| **Method** | `get()` |
| **Path** | `/orders/{orderId}` |
| **Authz** | Owner or Admin |
| **Request Shape** | None |
| **Response Shape** | `Order` model |
| **Failure Modes** | `PERMISSION_DENIED` if not owner and not admin; `not-found` |

**Example:**

```dart
Future<Order> getOrder(String orderId) async {
  final doc = await _firestore.collection('orders').doc(orderId).get();
  if (!doc.exists) {
    throw OrderNotFoundException(orderId: orderId);
  }
  return Order.fromJson(doc.data()!);
}
```

### 5.5 List All Orders (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin retrieves all orders for dashboard |
| **Method** | `get()` or `snapshots()` |
| **Path** | `/orders` (no filter) |
| **Authz** | Admin |
| **Request Shape** | None (optional `status` filter) |
| **Response Shape** | `Stream<List<Order>>` |
| **Failure Modes** | `PERMISSION_DENIED` if not admin |

**Example:**

```dart
Stream<List<Order>> watchAllOrders({String? statusFilter}) {
  var query = _firestore.collection('orders').orderBy('createdAt', descending: true);
  if (statusFilter != null) {
    query = query.where('orderStatus', isEqualTo: statusFilter);
  }
  return query
      .snapshots()
      .map((q) => q.docs.map((doc) => Order.fromJson(doc.data())).toList());
}
```

### 5.6 Update Order Status (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin changes order status (Processing → Confirmed → Shipped → Delivered) |
| **Method** | `update()` |
| **Path** | `/orders/{orderId}` |
| **Authz** | Admin |
| **Request Shape** | `{ orderStatus: string }` |
| **Response Shape** | None |
| **Failure Modes** | `PERMISSION_DENIED` if not admin |

**Example:**

```dart
Future<void> updateOrderStatus({
  required String orderId,
  required OrderStatus newStatus,
}) async {
  await _firestore.collection('orders').doc(orderId).update({
    'orderStatus': newStatus.name,
  });
}
```

## 5.7 `/reviews` Operations

### 5.7.1 Create Review

| Field | Value |
|---|---|
| **Operation** | Customer submits a product review |
| **Method** | `add()` (auto-generate reviewId) |
| **Path** | `/reviews` |
| **Authz** | Authenticated (owner must equal auth.uid) |
| **Request Shape** | `{ productId, userId, userFullName, rating: 1-5, title, body, status: 'pending', createdAt, updatedAt }` |
| **Response Shape** | `DocumentReference` |
| **Failure Modes** | `PERMISSION_DENIED` if not authenticated or `userId != auth.uid` or `status != 'pending'` |

**Example:**

```dart
Future<String> createReview({
  required String productId,
  required String userId,
  required String userFullName,
  required int rating,
  required String title,
  required String body,
}) async {
  final ref = await _firestore.collection('reviews').add({
    'productId': productId,
    'userId': userId,
    'userFullName': userFullName,
    'rating': rating,
    'title': title,
    'body': body,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'moderatedAt': null,
    'moderatedBy': null,
  });
  return ref.id;
}
```

### 5.7.2 Stream Approved Reviews for a Product

| Field | Value |
|---|---|
| **Operation** | Real-time stream of approved reviews for a product detail page |
| **Method** | `snapshots()` with `where` filter |
| **Path** | `/reviews` (filtered by `productId` and `status == 'approved'`) |
| **Authz** | Public (anyone can read approved reviews) |
| **Request Shape** | `productId: string` |
| **Response Shape** | `Stream<List<Review>>` |
| **Failure Modes** | Network error |

**Example:**

```dart
Stream<List<Review>> watchApprovedReviews(String productId) {
  return _firestore
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((doc) => Review.fromJson(doc.data())).toList());
}
```

### 5.7.3 Stream Pending Reviews (Admin Moderation Queue)

| Field | Value |
|---|---|
| **Operation** | Admin sees all pending reviews |
| **Method** | `snapshots()` |
| **Path** | `/reviews` (filtered by `status == 'pending'`) |
| **Authz** | Admin |
| **Response Shape** | `Stream<List<Review>>` |

### 5.7.4 Moderate Review (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin approves or rejects a review |
| **Method** | `update()` |
| **Path** | `/reviews/{reviewId}` |
| **Authz** | Admin |
| **Request Shape** | `{ status: 'approved'|'rejected', moderatedAt: timestamp, moderatedBy: uid }` |
| **Failure Modes** | `PERMISSION_DENIED` if not admin; rule blocks mutation of `rating`, `title`, `body` |

## 5.8 `/supportTickets` Operations

### 5.8.1 Create Support Ticket

| Field | Value |
|---|---|
| **Operation** | Customer submits a support request |
| **Method** | `add()` |
| **Path** | `/supportTickets` |
| **Authz** | Authenticated |
| **Request Shape** | `{ userId, userFullName, userEmail, subject, subjectCategory, messageBody, relatedOrderId?, status: 'open', createdAt, updatedAt, adminResponse: null, respondedAt: null, respondedBy: null }` |
| **Response Shape** | `DocumentReference` |

### 5.8.2 Stream Customer's Tickets

| Field | Value |
|---|---|
| **Operation** | Customer sees their own ticket history |
| **Method** | `snapshots()` |
| **Path** | `/supportTickets` (filtered by `userId == auth.uid`) |
| **Authz** | Owner |
| **Response Shape** | `Stream<List<SupportTicket>>` |

### 5.8.3 Stream Open Tickets (Admin Queue)

| Field | Value |
|---|---|
| **Operation** | Admin sees open tickets |
| **Method** | `snapshots()` |
| **Path** | `/supportTickets` (optionally filtered by `status`) |
| **Authz** | Admin |
| **Response Shape** | `Stream<List<SupportTicket>>` |

### 5.8.4 Respond to Ticket (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin responds to a support ticket |
| **Method** | `update()` |
| **Path** | `/supportTickets/{ticketId}` |
| **Authz** | Admin |
| **Request Shape** | `{ status: 'in_progress'|'resolved'|'closed', adminResponse: string, respondedAt: timestamp, respondedBy: uid }` |

## 5.9 `/feedback` Operations

### 5.9.1 Create Feedback

| Field | Value |
|---|---|
| **Operation** | User (or anonymous) submits feedback/issue report |
| **Method** | `add()` |
| **Path** | `/feedback` |
| **Authz** | Public (anonymous allowed) |
| **Request Shape** | `{ userId?, isAnonymous: bool, category: enum, description, screenshotUrl?, relatedProductId?, status: 'new', createdAt, triagedAt: null, triagedBy: null, triageNotes: null }` |
| **Response Shape** | `DocumentReference` |

> **NOTE** — The rule enforces that if `isAnonymous == true`, then `userId == null` and `request.auth == null`. If `isAnonymous == false`, then `userId == request.auth.uid`.

### 5.9.2 List Feedback (Admin Triage Queue)

| Field | Value |
|---|---|
| **Operation** | Admin sees all feedback for triage |
| **Method** | `get()` or `snapshots()` |
| **Path** | `/feedback` (optionally filtered by `status` or `category`) |
| **Authz** | Admin only |

### 5.9.3 Triage Feedback (Admin)

| Field | Value |
|---|---|
| **Operation** | Admin updates feedback status and adds notes |
| **Method** | `update()` |
| **Path** | `/feedback/{feedbackId}` |
| **Authz** | Admin |
| **Request Shape** | `{ status: enum, triagedAt: timestamp, triagedBy: uid, triageNotes: string }` |

## 5.10 `/faq` Operations

### 5.10.1 List Active FAQs

| Field | Value |
|---|---|
| **Operation** | Fetch active FAQs for in-app FAQ page |
| **Method** | `get()` or `snapshots()` |
| **Path** | `/faq` (filtered by `isActive == true`) |
| **Authz** | Public |
| **Response Shape** | `Future<List<Faq>>` or `Stream<List<Faq>>` |

**Example:**

```dart
Future<List<Faq>> getActiveFaqs() async {
  final query = await _firestore
      .collection('faq')
      .where('isActive', isEqualTo: true)
      .orderBy('category')
      .orderBy('displayOrder')
      .get();
  return query.docs.map((doc) => Faq.fromJson(doc.data())).toList();
}
```

### 5.10.2 CRUD FAQ (Admin)

| Operation | Method | Path | Authz |
|---|---|---|---|
| Create | `set()` or `add()` | `/faq` or `/faq/{faqId}` | Admin |
| Read (single) | `get()` | `/faq/{faqId}` | Admin |
| Update | `update()` | `/faq/{faqId}` | Admin |
| Delete | `delete()` | `/faq/{faqId}` | Admin |

## 5.11 `/users/{uid}/addresses[]` Operations

Addresses are embedded as an array in the user document. Operations use `FieldValue.arrayUnion()` and `FieldValue.arrayRemove()` for add/remove, and a read-modify-write pattern for edit.

### 5.11.1 Add Address

```dart
Future<void> addAddress(String uid, Address address) async {
  await _firestore.collection('users').doc(uid).update({
    'addresses': FieldValue.arrayUnion([address.toJson()]),
  });
}
```

### 5.11.2 Remove Address

```dart
Future<void> removeAddress(String uid, Address address) async {
  await _firestore.collection('users').doc(uid).update({
    'addresses': FieldValue.arrayRemove([address.toJson()]),
  });
}
```

### 5.11.3 Update Address (read-modify-write)

```dart
Future<void> updateAddress(String uid, String addressId, Address newAddress) async {
  final ref = _firestore.collection('users').doc(uid);
  await _firestore.runTransaction((txn) async {
    final snapshot = await txn.get(ref);
    final addresses = (snapshot.data()!['addresses'] as List)
        .map((a) => Address.fromJson(a as Map<String, dynamic>))
        .toList();
    final idx = addresses.indexWhere((a) => a.addressId == addressId);
    if (idx == -1) throw AddressNotFoundException(addressId: addressId);
    addresses[idx] = newAddress;
    txn.update(ref, {'addresses': addresses.map((a) => a.toJson()).toList()});
  });
}
```

## 6. Authentication Operations

Authentication operations go through Firebase Auth, not Firestore. They are documented here for completeness.

### 6.1 Register

```dart
Future<UserCredential> register({
  required String email,
  required String password,
}) async {
  return _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

### 6.2 Login

```dart
Future<UserCredential> login({
  required String email,
  required String password,
}) async {
  return _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

### 6.3 Send Password Reset

```dart
Future<void> sendPasswordReset(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}
```

### 6.4 Sign Out

```dart
Future<void> signOut() async {
  await _auth.signOut();
}
```

### 6.5 Auth State Stream

```dart
Stream<User?> watchAuthState() {
  return _auth.authStateChanges();
}
```

## 7. Analytics Events

Firebase Analytics events are fire-and-forget. They never block UI and never throw user-visible errors.

| Event Name | Triggered When | Parameters |
|---|---|---|
| `sign_up` | User successfully registers | `method: 'email'` |
| `login` | User successfully logs in | `method: 'email'` |
| `view_item` | User opens product detail | `item_id`, `item_name`, `item_brand`, `price` |
| `add_to_cart` | User adds product to cart | `item_id`, `quantity`, `value` |
| `remove_from_cart` | User removes item from cart | `item_id`, `quantity` |
| `begin_checkout` | User navigates to checkout page | `value`, `currency: 'USD'`, `items` |
| `purchase` | Order successfully created | `transaction_id`, `value`, `items` |
| `admin_action` | Admin performs CRUD | `action: 'create_product'|'update_stock'|...` |

Events are dispatched via `AnalyticsService`:

```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  Future<void> logPurchase({
    required String orderId,
    required double value,
    required List<CartItem> items,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'purchase',
      parameters: {
        'transaction_id': orderId,
        'value': value,
        'currency': 'USD',
        'items': items.map((i) => {
          'item_id': i.productId,
          'item_name': i.modelName,
          'quantity': i.quantity,
          'price': i.unitPrice,
        }).toList(),
      },
    );
  }
}
```

## 8. Error Codes

Standard Firebase error codes surfaced to the UI. Each is mapped to a user-friendly message in `lib/core/utils/error_translator.dart`.

| Code | Meaning | User Message |
|---|---|---|
| `permission-denied` | Security rule rejected the operation | "You don't have permission to do this." |
| `not-found` | Document does not exist | "We couldn't find that." |
| `already-exists` | Document ID collision | "That already exists." |
| `invalid-argument` | Field constraint violated | "Some information was invalid." |
| `unauthenticated` | No auth token; session expired | "Please sign in again." |
| `unavailable` | Firestore service unreachable (network) | "Check your internet connection." |
| `deadline-exceeded` | Operation timed out | "That took too long. Please try again." |
| `resource-exhausted` | Quota exceeded (Spark tier) | "We're busy. Please try in a moment." |
| `internal` | Unexpected server error | "Something went wrong on our end." |

> **NOTE** — `resource-exhausted` on Spark Tier typically means the daily write quota (20K writes/day) or bandwidth quota (1GB/day) was hit. See [RISKS.md](RISKS.md) § Quota Risks.

## 9. References

- Internal: [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [SECURITY.md](SECURITY.md), [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md), [PRODUCT_REQUIREMENTS.md](PRODUCT_REQUIREMENTS.md), [RISKS.md](RISKS.md)
- External: [Cloud Firestore Dart SDK](https://pub.dev/packages/cloud_firestore), [Firebase Auth Dart SDK](https://pub.dev/packages/firebase_auth), [Firebase Analytics Dart SDK](https://pub.dev/packages/firebase_analytics), [Firestore error codes](https://firebase.google.com/docs/reference/node/firebase.firestore#firestoreerror)
