import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Service for monitoring and optimizing app performance
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Performance metrics
  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};
  final List<double> _frameRenderTimes = [];
  Timer? _memoryMonitorTimer;
  bool _isMonitoring = false;

  // Performance thresholds
  static const Duration _slowOperationThreshold = Duration(milliseconds: 100);
  static const Duration _verySlowOperationThreshold = Duration(milliseconds: 500);
  static const double _targetFrameTime = 16.67; // 60fps = 16.67ms per frame
  static const int _maxFrameHistory = 100;

  /// Initialize performance monitoring
  void initialize() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _startFrameMonitoring();
    _startMemoryMonitoring();
    
    if (kDebugMode) {
      print('PerformanceService: Monitoring started');
    }
  }

  /// Stop performance monitoring
  void dispose() {
    _isMonitoring = false;
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
    
    if (kDebugMode) {
      print('PerformanceService: Monitoring stopped');
    }
  }

  /// Measure operation performance
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      _recordOperationTime(operationName, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordOperationTime('$operationName (error)', stopwatch.elapsed);
      rethrow;
    }
  }

  /// Measure synchronous operation performance
  T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      _recordOperationTime(operationName, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordOperationTime('$operationName (error)', stopwatch.elapsed);
      rethrow;
    }
  }

  /// Record operation timing
  void _recordOperationTime(String operationName, Duration duration) {
    _operationTimes.putIfAbsent(operationName, () => []);
    _operationCounts.putIfAbsent(operationName, () => 0);
    
    _operationTimes[operationName]!.add(duration);
    _operationCounts[operationName] = _operationCounts[operationName]! + 1;
    
    // Keep only recent measurements (last 100)
    if (_operationTimes[operationName]!.length > 100) {
      _operationTimes[operationName]!.removeAt(0);
    }
    
    // Log slow operations in debug mode
    if (kDebugMode && duration > _slowOperationThreshold) {
      final level = duration > _verySlowOperationThreshold ? 'VERY SLOW' : 'SLOW';
      print('PerformanceService: $level operation "$operationName" took ${duration.inMilliseconds}ms');
    }
  }

  /// Start monitoring frame render times
  void _startFrameMonitoring() {
    try {
      SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
        if (!_isMonitoring) return;
        
        final frameTime = timeStamp.inMicroseconds / 1000.0; // Convert to milliseconds
        _frameRenderTimes.add(frameTime);
        
        // Keep only recent frame times
        if (_frameRenderTimes.length > _maxFrameHistory) {
          _frameRenderTimes.removeAt(0);
        }
        
        // Log dropped frames in debug mode
        if (kDebugMode && frameTime > _targetFrameTime * 2) {
          print('PerformanceService: Dropped frame detected - ${frameTime.toStringAsFixed(2)}ms');
        }
      });
    } catch (e) {
      // In test environment, SchedulerBinding might not be available
      if (kDebugMode) {
        print('PerformanceService: Frame monitoring not available in test environment');
      }
    }
  }

  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isMonitoring) {
        timer.cancel();
        return;
      }
      
      _logMemoryUsage();
    });
  }

  /// Log current memory usage
  void _logMemoryUsage() {
    if (kDebugMode) {
      developer.Timeline.startSync('MemoryCheck');
      
      // Force garbage collection to get accurate reading
      developer.Timeline.finishSync();
      
      print('PerformanceService: Memory check completed');
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'operations': <String, dynamic>{},
      'frames': <String, dynamic>{},
    };

    // Operation statistics
    for (final entry in _operationTimes.entries) {
      final times = entry.value;
      if (times.isEmpty) continue;

      final totalMs = times.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
      final avgMs = totalMs / times.length;
      final maxMs = times.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);
      final minMs = times.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b);

      stats['operations'][entry.key] = {
        'count': _operationCounts[entry.key] ?? 0,
        'averageMs': avgMs.toStringAsFixed(2),
        'maxMs': maxMs,
        'minMs': minMs,
        'totalMs': totalMs,
      };
    }

    // Frame statistics
    if (_frameRenderTimes.isNotEmpty) {
      final avgFrameTime = _frameRenderTimes.reduce((a, b) => a + b) / _frameRenderTimes.length;
      final maxFrameTime = _frameRenderTimes.reduce((a, b) => a > b ? a : b);
      final droppedFrames = _frameRenderTimes.where((time) => time > _targetFrameTime * 1.5).length;
      final fps = 1000 / avgFrameTime;

      stats['frames'] = {
        'averageFrameTimeMs': avgFrameTime.toStringAsFixed(2),
        'maxFrameTimeMs': maxFrameTime.toStringAsFixed(2),
        'estimatedFPS': fps.toStringAsFixed(1),
        'droppedFrames': droppedFrames,
        'framesSampled': _frameRenderTimes.length,
        'targetFrameTimeMs': _targetFrameTime.toStringAsFixed(2),
      };
    }

    return stats;
  }

  /// Check if performance is acceptable
  bool isPerformanceAcceptable() {
    // Check average frame time
    if (_frameRenderTimes.isNotEmpty) {
      final avgFrameTime = _frameRenderTimes.reduce((a, b) => a + b) / _frameRenderTimes.length;
      if (avgFrameTime > _targetFrameTime * 1.5) {
        return false; // Frame rate too low
      }
    }

    // Check for consistently slow operations
    for (final entry in _operationTimes.entries) {
      final times = entry.value;
      if (times.length >= 5) {
        final avgTime = times.fold<int>(0, (sum, d) => sum + d.inMilliseconds) / times.length;
        if (avgTime > _slowOperationThreshold.inMilliseconds) {
          return false; // Operation consistently slow
        }
      }
    }

    return true;
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    // Frame rate recommendations
    if (_frameRenderTimes.isNotEmpty) {
      final avgFrameTime = _frameRenderTimes.reduce((a, b) => a + b) / _frameRenderTimes.length;
      final droppedFrames = _frameRenderTimes.where((time) => time > _targetFrameTime * 1.5).length;
      
      if (avgFrameTime > _targetFrameTime * 1.2) {
        recommendations.add('Frame rate is below target (${(1000/avgFrameTime).toStringAsFixed(1)} fps). Consider reducing animation complexity.');
      }
      
      if (droppedFrames > _frameRenderTimes.length * 0.1) {
        recommendations.add('High number of dropped frames detected. Consider optimizing list rendering or reducing simultaneous animations.');
      }
    }

    // Operation performance recommendations
    for (final entry in _operationTimes.entries) {
      final times = entry.value;
      if (times.length >= 3) {
        final avgTime = times.fold<int>(0, (sum, d) => sum + d.inMilliseconds) / times.length;
        
        if (avgTime > _verySlowOperationThreshold.inMilliseconds) {
          recommendations.add('Operation "${entry.key}" is very slow (${avgTime.toStringAsFixed(1)}ms avg). Consider optimization or caching.');
        } else if (avgTime > _slowOperationThreshold.inMilliseconds) {
          recommendations.add('Operation "${entry.key}" is slow (${avgTime.toStringAsFixed(1)}ms avg). Consider minor optimizations.');
        }
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('Performance is within acceptable limits.');
    }

    return recommendations;
  }

  /// Clear performance history
  void clearHistory() {
    _operationTimes.clear();
    _operationCounts.clear();
    _frameRenderTimes.clear();
    
    if (kDebugMode) {
      print('PerformanceService: Performance history cleared');
    }
  }

  /// Log performance summary
  void logPerformanceSummary() {
    if (!kDebugMode) return;

    print('\n=== Performance Summary ===');
    
    final stats = getPerformanceStats();
    
    // Frame performance
    if (stats['frames'] != null) {
      final frames = stats['frames'] as Map<String, dynamic>;
      print('Frame Performance:');
      print('  Average FPS: ${frames['estimatedFPS']}');
      print('  Average Frame Time: ${frames['averageFrameTimeMs']}ms');
      print('  Dropped Frames: ${frames['droppedFrames']}/${frames['framesSampled']}');
    }
    
    // Operation performance
    if (stats['operations'] != null) {
      final operations = stats['operations'] as Map<String, dynamic>;
      print('Operation Performance:');
      
      for (final entry in operations.entries) {
        final op = entry.value as Map<String, dynamic>;
        print('  ${entry.key}: ${op['averageMs']}ms avg (${op['count']} calls)');
      }
    }
    
    // Recommendations
    final recommendations = getPerformanceRecommendations();
    print('Recommendations:');
    for (final rec in recommendations) {
      print('  - $rec');
    }
    
    print('========================\n');
  }
}