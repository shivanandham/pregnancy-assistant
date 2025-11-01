import 'backend_config.dart';

/// API configuration for HTTP client settings
/// Uses BackendConfig as single source of truth for URL and environment info
class ApiConfig {
  /// Backend base URL - delegates to BackendConfig
  static String get baseUrl => BackendConfig.url;
  
  /// Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  /// Default HTTP headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Environment info - delegates to BackendConfig
  static String get environment => BackendConfig.environment;
  
  /// Development mode check - delegates to BackendConfig
  static bool get isDevelopment => BackendConfig.isDevelopment;
  
  /// Production mode check - delegates to BackendConfig
  static bool get isProduction => BackendConfig.isProduction;
}
