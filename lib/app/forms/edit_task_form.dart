import 'package:nylo_framework/nylo_framework.dart';
import '../services/validation_service.dart';
import '../models/todo.dart';

/* Edit Task Form
|--------------------------------------------------------------------------
| Enhanced form with comprehensive validation for task editing
| Usage: https://nylo.dev/docs/6.x/forms#how-it-works
| Casts: https://nylo.dev/docs/6.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/6.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class EditTaskForm extends NyFormData {
  EditTaskForm({String? name}) : super(name ?? "edit_task");

  @override
  fields() => [
        Field.text("title",
            validate: FormValidator.notEmpty(message: "Title cannot be empty")),
        Field.text("description"),
        Field.date("due_date"),
        Field.text("priority"),
        Field.text("category"),
      ];

  /// Initialize form with existing todo data
  void initializeWithTodo(Todo todo) {
    final formData = data();
    formData['title'] = todo.title;
    formData['description'] = todo.description;
    formData['due_date'] = todo.dueDate;
    formData['priority'] = todo.priority.toString();
    formData['category'] = todo.categoryId;
  }

  /// Validate the entire form with additional business logic
  Map<String, String> validateForm({
    required List<String> availableCategoryIds,
    Todo? originalTodo,
  }) {
    final errors = <String, String>{};

    // Get form data
    final formData = data();
    final title = formData['title'] as String?;
    final description = formData['description'] as String?;
    final dueDate = formData['due_date'] as DateTime?;
    final priorityStr = formData['priority'] as String?;
    final categoryId = formData['category'] as String?;

    // Validate title
    final titleError = ValidationService.validateTitle(title);
    if (titleError != null) {
      errors['title'] = titleError;
    }

    // Validate description
    final descriptionError = ValidationService.validateDescription(description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
    }

    // Validate due date
    final dueDateError = ValidationService.validateDueDate(dueDate);
    if (dueDateError != null) {
      errors['due_date'] = dueDateError;
    }

    // Validate priority
    final priority = int.tryParse(priorityStr ?? '');
    final priorityError = ValidationService.validatePriority(priority);
    if (priorityError != null) {
      errors['priority'] = priorityError;
    }

    // Validate category
    final categoryError = ValidationService.validateCategoryId(categoryId, availableCategoryIds);
    if (categoryError != null) {
      errors['category'] = categoryError;
    }

    return errors;
  }

  /// Get sanitized form data
  Map<String, dynamic> getSanitizedData() {
    final formData = data();
    return {
      'title': ValidationService.sanitizeForDisplay(formData['title'] as String?),
      'description': ValidationService.sanitizeForDisplay(formData['description'] as String?),
      'due_date': formData['due_date'],
      'priority': int.tryParse(formData['priority'] as String? ?? '2') ?? 2,
      'category': formData['category'],
    };
  }

  /// Check if form data has changed from original
  bool hasChanges(Todo originalTodo) {
    final formData = data();
    final currentTitle = formData['title'] as String?;
    final currentDescription = formData['description'] as String?;
    final currentDueDate = formData['due_date'] as DateTime?;
    final currentPriority = int.tryParse(formData['priority'] as String? ?? '');
    final currentCategory = formData['category'] as String?;

    return currentTitle?.trim() != originalTodo.title ||
           currentDescription?.trim() != originalTodo.description ||
           currentDueDate != originalTodo.dueDate ||
           currentPriority != originalTodo.priority ||
           currentCategory != originalTodo.categoryId;
  }

  /// Check if all required fields are filled
  bool get hasRequiredFields {
    final formData = data();
    final title = formData['title'] as String?;
    final category = formData['category'] as String?;
    
    return title != null && 
           title.trim().isNotEmpty && 
           category != null && 
           category.trim().isNotEmpty;
  }

  /// Get validation summary
  List<String> getValidationSummary({
    required List<String> availableCategoryIds,
    Todo? originalTodo,
  }) {
    final errors = validateForm(
      availableCategoryIds: availableCategoryIds,
      originalTodo: originalTodo,
    );
    return errors.values.toList();
  }

  /// Create updated todo from form data
  Todo createUpdatedTodo(Todo originalTodo) {
    final sanitizedData = getSanitizedData();
    
    return originalTodo.copyWith(
      title: sanitizedData['title'] as String,
      description: sanitizedData['description'] as String?,
      dueDate: sanitizedData['due_date'] as DateTime?,
      priority: sanitizedData['priority'] as int,
      categoryId: sanitizedData['category'] as String,
    );
  }
}