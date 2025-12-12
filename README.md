# TaskFlow - Modern Todo Application

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24.0+-blue?style=flat-square&logo=flutter" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Nylo-6.9.1-green?style=flat-square" alt="Nylo Framework">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Tests-58%20Passing-brightgreen?style=flat-square" alt="Tests">
</p>

TaskFlow is a modern, intuitive todo application built with Flutter using the Nylo framework. It provides users with a clean, organized way to manage their tasks across different categories with a focus on visual appeal and user experience.

## ✨ Features

### Core Functionality
- **Task Management**: Create, edit, delete, and complete tasks with ease
- **Category Organization**: Organize tasks by Personal, Work, Shopping, and Health categories
- **Priority Levels**: Set task priorities (Low, Medium, High) for better organization
- **Due Date Tracking**: Set and track due dates for time-sensitive tasks
- **Smart Filtering**: Filter tasks by completion status, categories, and time periods

### User Experience
- **Modern UI Design**: Soft, rounded interface with mint green accents (#32C7AE)
- **Smooth Animations**: 60fps animations and transitions throughout the app
- **Empty States**: Informative empty state messages with encouraging copy
- **Statistics Dashboard**: Visual progress tracking with charts and metrics
- **Offline-First**: Local storage ensures your data is always available

### Technical Excellence
- **Performance Optimized**: Handles 1000+ tasks efficiently with virtual scrolling
- **Comprehensive Testing**: 58 passing tests with property-based testing approach
- **Error Handling**: Robust error boundaries and graceful failure recovery
- **Accessibility**: WCAG AA compliant with proper screen reader support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.4.0

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd taskflow-todo-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (for Hive adapters)**
   ```bash
   dart run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

TaskFlow follows the **Nylo MVC architecture** with clean separation of concerns:

### Project Structure
```
lib/
├── app/
│   ├── controllers/          # Business logic controllers
│   ├── models/              # Data models with Hive adapters
│   ├── services/            # Shared services (storage, validation, etc.)
│   ├── repositories/        # Data access layer
│   └── forms/               # Form handling classes
├── resources/
│   ├── pages/               # UI pages extending NyStatefulWidget
│   ├── widgets/             # Reusable UI components
│   └── themes/              # App theming and styling
├── routes/                  # Route definitions
└── bootstrap/               # App initialization
```

### Key Components

- **Models**: Todo, Category, and TaskStatistics with Hive serialization
- **Controllers**: TodoController, CategoryController, StatisticsController
- **Services**: Storage, Performance, Validation, and Error Handling
- **Repositories**: Abstracted data access with Repository pattern
- **UI Components**: Modular widgets following design system guidelines

## 🎨 Design System

### Color Palette
- **Primary**: Mint Green `#32C7AE`
- **Categories**:
  - Personal: Mint `#32C7AE`
  - Work: Purple `#8B5CF6`
  - Shopping: Orange `#F97316`
  - Health: Green `#10B981`

### UI Principles
- **Rounded Corners**: Consistent 8-12px border radius
- **Soft Shadows**: Subtle elevation for depth
- **8px Grid System**: Consistent spacing throughout
- **Typography Hierarchy**: Clear text hierarchy with proper contrast

## 🧪 Testing

TaskFlow uses a comprehensive dual testing approach:

### Test Coverage
- **58 Tests Passing** (100% success rate)
- **Property-Based Tests**: Universal behavior validation
- **Unit Tests**: Specific functionality and edge cases
- **Integration Tests**: End-to-end workflow validation
- **Performance Tests**: Large dataset handling and optimization

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/unit/
flutter test test/integration/
flutter test test/property/
```

## 📊 Performance

### Benchmarks
- **Filtering**: 0ms for category/completion/priority filters
- **Search**: ~303ms average for complex text searches
- **Memory Usage**: ~0.1MB for 100 todos
- **UI Performance**: Consistent 60fps animations
- **Large Datasets**: Efficiently handles 1000+ tasks

### Optimization Features
- Virtual scrolling for large lists
- Debounced search with caching
- Efficient Hive storage operations
- Memory management with proper disposal

## 🛠️ Development

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Nylo Framework**: MVC architecture and routing
- **Hive**: Local database for offline storage
- **Google Fonts**: Typography system
- **Material Design**: Base UI components

### Development Guidelines
The project includes comprehensive steering documents in `.kiro/steering/`:
- `flutter-nylo-development.md` - Nylo framework patterns
- `taskflow-design-system.md` - UI/UX guidelines
- `data-management.md` - Storage and repository patterns
- `testing-strategy.md` - Testing approaches and standards
- `performance-optimization.md` - Performance best practices
- `error-handling-patterns.md` - Error handling and recovery

## 📱 Screenshots & Features

### Main Interface
- Clean task list with category indicators
- Tab-based filtering (All, Today, Completed)
- Category filter chips with distinct colors
- Floating action button for quick task creation

### Task Management
- Modal sheets for task creation and editing
- Form validation with user-friendly error messages
- Priority selection and due date picker
- Swipe actions for quick edit/delete

### Statistics Dashboard
- Circular progress indicator with completion percentage
- Task count metrics (Total, Done, Pending)
- Weekly progress bar chart
- Real-time statistics updates

## 🔧 Configuration

### Environment Setup
The app uses a `.env` file for configuration:
```env
DEFAULT_LOCALE="en"
APP_NAME="TaskFlow"
```

### Customization
- Modify colors in `lib/resources/themes/`
- Add new categories in `Category.getDefaultCategories()`
- Extend validation rules in `lib/app/services/validation_service.dart`

## 📄 Documentation

- **Technical Documentation**: See `TECNICAL-DOCUMENTATION.md`
- **Integration Summary**: See `INTEGRATION_SUMMARY.md`
- **Spec Documents**: See `.kiro/specs/taskflow-todo-app/`
- **API Documentation**: Generated from code comments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the steering document guidelines
4. Write tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📋 Requirements

### System Requirements
- **Flutter**: >= 3.24.0
- **Dart**: >= 3.4.0
- **iOS**: iOS 12.0+ (for iOS builds)
- **Android**: API level 21+ (Android 5.0+)

### Dependencies
- `nylo_framework: ^6.9.1` - MVC framework
- `hive: ^2.2.3` - Local database
- `google_fonts: ^6.3.2` - Typography
- `intl: ^0.20.2` - Internationalization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Nylo Framework](https://nylo.dev) - Flutter MVC framework
- UI inspiration from modern design systems
- Performance optimization techniques from Flutter community
- Testing strategies from property-based testing principles

---

**TaskFlow** - Organize your tasks, optimize your productivity. ✅
