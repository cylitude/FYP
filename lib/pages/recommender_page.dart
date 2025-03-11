import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class RecommenderPage {
  /// Fetch user measurements from Firestore, parse them, then return "S", "M", "L", or "XL"
  Future<String> getRecommendedSizeForUser(String userId) async {
    // 1. Attempt to fetch the user's doc from Firestore
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnap = await docRef.get();

    // 2. If the doc doesn't exist, or has no data, return a fallback size
    if (!docSnap.exists) {
      debugPrint("No Firestore document found for userId: $userId");
      return 'S'; // or any default
    }
    final data = docSnap.data() ?? {};

    // 3. Parse fields as doubles (handles int, double, or string)
    final double userHeight = _parseDouble(data['height']);
    final double userChest = _parseDouble(data['chest']);
    final double userShoulder = _parseDouble(data['shoulder']);

    // 4. Compute recommended size with your point-based logic
    return _computeRecommendedSize(
      height: userHeight,
      chestCircumference: userChest,
      shoulderWidth: userShoulder,
    );
  }

  /// Safely parse dynamic values into a double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    // If it's already a number (int/double), just convert
    if (value is num) {
      return value.toDouble();
    }

    // If it's a string, try parsing it
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    // Fallback if we can't parse
    return 0.0;
  }

  /// Core logic for computing the recommended size
  /// Basic height (3 pts), chest circumference (2 pts), shoulder width (2 pts)
  String _computeRecommendedSize({
    required double height,
    required double chestCircumference,
    required double shoulderWidth,
  }) {
    // 1. Determine each metric's "vote"
    final basicSize = _sizeFromHeight(height);
    final chestSize = _sizeFromChest(chestCircumference);
    final shoulderSize = _sizeFromShoulder(shoulderWidth);

    // 2. Assign points
    final points = {'S': 0, 'M': 0, 'L': 0, 'XL': 0};

    // Basic height = 3 points
    points[basicSize] = (points[basicSize] ?? 0) + 3;
    // Chest circumference = 2 points
    points[chestSize] = (points[chestSize] ?? 0) + 2;
    // Shoulder width = 2 points
    points[shoulderSize] = (points[shoulderSize] ?? 0) + 2;

    // 3. Find which size has the highest total points
    String recommended = 'S';
    int maxPoints = 0;
    points.forEach((size, pts) {
      if (pts > maxPoints) {
        maxPoints = pts;
        recommended = size;
      }
    });

    return recommended;
  }

  /// Helper: Basic measurement → size
  String _sizeFromHeight(double height) {
    if (height >= 160 && height <= 167) return 'S';
    if (height >= 168 && height <= 175) return 'M';
    if (height >= 176 && height <= 184) return 'L';
    if (height >= 185 && height <= 195) return 'XL';
    return 'XL'; // fallback if out-of-range
  }

  /// Helper: Chest circumference (cm) → size
  String _sizeFromChest(double chest) {
    if (chest >= 47 && chest <= 50) return 'S';
    if (chest >= 51 && chest <= 53) return 'M';
    if (chest >= 54 && chest <= 56) return 'L';
    if (chest >= 57 && chest <= 60) return 'XL';
    return 'XL'; // fallback if out-of-range
  }

  /// Helper: Shoulder width (cm) → size
  String _sizeFromShoulder(double shoulder) {
    if (shoulder >= 44 && shoulder <= 45) return 'S';
    if (shoulder >= 46 && shoulder <= 48) return 'M';
    if (shoulder >= 49 && shoulder <= 50) return 'L';
    if (shoulder >= 51 && shoulder <= 52) return 'XL';
    return 'XL'; // fallback if out-of-range
  }
}
