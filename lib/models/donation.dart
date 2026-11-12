class Donation {
  final int id;
  final String foodName;
  final double quantityKg;
  final String expiration;
  final String pickupTime;
  final String establishmentName;
  final String address;
  final String ownerEmail;
  final String status;
  final bool favorite;

  const Donation({
    required this.id,
    required this.foodName,
    required this.quantityKg,
    required this.expiration,
    required this.pickupTime,
    required this.establishmentName,
    required this.address,
    required this.ownerEmail,
    this.status = 'Disponível',
    this.favorite = false,
  });

  Donation copyWith({
    int? id,
    String? foodName,
    double? quantityKg,
    String? expiration,
    String? pickupTime,
    String? establishmentName,
    String? address,
    String? ownerEmail,
    String? status,
    bool? favorite,
  }) {
    return Donation(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      quantityKg: quantityKg ?? this.quantityKg,
      expiration: expiration ?? this.expiration,
      pickupTime: pickupTime ?? this.pickupTime,
      establishmentName: establishmentName ?? this.establishmentName,
      address: address ?? this.address,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      status: status ?? this.status,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'quantityKg': quantityKg,
      'expiration': expiration,
      'pickupTime': pickupTime,
      'establishmentName': establishmentName,
      'address': address,
      'ownerEmail': ownerEmail,
      'status': status,
      'favorite': favorite,
    };
  }

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'] as int,
      foodName: map['foodName'] as String,
      quantityKg: (map['quantityKg'] as num).toDouble(),
      expiration: map['expiration'] as String,
      pickupTime: map['pickupTime'] as String,
      establishmentName: map['establishmentName'] as String,
      address: map['address'] as String,
      ownerEmail: map['ownerEmail'] as String? ?? '',
      status: map['status'] as String? ?? 'Disponível',
      favorite: map['favorite'] as bool? ?? false,
    );
  }
}
