import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE history_devices(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      device_name TEXT,
      device_ip TEXT,
      first_connected_time DATETIME,
      last_connected_time DATETIME,
      total_connected_time,
      connected_count INTEGER,
    )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> insertDevice(sql.Database database, Map<String, dynamic> device) async {
    return await database.insert('history_devices', device);
  }

  static Future<List<Map<String, dynamic>>> getDevices(sql.Database database) async {
    return await database.query('history_devices');
  }

  static Future<int> updateDevice(sql.Database database, Map<String, dynamic> device) async {
    return await database.update('history_devices', device, where: 'id = ?', whereArgs: [device['id']]);
  }

  static Future<int> deleteDevice(sql.Database database, int id) async {
    return await database.delete('history_devices', where: 'id = ?', whereArgs: [id]);
  }
}
