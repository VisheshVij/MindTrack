import 'dart:convert';
import 'package:flutter/services.dart';
import 'person_profile.dart';

/// Loads and caches the people list from assets/data/people.json.
/// No network or database needed — just edit the JSON and rebuild.
class PeopleStore {
  static final PeopleStore _instance = PeopleStore._internal();
  factory PeopleStore() => _instance;
  PeopleStore._internal();

  List<PersonProfile> _people = [];
  List<PersonProfile> get all => _people;

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/people.json');
    final list = json.decode(raw) as List<dynamic>;
    _people = list
        .map((e) => PersonProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns the person whose NFC tag UID matches, or null.
  PersonProfile? findByUid(String uid) {
    try {
      return _people.firstWhere(
        (p) => p.uid.toUpperCase() == uid.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
