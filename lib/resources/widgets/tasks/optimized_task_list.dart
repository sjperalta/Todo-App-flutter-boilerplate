import 'package:flutter/material.dart';
import '/app/models/todo.dart';
import '/app/models/category.dart';
import '/app/services/performance_service.dart';
import '/resources/widgets/tasks/task_list_tile.dart';
import '/resources/widgets/tasks/task_empty_state.dart';

/// Optimized task list widget for handling large datasets efficiently
class OptimizedTaskList extends StatefulWidget {
  final List<Todo> todos;
  final List<Category> categories;
  final Function(Todo) onToggleComplete;
  final Function(Todo) onEdit;
  final Function(Todo) onDelete;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final IconData? emptyStateIcon;
  final VoidCallback? onAddTask;

  const OptimizedTaskList({
    super.key,
    required this.todos,
    required this.categories,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.onAddTask,
  });

  @override
  State<OptimizedTaskList> createState() => _OptimizedTaskListState();
}

class _OptimizedTaskListState extends State<OptimizedTaskList> {
  
  // Performance optimization: Cache category lookups
  late final Map<String, Category> _categoryCache;
  
  // Performance optimization: Track visible items for lazy loading
  final Set<int> _visibleItems = {};
  
  // Performance optimization: Debounce scroll events
  bool _isScrolling = false;
  


  @override
  void initState() {
    super.initState();
    _buildCategoryCache();
  }

  @override
  void didUpdateWidget(OptimizedTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Rebuild cache if categories changed
    if (widget.categories != oldWidget.categories) {
      _buildCategoryCache();
    }
  }

  /// Build category lookup cache for O(1) access
  void _buildCategoryCache() {
    _categoryCache = {
      for (final category in widget.categories) category.id: category
    };
  }

  @override
  Widget build(BuildContext context) {
    
    return PerformanceService().measureSync(
      'OptimizedTaskList.build',
      () => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.todos.isEmpty) {
      return _buildEmptyState();
    }

    // Use different list implementations based on size for optimal performance
    if (widget.todos.length > 1000) {
      return _buildVirtualizedList();
    } else if (widget.todos.length > 100) {
      return _buildOptimizedList();
    } else {
      return _buildStandardList();
    }
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return TaskEmptyState(
      title: widget.emptyStateTitle ?? 'No tasks yet',
      subtitle: widget.emptyStateSubtitle ?? 'Add a task to get started',
      icon: widget.emptyStateIcon ?? Icons.task_alt,
      onActionTap: widget.onAddTask,
      actionText: widget.onAddTask != null ? 'Add Task' : null,
    );
  }

  /// Standard list for small datasets (< 100 items)
  Widget _buildStandardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.todos.length,
      itemBuilder: (context, index) => _buildTaskItem(index),
    );
  }

  /// Optimized list for medium datasets (100-1000 items)
  Widget _buildOptimizedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.todos.length,
      // Performance optimization: Use item extent for better scrolling
      itemExtent: _estimateItemHeight(),
      // Performance optimization: Cache extent for smoother scrolling
      cacheExtent: 1000.0,
      itemBuilder: (context, index) => _buildTaskItem(index),
    );
  }

  /// Virtualized list for large datasets (> 1000 items)
  Widget _buildVirtualizedList() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.todos.length,
        itemExtent: _estimateItemHeight(),
        cacheExtent: 500.0, // Smaller cache for very large lists
        // Performance optimization: Add repaint boundaries for complex items
        addRepaintBoundaries: true,
        // Performance optimization: Add automatic keep alive for visible items
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) => _buildVirtualizedTaskItem(index),
      ),
    );
  }

  /// Handle scroll notifications for performance tracking
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _isScrolling = true;
    } else if (notification is ScrollEndNotification) {
      _isScrolling = false;
      _updateVisibleItems(notification.metrics);
    }
    return false;
  }

  /// Update visible items tracking for performance optimization
  void _updateVisibleItems(ScrollMetrics metrics) {
    if (widget.todos.length <= 100) return; // Only for larger lists
    
    final itemHeight = _estimateItemHeight();
    final startIndex = (metrics.pixels / itemHeight).floor().clamp(0, widget.todos.length - 1);
    final endIndex = ((metrics.pixels + metrics.viewportDimension) / itemHeight)
        .ceil()
        .clamp(0, widget.todos.length - 1);
    
    _visibleItems.clear();
    for (int i = startIndex; i <= endIndex; i++) {
      _visibleItems.add(i);
    }
  }

  /// Estimate item height for performance optimizations
  double _estimateItemHeight() {
    // Base height + potential description + potential due date
    return 80.0; // Estimated based on TaskListTile design
  }

  /// Build standard task item
  Widget _buildTaskItem(int index) {
    final todo = widget.todos[index];
    final category = _categoryCache[todo.categoryId];
    
    return TaskListTile(
      key: ValueKey(todo.id), // Stable key for performance
      todo: todo,
      category: category,
      onToggleComplete: () => widget.onToggleComplete(todo),
      onEdit: () => widget.onEdit(todo),
      onDelete: () => widget.onDelete(todo),
    );
  }

  /// Build virtualized task item with performance optimizations
  Widget _buildVirtualizedTaskItem(int index) {
    final todo = widget.todos[index];
    final category = _categoryCache[todo.categoryId];
    
    // Performance optimization: Use RepaintBoundary for complex items
    return RepaintBoundary(
      child: TaskListTile(
        key: ValueKey(todo.id),
        todo: todo,
        category: category,
        onToggleComplete: () => _handleToggleComplete(todo, index),
        onEdit: () => _handleEdit(todo, index),
        onDelete: () => _handleDelete(todo, index),
      ),
    );
  }

  /// Handle toggle complete with performance tracking
  void _handleToggleComplete(Todo todo, int index) {
    PerformanceService().measureSync(
      'TaskList.toggleComplete',
      () => widget.onToggleComplete(todo),
    );
  }

  /// Handle edit with performance tracking
  void _handleEdit(Todo todo, int index) {
    PerformanceService().measureSync(
      'TaskList.edit',
      () => widget.onEdit(todo),
    );
  }

  /// Handle delete with performance tracking
  void _handleDelete(Todo todo, int index) {
    PerformanceService().measureSync(
      'TaskList.delete',
      () => widget.onDelete(todo),
    );
  }
}

