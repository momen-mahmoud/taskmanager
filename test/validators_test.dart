import 'package:assessment/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects malformed',
        () => expect(Validators.email('not-an-email'), isNotNull));
    test('accepts valid',
        () => expect(Validators.email('jane@example.com'), isNull));
  });

  group('Validators.password', () {
    test('rejects short', () => expect(Validators.password('123'), isNotNull));
    test('accepts 6+ chars',
        () => expect(Validators.password('secret1'), isNull));
  });

  group('Validators.name', () {
    test('rejects empty', () => expect(Validators.name(''), isNotNull));
    test('accepts valid', () => expect(Validators.name('Jane'), isNull));
  });
}
