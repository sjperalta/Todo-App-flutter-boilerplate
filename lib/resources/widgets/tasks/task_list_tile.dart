import 'package:flutter/material.dart';
import '/app/models/todo.dart';
import '/app/models/category.dart';
import '/resources/themes/styles/theme_extensions.dart';
import '/resources/themes/styles/widget_styles.dart';

class TaskListTile extends StatelessWidget {
  final Todo todo;
  final Category? category;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskListTile({
    super.key,
    required this.todo,
    this.category,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit action
          onEdit();
          return false; // Don't dismiss
        } else if (direction == DismissDirection.endToStart) {
          // Delete action
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: GestureDetector(
        onLongPress: () => _showActionSheet(context),
        child: TaskFlowWidgets.card(
          context: context,
          padding: TaskFlowSpacing.paddingMD,
          margin: TaskFlowSpacing.paddingVerticalSM,
          child: Row(
            children: [
              // Checkbox with enhanced styling
              GestureDetector(
                onTap: onToggleComplete,
                child: AnimatedContainer(
                  duration: context.taskFlowTheme.animationDuration,
                  curve: Curves.easeInOutCubic,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: todo.isCompleted 
                      ? context.colors.primaryAccent 
                      : Colors.transparent,
                    border: Border.all(
                      color: todo.isCompleted 
                        ? context.colors.primaryAccent 
                        : context.colors.inputBorder,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: todo.isCompleted 
                      ? TaskFlowShadows.soft(context.colors.primaryAccent.withValues(alpha: 0.3))
                      : null,
                  ),
                  child: todo.isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: todo.isCompleted 
                          ? context.colors.content.withValues(alpha: 0.5)
                          : context.colors.content,
                        decoration: todo.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (todo.description != null && todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: todo.isCompleted 
                            ? context.colors.content.withValues(alpha: 0.3)
                            : context.colors.content.withValues(alpha: 0.6),
                          decoration: todo.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        ),
                      ),
                    ],
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: _getDueDateColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: _getDueDateColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Category indicator and priority
              Column(
                children: [
                  if (category != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category!.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  // Priority indicator with enhanced styling
                  TaskFlowWidgets.priorityIndicator(
                    priority: todo.priority,
                    context: context,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      margin: TaskFlowSpacing.paddingVerticalSM,
      decoration: BoxDecoration(
        color: isLeft ? context.colors.infoColor : context.colors.errorColor,
        borderRadius: BorderRadius.circular(context.taskFlowTheme.cardRadius),
        boxShadow: TaskFlowShadows.medium(
          (isLeft ? context.colors.infoColor : context.colors.errorColor).withValues(alpha: 0.3),
        ),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: TaskFlowSpacing.paddingHorizontalLG,
      child: Icon(
        isLeft ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              todo.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                todo.isCompleted ? Icons.undo : Icons.check_circle,
                color: todo.isCompleted ? Colors.orange : Colors.green,
              ),
              title: Text(todo.isCompleted ? 'Mark as Pending' : 'Mark as Complete'),
              onTap: () {
                Navigator.of(context).pop();
                onToggleComplete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task'),
              onTap: () async {
                Navigator.of(context).pop();
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed) {
                  onDelete();
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }



  Color _getDueDateColor(BuildContext context) {
    if (todo.dueDate == null) return context.colors.content.withValues(alpha: 0.6);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    
    if (dueDate.isBefore(today)) {
      return context.colors.errorColor; // Overdue
    } else if (dueDate.isAtSameMomentAs(today)) {
      return context.colors.warningColor; // Due today
    } else {
      return context.colors.content.withValues(alpha: 0.6); // Future
    }
  }

  String _formatDueDate() {
    if (todo.dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    
    if (dueDate.isBefore(today)) {
      final daysDiff = today.difference(dueDate).inDays;
      return daysDiff == 1 ? 'Yesterday' : '$daysDiff days ago';
    } else if (dueDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      final daysDiff = dueDate.difference(today).inDays;
      return 'In $daysDiff days';
    }
  }
}