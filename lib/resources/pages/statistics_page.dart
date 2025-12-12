import '/bootstrap/extensions.dart';
import '/resources/widgets/safearea_widget.dart';
import '/app/controllers/statistics_controller.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class StatisticsPage extends NyStatefulWidget<StatisticsController> {
  static RouteView path = ("/statistics", (context) {
    // Extract query parameters from the current route
    final route = ModalRoute.of(context);
    final settings = route?.settings;
    final uri = settings?.name != null ? Uri.tryParse(settings!.name!) : null;
    
    return StatisticsPage(
      initialPeriod: uri?.queryParameters['period'],
    );
  });

  final String? initialPeriod;

  StatisticsPage({
    super.key,
    this.initialPeriod,
  }) : super(child: () => _StatisticsPageState());
}

class _StatisticsPageState extends NyPage<StatisticsPage> {
  @override
  get init => () async {
    await widget.controller.initializeWithPeriod(widget.initialPeriod);
  };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal();

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.background,
      appBar: AppBar(
        backgroundColor: context.color.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.color.content,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.color.content,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: RefreshIndicator(
          onRefresh: () async {
            await widget.controller.refresh();
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular progress indicator with completion percentage
                _buildProgressOverview(context),
                
                const SizedBox(height: 32),
                
                // Task count metrics
                _buildTaskMetrics(context),
                
                const SizedBox(height: 32),
                
                // Weekly progress bar chart
                _buildWeeklyProgress(context),
                
                const SizedBox(height: 32),
                
                // Category breakdown
                _buildCategoryBreakdown(context),
                
                const SizedBox(height: 32),
                
                // Additional insights
                _buildAdditionalInsights(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    final percentage = widget.controller.completionPercentage;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.color.surfaceBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.color.content,
            ),
          ),
          const SizedBox(height: 24),
          
          // Circular progress indicator
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: context.color.primaryAccent.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(context.color.primaryAccent),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.color.content,
                      ),
                    ),
                    Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.content.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total',
                widget.controller.totalTasks.toString(),
                Icons.list_alt,
                context.color.primaryAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Done',
                widget.controller.completedTasks.toString(),
                Icons.check_circle,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Pending',
                widget.controller.pendingTasks.toString(),
                Icons.schedule,
                const Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.color.content,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.color.content.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context) {
    final weeklyData = widget.controller.weeklyProgress;
    final maxValue = weeklyData.values.isEmpty ? 1 : weeklyData.values.reduce((a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.color.surfaceBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyData.entries.map((entry) {
                    final height = maxValue > 0 ? (entry.value / maxValue) * 100 : 0.0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: context.color.content.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Bar
                        Container(
                          width: 24,
                          height: height.clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            color: context.color.primaryAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Day label
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.color.content.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context) {
    final categoryData = widget.controller.getCategoryBreakdownWithDetails();
    
    if (categoryData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.color.surfaceBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: categoryData.map((category) {
              final percentage = category['percentage'] as double;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 20,
                      color: category['color'] as Color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.color.content,
                                ),
                              ),
                              Text(
                                '${category['count']} (${percentage.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.color.content.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: (category['color'] as Color).withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(category['color'] as Color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInsights(BuildContext context) {
    final todayStats = widget.controller.getTodayStatistics();
    final weekStats = widget.controller.getWeekStatistics();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 16),
        
        // Today's stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.color.surfaceBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.today,
                size: 20,
                color: context.color.primaryAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.color.content,
                      ),
                    ),
                    Text(
                      '${todayStats['completed_today']} of ${todayStats['due_today']} tasks completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.content.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // This week's stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.color.surfaceBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                size: 20,
                color: context.color.primaryAccent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.color.content,
                      ),
                    ),
                    Text(
                      '${weekStats['completed_this_week']} of ${weekStats['due_this_week']} tasks completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.content.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}