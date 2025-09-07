// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '記帳本';

  @override
  String get home => '首頁';

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String get total => '總計';

  @override
  String get thisMonth => '本月';

  @override
  String get addTransaction => '新增交易';

  @override
  String get addIncome => '新增收入';

  @override
  String get addExpense => '新增支出';

  @override
  String get title => '標題';

  @override
  String get amount => '金額';

  @override
  String get category => '分類';

  @override
  String get description => '說明';

  @override
  String get date => '日期';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get categories => '分類管理';

  @override
  String get addCategory => '新增分類';

  @override
  String get editCategory => '編輯分類';

  @override
  String get categoryName => '分類名稱';

  @override
  String get selectIcon => '選擇圖示';

  @override
  String get selectColor => '選擇顏色';

  @override
  String get export => '匯出';

  @override
  String get import => '匯入';

  @override
  String get selectDateRange => '選擇日期範圍';

  @override
  String get startDate => '開始日期';

  @override
  String get endDate => '結束日期';

  @override
  String get exportData => '匯出資料';

  @override
  String get importData => '匯入資料';

  @override
  String get selectFile => '選擇檔案';

  @override
  String get settings => '設定';

  @override
  String get theme => '主題';

  @override
  String get language => '語言';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get system => '系統';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get pleaseEnterTitle => '請輸入標題';

  @override
  String get pleaseEnterAmount => '請輸入金額';

  @override
  String get pleaseEnterValidAmount => '請輸入有效金額';

  @override
  String get pleaseSelectCategory => '請選擇分類';

  @override
  String get food => '飲食';

  @override
  String get clothing => '服飾';

  @override
  String get housing => '居住';

  @override
  String get transportation => '交通';

  @override
  String get education => '教育';

  @override
  String get entertainment => '娛樂';

  @override
  String get salary => '薪資';

  @override
  String get business => '事業';

  @override
  String get investment => '投資';

  @override
  String get gift => '禮品';

  @override
  String get other => '其他';

  @override
  String get noExpensesYet => '尚無支出記錄';

  @override
  String get noIncomeYet => '尚無收入記錄';

  @override
  String get tapPlusToStart => '點擊 + 按鈕開始記帳';

  @override
  String get net => '淨額';

  @override
  String get manageCategories => '分類管理';

  @override
  String get iconColor => '圖示與顏色';

  @override
  String get deleteConfirmTitle => '刪除交易';

  @override
  String deleteConfirmMessage(String title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String deleteCategoryMessage(String categoryName) {
    return '確定要刪除「$categoryName」分類嗎？';
  }

  @override
  String get categoryDeletedSuccess => '分類刪除成功';

  @override
  String failedToDeleteCategory(String error) {
    return '刪除分類失敗：$error';
  }

  @override
  String get noCategoriesYet => '尚無分類';

  @override
  String get update => '更新';

  @override
  String get displayName => '顯示名稱';

  @override
  String get importInstructions => '匯入說明';

  @override
  String get selectCSVFormat => '請選擇符合以下格式的 CSV 檔案：';

  @override
  String get dateFormat => '日期：yyyy-MM-dd 格式（例如：2024-01-15）';

  @override
  String get titleFormat => '標題：交易說明';

  @override
  String get amountFormat => '金額：正數（例如：85.50）';

  @override
  String get typeFormat => '類型：INCOME 或 EXPENSE';

  @override
  String get categoryFormat => '分類：必須與現有分類名稱相符';

  @override
  String get descriptionFormat => '說明：選填項目';

  @override
  String get importNote => '注意：所有有效的交易將被匯入。請確保您的 CSV 資料準確無誤。';

  @override
  String get sampleCSVFormat => '範例 CSV 格式';

  @override
  String get copy => '複製';

  @override
  String get selectCSVFile => '選擇 CSV 檔案';

  @override
  String get importing => '匯入中...';

  @override
  String get importResult => '匯入結果';

  @override
  String get successfullyImported => '成功匯入';

  @override
  String get transactions => '筆交易';

  @override
  String get errorsEncountered => '發生錯誤';

  @override
  String get rows => '筆資料';

  @override
  String get errors => '錯誤：';

  @override
  String get done => '完成';

  @override
  String importSuccessMessage(int count) {
    return '成功匯入 $count 筆交易';
  }

  @override
  String importFailedMessage(int count) {
    return '匯入失敗，有 $count 個錯誤';
  }

  @override
  String importFailedWithError(String error) {
    return '匯入失敗：$error';
  }

  @override
  String get sampleCSVCopied => '範例 CSV 已複製到剪貼簿';

  @override
  String get exportSummary => '匯出摘要';

  @override
  String get period => '期間';

  @override
  String get totalTransactions => '總交易數';

  @override
  String get totalIncome => '總收入';

  @override
  String get totalExpenses => '總支出';

  @override
  String get netBalance => '淨餘額';

  @override
  String get selectDateRangeToSee => '選擇日期範圍以查看摘要';

  @override
  String get selectStartDate => '選擇開始日期';

  @override
  String get selectEndDate => '選擇結束日期';

  @override
  String get exporting => '匯出中...';

  @override
  String get exportAndShareCSV => '匯出並分享 CSV';

  @override
  String errorLoadingSummary(String error) {
    return '載入摘要時發生錯誤：$error';
  }

  @override
  String get pleaseSelectDates => '請選擇開始日期和結束日期';

  @override
  String get endDateAfterStart => '結束日期必須晚於開始日期';

  @override
  String get csvExportedSuccessfully => 'CSV 匯出並分享成功！';

  @override
  String exportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get noTransactionsFound => '在所選日期範圍內未找到交易記錄';

  @override
  String get exportContent => '匯出內容';

  @override
  String failedToShareFile(String error) {
    return '分享檔案失敗：$error';
  }

  @override
  String get csvContent => 'CSV 內容：';

  @override
  String get close => '關閉';

  @override
  String expenseTrackerExport(String fileName) {
    return '記帳本匯出 - $fileName';
  }

  @override
  String get financialDataExport => '財務資料匯出';

  @override
  String get editTransaction => '編輯交易';

  @override
  String get expenseTransaction => '支出交易';

  @override
  String get incomeTransaction => '收入交易';

  @override
  String get titleHint => '例如：午餐費用';

  @override
  String get amountHint => '0.00';

  @override
  String get selectCategory => '選擇分類';

  @override
  String get descriptionOptional => '說明（選填）';

  @override
  String get addNotesHint => '為此交易添加備註';

  @override
  String get preview => '預覽';

  @override
  String get transactionTitle => '交易標題';

  @override
  String errorLoadingCategories(String error) {
    return '載入分類時發生錯誤：$error';
  }

  @override
  String errorSavingTransaction(String error) {
    return '儲存交易時發生錯誤：$error';
  }

  @override
  String get incomeCategory => '收入分類';

  @override
  String get expenseCategory => '支出分類';

  @override
  String get displayNameHint => '例如：飲食消費';

  @override
  String get pleaseEnterDisplayName => '請輸入顯示名稱';

  @override
  String get internalName => '內部名稱';

  @override
  String get internalNameHint => '例如：food_dining';

  @override
  String get internalNameHelper => '內部使用，若留空將自動生成';

  @override
  String get icon => '圖示';

  @override
  String get tapToChange => '點擊修改';

  @override
  String get color => '顏色';

  @override
  String errorSavingCategory(String error) {
    return '儲存分類時發生錯誤：$error';
  }

  @override
  String get defaultCategory => '預設分類';

  @override
  String get customCategory => '自訂分類';

  @override
  String deleteConfirmCategory(String categoryName) {
    return '確定要刪除「$categoryName」嗎？';
  }

  @override
  String failedToDeleteCategoryError(String error) {
    return '刪除分類失敗：$error';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '記帳本';

  @override
  String get home => '首頁';

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String get total => '總計';

  @override
  String get thisMonth => '本月';

  @override
  String get addTransaction => '新增交易';

  @override
  String get addIncome => '新增收入';

  @override
  String get addExpense => '新增支出';

  @override
  String get title => '標題';

  @override
  String get amount => '金額';

  @override
  String get category => '分類';

  @override
  String get description => '說明';

  @override
  String get date => '日期';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get categories => '分類管理';

  @override
  String get addCategory => '新增分類';

  @override
  String get editCategory => '編輯分類';

  @override
  String get categoryName => '分類名稱';

  @override
  String get selectIcon => '選擇圖示';

  @override
  String get selectColor => '選擇顏色';

  @override
  String get export => '匯出';

  @override
  String get import => '匯入';

  @override
  String get selectDateRange => '選擇日期範圍';

  @override
  String get startDate => '開始日期';

  @override
  String get endDate => '結束日期';

  @override
  String get exportData => '匯出資料';

  @override
  String get importData => '匯入資料';

  @override
  String get selectFile => '選擇檔案';

  @override
  String get settings => '設定';

  @override
  String get theme => '主題';

  @override
  String get language => '語言';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get system => '系統';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get pleaseEnterTitle => '請輸入標題';

  @override
  String get pleaseEnterAmount => '請輸入金額';

  @override
  String get pleaseEnterValidAmount => '請輸入有效金額';

  @override
  String get pleaseSelectCategory => '請選擇分類';

  @override
  String get food => '飲食';

  @override
  String get clothing => '服飾';

  @override
  String get housing => '居住';

  @override
  String get transportation => '交通';

  @override
  String get education => '教育';

  @override
  String get entertainment => '娛樂';

  @override
  String get salary => '薪資';

  @override
  String get business => '事業';

  @override
  String get investment => '投資';

  @override
  String get gift => '禮品';

  @override
  String get other => '其他';

  @override
  String get noExpensesYet => '尚無支出記錄';

  @override
  String get noIncomeYet => '尚無收入記錄';

  @override
  String get tapPlusToStart => '點擊 + 按鈕開始記帳';

  @override
  String get net => '淨額';

  @override
  String get manageCategories => '分類管理';

  @override
  String get iconColor => '圖示與顏色';

  @override
  String get deleteConfirmTitle => '刪除交易';

  @override
  String deleteConfirmMessage(String title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String deleteCategoryMessage(String categoryName) {
    return '確定要刪除「$categoryName」分類嗎？';
  }

  @override
  String get categoryDeletedSuccess => '分類刪除成功';

  @override
  String failedToDeleteCategory(String error) {
    return '刪除分類失敗：$error';
  }

  @override
  String get noCategoriesYet => '尚無分類';

  @override
  String get update => '更新';

  @override
  String get displayName => '顯示名稱';

  @override
  String get importInstructions => '匯入說明';

  @override
  String get selectCSVFormat => '請選擇符合以下格式的 CSV 檔案：';

  @override
  String get dateFormat => '日期：yyyy-MM-dd 格式（例如：2024-01-15）';

  @override
  String get titleFormat => '標題：交易說明';

  @override
  String get amountFormat => '金額：正數（例如：85.50）';

  @override
  String get typeFormat => '類型：INCOME 或 EXPENSE';

  @override
  String get categoryFormat => '分類：必須與現有分類名稱相符';

  @override
  String get descriptionFormat => '說明：選填項目';

  @override
  String get importNote => '注意：所有有效的交易將被匯入。請確保您的 CSV 資料準確無誤。';

  @override
  String get sampleCSVFormat => '範例 CSV 格式';

  @override
  String get copy => '複製';

  @override
  String get selectCSVFile => '選擇 CSV 檔案';

  @override
  String get importing => '匯入中...';

  @override
  String get importResult => '匯入結果';

  @override
  String get successfullyImported => '成功匯入';

  @override
  String get transactions => '筆交易';

  @override
  String get errorsEncountered => '發生錯誤';

  @override
  String get rows => '筆資料';

  @override
  String get errors => '錯誤：';

  @override
  String get done => '完成';

  @override
  String importSuccessMessage(int count) {
    return '成功匯入 $count 筆交易';
  }

  @override
  String importFailedMessage(int count) {
    return '匯入失敗，有 $count 個錯誤';
  }

  @override
  String importFailedWithError(String error) {
    return '匯入失敗：$error';
  }

  @override
  String get sampleCSVCopied => '範例 CSV 已複製到剪貼簿';

  @override
  String get exportSummary => '匯出摘要';

  @override
  String get period => '期間';

  @override
  String get totalTransactions => '總交易數';

  @override
  String get totalIncome => '總收入';

  @override
  String get totalExpenses => '總支出';

  @override
  String get netBalance => '淨餘額';

  @override
  String get selectDateRangeToSee => '選擇日期範圍以查看摘要';

  @override
  String get selectStartDate => '選擇開始日期';

  @override
  String get selectEndDate => '選擇結束日期';

  @override
  String get exporting => '匯出中...';

  @override
  String get exportAndShareCSV => '匯出並分享 CSV';

  @override
  String errorLoadingSummary(String error) {
    return '載入摘要時發生錯誤：$error';
  }

  @override
  String get pleaseSelectDates => '請選擇開始日期和結束日期';

  @override
  String get endDateAfterStart => '結束日期必須晚於開始日期';

  @override
  String get csvExportedSuccessfully => 'CSV 匯出並分享成功！';

  @override
  String exportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get noTransactionsFound => '在所選日期範圍內未找到交易記錄';

  @override
  String get exportContent => '匯出內容';

  @override
  String failedToShareFile(String error) {
    return '分享檔案失敗：$error';
  }

  @override
  String get csvContent => 'CSV 內容：';

  @override
  String get close => '關閉';

  @override
  String expenseTrackerExport(String fileName) {
    return '記帳本匯出 - $fileName';
  }

  @override
  String get financialDataExport => '財務資料匯出';

  @override
  String get editTransaction => '編輯交易';

  @override
  String get expenseTransaction => '支出交易';

  @override
  String get incomeTransaction => '收入交易';

  @override
  String get titleHint => '例如：午餐費用';

  @override
  String get amountHint => '0.00';

  @override
  String get selectCategory => '選擇分類';

  @override
  String get descriptionOptional => '說明（選填）';

  @override
  String get addNotesHint => '為此交易添加備註';

  @override
  String get preview => '預覽';

  @override
  String get transactionTitle => '交易標題';

  @override
  String errorLoadingCategories(String error) {
    return '載入分類時發生錯誤：$error';
  }

  @override
  String errorSavingTransaction(String error) {
    return '儲存交易時發生錯誤：$error';
  }

  @override
  String get incomeCategory => '收入分類';

  @override
  String get expenseCategory => '支出分類';

  @override
  String get displayNameHint => '例如：飲食消費';

  @override
  String get pleaseEnterDisplayName => '請輸入顯示名稱';

  @override
  String get internalName => '內部名稱';

  @override
  String get internalNameHint => '例如：food_dining';

  @override
  String get internalNameHelper => '內部使用，若留空將自動生成';

  @override
  String get icon => '圖示';

  @override
  String get tapToChange => '點擊修改';

  @override
  String get color => '顏色';

  @override
  String errorSavingCategory(String error) {
    return '儲存分類時發生錯誤：$error';
  }

  @override
  String get defaultCategory => '預設分類';

  @override
  String get customCategory => '自訂分類';

  @override
  String deleteConfirmCategory(String categoryName) {
    return '確定要刪除「$categoryName」嗎？';
  }

  @override
  String failedToDeleteCategoryError(String error) {
    return '刪除分類失敗：$error';
  }
}
