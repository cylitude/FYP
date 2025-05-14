import '../models/shop.dart';
import '../models/product.dart';

/// Pulls distinct, lowercase words >3 letters out of Gemini’s reply.
List<String> extractKeywords(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 3)
      .toSet()
      .toList();
}

/// Scores every Product by overlap with those keywords, returns the best.
Future<Product?> findBestMatch(List<String> keywords) async {
  final products = Shop().shop;
  Product? best;
  var bestScore = 0;

  for (var p in products) {
    final score = p.keywords.where((k) => keywords.contains(k)).length;
    if (score > bestScore) {
      bestScore = score;
      best = p;
    }
  }

  return best;
}
