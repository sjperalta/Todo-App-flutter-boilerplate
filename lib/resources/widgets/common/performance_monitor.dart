import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/app/services/performance_service.dart';
import '/app/services/performance_test_service.dart';
import '/app/services/search_optimization_service.dart';

/// Performance monitoring widget for debugging and optimization
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  bool _showStats = false;
  Map<String, dynamic>? _performanceStats;
  Map<String, dynamic>? _cacheStats;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showStats) _buildStatsOverlay(),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      top: 50,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: _toggleStats,
        backgroundColor: Colors.black87,
        child: Icon(
          _showStats ? Icons.close : Icons.speed,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsOverlay() {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPerformanceStats(),
                    const SizedBox(height: 16),
                    _buildCacheStats(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.speed, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Stats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (_performanceStats != null) ...[
          _buildStatsSection(_performanceStats!),
        ] else ...[
          const Text(
            'No performance data available',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _buildCacheStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cache Stats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (_cacheStats != null) ...[
          _buildCacheSection(_cacheStats!),
        ] else ...[
          const Text(
            'No cache data available',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frame stats
        if (stats['frames'] != null) ...[
          _buildStatItem('FPS', stats['frames']['estimatedFPS'] ?? 'N/A'),
          _buildStatItem('Frame Time', '${stats['frames']['averageFrameTimeMs'] ?? 'N/A'}ms'),
          _buildStatItem('Dropped Frames', stats['frames']['droppedFrames']?.toString() ?? 'N/A'),
        ],
        
        // Operation stats
        if (stats['operations'] != null) ...[
          const SizedBox(height: 8),
          const Text(
            'Operations:',
            style: TextStyle(color: Colors.yellow, fontSize: 10),
          ),
          ...((stats['operations'] as Map<String, dynamic>).entries.take(5).map(
            (entry) => _buildStatItem(
              entry.key,
              '${entry.value['averageMs']}ms (${entry.value['count']})',
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildCacheSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatItem('Filter Cache', stats['filterCacheSize']?.toString() ?? '0'),
        _buildStatItem('Search Cache', stats['searchCacheSize']?.toString() ?? '0'),
        _buildStatItem('Index Cache', stats['indexCacheSize']?.toString() ?? '0'),
        _buildStatItem('Total Entries', stats['totalCacheEntries']?.toString() ?? '0'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _refreshStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _clearCache,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Clear Cache',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _runPerformanceTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Run Test',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _logSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Log Summary',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleStats() {
    setState(() {
      _showStats = !_showStats;
      if (_showStats) {
        _refreshStats();
      }
    });
  }

  void _refreshStats() {
    setState(() {
      _performanceStats = PerformanceService().getPerformanceStats();
      _cacheStats = SearchOptimizationService().getCacheStats();
    });
  }

  void _clearCache() {
    SearchOptimizationService().clearCache();
    PerformanceService().clearHistory();
    _refreshStats();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _runPerformanceTest() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Running performance test...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final testService = PerformanceTestService();
      await testService.runPerformanceTests(
        smallDatasetSize: 50,
        mediumDatasetSize: 500,
        largeDatasetSize: 1000,
      );
      
      _refreshStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Performance test completed'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _logSummary() {
    PerformanceService().logPerformanceSummary();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Performance summary logged to console'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

/// Extension to easily wrap widgets with performance monitoring
extension PerformanceMonitorExtension on Widget {
  Widget withPerformanceMonitor({bool showOverlay = false}) {
    return PerformanceMonitor(
      showOverlay: showOverlay,
      child: this,
    );
  }
}