/// Sliver version for use in CustomScrollView
class OptimizedTaskListSliver extends StatelessWidget {
  final List<Todo> todos;
  final List<Category> categories;
  final Function(Todo) onToggleComplete;
  final Function(Todo) onEdit;
  final Function(Todo) onDelete;

  const OptimizedTaskListSliver({
    super.key,
    required this.todos,
    required this.categories,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    // Build category cache
    final categoryCache = {
      for (final category in categories) category.id: category
    };

    return SliverList.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final category = categoryCache[todo.categoryId];
        
        return RepaintBoundary(
          child: TaskListTile(
            key: ValueKey(todo.id),
            todo: todo,
            category: category,
            onToggleComplete: () => onToggleComplete(todo),
            onEdit: () => onEdit(todo),
            onDelete: () => onDelete(todo),
          ),
        );
      },
    );
  }
}

/// Animated list version for smooth insertions/deletions
class AnimatedOptimizedTaskList extends StatefulWidget {
  final List<Todo> todos;
  final List<Category> categories;
  final Function(Todo) onToggleComplete;
  final Function(Todo) onEdit;
  final Function(Todo) onDelete;
  final Duration animationDuration;

  const AnimatedOptimizedTaskList({
    super.key,
    required this.todos,
    required this.categories,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedOptimizedTaskList> createState() => _AnimatedOptimizedTaskListState();
}

class _AnimatedOptimizedTaskListState extends State<AnimatedOptimizedTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Todo> _displayedTodos;
  late Map<String, Category> _categoryCache;

  @override
  void initState() {
    super.initState();
    _displayedTodos = List.from(widget.todos);
    _buildCategoryCache();
  }

  @override
  void didUpdateWidget(AnimatedOptimizedTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.categories != oldWidget.categories) {
      _buildCategoryCache();
    }
    
    if (widget.todos != oldWidget.todos) {
      _updateList(oldWidget.todos, widget.todos);
    }
  }

  void _buildCategoryCache() {
    _categoryCache = {
      for (final category in widget.categories) category.id: category
    };
  }

  void _updateList(List<Todo> oldTodos, List<Todo> newTodos) {
    // Simple implementation - for production, consider using a more sophisticated diff algorithm
    final oldIds = oldTodos.map((t) => t.id).toSet();
    final newIds = newTodos.map((t) => t.id).toSet();
    
    // Handle removals
    final removedIds = oldIds.difference(newIds);
    for (final id in removedIds) {
      final index = _displayedTodos.indexWhere((t) => t.id == id);
      if (index >= 0) {
        final removedTodo = _displayedTodos.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildAnimatedItem(removedTodo, animation),
          duration: widget.animationDuration,
        );
      }
    }
    
    // Handle additions
    final addedIds = newIds.difference(oldIds);
    for (final id in addedIds) {
      final todo = newTodos.firstWhere((t) => t.id == id);
      _displayedTodos.add(todo);
      _listKey.currentState?.insertItem(
        _displayedTodos.length - 1,
        duration: widget.animationDuration,
      );
    }
    
    // Update existing items
    for (int i = 0; i < _displayedTodos.length; i++) {
      final displayedTodo = _displayedTodos[i];
      final newTodo = newTodos.firstWhere(
        (t) => t.id == displayedTodo.id,
        orElse: () => displayedTodo,
      );
      if (newTodo != displayedTodo) {
        _displayedTodos[i] = newTodo;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.all(20),
      initialItemCount: _displayedTodos.length,
      itemBuilder: (context, index, animation) {
        if (index >= _displayedTodos.length) return const SizedBox.shrink();
        return _buildAnimatedItem(_displayedTodos[index], animation);
      },
    );
  }

  Widget _buildAnimatedItem(Todo todo, Animation<double> animation) {
    final category = _categoryCache[todo.categoryId];
    
    return SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: TaskListTile(
          key: ValueKey(todo.id),
          todo: todo,
          category: category,
          onToggleComplete: () => widget.onToggleComplete(todo),
          onEdit: () => widget.onEdit(todo),
          onDelete: () => widget.onDelete(todo),
        ),
      ),
    );
  }
}