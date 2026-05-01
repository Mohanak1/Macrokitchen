import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String title;
  final String? imageUrl;
  final String type; // 'restaurant'
  final double rating;
  final double calories;
  final double protein;
  final double carbs;
  final double? totalFat;
  final double? sodium;
  final double? sugar;
  final double? fiber;
  final double? saturatedFat;
  final List<String> allergens;
  final bool isActive;
  final DateTime createdAt;

  const Meal({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.title,
    this.imageUrl,
    required this.type,
    this.rating = 0,
    required this.calories,
    required this.protein,
    required this.carbs,
    this.totalFat,
    this.sodium,
    this.sugar,
    this.fiber,
    this.saturatedFat,
    this.allergens = const [],
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, restaurantId];
}
