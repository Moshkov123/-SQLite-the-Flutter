import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(
    home: LocalDatabase(),
  ));
}

class LocalDatabase extends StatefulWidget {
  const LocalDatabase({Key? key}) : super(key: key);

  @override
  _LocalDatabaseState createState() => _LocalDatabaseState();
}

class _LocalDatabaseState extends State<LocalDatabase> {
  late Database database;
  final String tableName = 'student_table';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sqlite CRUD Operations"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text;
                int age = int.tryParse(ageController.text) ?? 0;
                await insertData(name, age);
                print('Data Inserted: $name, $age');
              },
              child: Text('Insert Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                var data = await fetchData();
                print('Fetched Data: $data');
              },
              child: Text('Fetch Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateData(2, 'Tom');
                print('Data Updated');
              },
              child: Text('Update Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteData(1);
                print('Data Deleted');
              },
              child: Text('Delete Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> initializeDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, 'student_database.db');
    database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE $tableName (
          id INTEGER PRIMARY KEY,
          name TEXT,
          age INTEGER
        )
      ''');
    });
  }

  Future<void> insertData(String name, int age) async {
    await database.insert(tableName, {'name': name, 'age': age}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Future<void> deleteData(int id) async {
  //   await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
  // }
  Future<void> deleteData(int id) async {
    var lastEntry = await database.rawQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1');
    if (lastEntry.isNotEmpty) {
      Object? lastEntryId = lastEntry.first['id'];
      await database.delete(tableName, where: 'id = ?', whereArgs: [lastEntryId]);
      print('Last Entry Deleted');
    } else {
      print('Database is empty. No entries to delete.');
    }
  }

  Future<void> updateData(int id, String s) async {
    await database.update(tableName, {'name': s}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    return await database.query(tableName);
  }
}
