import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../services/local_storage_service.dart';

class DonationProvider extends ChangeNotifier {
  final LocalStorageService storage;

  DonationProvider(this.storage);

  List<Donation> donations = [];
  bool loading = false;
  String? error;

  int get totalCount => donations.length;

  int get availableCount =>
      donations.where((item) => item.status == 'Disponível').length;

  int get reservedCount =>
      donations.where((item) => item.status == 'Reservado').length;

  int get pickedUpCount =>
      donations.where((item) => item.status == 'Retirado').length;

  double get reusedKg => donations
      .where((item) => item.status == 'Retirado')
      .fold(0, (sum, item) => sum + item.quantityKg);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      donations = List<Donation>.of(await storage.getDonations());
    } catch (_) {
      error = 'Não foi possível carregar as doações.';
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> add({
    required String foodName,
    required double quantityKg,
    required String expiration,
    required String pickupTime,
    required String establishmentName,
    required String address,
    required String ownerEmail,
  }) async {
    error = null;

    try {
      final updatedList = List<Donation>.of(donations);
      final nextId = updatedList.isEmpty
          ? 1
          : updatedList
                  .map((item) => item.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      updatedList.insert(
        0,
        Donation(
          id: nextId,
          foodName: foodName,
          quantityKg: quantityKg,
          expiration: expiration,
          pickupTime: pickupTime,
          establishmentName: establishmentName,
          address: address,
          ownerEmail: ownerEmail,
        ),
      );

      await storage.saveDonations(updatedList);
      donations = updatedList;
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Não foi possível salvar a doação.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDonation(Donation updated) async {
    error = null;

    try {
      final updatedList = List<Donation>.of(donations);
      final index = updatedList.indexWhere((item) => item.id == updated.id);

      if (index < 0) {
        error = 'Doação não encontrada.';
        notifyListeners();
        return false;
      }

      updatedList[index] = updated;
      await storage.saveDonations(updatedList);
      donations = updatedList;
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Não foi possível atualizar a doação.';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(Donation donation) async {
    await _replace(donation.copyWith(favorite: !donation.favorite));
  }

  Future<void> reserve(Donation donation) async {
    if (donation.status != 'Disponível') return;
    await _replace(donation.copyWith(status: 'Reservado'));
  }

  Future<void> confirmPickup(Donation donation) async {
    if (donation.status != 'Reservado') return;
    await _replace(donation.copyWith(status: 'Retirado'));
  }

  Future<bool> delete(Donation donation) async {
    error = null;

    try {
      final updatedList = List<Donation>.of(donations)
        ..removeWhere((item) => item.id == donation.id);
      await storage.saveDonations(updatedList);
      donations = updatedList;
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Não foi possível excluir a doação.';
      notifyListeners();
      return false;
    }
  }

  Donation? findById(int id) {
    for (final item in donations) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _replace(Donation updated) async {
    final updatedList = List<Donation>.of(donations);
    final index = updatedList.indexWhere((item) => item.id == updated.id);
    if (index < 0) return;
    updatedList[index] = updated;
    await storage.saveDonations(updatedList);
    donations = updatedList;
    error = null;
    notifyListeners();
  }
}
