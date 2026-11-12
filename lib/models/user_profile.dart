class UserProfile {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String type;
  final String cep;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.type,
    required this.cep,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  bool get isSupplier => type == 'Fornecedor';

  String get fullAddress {
    return '$street, $number - $neighborhood, $city/$state';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'type': type,
      'cep': cep,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String,
      type: map['type'] as String,
      cep: map['cep'] as String,
      street: map['street'] as String,
      number: map['number'] as String,
      neighborhood: map['neighborhood'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
    );
  }
}
