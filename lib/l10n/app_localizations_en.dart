// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get home => 'Home';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get total => 'Total';

  @override
  String get thisMonth => 'This Month';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get selectFile => 'Select File';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get food => 'Food';

  @override
  String get clothing => 'Clothing';

  @override
  String get housing => 'Housing';

  @override
  String get transportation => 'Transportation';

  @override
  String get education => 'Education';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get salary => 'Salary';

  @override
  String get business => 'Business';

  @override
  String get investment => 'Investment';

  @override
  String get gift => 'Gift';

  @override
  String get other => 'Other';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get noIncomeYet => 'No income yet';

  @override
  String get tapPlusToStart => 'Tap the + button to start tracking';

  @override
  String get net => 'Net';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get iconColor => 'Icon & Color';

  @override
  String get deleteConfirmTitle => 'Delete Transaction';

  @override
  String deleteConfirmMessage(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String deleteCategoryMessage(String categoryName) {
    return 'Are you sure you want to delete the \"$categoryName\" category?';
  }

  @override
  String get categoryDeletedSuccess => 'Category deleted successfully';

  @override
  String failedToDeleteCategory(String error) {
    return 'Failed to delete category: $error';
  }

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get update => 'Update';

  @override
  String get displayName => 'Display Name';

  @override
  String get importInstructions => 'Import Instructions';

  @override
  String get selectCSVFormat => 'Select a CSV file with the following format:';

  @override
  String get dateFormat => 'Date: yyyy-MM-dd format (e.g., 2024-01-15)';

  @override
  String get titleFormat => 'Title: Transaction description';

  @override
  String get amountFormat => 'Amount: Positive number (e.g., 85.50)';

  @override
  String get typeFormat => 'Type: INCOME or EXPENSE';

  @override
  String get categoryFormat => 'Category: Must match existing category name';

  @override
  String get descriptionFormat => 'Description: Optional details';

  @override
  String get importNote =>
      'Note: All valid transactions will be imported. Please ensure your CSV data is accurate.';

  @override
  String get sampleCSVFormat => 'Sample CSV Format';

  @override
  String get copy => 'Copy';

  @override
  String get selectCSVFile => 'Select CSV File';

  @override
  String get importing => 'Importing...';

  @override
  String get importResult => 'Import Result';

  @override
  String get successfullyImported => 'Successfully imported';

  @override
  String get transactions => 'transactions';

  @override
  String get errorsEncountered => 'Errors encountered';

  @override
  String get rows => 'rows';

  @override
  String get errors => 'Errors:';

  @override
  String get done => 'Done';

  @override
  String importSuccessMessage(int count) {
    return 'Successfully imported $count transactions';
  }

  @override
  String importFailedMessage(int count) {
    return 'Import failed with $count errors';
  }

  @override
  String importFailedWithError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get sampleCSVCopied => 'Sample CSV copied to clipboard';

  @override
  String get exportSummary => 'Export Summary';

  @override
  String get period => 'Period';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get selectDateRangeToSee => 'Select date range to see summary';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportAndShareCSV => 'Export and Share CSV';

  @override
  String errorLoadingSummary(String error) {
    return 'Error loading summary: $error';
  }

  @override
  String get pleaseSelectDates => 'Please select start and end dates';

  @override
  String get endDateAfterStart => 'End date must be after start date';

  @override
  String get csvExportedSuccessfully => 'CSV exported and shared successfully!';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get noTransactionsFound =>
      'No transactions found for selected date range';

  @override
  String get exportContent => 'Export Content';

  @override
  String failedToShareFile(String error) {
    return 'Failed to share file: $error';
  }

  @override
  String get csvContent => 'CSV content:';

  @override
  String get close => 'Close';

  @override
  String expenseTrackerExport(String fileName) {
    return 'Expense Tracker Export - $fileName';
  }

  @override
  String get financialDataExport => 'Financial Data Export';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get expenseTransaction => 'Expense Transaction';

  @override
  String get incomeTransaction => 'Income Transaction';

  @override
  String get titleHint => 'e.g., Lunch at restaurant';

  @override
  String get amountHint => '0.00';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get addNotesHint => 'Add notes about this transaction';

  @override
  String get preview => 'Preview';

  @override
  String get transactionTitle => 'Transaction Title';

  @override
  String errorLoadingCategories(String error) {
    return 'Error loading categories: $error';
  }

  @override
  String errorSavingTransaction(String error) {
    return 'Error saving transaction: $error';
  }

  @override
  String get incomeCategory => 'Income Category';

  @override
  String get expenseCategory => 'Expense Category';

  @override
  String get displayNameHint => 'e.g., Food & Dining';

  @override
  String get pleaseEnterDisplayName => 'Please enter a display name';

  @override
  String get internalName => 'Internal Name';

  @override
  String get internalNameHint => 'e.g., food_dining';

  @override
  String get internalNameHelper =>
      'Used internally, will be auto-generated if empty';

  @override
  String get icon => 'Icon';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get color => 'Color';

  @override
  String errorSavingCategory(String error) {
    return 'Error saving category: $error';
  }

  @override
  String get defaultCategory => 'Default Category';

  @override
  String get customCategory => 'Custom Category';

  @override
  String deleteConfirmCategory(String categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"?';
  }

  @override
  String failedToDeleteCategoryError(String error) {
    return 'Failed to delete category: $error';
  }

  @override
  String get categoryNameAlreadyExists =>
      'A category with this name already exists';
}
