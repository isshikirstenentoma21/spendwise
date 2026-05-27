# SpendWise Lab 05

Flutter project for Lab 05: Local Data Persistence with Hive.

## Open in VS Code

Open this folder:

`C:\Users\Dell\OneDrive\Desktop\spendwise`

## Included Features

- Hive setup in `main.dart`
- Generated Hive adapters for `ExpenseCategory` and `Expense`
- `expenses` typed Hive box and `settings` box
- Service layer in `lib/services/expense_service.dart`
- Add, read, edit, and delete expenses
- Swipe left to delete with confirmation
- Category filter chips
- Summary card with total spending
- Monthly budget dialog stored under `monthly_budget`
- Budget progress bar with warning at 80%
- Export current-month expenses to a text file
- Reactive HomeScreen updates with `ValueListenableBuilder`

## Useful Commands

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart analyze
flutter test
flutter run
```

## Local Setup Notes

The project has already passed:

```powershell
dart analyze
flutter test
```

Windows may show a Developer Mode warning because `path_provider` uses Flutter plugins. If that appears, enable Developer Mode in Windows Settings.
