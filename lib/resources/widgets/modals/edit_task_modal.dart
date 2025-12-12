import 'package:flutter/material.dart';
import '/app/models/todo.dart';
import '/app/models/category.dart';
import '/app/services/error_handling_service.dart';
import '/app/services/validation_service.dart';
import '/bootstrap/extensions.dart';

class EditTaskModal extends StatefulWidget {
  final Todo todo;
  final List<Category> categories;
  final Function(Todo) onTaskUpdated;
  final VoidCallback onCancel;

  const EditTaskModal({
    super.key,
    required this.todo,
    required this.categories,
    required this.onTaskUpdated,
    required this.onCancel,
  });

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form data - initialized with existing todo data
  late String _title;
  late String? _description;
  late DateTime? _dueDate;
  late int _priority;
  late String _categoryId;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing todo data
    _title = widget.todo.title;
    _description = widget.todo.description;
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
    _categoryId = widget.todo.categoryId;
    
    // Ensure category exists in available categories
    final categoryExists = widget.categories.any((cat) => cat.id == _categoryId);
    if (!categoryExists && widget.categories.isNotEmpty) {
      _categoryId = widget.categories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.color.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.color.content.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          _buildHeader(context),
          
          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleField(context),
                    const SizedBox(height: 16),
                    _buildDescriptionField(context),
                    const SizedBox(height: 16),
                    _buildDueDateField(context),
                    const SizedBox(height: 16),
                    _buildPriorityField(context),
                    const SizedBox(height: 16),
                    _buildCategoryField(context),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.color.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit,
              color: context.color.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.color.content,
                  ),
                ),
                Text(
                  'Update your task details',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.color.content.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _title,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Enter task title',
            hintStyle: TextStyle(
              color: context.color.content.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: context.color.surfaceBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.color.primaryAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            counterText: '',
          ),
          onChanged: (value) {
            setState(() {
              _title = value;
            });
          },
          validator: (value) => ValidationService.validateTitle(value),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _description ?? '',
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Enter task description (optional)',
            hintStyle: TextStyle(
              color: context.color.content.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: context.color.surfaceBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.color.primaryAccent, width: 2),
            ),
            counterText: '',
          ),
          onChanged: (value) {
            setState(() {
              _description = value.isEmpty ? null : value;
            });
          },
          validator: (value) => ValidationService.validateDescription(value),
        ),
      ],
    );
  }

  Widget _buildDueDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.color.surfaceBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: context.color.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? _formatDate(_dueDate!)
                        : 'Select due date (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      color: _dueDate != null
                          ? context.color.content
                          : context.color.content.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (_dueDate != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      color: context.color.content.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityField(BuildContext context) {
    final priorities = [
      {'value': 1, 'text': 'Low', 'color': Colors.green},
      {'value': 2, 'text': 'Medium', 'color': Colors.orange},
      {'value': 3, 'text': 'High', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: priorities.map((priority) {
            final isSelected = _priority == priority['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = priority['value'] as int;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (priority['color'] as Color).withValues(alpha: 0.1)
                        : context.color.surfaceBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (priority['color'] as Color)
                          : context.color.content.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    priority['text'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? (priority['color'] as Color)
                          : context.color.content,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.color.content,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.categories.map((category) {
            final isSelected = _categoryId == category.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _categoryId = category.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withValues(alpha: 0.2)
                      : context.color.surfaceBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? category.color
                        : category.color.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? category.color
                          : category.color.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? category.color
                            : category.color.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : widget.onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.color.content.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleUpdateTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.color.primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Update Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: context.color.primaryAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleUpdateTask() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Additional validation
    final validationErrors = <String>[];
    
    // Validate title
    final titleError = ValidationService.validateTitle(_title);
    if (titleError != null) validationErrors.add(titleError);
    
    // Validate description
    final descriptionError = ValidationService.validateDescription(_description);
    if (descriptionError != null) validationErrors.add(descriptionError);
    
    // Validate due date
    final dueDateError = ValidationService.validateDueDate(_dueDate);
    if (dueDateError != null) validationErrors.add(dueDateError);
    
    // Validate priority
    final priorityError = ValidationService.validatePriority(_priority);
    if (priorityError != null) validationErrors.add(priorityError);
    
    // Validate category
    final availableCategoryIds = widget.categories.map((c) => c.id).toList();
    final categoryError = ValidationService.validateCategoryId(_categoryId, availableCategoryIds);
    if (categoryError != null) validationErrors.add(categoryError);

    if (validationErrors.isNotEmpty) {
      ErrorHandlingService.showError(
        context,
        ValidationException(validationErrors.first),
      );
      return;
    }

    // Check if there are any changes
    final hasChanges = _title.trim() != widget.todo.title ||
                      _description?.trim() != widget.todo.description ||
                      _dueDate != widget.todo.dueDate ||
                      _priority != widget.todo.priority ||
                      _categoryId != widget.todo.categoryId;

    if (!hasChanges) {
      ErrorHandlingService.showWarning(
        context,
        'No changes were made to the task',
      );
      widget.onCancel();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sanitize input data
      final sanitizedTitle = ValidationService.sanitizeForDisplay(_title.trim());
      final sanitizedDescription = _description?.trim().isNotEmpty == true 
          ? ValidationService.sanitizeForDisplay(_description!.trim())
          : null;

      // Create updated todo from form data
      final updatedTodo = widget.todo.copyWith(
        title: sanitizedTitle,
        description: sanitizedDescription,
        dueDate: _dueDate,
        categoryId: _categoryId,
        priority: _priority,
      );

      // Final validation of the updated todo
      final todoErrors = updatedTodo.validate();
      if (todoErrors.isNotEmpty) {
        throw ValidationException(todoErrors.first);
      }

      // Call the callback to update the task
      widget.onTaskUpdated(updatedTodo);
      
      // Show success message
      if (mounted) {
        ErrorHandlingService.showSuccess(
          context,
          'Task "${updatedTodo.title}" updated successfully',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message using enhanced error handling
      if (mounted) {
        ErrorHandlingService.showError(
          context,
          e,
          customMessage: 'Failed to update task. Please check your input and try again.',
        );
      }
    }
  }
}