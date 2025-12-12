/// Enhanced validation service for form inputs and data validation
class ValidationService {
  /// Validate task title
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < 1) {
      return 'Title must be at least 1 character long';
    }
    
    if (trimmed.length > 100) {
      return 'Title cannot exceed 100 characters';
    }
    
    // Check for invalid characters
    if (trimmed.contains(RegExp(r'[<>{}[\]\\|`~]'))) {
      return 'Title contains invalid characters';
    }
    
    return null;
  }

  /// Validate task description
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Description is optional
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    
    return null;
  }

  /// Validate task priority
  static String? validatePriority(int? priority) {
    if (priority == null) {
      return 'Priority must be selected';
    }
    
    if (priority < 1 || priority > 3) {
      return 'Priority must be between 1 (Low) and 3 (High)';
    }
    
    return null;
  }

  /// Validate category ID
  static String? validateCategoryId(String? categoryId, List<String> validCategoryIds) {
    if (categoryId == null || categoryId.trim().isEmpty) {
      return 'Category must be selected';
    }
    
    if (!validCategoryIds.contains(categoryId)) {
      return 'Invalid category selected';
    }
    
    return null;
  }

  /// Validate due date
  static String? validateDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return null; // Due date is optional
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    // Allow today and future dates
    if (taskDate.isBefore(today)) {
      return 'Due date cannot be in the past';
    }
    
    // Reasonable upper limit (2 years from now)
    final maxDate = today.add(const Duration(days: 365 * 2));
    if (taskDate.isAfter(maxDate)) {
      return 'Due date cannot be more than 2 years in the future';
    }
    
    return null;
  }

  /// Validate category name
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name cannot be empty';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < 2) {
      return 'Category name must be at least 2 characters long';
    }
    
    if (trimmed.length > 50) {
      return 'Category name cannot exceed 50 characters';
    }
    
    // Check for invalid characters
    if (trimmed.contains(RegExp(r'[<>{}[\]\\|`~]'))) {
      return 'Category name contains invalid characters';
    }
    
    return null;
  }

  /// Validate search query
  static String? validateSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return null; // Empty search is valid (shows all)
    }
    
    final trimmed = query.trim();
    
    if (trimmed.length > 100) {
      return 'Search query cannot exceed 100 characters';
    }
    
    return null;
  }

  /// Validate email format (for future features)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password strength (for future features)
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (password.length > 128) {
      return 'Password cannot exceed 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validate file name (for future features)
  static String? validateFileName(String? fileName) {
    if (fileName == null || fileName.trim().isEmpty) {
      return 'File name cannot be empty';
    }
    
    final trimmed = fileName.trim();
    
    if (trimmed.length > 255) {
      return 'File name cannot exceed 255 characters';
    }
    
    // Check for invalid file name characters
    if (trimmed.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return 'File name contains invalid characters';
    }
    
    // Check for reserved names (Windows)
    final reservedNames = ['CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 
                          'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 
                          'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 
                          'LPT7', 'LPT8', 'LPT9'];
    
    if (reservedNames.contains(trimmed.toUpperCase())) {
      return 'File name is reserved and cannot be used';
    }
    
    return null;
  }

  /// Validate positive integer
  static String? validatePositiveInteger(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    final intValue = int.tryParse(value.trim());
    
    if (intValue == null) {
      return '$fieldName must be a valid number';
    }
    
    if (intValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  /// Validate non-negative integer
  static String? validateNonNegativeInteger(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    final intValue = int.tryParse(value.trim());
    
    if (intValue == null) {
      return '$fieldName must be a valid number';
    }
    
    if (intValue < 0) {
      return '$fieldName cannot be negative';
    }
    
    return null;
  }

  /// Validate URL format (for future features)
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'URL cannot be empty';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(url.trim())) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate phone number (for future features)
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }
    
    return null;
  }

  /// Validate that a string contains only alphanumeric characters
  static String? validateAlphanumeric(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters and numbers';
    }
    
    return null;
  }

  /// Validate string length
  static String? validateLength(
    String? value, {
    required int minLength,
    required int maxLength,
    String fieldName = 'Value',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    if (trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    
    return null;
  }

  /// Validate that two values match (e.g., password confirmation)
  static String? validateMatch(
    String? value1,
    String? value2, {
    String fieldName = 'Values',
  }) {
    if (value1 != value2) {
      return '$fieldName do not match';
    }
    
    return null;
  }

  /// Validate multiple fields at once
  static List<String> validateMultiple(Map<String, String? Function()> validators) {
    final errors = <String>[];
    
    validators.forEach((fieldName, validator) {
      final error = validator();
      if (error != null) {
        errors.add('$fieldName: $error');
      }
    });
    
    return errors;
  }

  /// Check if string is safe for display (no XSS)
  static bool isSafeForDisplay(String? value) {
    if (value == null) return true;
    
    // Check for potentially dangerous HTML/script tags
    final dangerousPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false),
      RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false),
      RegExp(r'<embed[^>]*>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'onload=', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
    ];
    
    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(value)) {
        return false;
      }
    }
    
    return true;
  }

  /// Sanitize string for safe display
  static String sanitizeForDisplay(String? value) {
    if (value == null) return '';
    
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}