import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService storage;

  AuthProvider(this.storage);

  UserProfile? profile;
  bool loading = false;
  String? error;

  bool get isLoggedIn => profile != null;

  Future<void> restoreSession() async {
    final email = await storage.getSession();
    if (email == null) return;
    final users = await storage.getUsers();
    for (final user in users) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        profile = user;
        notifyListeners();
        return;
      }
    }
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    final users = await storage.getUsers();
    UserProfile? found;
    for (final user in users) {
      if (user.email.toLowerCase() == email.trim().toLowerCase() &&
          user.password == password) {
        found = user;
        break;
      }
    }

    loading = false;

    if (found == null) {
      error = 'E-mail ou senha inválidos.';
      notifyListeners();
      return false;
    }

    profile = found;
    await storage.saveSession(found.email);
    notifyListeners();
    return true;
  }

  Future<bool> register(UserProfile newProfile) async {
    loading = true;
    error = null;
    notifyListeners();

    final users = await storage.getUsers();
    final exists = users.any(
      (user) => user.email.toLowerCase() == newProfile.email.toLowerCase(),
    );

    if (exists) {
      loading = false;
      error = 'Já existe uma conta com este e-mail.';
      notifyListeners();
      return false;
    }

    final created = UserProfile(
      id: users.length + 1,
      name: newProfile.name,
      email: newProfile.email.trim(),
      password: newProfile.password,
      phone: newProfile.phone,
      type: newProfile.type,
      cep: newProfile.cep,
      street: newProfile.street,
      number: newProfile.number,
      neighborhood: newProfile.neighborhood,
      city: newProfile.city,
      state: newProfile.state,
    );

    users.add(created);
    await storage.saveUsers(users);
    await storage.saveSession(created.email);
    profile = created;
    loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateProfile(UserProfile updated) async {
    final users = await storage.getUsers();
    final index = users.indexWhere((user) => user.id == updated.id);
    if (index < 0) return false;
    users[index] = updated;
    await storage.saveUsers(users);
    profile = updated;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await storage.clearSession();
    profile = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
