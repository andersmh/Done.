import 'dart:io';
import '../model/item.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/*
  Auther: Anders Mæhlum Halvorsen
*/

class DatabaseItemHelper {
  static const String tableName = "table_items";
  static const String columnId = "id";
  static const String columnItemName = "item_name";
  static const String columnDateCreated = "date_created";
  static const String columnItemDone = "item_done";

  static final DatabaseItemHelper _instance = new DatabaseItemHelper.internal();

  factory DatabaseItemHelper() => _instance;
  static Database _db;

  Future<Database> get getDb async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseItemHelper.internal();

  initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "taske_db.db");
    var dbCreated = await openDatabase(path, version: 1, onCreate: _onCreate);
    return dbCreated;
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $tableName("
        "$columnId INTEGER PRIMARY KEY, "
        "$columnItemName TEXT, "
        "$columnDateCreated TEXT,"
        "$columnItemDone INTEGER);");
  }

  Future<int> saveItem(Item item) async {
    var dbClient = await getDb;
    int rowsSaved = await dbClient.insert(tableName, item.toMap());
    return rowsSaved;
  }

  Future<List> getItems() async {
    var dbClient = await getDb;
    var result = await dbClient
        .rawQuery("SELECT * FROM $tableName ORDER BY $columnItemDone ASC");
    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await getDb;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT (*) FROM $tableName"));
  }

  Future<Item> getItem(int itemId) async {
    var dbClient = await getDb;
    var item = await dbClient
        .rawQuery("SELECT * FROM $tableName WHERE $columnId=$itemId");
    if (item.length == 0) return null;
    return new Item.fromMap(item.first);
  }

  Future<int> deleteItem(int id) async {
    var db = await getDb;
    int rowsDeleted =
        await db.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
    return rowsDeleted;
  }

  Future<int> updateItem(Item item) async {
    int id = item.id;
    print("id of the item is $id");
    var db = await getDb;
    int rowsUpdated = await db.update("$tableName", item.toMap(),
        where: "$columnId  = ?", whereArgs: [item.id]);
    return rowsUpdated;
  }

  Future close() async {
    var dbClient = await getDb;
    dbClient.close();
  }
}
