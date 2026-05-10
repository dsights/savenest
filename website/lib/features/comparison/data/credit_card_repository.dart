import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../credit_card_model.dart';

// Repository Interface
abstract class CreditCardRepository {
  Future<List<CreditCardDeal>> getCreditCards();
}

// Implementation
class JsonCreditCardRepository implements CreditCardRepository {
  List<CreditCardDeal>? _cachedData;

  @override
  Future<List<CreditCardDeal>> getCreditCards() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString('assets/data/credit_cards.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedData = jsonList.map((json) => CreditCardDeal.fromJson(json)).toList();
    return _cachedData!;
  }
}

// Provider
final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  return JsonCreditCardRepository();
});

final creditCardsProvider = FutureProvider<List<CreditCardDeal>>((ref) async {
  final repository = ref.watch(creditCardRepositoryProvider);
  return repository.getCreditCards();
});
