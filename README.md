# FlowFi - Personal Finance Companion

A modern, clean, and intuitive Flutter mobile app for tracking daily transactions, understanding spending habits, managing financial goals, and viewing actionable insights.

## 🎯 Overview

FlowFi is a lightweight personal finance companion designed to help users:
- **Track daily transactions** with detailed categorization
- **Monitor spending patterns** through visual charts and analytics
- **Set and track goals** like no-spend challenges and savings targets
- **Get actionable insights** about their financial habits
- **Manage finances** with an intuitive, mobile-first interface

This is NOT a banking app. It's a personal finance tracker focused on self-awareness and habit building.

## ✨ Key Features

### 1. **Home Dashboard**
- Current balance calculation (income - expenses)
- Total income and expense overview
- Savings progress indicator
- Weekly spending trend visualization
- Smart insights (e.g., "You spent more than usual today")
- Quick access to your active goals

### 2. **Transaction Management**
- Add transactions with amount, type (income/expense), category, date, and notes
- Edit existing transactions
- Delete transactions with swipe gesture
- Filter by transaction type (All/Income/Expense)
- Search transactions by note or amount
- Transactions grouped by date for easy browsing

### 3. **No-Spend Challenge / Goals**
- Create custom goals and challenges
- Track no-spend streaks visually
- Set target durations
- See progress toward goal completion
- Increment days and reset streaks as needed
- Support for multiple goal types (no-spend challenge, savings target, budget limit)

### 4. **Insights & Analytics**
- **Top Spending Category**: See where most money goes
- **Weekly Comparison**: Compare this week vs. last week spending
- **Daily Average**: Understand daily spending patterns
- **Category Breakdown**: Pie chart showing spending by category
- **Spending Trends**: Visual insights into spending patterns
- **Most Frequent Type**: See if you spend or earn more often

### 5. **Clean Mobile UX**
- Bottom navigation for easy screen navigation
- Floating action button for quick transaction entry
- Empty states for better guidance
- Loading states for data operations
- Error handling and recovery
- Responsive design for different screen sizes
- Touch-friendly buttons and interactions
- Smooth transitions and animations

## 🏗️ Architecture & Code Quality

### Project Structure
```
lib/
├── main.dart                 # App entry point & theme setup
├── providers.dart            # Riverpod state management
├── constants/
│   └── app_theme.dart       # Colors, spacing, typography
├── models/
│   ├── transaction.dart      # Transaction model with Hive
│   ├── goal.dart            # Goal model with Hive
│   └── savings_streak.dart   # SavingsStreak model with Hive
├── services/
│   ├── hive_service.dart    # Database initialization
│   ├── transaction_service.dart  # Transaction CRUD & queries
│   ├── goal_service.dart    # Goal CRUD & operations
│   ├── analytics_service.dart    # All analytics computations
│   └── dummy_data_service.dart   # Dummy data initialization
├── screens/
│   ├── main_navigation_screen.dart  # Bottom nav container
│   ├── home_screen.dart     # Dashboard with balance & insights
│   ├── transactions_screen.dart     # Transaction list & filtering
│   ├── goals_screen.dart    # Goals & challenges management
│   ├── insights_screen.dart  # Analytics & trends
│   └── add_edit_transaction_screen.dart  # Transaction form
├── widgets/
│   ├── cards/               # Reusable card components
│   ├── buttons/             # Primary & secondary buttons
│   ├── inputs/              # Form inputs
│   ├── charts/              # Chart widgets
│   └── misc/                # Empty states, loading, errors
└── utils/
    ├── formatters.dart      # Date and currency formatting
    └── extensions.dart      # Useful Dart extensions
```

### Key Design Decisions

1. **Riverpod for State Management**: Provides reactive, compile-safe dependency injection
2. **Hive for Local Storage**: Fast, lightweight, and perfect for mobile
3. **Clean Architecture**: Separated services, providers, and UI layers
4. **Reusable Widgets**: Consistent design system with card, button, and input components
5. **No Hardcoded Data**: All UI driven by services and state
6. **Dynamic Analytics**: All insights computed from transactions (not stored)

## 📱 Technology Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **State Management**: Riverpod 2.4+
- **Local Storage**: Hive 2.2+
- **Charts**: FL Chart 0.65+
- **Formatting**: Intl 0.19+

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart 3.0+

