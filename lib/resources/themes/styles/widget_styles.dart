import 'package:flutter/material.dart';
import '/resources/themes/styles/theme_extensions.dart';
import '/resources/themes/styles/animation_styles.dart';

/// Pre-built styled widgets for consistent UI across the app
class TaskFlowWidgets {
  
  /// Styled card with consistent theming
  static Widget card({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? elevation,
    VoidCallback? onTap,
  }) {
    final colors = context.colors;
    final taskFlowTheme = context.taskFlowTheme;
    
    return Container(
      margin: margin ?? TaskFlowSpacing.paddingVerticalSM,
      child: Material(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: BorderRadius.circular(taskFlowTheme.cardRadius),
        elevation: elevation ?? taskFlowTheme.shadowElevation,
        shadowColor: colors.cardShadow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(taskFlowTheme.cardRadius),
          child: Padding(
            padding: padding ?? TaskFlowSpacing.paddingMD,
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Styled button with consistent theming
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
    bool isLoading = false,
    IconData? icon,
    double? width,
    EdgeInsets? padding,
  }) {
    final colors = context.colors;
    final taskFlowTheme = context.taskFlowTheme;
    
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryAccent,
          foregroundColor: Colors.white,
          padding: padding ?? TaskFlowSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(taskFlowTheme.buttonRadius),
          ),
          elevation: taskFlowTheme.shadowElevation,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  /// Styled secondary button
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
    IconData? icon,
    double? width,
    EdgeInsets? padding,
  }) {
    final colors = context.colors;
    final taskFlowTheme = context.taskFlowTheme;
    
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryAccent,
          padding: padding ?? TaskFlowSpacing.paddingMD,
          side: BorderSide(color: colors.primaryAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(taskFlowTheme.buttonRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Styled text button
  static Widget textButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
    IconData? icon,
    Color? textColor,
  }) {
    final colors = context.colors;
    
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor ?? colors.primaryAccent),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: context.textTheme.labelLarge?.copyWith(
              color: textColor ?? colors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Styled input field
  static Widget inputField({
    required BuildContext context,
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    int? maxLines = 1,
    bool enabled = true,
  }) {
    final colors = context.colors;
    
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      style: context.textTheme.bodyMedium?.copyWith(
        color: colors.content,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colors.content.withValues(alpha: 0.6)) : null,
        suffixIcon: suffixIcon,
        labelStyle: context.textTheme.bodyMedium?.copyWith(
          color: colors.content.withValues(alpha: 0.8),
        ),
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: colors.content.withValues(alpha: 0.6),
        ),
      ),
    );
  }
  
  /// Styled category chip
  static Widget categoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
    required Color categoryColor,
  }) {
    final colors = context.colors;
    final taskFlowTheme = context.taskFlowTheme;
    
    return AnimatedContainer(
      duration: taskFlowTheme.animationDuration,
      curve: AnimationStyles.defaultCurve,
      child: FilterChip(
        label: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : colors.content,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: colors.inputBackground,
        selectedColor: categoryColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? categoryColor : colors.inputBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(taskFlowTheme.chipRadius),
        ),
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
      ),
    );
  }
  
  /// Styled priority indicator
  static Widget priorityIndicator({
    required int priority,
    required BuildContext context,
    double size = 12,
  }) {
    final colors = context.colors;
    final priorityColor = getPriorityColor(priority, colors);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: priorityColor,
        shape: BoxShape.circle,
        boxShadow: TaskFlowShadows.soft(priorityColor.withValues(alpha: 0.3)),
      ),
    );
  }
  
  /// Styled loading indicator
  static Widget loadingIndicator({
    required BuildContext context,
    double size = 24,
    Color? color,
  }) {
    final colors = context.colors;
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? colors.primaryAccent,
        ),
      ),
    );
  }
  
  /// Styled empty state
  static Widget emptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    final colors = context.colors;
    
    return Center(
      child: Padding(
        padding: TaskFlowSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colors.content.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.content.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.content.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
  
  /// Styled section header
  static Widget sectionHeader({
    required String title,
    required BuildContext context,
    String? subtitle,
    Widget? action,
  }) {
    final colors = context.colors;
    
    return Padding(
      padding: TaskFlowSpacing.paddingHorizontalMD,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.content,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.content.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}