import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../models/budget.dart';

class DatabaseHelper {
  static const _databaseName = 'expense_tracker.db';
  static const _databaseVersion = 2;
  static const _transactionsTable = 'transactions';
  static const _categoriesTable = 'categories';
  static const _budgetsTable = 'budgets';

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
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_income_category INTEGER NOT NULL DEFAULT 0
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

    // Create budgets table
    await db.execute('''
      CREATE TABLE $_budgetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        amount REAL NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES $_categoriesTable (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to 2
      await _migrateFromV1ToV2(db);
    }
  }

  Future _insertDefaultCategories(Database db) async {
    for (Category category in DefaultCategories.allDefaultCategories) {
      await db.insert(_categoriesTable, category.toMap());
    }
  }

  Future _migrateFromV1ToV2(Database db) async {
    // Create new tables
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_income_category INTEGER NOT NULL DEFAULT 0
      )
    ''');

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

    await db.execute('''
      CREATE TABLE $_budgetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        amount REAL NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES $_categoriesTable (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // Migrate old expenses data if exists
    try {
      List<Map<String, dynamic>> oldExpenses = await db.query('expenses');
      
      for (Map<String, dynamic> expense in oldExpenses) {
        // Find matching category by name
        List<Map<String, dynamic>> categoryResult = await db.query(
          _categoriesTable,
          where: 'name = ?',
          whereArgs: [expense['category']],
          limit: 1,
        );
        
        if (categoryResult.isNotEmpty) {
          await db.insert(_transactionsTable, {
            'title': expense['title'],
            'amount': expense['amount'],
            'category_id': categoryResult.first['id'],
            'date': expense['date'],
            'description': expense['description'],
            'type': 'expense',
          });
        }
      }
      
      // Drop old table
      await db.execute('DROP TABLE IF EXISTS expenses');
    } catch (e) {
      // Old table might not exist, ignore error
    }
  }

  // Transaction methods
  Future<int> insertTransaction(model.Transaction transaction) async {
    Database db = await database;
    return await db.insert(_transactionsTable, transaction.toMap());
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.* FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      ORDER BY t.date DESC
    ''');
    
    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<List<model.Transaction>> getTransactionsByType(model.TransactionType type) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.* FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE t.type = ?
      ORDER BY t.date DESC
    ''', [type.name]);
    
    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<List<model.Transaction>> getTransactionsByCategory(Category category) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.* FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE t.category_id = ?
      ORDER BY t.date DESC
    ''', [category.id]);
    
    return List.generate(maps.length, (i) {
      Category cat = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], cat);
    });
  }

  Future<List<model.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
    {model.TransactionType? type}
  ) async {
    Database db = await database;
    
    String whereClause = 't.date >= ? AND t.date <= ?';
    List<dynamic> whereArgs = [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch];
    
    if (type != null) {
      whereClause += ' AND t.type = ?';
      whereArgs.add(type.name);
    }
    
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, c.* FROM $_transactionsTable t
      JOIN $_categoriesTable c ON t.category_id = c.id
      WHERE $whereClause
      ORDER BY t.date DESC
    ''', whereArgs);
    
    return List.generate(maps.length, (i) {
      Category category = Category.fromMap(maps[i]);
      return model.Transaction.fromMap(maps[i], category);
    });
  }

  Future<Map<Category, double>> getCategoryTotals({model.TransactionType? type}) async {
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
    return await db.delete(_transactionsTable, where: 'id = ?', whereArgs: [id]);
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
    int month, 
    {model.TransactionType? type}
  ) async {
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(year, month + 1, 1)
        .subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    return getTransactionsByDateRange(
      DateTime.fromMillisecondsSinceEpoch(startOfMonth),
      DateTime.fromMillisecondsSinceEpoch(endOfMonth),
      type: type,
    );
  }

  Future<double> getTotalByMonth(
    int year, 
    int month, 
    model.TransactionType type
  ) async {
    Database db = await database;
    
    final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(year, month + 1, 1)
        .subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $_transactionsTable 
      WHERE date >= ? AND date <= ? AND type = ?
    ''', [startOfMonth, endOfMonth, type.name]);
    
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

  Future<List<Category>> getCategoriesByType({bool isIncomeCategory = false}) async {
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

  // Budget methods
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    return await db.insert(_budgetsTable, budget.toMap());
  }

  Future<List<Budget>> getAllBudgets() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.* FROM $_budgetsTable b
      LEFT JOIN $_categoriesTable c ON b.category_id = c.id
      ORDER BY b.start_date DESC
    ''');
    
    return List.generate(maps.length, (i) {
      Category? category = maps[i]['category_id'] != null 
          ? Category.fromMap(maps[i]) 
          : null;
      return Budget.fromMap(maps[i], category);
    });
  }

  Future<List<Budget>> getActiveBudgets() async {
    Database db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, c.* FROM $_budgetsTable b
      LEFT JOIN $_categoriesTable c ON b.category_id = c.id
      WHERE b.is_active = 1 AND b.start_date <= ? AND b.end_date >= ?
      ORDER BY b.start_date DESC
    ''', [now, now]);
    
    return List.generate(maps.length, (i) {
      Category? category = maps[i]['category_id'] != null 
          ? Category.fromMap(maps[i]) 
          : null;
      return Budget.fromMap(maps[i], category);
    });
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      _budgetsTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete(_budgetsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getBudgetUsage(Budget budget) async {
    Database db = await database;
    
    String whereClause = 't.date >= ? AND t.date <= ? AND t.type = ?';
    List<dynamic> whereArgs = [
      budget.startDate.millisecondsSinceEpoch,
      budget.endDate.millisecondsSinceEpoch,
      'expense',
    ];

    if (budget.category != null) {
      whereClause += ' AND t.category_id = ?';
      whereArgs.add(budget.category!.id);
    }

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(t.amount) as total FROM $_transactionsTable t
      WHERE $whereClause
    ''', whereArgs);
    
    return result[0]['total'] ?? 0.0;
  }
}
