---
inclusion: always
---

# TaskFlow Design System Guidelines

## Visual Identity

### Color Palette
- **Primary**: Mint Green `#32C7AE` - Used for accents, buttons, and primary actions
- **Categories**:
  - Personal: Mint `#32C7AE`
  - Work: Purple `#8B5CF6`
  - Shopping: Orange `#F97316`
  - Health: Green `#10B981`

### Typography
- Use Google Fonts for consistent typography
- Maintain proper text hierarchy with appropriate font weights
- Ensure sufficient contrast ratios for accessibility

### UI Elements
- **Rounded Corners**: Apply consistent border radius (8-12px) to cards, buttons, and containers
- **Soft Shadows**: Use subtle elevation for depth without harsh shadows
- **Spacing**: Follow 8px grid system for consistent spacing

## Component Standards

### Task List Items
```dart
// TaskListTile should include:
- Checkbox for completion toggle
- Category color indicator (left border or chip)
- Priority visual cues (icons or color intensity)
- Title and description text
- Due date display when applicable
```

### Category Chips
```dart
// CategoryChip specifications:
- Rounded pill shape with category color
- Selected state with darker background
- Consistent padding and typography
- Tap feedback animations
```

### Modal Sheets
```dart
// Modal design requirements:
- Bottom sheet with rounded top corners
- Proper handle indicator at top
- Consistent padding and spacing
- Form fields with proper validation styling
```

### Empty States
```dart
// Empty state components:
- Centered icon and message
- Encouraging copy ("No tasks yet" vs "No items")
- Consistent with overall app aesthetic
- Optional call-to-action button
```

## Animation Guidelines

### Transitions
- Use smooth, natural animations (200-300ms duration)
- Implement proper easing curves (ease-in-out)
- Provide immediate visual feedback for user interactions

### Loading States
- Show loading indicators for operations > 100ms
- Use skeleton screens for content loading
- Maintain layout stability during loading

### Micro-interactions
- Checkbox toggle animations
- Button press feedback
- List item swipe actions
- Modal slide-in/out transitions

## Accessibility

### Color Contrast
- Ensure WCAG AA compliance (4.5:1 ratio minimum)
- Don't rely solely on color to convey information
- Provide alternative indicators for color-blind users

### Touch Targets
- Minimum 44px touch target size
- Adequate spacing between interactive elements
- Clear visual feedback for touch interactions

### Screen Readers
- Proper semantic labels for all interactive elements
- Meaningful content descriptions
- Logical focus order and navigation

## Responsive Design

### Screen Sizes
- Support phones (320px - 480px width)
- Optimize for tablets (768px+ width)
- Maintain usability across orientations

### Layout Adaptation
- Flexible grid systems
- Scalable typography
- Adaptive spacing and component sizing

## Implementation Notes

### Theme Configuration
```dart
// Use TaskFlowTheme for consistent styling
ThemeData taskFlowTheme = ThemeData(
  primaryColor: Color(0xFF32C7AE),
  // Configure other theme properties
);
```

### Custom Widgets
- Create reusable components following design system
- Maintain consistent prop interfaces
- Document component usage and variations

### Asset Management
- Organize icons and images in logical folders
- Use SVG icons when possible for scalability
- Optimize image assets for different screen densities

This design system ensures visual consistency and excellent user experience throughout the TaskFlow application.