class Validators {
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate weight input
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }
    
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    
    if (weight > 1000) {
      return 'Weight seems too high. Please check your input';
    }
    
    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both dates are required';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date must be before end date';
    }
    
    return null;
  }

  /// Validate pregnancy dates
  static String? validatePregnancyDates(DateTime? lastMenstrualPeriod, DateTime? dueDate) {
    if (lastMenstrualPeriod == null || dueDate == null) {
      return 'Both dates are required';
    }
    
    if (lastMenstrualPeriod.isAfter(dueDate)) {
      return 'Last menstrual period must be before due date';
    }
    
    final daysDifference = dueDate.difference(lastMenstrualPeriod).inDays;
    if (daysDifference < 200 || daysDifference > 350) {
      return 'Pregnancy duration should be between 200-350 days';
    }
    
    return null;
  }

  /// Validate appointment date
  static String? validateAppointmentDate(DateTime? date) {
    if (date == null) {
      return 'Appointment date is required';
    }
    
    final now = DateTime.now();
    if (date.isBefore(now.subtract(const Duration(days: 1)))) {
      return 'Appointment date cannot be in the past';
    }
    
    return null;
  }

  /// Validate text length
  static String? validateTextLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$fieldName must be no more than $maxLength characters';
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  /// Validate age
  static String? validateAge(String? value) {
    final numericError = validateNumeric(value, 'Age');
    if (numericError != null) return numericError;
    
    final age = int.parse(value!);
    if (age < 13 || age > 100) {
      return 'Age must be between 13 and 100';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate time
  static String? validateTime(DateTime? time) {
    if (time == null) {
      return 'Time is required';
    }
    
    return null;
  }

  /// Validate duration
  static String? validateDuration(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a valid duration';
    }
    
    if (duration <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }
}
