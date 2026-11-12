import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cep_address.dart';

class CepService {
  Future<CepAddress> search(String cep) async {
    final clean = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.length != 8) {
      throw Exception('Informe um CEP com 8 números.');
    }

    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$clean/json/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível consultar o CEP.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['erro'] == true) {
      throw Exception('CEP não encontrado.');
    }

    return CepAddress.fromJson(data);
  }
}
