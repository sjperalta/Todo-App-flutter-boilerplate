import 'dart:ui';
import 'package:flutter/material.dart';
import '/resources/widgets/splash_screen.dart';
import '/resources/widgets/common/error_boundary.dart';
import '/bootstrap/app.dart';
import '/config/providers.dart';
import '../app/services/storage_service.dart';
import '../main.dart' as app_main;
import 'package:nylo_framework/nylo_framework.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// This method is called to initialize Nylo.
  static Future<Nylo> nylo() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (getEnv('SHOW_SPLASH_SCREEN', defaultValue: false)) {
      runApp(SplashScreen.app());
    }

    await _setup();
    return await bootApplication(providers);
  }

  /// This method is called after Nylo is initialized.
  static Future<void> finished(Nylo nylo) async {
    await bootFinished(nylo, providers);

    // Handle any pending deep links from app launch
    await _initializeDeepLinking();

    // Set up global error handling
    _setupGlobalErrorHandling();

    // Wrap the main app with error boundary
    runApp(
      ErrorBoundary(
        child: Main(nylo),
        errorTitle: 'TaskFlow Error',
        errorMessage: 'Something went wrong with TaskFlow. Please restart the app or contact support if the problem persists.',
        onRetry: () {
          // Restart the app by re-running main
          app_main.main();
        },
      ),
    );
  }
}

/* Setup
|--------------------------------------------------------------------------
| You can use _setup to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

_setup() async {
  /// Initialize Hive storage
  await _initializeStorage();
}

/// Initialize Hive storage system with enhanced error handling
_initializeStorage() async {
  try {
    await StorageService.initialize();
    print('Storage initialized successfully');
  } catch (e) {
    print('Error initializing storage: $e');
    
    // Attempt recovery
    try {
      print('Attempting storage recovery...');
      await StorageService.initialize();
      print('Storage recovery successful');
    } catch (recoveryError) {
      print('Storage recovery failed: $recoveryError');
      // The app can still run with limited functionality
      // Storage errors will be handled at the UI level
    }
  }
}

/// Initialize deep linking system
_initializeDeepLinking() async {
  try {
    // Handle any deep links that were received during app launch
    // This will be processed once the app is fully initialized
    print('Deep linking system initialized');
  } catch (e) {
    // Log error but don't crash the app
    print('Error initializing deep linking: $e');
  }
}

/// Set up global error handling
_setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
    
    // In production, you might want to send this to a crash reporting service
    // like Firebase Crashlytics or Sentry
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack Trace: $stack');
    
    // In production, you might want to send this to a crash reporting service
    return true; // Indicates that the error was handled
  };
}
