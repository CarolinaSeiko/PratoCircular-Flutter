import 'package:flutter_test/flutter_test.dart';
import 'package:prato_circular/services/validators.dart';

void main() {
  test('campo obrigatório rejeita vazio', () {
    expect(Validators.requiredField(''), isNotNull);
  });

  test('campo obrigatório aceita texto', () {
    expect(Validators.requiredField('Alimento'), isNull);
  });

  test('email rejeita formato inválido', () {
    expect(Validators.email('teste'), isNotNull);
  });

  test('email aceita formato válido', () {
    expect(Validators.email('teste@email.com'), isNull);
  });

  test('senha rejeita menos de seis caracteres', () {
    expect(Validators.password('12345'), isNotNull);
  });

  test('senha aceita seis caracteres', () {
    expect(Validators.password('123456'), isNull);
  });

  test('quantidade rejeita zero', () {
    expect(Validators.positiveNumber('0'), isNotNull);
  });

  test('quantidade rejeita texto', () {
    expect(Validators.positiveNumber('abc'), isNotNull);
  });

  test('quantidade aceita número positivo', () {
    expect(Validators.positiveNumber('5'), isNull);
  });

  test('quantidade aceita decimal com vírgula', () {
    expect(Validators.positiveNumber('2,5'), isNull);
  });
}
