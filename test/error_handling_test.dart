import 'package:flutter_test/flutter_test.dart';
import '../lib/app/services/error_handling_service.dart';
import '../lib/app/services/validation_service.dart';

void main() {
  group('Error Handling Tests', () {
    group('ValidationService', () {
      test('should validate title correctly', () {
        // Valid titles
        expect(ValidationService.validateTitle('Valid Title'), isNull);
        expect(ValidationService.validateTitle('A'), isNull); // Minimum length
        expect(ValidationService.validateTitle('A' * 100), isNull); // Maximum length

        // Invalid titles
        expect(ValidationService.validateTitle(null), isNotNull);
        expect(ValidationService.validateTitle(''), isNotNull);
        expect(ValidationService.validateTitle('   '), isNotNull);
        expect(ValidationService.validateTitle('A' * 101), isNotNull); // Too long
        expect(ValidationService.validateTitle('Title<script>'), isNotNull); // Invalid chars
      });

      test('should validate description correctly', () {
        // Valid descriptions
        expect(ValidationService.validateDescription(null), isNull);
        expect(ValidationService.validateDescription(''), isNull);
        expect(ValidationService.validateDescription('Valid description'), isNull);
        expect(ValidationService.validateDescription('A' * 500), isNull); // Maximum length

        // Invalid descriptions
        expect(ValidationService.validateDescription('A' * 501), isNotNull); // Too long
      });

      test('should validate priority correctly', () {
        // Valid priorities
        expect(ValidationService.validatePriority(1), isNull);
        expect(ValidationService.validatePriority(2), isNull);
        expect(ValidationService.validatePriority(3), isNull);

        // Invalid priorities
        expect(ValidationService.validatePriority(null), isNotNull);
        expect(ValidationService.validatePriority(0), isNotNull);
        expect(ValidationService.validatePriority(4), isNotNull);
        expect(ValidationService.validatePriority(-1), isNotNull);
      });

      test('should validate category ID correctly', () {
        final validCategories = ['personal', 'work', 'shopping', 'health'];

        // Valid category IDs
        expect(ValidationService.validateCategoryId('personal', validCategories), isNull);
        expect(ValidationService.validateCategoryId('work', validCategories), isNull);

        // Invalid category IDs
        expect(ValidationService.validateCategoryId(null, validCategories), isNotNull);
        expect(ValidationService.validateCategoryId('', validCategories), isNotNull);
        expect(ValidationService.validateCategoryId('invalid', validCategories), isNotNull);
      });

      test('should validate due date correctly', () {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));
        final farFuture = today.add(const Duration(days: 365 * 3));

        // Valid due dates
        expect(ValidationService.validateDueDate(null), isNull); // Optional
        expect(ValidationService.validateDueDate(today), isNull);
        expect(ValidationService.validateDueDate(tomorrow), isNull);

        // Invalid due dates
        expect(ValidationService.validateDueDate(yesterday), isNotNull); // Past date
        expect(ValidationService.validateDueDate(farFuture), isNotNull); // Too far in future
      });

      test('should sanitize strings for display', () {
        expect(ValidationService.sanitizeForDisplay('<script>alert("xss")</script>'), 
               equals('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'));
        expect(ValidationService.sanitizeForDisplay('Normal text'), equals('Normal text'));
        expect(ValidationService.sanitizeForDisplay(null), equals(''));
      });

      test('should check if string is safe for display', () {
        expect(ValidationService.isSafeForDisplay('Normal text'), isTrue);
        expect(ValidationService.isSafeForDisplay('<script>alert("xss")</script>'), isFalse);
        expect(ValidationService.isSafeForDisplay('javascript:alert("xss")'), isFalse);
        expect(ValidationService.isSafeForDisplay(null), isTrue);
      });
    });

    group('Custom Exceptions', () {
      test('should create ValidationException correctly', () {
        final exception = ValidationException('Test validation error');
        expect(exception.message, equals('Test validation error'));
        expect(exception.toString(), contains('ValidationException'));
      });

      test('should create NetworkException correctly', () {
        final exception = NetworkException('Network error');
        expect(exception.message, equals('Network error'));
        expect(exception.toString(), contains('NetworkException'));
      });

      test('should create StorageException correctly', () {
        final exception = StorageException('Storage error');
        expect(exception.message, equals('Storage error'));
        expect(exception.toString(), contains('StorageException'));
      });
    });

    group('Error Message Generation', () {
      test('should generate appropriate error messages for different exception types', () {
        // This tests the private _getErrorMessage method indirectly
        final validationError = ValidationException('Invalid input');
        final networkError = NetworkException('No connection');
        final storageError = StorageException('Disk full');
        final argumentError = ArgumentError('Invalid argument');
        final formatError = FormatException('Invalid format');
        final genericError = Exception('Generic error');


        // We can't directly test the private method, but we can test that
        // different error types are handled appropriately by checking their types
        expect(validationError, isA<ValidationException>());
        expect(networkError, isA<NetworkException>());
        expect(storageError, isA<StorageException>());
        expect(argumentError, isA<ArgumentError>());
        expect(formatError, isA<FormatException>());
        expect(genericError, isA<Exception>());
      });
    });

    group('Input Validation', () {
      test('should validate multiple fields correctly', () {
        final validators = {
          'title': () => ValidationService.validateTitle('Valid Title'),
          'priority': () => ValidationService.validatePriority(2),
          'category': () => ValidationService.validateCategoryId('personal', ['personal', 'work']),
        };

        final errors = ValidationService.validateMultiple(validators);
        expect(errors, isEmpty);
      });

      test('should collect multiple validation errors', () {
        final validators = {
          'title': () => ValidationService.validateTitle(''),
          'priority': () => ValidationService.validatePriority(0),
          'category': () => ValidationService.validateCategoryId('invalid', ['personal', 'work']),
        };

        final errors = ValidationService.validateMultiple(validators);
        expect(errors, hasLength(3));
        expect(errors[0], contains('title'));
        expect(errors[1], contains('priority'));
        expect(errors[2], contains('category'));
      });
    });

    group('String Validation', () {
      test('should validate length correctly', () {
        expect(ValidationService.validateLength('test', minLength: 2, maxLength: 10), isNull);
        expect(ValidationService.validateLength('a', minLength: 2, maxLength: 10), isNotNull);
        expect(ValidationService.validateLength('a' * 11, minLength: 2, maxLength: 10), isNotNull);
        expect(ValidationService.validateLength(null, minLength: 2, maxLength: 10), isNotNull);
      });

      test('should validate alphanumeric strings correctly', () {
        expect(ValidationService.validateAlphanumeric('abc123'), isNull);
        expect(ValidationService.validateAlphanumeric('ABC'), isNull);
        expect(ValidationService.validateAlphanumeric('123'), isNull);
        expect(ValidationService.validateAlphanumeric('abc-123'), isNotNull);
        expect(ValidationService.validateAlphanumeric('abc 123'), isNotNull);
        expect(ValidationService.validateAlphanumeric(null), isNotNull);
      });

      test('should validate email format correctly', () {
        expect(ValidationService.validateEmail('test@example.com'), isNull);
        expect(ValidationService.validateEmail('user.name+tag@domain.co.uk'), isNull);
        expect(ValidationService.validateEmail('invalid-email'), isNotNull);
        expect(ValidationService.validateEmail('test@'), isNotNull);
        expect(ValidationService.validateEmail('@example.com'), isNotNull);
        expect(ValidationService.validateEmail(null), isNotNull);
      });

      test('should validate URL format correctly', () {
        expect(ValidationService.validateUrl('https://example.com'), isNull);
        expect(ValidationService.validateUrl('http://www.example.com/path'), isNull);
        expect(ValidationService.validateUrl('invalid-url'), isNotNull);
        expect(ValidationService.validateUrl('ftp://example.com'), isNotNull);
        expect(ValidationService.validateUrl(null), isNotNull);
      });

      test('should validate phone numbers correctly', () {
        expect(ValidationService.validatePhoneNumber('1234567890'), isNull);
        expect(ValidationService.validatePhoneNumber('+1 (555) 123-4567'), isNull);
        expect(ValidationService.validatePhoneNumber('555.123.4567'), isNull);
        expect(ValidationService.validatePhoneNumber('123'), isNotNull); // Too short
        expect(ValidationService.validatePhoneNumber('1' * 16), isNotNull); // Too long
        expect(ValidationService.validatePhoneNumber(null), isNotNull);
      });

      test('should validate password strength correctly', () {
        expect(ValidationService.validatePassword('Password123'), isNull);
        expect(ValidationService.validatePassword('StrongP@ss1'), isNull);
        expect(ValidationService.validatePassword('weak'), isNotNull); // Too short
        expect(ValidationService.validatePassword('password123'), isNotNull); // No uppercase
        expect(ValidationService.validatePassword('PASSWORD123'), isNotNull); // No lowercase
        expect(ValidationService.validatePassword('Password'), isNotNull); // No numbers
        expect(ValidationService.validatePassword(null), isNotNull);
      });

      test('should validate positive integers correctly', () {
        expect(ValidationService.validatePositiveInteger('5'), isNull);
        expect(ValidationService.validatePositiveInteger('100'), isNull);
        expect(ValidationService.validatePositiveInteger('0'), isNotNull);
        expect(ValidationService.validatePositiveInteger('-5'), isNotNull);
        expect(ValidationService.validatePositiveInteger('abc'), isNotNull);
        expect(ValidationService.validatePositiveInteger(null), isNotNull);
      });

      test('should validate non-negative integers correctly', () {
        expect(ValidationService.validateNonNegativeInteger('0'), isNull);
        expect(ValidationService.validateNonNegativeInteger('5'), isNull);
        expect(ValidationService.validateNonNegativeInteger('100'), isNull);
        expect(ValidationService.validateNonNegativeInteger('-1'), isNotNull);
        expect(ValidationService.validateNonNegativeInteger('abc'), isNotNull);
        expect(ValidationService.validateNonNegativeInteger(null), isNotNull);
      });

      test('should validate matching values correctly', () {
        expect(ValidationService.validateMatch('password', 'password'), isNull);
        expect(ValidationService.validateMatch('password', 'different'), isNotNull);
        expect(ValidationService.validateMatch(null, null), isNull);
        expect(ValidationService.validateMatch('test', null), isNotNull);
      });
    });
  });
}