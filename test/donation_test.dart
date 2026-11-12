import 'package:flutter_test/flutter_test.dart';
import 'package:prato_circular/models/donation.dart';

void main() {
  test('copyWith altera status', () {
    const donation = Donation(
      id: 1,
      foodName: 'Pães',
      quantityKg: 5,
      expiration: '15/11/2026',
      pickupTime: '18h',
      establishmentName: 'Padaria',
      address: 'Rua A',
      ownerEmail: 'a@a.com',
    );
    final updated = donation.copyWith(status: 'Reservado');
    expect(updated.status, 'Reservado');
    expect(updated.foodName, 'Pães');
  });

  test('map preserva dados da doação', () {
    const donation = Donation(
      id: 2,
      foodName: 'Frutas',
      quantityKg: 3.5,
      expiration: '16/11/2026',
      pickupTime: '17h',
      establishmentName: 'Mercado',
      address: 'Rua B',
      ownerEmail: 'b@b.com',
      favorite: true,
    );
    final restored = Donation.fromMap(donation.toMap());
    expect(restored.id, 2);
    expect(restored.favorite, isTrue);
  });
}
