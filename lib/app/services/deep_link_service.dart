import 'package:flutter/material.dart';

/// Deep linking service for handling app state restoration and URL navigation
/// Supports TaskFlow-specific deep links for tabs, categories, and statistics
class DeepLinkService {
  static const String _baseUrl = 'taskflow://';
  static const String _webBaseUrl = 'https://taskflow.app/';

  /// Parse deep link URL and extract route and parameters
  static DeepLinkData? parseDeepLink(String url) {
    try {
      Uri uri;
      
      // Handle both app scheme and web URLs
      if (url.startsWith(_baseUrl)) {
        uri = Uri.parse(url);
      } else if (url.startsWith(_webBaseUrl)) {
        uri = Uri.parse(url);
      } else if (url.startsWith('/')) {
        // Handle relative URLs
        uri = Uri.parse('$_baseUrl${url.substring(1)}');
      } else {
        return null;
      }

      final path = uri.path;
      final queryParams = uri.queryParameters;

      return DeepLinkData(
        route: path,
        queryParameters: queryParams,
        fragment: uri.fragment.isNotEmpty ? uri.fragment : null,
      );
    } catch (e) {
      print('DeepLinkService: Error parsing deep link: $e');
      return null;
    }
  }

  /// Generate deep link URL for home page with filters
  static String generateHomeDeepLink({
    String? tab,
    String? category,
  }) {
    final params = <String, String>{};
    
    if (tab != null && tab != 'all') {
      params['tab'] = tab;
    }
    
    if (category != null) {
      params['category'] = category;
    }
    
    final queryString = params.isNotEmpty 
        ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';
    
    return '$_baseUrl/home$queryString';
  }

  /// Generate deep link URL for statistics page
  static String generateStatisticsDeepLink({
    String? period,
    String? view,
  }) {
    final params = <String, String>{};
    
    if (period != null) {
      params['period'] = period;
    }
    
    if (view != null) {
      params['view'] = view;
    }
    
    final queryString = params.isNotEmpty 
        ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';
    
    return '$_baseUrl/statistics$queryString';
  }

  /// Generate web-compatible deep link
  static String generateWebDeepLink(String route, [Map<String, String>? params]) {
    final queryString = params != null && params.isNotEmpty 
        ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';
    
    return '$_webBaseUrl${route.startsWith('/') ? route.substring(1) : route}$queryString';
  }

  /// Handle incoming deep link and navigate appropriately
  static Future<bool> handleDeepLink(
    BuildContext context,
    String url, {
    bool replace = false,
  }) async {
    final deepLinkData = parseDeepLink(url);
    
    if (deepLinkData == null) {
      print('DeepLinkService: Invalid deep link format: $url');
      return false;
    }

    try {
      return await _navigateToDeepLink(context, deepLinkData, replace: replace);
    } catch (e) {
      print('DeepLinkService: Error handling deep link: $e');
      return false;
    }
  }

  /// Navigate to the appropriate page based on deep link data
  static Future<bool> _navigateToDeepLink(
    BuildContext context,
    DeepLinkData data, {
    bool replace = false,
  }) async {
    switch (data.route) {
      case '/':
      case '/home':
        return _navigateToHome(context, data.queryParameters, replace: replace);
      
      case '/statistics':
        return _navigateToStatistics(context, data.queryParameters, replace: replace);
      
      case '/app/home':
        return _navigateToHome(context, data.queryParameters, replace: replace);
      
      case '/app/statistics':
        return _navigateToStatistics(context, data.queryParameters, replace: replace);
      
      default:
        print('DeepLinkService: Unknown route: ${data.route}');
        return false;
    }
  }

  /// Navigate to home page with query parameters
  static Future<bool> _navigateToHome(
    BuildContext context,
    Map<String, String> params, {
    bool replace = false,
  }) async {
    try {
      final route = params.isNotEmpty 
          ? '/home?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '/home';
      
      if (replace) {
        await Navigator.of(context).pushReplacementNamed(route);
      } else {
        await Navigator.of(context).pushNamed(route);
      }
      
      return true;
    } catch (e) {
      print('DeepLinkService: Error navigating to home: $e');
      return false;
    }
  }

  /// Navigate to statistics page with query parameters
  static Future<bool> _navigateToStatistics(
    BuildContext context,
    Map<String, String> params, {
    bool replace = false,
  }) async {
    try {
      final route = params.isNotEmpty 
          ? '/statistics?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '/statistics';
      
      if (replace) {
        await Navigator.of(context).pushReplacementNamed(route);
      } else {
        await Navigator.of(context).pushNamed(route);
      }
      
      return true;
    } catch (e) {
      print('DeepLinkService: Error navigating to statistics: $e');
      return false;
    }
  }

  /// Validate deep link format
  static bool isValidDeepLink(String url) {
    return parseDeepLink(url) != null;
  }

  /// Extract route from deep link
  static String? getRouteFromDeepLink(String url) {
    final data = parseDeepLink(url);
    return data?.route;
  }

  /// Extract query parameters from deep link
  static Map<String, String>? getQueryParametersFromDeepLink(String url) {
    final data = parseDeepLink(url);
    return data?.queryParameters;
  }

  /// Generate shareable deep link for current app state
  static String generateShareableLink({
    required String route,
    Map<String, String>? params,
    bool useWebFormat = true,
  }) {
    if (useWebFormat) {
      return generateWebDeepLink(route, params);
    } else {
      final queryString = params != null && params.isNotEmpty 
          ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';
      
      return '$_baseUrl$route$queryString';
    }
  }

  /// Handle app launch from deep link
  static Future<void> handleAppLaunchDeepLink(String? initialRoute) async {
    if (initialRoute == null || initialRoute.isEmpty) {
      return;
    }

    // Store the initial route for later processing
    // This will be handled when the app is fully initialized
    _pendingDeepLink = initialRoute;
  }

  /// Process pending deep link after app initialization
  static Future<bool> processPendingDeepLink(BuildContext context) async {
    if (_pendingDeepLink == null) {
      return false;
    }

    final url = _pendingDeepLink!;
    _pendingDeepLink = null;

    return await handleDeepLink(context, url, replace: true);
  }

  static String? _pendingDeepLink;

  /// Check if there's a pending deep link
  static bool get hasPendingDeepLink => _pendingDeepLink != null;

  /// Clear pending deep link
  static void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }
}

/// Data class for parsed deep link information
class DeepLinkData {
  final String route;
  final Map<String, String> queryParameters;
  final String? fragment;

  const DeepLinkData({
    required this.route,
    required this.queryParameters,
    this.fragment,
  });

  @override
  String toString() {
    return 'DeepLinkData(route: $route, queryParameters: $queryParameters, fragment: $fragment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DeepLinkData &&
        other.route == route &&
        _mapEquals(other.queryParameters, queryParameters) &&
        other.fragment == fragment;
  }

  @override
  int get hashCode {
    return route.hashCode ^ 
           queryParameters.hashCode ^ 
           (fragment?.hashCode ?? 0);
  }

  /// Helper method to compare maps
  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }
    
    return true;
  }
}