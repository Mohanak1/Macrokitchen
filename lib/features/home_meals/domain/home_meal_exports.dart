import 'package:cloud_firestore/cloud_firestore.dart';

class HomeMeal {
  final String id;
  final String userId;
  final String title;
  final String? notes;
  final double calories;
  final double protein;
  final double carbs;
  final double totalFat;
  final double sodium;
  final double sugar;
  final double fiber;
  final double saturatedFat;
  final DateTime loggedAt;

  const HomeMeal({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.totalFat,
    required this.sodium,
    required this.sugar,
    required this.fiber,
    required this.saturatedFat,
    required this.loggedAt,
  });

  factory HomeMeal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    double n(dynamic v) => (v ?? 0).toDouble();
    return HomeMeal(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      notes: data['notes'] as String?,
      calories: n(data['calories']),
      protein: n(data['protein']),
      carbs: n(data['carbs']),
      totalFat: n(data['totalFat']),
      sodium: n(data['sodium']),
      sugar: n(data['sugar']),
      fiber: n(data['fiber']),
      saturatedFat: n(data['saturatedFat']),
      loggedAt:
          (data['loggedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'notes': notes,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'totalFat': totalFat,
        'sodium': sodium,
        'sugar': sugar,
        'fiber': fiber,
        'saturatedFat': saturatedFat,
        'loggedAt': Timestamp.fromDate(loggedAt),
      };
}