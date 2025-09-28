import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../models/theme_preference.dart';
import '../models/language_preference.dart';

class DatabaseHelper {
  static const _databaseName = 'expense_tracker.db';
  static const _databaseVersion = 1;
  static const _transactionsTable = 'transactions';
  static const _categoriesTable = 'categories';
  static const _themePreferencesTable = 'theme_preferences';
  static const _languagePreferencesTable = 'language_preferences';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        display_name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_income_category INTEGER NOT NULL DEFAULT 0,
        UNIQUE(display_name, is_income_category)
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        description TEXT,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        FOREIGN KEY (category_id) REFERENCES $_categoriesTable (id)
      )
    ''');

    // Create theme preferences table
    await db.execute('''
      CREATE TABLE $_themePreferencesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_mode TEXT NOT NULL CHECK (theme_mode IN ('light', 'dark', 'system')),
        last_updated INTEGER NOT NULL
      )
    ''');

    // Create language preferences table
    await db.execute('''
      CREATE TABLE $_languagePreferencesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_code TEXT NOT NULL CHECK (language_code IN ('en', 'zh_TW')),
        last_updated INTEGER NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // Insert default theme preference
    await _insertDefaultThemePreference(db);

    // Insert default language preference
    await _insertDefaultLanguagePreference(db);
  }

  Future _insertDefaultCategories(Database db) async {
    for (Category category in DefaultCategories.allDefaultCategories) {
      await db.insert(_categoriesTable, category.toMap());
    }
  }

  Future _insertDefaultThemePreference(Database db) async {
    final defaultTheme = ThemePreference(
      themeMode: AppThemeMode.system,
      lastUpdated: DateTime.now(),
    );
    await db.insert(_themePreferencesTable, defaultTheme.toMap());
  }

  Future _insertDefaultLanguagePreference(Database db) async {
    final defaultLanguage = LanguagePreference(
      languageCode: AppLanguage.english,
      lastUpdated: DateTime.now(),
    );
    await db.insert(_languagePreferencesTable, defaultLanguage.toMap());
  }

  // Transaction methods
  Future<int> insertTransaction(model.Transaction transaction) async {
    Database db = await database;
    return await db.insert(_transactionsTable, transaction.toMap());
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        t.id, t.title, t.amount, t.category_id, t.date, t.description, t.type,
        c.id as category_table_id, c.display_name, c.icon_code, c.color_value, c.is_default, c.is_income_category
      FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      ORDER BY t.date DESC
    ''');

    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<List<model.Transaction>> getTransactionsByType(
    model.TransactionType type,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        t.id, t.title, t.amount, t.category_id, t.date, t.description, t.type,
        c.id as category_table_id, c.display_name, c.icon_code, c.color_value, c.is_default, c.is_income_category
      FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE t.type = ?
      ORDER BY t.date DESC
    ''',
      [type.name],
    );

    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<List<model.Transaction>> getTransactionsByCategory(
    Category category,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        t.id, t.title, t.amount, t.category_id, t.date, t.description, t.type,
        c.id as category_table_id, c.display_name, c.icon_code, c.color_value, c.is_default, c.is_income_category
      FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE t.category_id = ?
      ORDER BY t.date DESC
    ''',
      [category.id],
    );

    return List.generate(maps.length, (i) {
      Category cat = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], cat);
    });
  }

  Future<List<model.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end, {
    model.TransactionType? type,
  }) async {
    Database db = await database;

    String whereClause = 't.date >= ? AND t.date <= ?';
    List<dynamic> whereArgs = [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ];

    if (type != null) {
      whereClause += ' AND t.type = ?';
      whereArgs.add(type.name);
    }

    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        t.id, t.title, t.amount, t.category_id, t.date, t.description, t.type,
        c.id as category_table_id, c.display_name, c.icon_code, c.color_value, c.is_default, c.is_income_category
      FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE $whereClause
      ORDER BY t.date DESC
    ''', whereArgs);

    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<Map<Category, double>> getCategoryTotals({
    model.TransactionType? type,
  }) async {
    Database db = await database;

    String whereClause = type != null ? 'WHERE t.type = ?' : '';
    List<dynamic> whereArgs = type != null ? [type.name] : [];

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.*, SUM(t.amount) as total FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      $whereClause
      GROUP BY c.id
      HAVING total > 0
    ''', whereArgs);

    Map<Category, double> totals = {};
    for (var row in result) {
      Category category = Category.fromMap(row);
      totals[category] = row['total'] ?? 0.0;
    }

    return totals;
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    Database db = await database;
    return await db.update(
      _transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByType(model.TransactionType type) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_transactionsTable WHERE type = ?',
      [type.name],
    );
    return result[0]['total'] ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    return getTotalByType(model.TransactionType.expense);
  }

  Future<double> getTotalIncome() async {
    return getTotalByType(model.TransactionType.income);
  }

  Future<double> getNetBalance() async {
    double income = await getTotalIncome();
    double expenses = await getTotalExpenses();
    return income - expenses;
  }

  Future<List<model.Transaction>> getTransactionsByMonth(
    int year,
    int month, {
    model.TransactionType? type,
  }) async {
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    return getTransactionsByDateRange(
      DateTime.fromMillisecondsSinceEpoch(startOfMonth),
      DateTime.fromMillisecondsSinceEpoch(endOfMonth),
      type: type,
    );
  }

  Future<double> getTotalByMonth(
    int year,
    int month,
    model.TransactionType type,
  ) async {
    Database db = await database;

    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM $_transactionsTable 
      WHERE date >= ? AND date <= ? AND type = ?
    ''',
      [startOfMonth, endOfMonth, type.name],
    );

    return result[0]['total'] ?? 0.0;
  }

  // Category methods
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert(_categoriesTable, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _categoriesTable,
      orderBy: 'display_name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType({
    bool isIncomeCategory = false,
  }) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _categoriesTable,
      where: 'is_income_category = ?',
      whereArgs: [isIncomeCategory ? 1 : 0],
      orderBy: 'display_name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Category.fromMap(maps.first) : null;
  }

  Future<int> updateCategory(Category category) async {
    Database db = await database;

    // Check if another category with same display_name and is_income_category exists
    List<Map<String, dynamic>> existingCategories = await db.query(
      _categoriesTable,
      where: 'display_name = ? AND is_income_category = ? AND id != ?',
      whereArgs: [
        category.displayName,
        category.isIncomeCategory ? 1 : 0,
        category.id,
      ],
    );

    if (existingCategories.isNotEmpty) {
      throw Exception('Category with this display name already exists in the same type');
    }

    return await db.update(
      _categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    // Note: This will fail if there are transactions using this category
    // due to foreign key constraint
    return await db.delete(_categoriesTable, where: 'id = ?', whereArgs: [id]);
  }

  // Theme preference methods
  Future<ThemePreference> getThemePreference() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _themePreferencesTable,
      limit: 1,
      orderBy: 'last_updated DESC',
    );

    if (maps.isNotEmpty) {
      return ThemePreference.fromMap(maps.first);
    } else {
      // Return default theme if none exists
      final defaultTheme = ThemePreference(
        themeMode: AppThemeMode.system,
        lastUpdated: DateTime.now(),
      );
      await insertThemePreference(defaultTheme);
      return defaultTheme;
    }
  }

  Future<int> insertThemePreference(ThemePreference themePreference) async {
    Database db = await database;
    return await db.insert(_themePreferencesTable, themePreference.toMap());
  }

  Future<int> updateThemePreference(ThemePreference themePreference) async {
    Database db = await database;

    // Clear all existing preferences first (we only want one)
    await db.delete(_themePreferencesTable);

    // Insert the new preference
    return await db.insert(
      _themePreferencesTable,
      themePreference.copyWith(lastUpdated: DateTime.now()).toMap(),
    );
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final themePreference = ThemePreference(
      themeMode: themeMode,
      lastUpdated: DateTime.now(),
    );
    await updateThemePreference(themePreference);
  }

  // Language preference methods
  Future<LanguagePreference> getLanguagePreference() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      _languagePreferencesTable,
      limit: 1,
      orderBy: 'last_updated DESC',
    );

    if (maps.isNotEmpty) {
      return LanguagePreference.fromMap(maps.first);
    } else {
      // Return default language if none exists
      final defaultLanguage = LanguagePreference(
        languageCode: AppLanguage.english,
        lastUpdated: DateTime.now(),
      );
      await insertLanguagePreference(defaultLanguage);
      return defaultLanguage;
    }
  }

  Future<int> insertLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    Database db = await database;
    return await db.insert(
      _languagePreferencesTable,
      languagePreference.toMap(),
    );
  }

  Future<int> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    Database db = await database;

    // Clear all existing preferences first (we only want one)
    await db.delete(_languagePreferencesTable);

    // Insert the new preference
    return await db.insert(
      _languagePreferencesTable,
      languagePreference.copyWith(lastUpdated: DateTime.now()).toMap(),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    final languagePreference = LanguagePreference(
      languageCode: language,
      lastUpdated: DateTime.now(),
    );
    await updateLanguagePreference(languagePreference);
  }
}
