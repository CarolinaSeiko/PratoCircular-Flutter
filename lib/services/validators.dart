class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório.';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (!value!.contains('@') || !value.contains('.')) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value!.length < 6) {
      return 'A senha deve ter ao menos 6 caracteres.';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final number = double.tryParse(value!.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'Informe uma quantidade válida.';
    }
    return null;
  }
}
