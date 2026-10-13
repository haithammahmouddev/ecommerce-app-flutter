
class FormatExceptionApp implements Exception {
  final String message;

  const FormatExceptionApp([this.message = 'An unexpected format error occurred. Please check your input.']);

  factory FormatExceptionApp.fromMessage(String message) {
    return FormatExceptionApp(message);
  }

  String get formattedMessage => message;

  factory FormatExceptionApp.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const FormatExceptionApp('The email address format is invalid. Please enter a valid email.');
      case 'invalid-phone-number-format':
        return const FormatExceptionApp('The provided phone number format is invalid. Please enter a valid number.');
      case 'invalid-date-format':
        return const FormatExceptionApp('The date format is invalid. Please enter a valid date.');
      case 'invalid-url-format':
        return const FormatExceptionApp('The URL format is invalid. Please enter a valid URL.');
      case 'invalid-credit-card-format':
        return const FormatExceptionApp('The credit card format is invalid. Please enter a valid credit card number.');
      case 'invalid-numeric-format':
        return const FormatExceptionApp('The input should be a valid numeric format.');
      default:
        return const FormatExceptionApp();
    }
  }
}
