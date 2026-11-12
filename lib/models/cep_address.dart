class CepAddress {
  final String cep;
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  const CepAddress({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory CepAddress.fromJson(Map<String, dynamic> json) {
    return CepAddress(
      cep: json['cep']?.toString() ?? '',
      street: json['logradouro']?.toString() ?? '',
      neighborhood: json['bairro']?.toString() ?? '',
      city: json['localidade']?.toString() ?? '',
      state: json['uf']?.toString() ?? '',
    );
  }
}
