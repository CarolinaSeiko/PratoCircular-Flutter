import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/donation.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const _usersKey = 'users';
  static const _donationsKey = 'donations';
  static const _sessionKey = 'session_email';
  static const _onboardingKey = 'onboarding_seen';

  Future<List<UserProfile>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => UserProfile.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUsers(List<UserProfile> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((user) => user.toMap()).toList()),
    );
  }

  Future<List<Donation>> getDonations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_donationsKey);
    if (raw == null || raw.isEmpty) {
      final seed = _seedDonations();
      await saveDonations(seed);
      return List<Donation>.of(seed);
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => Donation.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDonations(List<Donation> donations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _donationsKey,
      jsonEncode(donations.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<bool> wasOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  List<Donation> _seedDonations() {
    return [
      const Donation(
        id: 1,
        foodName: 'Pães variados',
        quantityKg: 8,
        expiration: '15/11/2026',
        pickupTime: '18h às 20h',
        establishmentName: 'Padaria Boa Mesa',
        address: 'Rua das Flores, 120 - Centro, São Paulo/SP',
        ownerEmail: 'padaria@pratocircular.com',
      ),
      const Donation(
        id: 2,
        foodName: 'Frutas e legumes',
        quantityKg: 12.5,
        expiration: '14/11/2026',
        pickupTime: '16h às 18h',
        establishmentName: 'Mercado Circular',
        address: 'Avenida Central, 450 - Bela Vista, São Paulo/SP',
        ownerEmail: 'mercado@pratocircular.com',
      ),
      const Donation(
        id: 3,
        foodName: 'Refeições prontas',
        quantityKg: 6,
        expiration: '13/11/2026',
        pickupTime: '20h às 21h',
        establishmentName: 'Restaurante Sabor',
        address: 'Rua Verde, 81 - Consolação, São Paulo/SP',
        ownerEmail: 'sabor@pratocircular.com',
      ),
    ];
  }
}
