/// Centralised form validators — keep validation rules in one place.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = double.tryParse(value.trim());
    if (n == null) return '$fieldName must be a number';
    if (n <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null; // optional fields
    final n = double.tryParse(value.trim());
    if (n == null) return '$fieldName must be a number';
    if (n < 0) return '$fieldName cannot be negative';
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.trim().isEmpty) return 'Height is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 50 || n > 300) return 'Height must be between 50–300 cm';
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Weight is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 10 || n > 500) return 'Weight must be between 10–500 kg';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid integer';
    if (n < 10 || n > 120) return 'Age must be between 10–120';
    return null;
  }
}
