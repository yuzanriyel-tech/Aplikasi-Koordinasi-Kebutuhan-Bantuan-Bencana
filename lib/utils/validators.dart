/// Kumpulan fungsi validasi yang bisa dipakai ulang.
/// return null -> input VALID; return 'pesan' -> TIDAK VALID.
class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
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

  static String? jumlah(String? value) {
    final requiredError = requiredField(value, fieldName: 'Jumlah');
    if (requiredError != null) return requiredError;
    final number = int.tryParse(value!.trim());
    if (number == null) return 'Jumlah harus berupa angka bulat';
    if (number < 1) return 'Jumlah minimal 1';
    if (number > 100000) return 'Jumlah maksimal 100.000';
    return null;
  }
}
