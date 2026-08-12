# Implementation Plan - Fix Missing Features for App-WatchHub

This plan addresses the 11 missing features identified for the App-WatchHub Flutter/Firebase commerce app.

## User Review Required

> [!IMPORTANT]
> The features will be implemented using the existing local filtering and sorting logic in the UI layer for speed, as the project deadline is tomorrow. We will also introduce a `ProfileProvider` to fetch extended user data from Firestore.

## Proposed Changes

### 1. Authentication & Security
- **[MODIFY] [login_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/auth/presentation/screens/login_screen.dart)**: Enhance the Password Recovery flow with better validation and user feedback.

### 2. Catalog Enhancements (Filters & Sorting)
- **[MODIFY] [catalog_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/catalog/presentation/screens/catalog_screen.dart)**:
    - Move Price Range, Product Type, and Sort filters into a dedicated `FilterModal` for a cleaner UI.
    - Ensure popularity sorting uses a more robust logic (if scores are available).

### 3. Product Details & Reviews
- **[MODIFY] [product_details_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/catalog/presentation/screens/product_details_screen.dart)**:
    - Add a full-screen image viewer for the "Image Zoom" feature.
    - Verify and polish review sorting by Date/Rating.

### 4. User Profile & Address
- **[NEW] [profile_provider.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/profile/presentation/providers/profile_provider.dart)**: Create a Riverpod provider to fetch user profile data (address, phone) from Firestore.
- **[MODIFY] [profile_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/profile/presentation/views/profile_screen.dart)**:
    - Display Shipping Address and Phone Number in the profile view.
    - Improve the "Edit Profile" dialog to ensure data persistence in Firestore.

### 5. Order Tracking & Wishlist
- **[MODIFY] [order_history_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/orders/presentation/views/order_history_screen.dart)**: Refine the tracking timeline UI to look more professional.
- **[MODIFY] [wishlist_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/wishlist/presentation/views/wishlist_screen.dart)**: Ensure "Move to Cart" button is prominent and functional.

### 6. Feedback & Support
- **[MODIFY] [profile_screen.dart](file:///C:/Users/PIKACHU%20-82/StudioProjects/Watch-Hub-App/lib/features/profile/presentation/views/profile_screen.dart)**: Finalize the Feedback dialog logic.

## Verification Plan

### Manual Verification
- **Auth**: Test "Forgot Password" with a valid/invalid email.
- **Catalog**: Verify that filtering by Price Range, Type, and Brand works simultaneously.
- **Product Details**: Test image zoom and review sorting.
- **Profile**: Edit profile info and verify it persists across sessions by checking Firestore and UI.
- **Wishlist**: Add an item to wishlist, then move it to cart and verify it's removed from wishlist and added to cart.
- **Orders**: View order history and verify the timeline stages.
- **Feedback**: Submit feedback and verify the snackbar and Firestore entry.
