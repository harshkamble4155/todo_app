import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as p;
import 'package:todo_app/models/todo_model.dart';

class DbHelper {
  final _dbName = 'todo.db';
  final _dbVersion = 1;

  final tblName = 'tbl_Todo';
  final col_id = 'id';
  final col_title = 'title';
  final col_desc = 'description';
  final col_type = 'type';

  DbHelper._privateConstructor();

  static final DbHelper instance = DbHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    String path = p.join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tblName (
        $col_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $col_title TEXT NOT NULL,
        $col_desc TEXT NOT NULL,
        $col_type TEXT NOT NULL
      )
      ''');
  }

  Future<int> insertTodo(TodoModel todoModel) async {
    Database db = await instance.database;
    return await db.insert(tblName, todoModel.toJson());
  }

  Future<List<Map<String, dynamic>>> fetchTodo() async {
    Database db = await instance.database;
    return await db.query(tblName);
  }

  Future<int> updateTodo(Map<String, dynamic> row, int i) async {
    Database db = await instance.database;
    return await db.update(tblName, row, where: "$col_id = ?", whereArgs: [i]);
  }

  Future<int> deleteTodo(int id) async {
    Database db = await instance.database;
    return await db.delete(tblName, where: "$col_id = ?", whereArgs: [id]);
  }
}
