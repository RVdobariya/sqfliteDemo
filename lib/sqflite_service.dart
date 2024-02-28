import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteService {
  final String databaseName = "user.db";

  Future<Database> initDb() async {
    final path = await getDatabasesPath();
    var paths = join(path, databaseName);
    return openDatabase(paths, version: 1, onCreate: (Database db, int i) {
      return db.execute("CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, age TEXT NOT NULL)");
    });
  }
}
