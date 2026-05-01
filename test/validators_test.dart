import 'package:flutter_test/flutter_test.dart';
import 'package:macrokitchen/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error for null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for malformed email', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('test.name+alias@domain.co.uk'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error for null or empty', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('returns error for too short password', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('returns error when no uppercase letter', () {
      expect(Validators.password('alllower1'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(Validators.password('Password1'), isNull);
      expect(Validators.password('StrongPass123!'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('Different1', 'Password1'), isNotNull);
    });

    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('Password1', 'Password1'), isNull);
    });
  });

  group('Validators.height', () {
    test('returns error for value below 50', () {
      expect(Validators.height('40'), isNotNull);
    });

    test('returns error for value above 300', () {
      expect(Validators.height('310'), isNotNull);
    });

    test('returns null for valid height', () {
      expect(Validators.height('175'), isNull);
      expect(Validators.height('50'), isNull);
      expect(Validators.height('300'), isNull);
    });

    test('returns error for non-numeric input', () {
      expect(Validators.height('abc'), isNotNull);
    });
  });

  group('Validators.weight', () {
    test('returns error for value below 10', () {
      expect(Validators.weight('5'), isNotNull);
    });

    test('returns error for value above 500', () {
      expect(Validators.weight('600'), isNotNull);
    });

    test('returns null for valid weight', () {
      expect(Validators.weight('70'), isNull);
      expect(Validators.weight('120.5'), isNull);
    });
  });

  group('Validators.age', () {
    test('returns error for age below 10', () {
      expect(Validators.age('5'), isNotNull);
    });

    test('returns error for age above 120', () {
      expect(Validators.age('130'), isNotNull);
    });

    test('returns null for valid age', () {
      expect(Validators.age('25'), isNull);
      expect(Validators.age('65'), isNull);
    });

    test('returns error for decimal age', () {
      expect(Validators.age('25.5'), isNotNull);
    });
  });

  group('Validators.positiveNumber', () {
    test('returns error for zero', () {
      expect(Validators.positiveNumber('0'), isNotNull);
    });

    test('returns error for negative', () {
      expect(Validators.positiveNumber('-5'), isNotNull);
    });

    test('returns null for positive number', () {
      expect(Validators.positiveNumber('100'), isNull);
      expect(Validators.positiveNumber('0.5'), isNull);
    });

    test('returns error for empty required field', () {
      expect(Validators.positiveNumber(''), isNotNull);
    });
  });

  group('Validators.nonNegativeNumber', () {
    test('returns null for empty (optional field)', () {
      expect(Validators.nonNegativeNumber(''), isNull);
      expect(Validators.nonNegativeNumber(null), isNull);
    });

    test('returns error for negative value', () {
      expect(Validators.nonNegativeNumber('-1'), isNotNull);
    });

    test('returns null for zero (valid for optional fields like sodium)', () {
      expect(Validators.nonNegativeNumber('0'), isNull);
    });

    test('returns null for positive values', () {
      expect(Validators.nonNegativeNumber('250'), isNull);
    });
  });
}
