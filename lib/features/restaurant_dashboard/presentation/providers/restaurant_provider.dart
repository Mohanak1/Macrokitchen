import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../meals/presentation/providers/meals_provider.dart';

// ── Restaurant Entity ─────────────────────────────────────────────────────────

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String ownerId;
  final String contactEmail;
  final bool isActive;

  const Restaurant({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.ownerId,
    required this.contactEmail,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, ownerId];
}

// ── Restaurant Datasource ─────────────────────────────────────────────────────

class RestaurantDatasource {
  final FirebaseFirestore _db;
  RestaurantDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<Restaurant?> getRestaurantByOwner(String ownerId) async {
    final snap = await _db
        .collection('restaurants')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final d = doc.data();
    return Restaurant(
      id: doc.id,
      name: d['name'] as String? ?? 'My Restaurant',
      logoUrl: d['logoUrl'] as String?,
      ownerId: d['ownerId'] as String? ?? ownerId,
      contactEmail: d['contactEmail'] as String? ?? '',
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    final snap = await _db
        .collection('restaurants')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((doc) {
      final d = doc.data();
      return Restaurant(
        id: doc.id,
        name: d['name'] as String? ?? '',
        logoUrl: d['logoUrl'] as String?,
        ownerId: d['ownerId'] as String? ?? '',
        contactEmail: d['contactEmail'] as String? ?? '',
        isActive: d['isActive'] as bool? ?? true,
      );
    }).toList();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final restaurantDatasourceProvider =
    Provider((_) => RestaurantDatasource());

/// Current restaurant for logged-in restaurant owner
final currentRestaurantProvider = FutureProvider<Restaurant?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null || !user.isRestaurant) return null;
  return ref
      .read(restaurantDatasourceProvider)
      .getRestaurantByOwner(user.uid);
});

/// All restaurants (for browsing)
final allRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return ref.read(restaurantDatasourceProvider).getAllRestaurants();
});

/// Meals for the current restaurant owner's restaurant
final restaurantOwnMealsProvider = FutureProvider((ref) async {
  final restaurant = await ref.watch(currentRestaurantProvider.future);
  if (restaurant == null) return [];
  final result = await ref
      .read(mealsRepositoryProvider)
      .getMealsByRestaurant(restaurant.id);
  return result.fold((_) => [], (m) => m);
});