### Installation

1. **Clone the repository**
   ```bash
   cd flowfi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters (optional, already provided)**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Running on Devices
```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d device_id

# Web
flutter run -d chrome
```

## 💾 Data Schema

### Transaction
- `id`: Unique identifier (UUID)
- `amount`: Transaction amount (double)
- `type`: "income" or "expense"
- `category`: Transaction category (enum)
- `date`: Transaction date
- `note`: Optional description
- `createdAt`: Creation timestamp

### Goal
- `id`: Unique identifier
- `name`: Goal name
- `type`: Goal type (noSpendChallenge, savingsTarget, budgetLimit)
- `targetDays`: Target duration
- `currentDays`: Current progress
- `startDate`: Goal start date
- `isActive`: Active status
- `lastResetDate`: Last streak reset

### SavingsStreak
- `currentStreak`: Current consecutive days (no spending)
- `longestStreak`: Historical longest streak
- `lastUpdated`: Last update timestamp

## 📊 Analytics Computations

All analytics are computed dynamically from transactions:

- **Balance**: Sum of all income - sum of all expenses
- **Weekly Trends**: Expenses grouped by day of week
- **Category Breakdown**: Expenses summed by category
- **Savings Progress**: (Income - Expenses) / Income
- **Daily Average**: Total expenses / number of unique spending days
- **Smart Insights**: Comparison of today vs. yesterday spending

## 🎨 Design System

### Color Palette
- **Primary**: Indigo (#6366F1)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)
- **Background**: Light gray (#FAFAFA)

### Typography
- **Headline 1**: 32px, Bold
- **Headline 2**: 24px, Bold
- **Headline 3**: 20px, Bold
- **Body 1**: 14px, Regular
- **Body 2**: 12px, Regular
- **Caption**: 11px, Regular

### Spacing
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- XXL: 48px

## 🔐 Local Data Storage

All data is stored locally using Hive with no internet connection required:
- **Transactions**: All transaction history
- **Goals**: All goal and challenge data
- **Streaks**: Savings streak tracking

Data is persisted across app sessions automatically.

## 🚫 Limitations & Assumptions

1. **No Backend**: This is a local-only app. Data is not synced to cloud.
2. **Single User**: No multi-user or authentication support.
3. **Single Currency**: Uses INR (₹) throughout the app.
4. **No Recurring Transactions**: All transactions must be entered manually.
5. **No Budget Enforcement**: Goals don't block actions, they're informational.
6. **No Export**: Data stays in the app (could be added as enhancement).

## 🎯 Future Enhancements

- Dark mode support
- Local notifications & reminders
- CSV export functionality
- Biometric authentication
- Multi-currency support
- Recurring transactions
- Cloud sync with Firebase
- Custom categories
- Data import from other apps

## 📸 Key Screens

### Home Dashboard
Displays balance, income/expenses, savings progress, weekly chart, and active goals.

### Transactions
Browse all transactions grouped by date with filtering and search capabilities.

### Goals & Challenges
Track no-spend challenges and savings goals with visual progress indicators.

### Insights
View analytics including spending breakdown, weekly trends, and daily averages.

## 📝 Dummy Data

The app comes pre-loaded with realistic dummy data for immediate testing:
- **15 sample transactions** across different categories and dates
- **1 active no-spend challenge** (7-day goal, started 1 day ago)
- **Mix of income and expense** transactions for realistic patterns

Dummy data is created only once during first app launch and stored in Hive.

## ✅ Testing Checklist

- [x] Add/Edit/Delete transactions
- [x] Filter transactions by type
- [x] Search transactions
- [x] View balance calculations
- [x] Create and manage goals
- [x] Track goal progress
- [x] View analytics and charts
- [x] Responsive layout on different screen sizes
- [x] Navigation between screens
- [x] Persist data across app restarts

## 🤝 Code Quality

- **Clean Architecture**: Separation of concerns with services, providers, and UI
- **Type Safety**: Full typing with strong null safety
- **Reusable Components**: DRY principle with shared widgets
- **Naming Conventions**: Clear, descriptive names for variables and functions
- **Documentation**: Inline comments for complex logic
- **Error Handling**: Graceful error states and UI feedback

## 📄 License

This project is created for evaluation purposes.

---

**Built with ❤️ using Flutter**

For questions or feedback, please contact the developer.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
