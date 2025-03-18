import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for a promo code.
class PromoCode {
  final String code;
  final int discountPercentage;

  PromoCode({
    required this.code,
    required this.discountPercentage,
  });

  /// Creates a PromoCode instance from a Firestore document map.
  factory PromoCode.fromMap(String docId, Map<String, dynamic> data) {
    return PromoCode(
      code: docId,
      discountPercentage: data['discountPercentage'] as int,
    );
  }

  /// Converts the PromoCode instance into a map.
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountPercentage': discountPercentage,
    };
  }
}

/// Service class to interact with promo codes stored in Firestore.
/// Uses the doc ID as the promo code (e.g., doc named "NEWJOINER25").
class PromoCodeService {
  /// Reference to the Firestore collection where promo codes are stored.
  final CollectionReference _promoCodesCollection =
      FirebaseFirestore.instance.collection('promoCodes');

  /// Fetches a promo code by doc ID. The doc ID must match [code].
  ///
  /// Returns a [PromoCode] if found, or null if no matching doc exists.
  Future<PromoCode?> getPromoCode(String code) async {
    try {
      // Directly fetch doc by ID, e.g. doc('NEWJOINER25')
      DocumentSnapshot docSnap =
          await _promoCodesCollection.doc(code).get();

      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;
        return PromoCode.fromMap(docSnap.id, data);
      } else {
        return null;
      }
    } catch (e) {
      developer.log(
        'Error retrieving promo code',
        error: e,
        name: 'PromoCodeService',
      );
      return null;
    }
  }
}
