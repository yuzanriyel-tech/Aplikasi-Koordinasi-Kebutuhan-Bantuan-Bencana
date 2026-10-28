class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = requiredField(value, fieldName: 'Nomor telepon');
    if (requiredError != null) return requiredError;
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{8,13}$');
    if (!phoneRegex.hasMatch(value!.trim())) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'Field ini',
  }) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Ulangi password wajib diisi';
    if (value != original) return 'Password tidak sama';
    return null;
  }

    static String? quantity(String? value) {
    final requiredError = requiredField(value, fieldName: 'Jumlah');
    if (requiredError != null) return requiredError;
    final number = int.tryParse(value!.trim());
    if (number == null) return 'Jumlah harus berupa angka bulat';
    if (number <= 0) return 'Jumlah harus lebih dari 0';
    if (number > 100000) return 'Jumlah maksimal 100.000';
    return null;
  }
}
