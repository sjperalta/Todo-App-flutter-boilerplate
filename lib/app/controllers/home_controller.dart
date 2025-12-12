import 'package:flutter/material.dart';
import 'todo_controller.dart';
import 'category_controller.dart';
import 'controller.dart';
import '/app/services/navigation_service.dart';
import '/app/services/deep_link_service.dart';
import '/app/models/todo.dart';

class HomeController extends Controller {
  final TodoController todoController = TodoController();
  final CategoryController categoryController = CategoryController();
  
  TabType _selectedTab = TabType.all;
  String? _selectedCategoryId;
  
  // Getters
  TabType get selectedTab => _selectedTab;
  String? get selectedCategoryId => _selectedCategoryId;
  int get taskCount => todoController.todoCount;
  
  @override
  construct(BuildContext context) async {
    super.construct(context);
    await initialize();
  }
  
  // Initialize controllers and load data
  Future<void> initialize() async {
    await categoryController.initialize();
    await todoController.initialize();
    setState(setState: () {});
  }

  // Initialize with deep linking parameters
  Future<void> initializeWithDeepLink({
    String? initialTab,
    String? initialCategory,
  }) async {
    await initialize();
    
    // Handle initial tab from deep link
    if (initialTab != null) {
      final tab = _parseTabFromString(initialTab);
      if (tab != null) {
        onTabSelected(tab);
      }
    }
    
    // Handle initial category from deep link
    if (initialCategory != null) {
      final categoryExists = categoryController.categories
          .any((cat) => cat.id == initialCategory);
      if (categoryExists) {
        onCategorySelected(initialCategory);
      }
    }
  }

  // Parse tab string to TabType enum
  TabType? _parseTabFromString(String tabString) {
    switch (tabString.toLowerCase()) {
      case 'all':
        return TabType.all;
      case 'today':
        return TabType.today;
      case 'completed':
        return TabType.completed;
      default:
        return null;
    }
  }
  
  // Handle tab selection with filter state persistence
  void onTabSelected(TabType tab) {
    _selectedTab = tab;
    // Apply tab filter while maintaining category filter
    todoController.filterByTab(tab);
    // Ensure category filter persists across tab switches
    if (_selectedCategoryId != null) {
      todoController.filterByCategory(_selectedCategoryId);
    }
    setState(setState: () {});
  }
  
  // Handle category filter selection with state persistence
  void onCategorySelected(String? categoryId) {
    _selectedCategoryId = categoryId;
    categoryController.selectCategory(categoryId);
    // Apply category filter while maintaining current tab filter
    todoController.filterByCategory(categoryId);
    setState(setState: () {});
  }
  
  // Handle floating action button tap
  void onAddTaskTap() {
    NavigationService.showNewTaskModal(
      context!,
      categories: categoryController.categories,
      onTaskCreated: _handleTaskCreated,
      onCancel: () => Navigator.of(context!).pop(),
    );
  }

  // Handle task creation from modal
  Future<void> _handleTaskCreated(Todo todo) async {
    try {
      final success = await todoController.createTodo(todo);
      if (success) {
        Navigator.of(context!).pop(); // Close modal
        showToastSuccess(
          title: "Task Created", 
          description: "\"${todo.title}\" has been added to your tasks"
        );
        setState(setState: () {}); // Refresh UI
      } else {
        showToastDanger(
          title: "Error", 
          description: "Failed to create task. Please try again."
        );
      }
    } catch (e) {
      showToastDanger(
        title: "Error", 
        description: "An unexpected error occurred: $e"
      );
    }
  }
  
  // Refresh data
  Future<void> refresh() async {
    await todoController.refresh();
    await categoryController.refresh();
    setState(setState: () {});
  }
  
  // Get tab title
  String getTabTitle(TabType tab) {
    switch (tab) {
      case TabType.all:
        return 'All';
      case TabType.today:
        return 'Today';
      case TabType.completed:
        return 'Completed';
    }
  }
  
  // Check if tab is selected
  bool isTabSelected(TabType tab) {
    return _selectedTab == tab;
  }
  
  // Check if category is selected
  bool isCategorySelected(String? categoryId) {
    return _selectedCategoryId == categoryId;
  }

  // Handle task editing (placeholder for future implementation)
  void onEditTask(String taskId) {
    // This will be implemented when the task editing modal is created
    showToastInfo(
      title: "Edit Task", 
      description: "Task editing will be implemented in a future task"
    );
  }

  // Handle task deletion
  Future<void> onDeleteTask(String taskId) async {
    final success = await todoController.deleteTodo(taskId);
    if (success) {
      showToastSuccess(
        title: "Task Deleted", 
        description: "Task has been deleted successfully"
      );
    } else {
      showToastDanger(
        title: "Error", 
        description: "Failed to delete task"
      );
    }
  }

  // Navigate to statistics page
  void onStatisticsTap() {
    NavigationService.navigateToNamed(
      context!,
      routeName: '/statistics',
    );
  }

  // Navigate to statistics with specific period
  void navigateToStatistics({String? period}) {
    NavigationService.navigateToNamed(
      context!,
      routeName: '/statistics',
      queryParameters: period != null ? {'period': period} : null,
    );
  }

  // Generate deep link URL for current state
  String generateDeepLink() {
    final params = <String, String>{};
    
    if (_selectedTab != TabType.all) {
      params['tab'] = _selectedTab.toString().split('.').last;
    }
    
    if (_selectedCategoryId != null) {
      params['category'] = _selectedCategoryId!;
    }
    
    if (params.isEmpty) {
      return '/home';
    }
    
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '/home?$queryString';
  }

  // Share current app state via deep link
  void shareCurrentState() {
    final deepLink = generateDeepLink();
    showToastInfo(
      title: "Deep Link Generated",
      description: "Current state: $deepLink"
    );
    // In a real app, this would use the share plugin
  }

  // Handle deep link navigation
  Future<bool> handleDeepLink(String url) async {
    if (context == null) return false;
    
    return await DeepLinkService.handleDeepLink(context!, url);
  }

  // Generate shareable deep link for current state
  String generateShareableDeepLink({bool useWebFormat = true}) {
    final params = <String, String>{};
    
    if (_selectedTab != TabType.all) {
      params['tab'] = _selectedTab.toString().split('.').last;
    }
    
    if (_selectedCategoryId != null) {
      params['category'] = _selectedCategoryId!;
    }
    
    return DeepLinkService.generateShareableLink(
      route: '/home',
      params: params.isNotEmpty ? params : null,
      useWebFormat: useWebFormat,
    );
  }

  // Clear category filter while maintaining tab selection
  void clearCategoryFilter() {
    _selectedCategoryId = null;
    categoryController.selectCategory(null);
    todoController.clearCategoryFilter();
    setState(setState: () {});
  }

  // Clear all filters and show all tasks
  void clearAllFilters() {
    _selectedTab = TabType.all;
    _selectedCategoryId = null;
    categoryController.selectCategory(null);
    todoController.clearFilters();
    setState(setState: () {});
  }

  // Check if any filters are active
  bool get hasActiveFilters => todoController.hasActiveFilters;

  // Get current filter description for UI
  String get filterDescription => todoController.getFilterDescription();
}
