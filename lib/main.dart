import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflitedemo/sqflite_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController name = TextEditingController();
  TextEditingController age = TextEditingController();
  ScrollController scroll = ScrollController();
  late Database database;
  List<Map<String, dynamic>> userData = [];
  int upDateId = 0;
  bool isUpdate = false;
  int offset = 0;

  @override
  void initState() {
    () async {
      database = await SqfliteService().initDb();
      var data = await database.query("user", limit: 10, offset: offset);
      userData = List<Map<String, dynamic>>.from(data);
      scroll.addListener(() async {
        if (scroll.position.pixels == scroll.position.maxScrollExtent) {
          debugPrint("scroll full");
          List<Map<String, dynamic>> data = await database.query("user", limit: 10, offset: offset + 10);
          List<Map<String, dynamic>> map = List<Map<String, dynamic>>.from(data);

          for (var element in map) {
            userData.add(element);
          }
          offset = offset + 10;
          debugPrint("offset === ${offset}");
          setState(() {});
        }
      });
      setState(() {});
    }();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: name,
              decoration: InputDecoration(hintText: "Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(100))),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: age,
              decoration: InputDecoration(hintText: "Age", border: OutlineInputBorder(borderRadius: BorderRadius.circular(100))),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                if (isUpdate) {
                  // int count = await database.rawUpdate("UPDATE user SET age = ${age.text.toString()} WHERE id = ${upDateId}");
                  int count = await database.update("user", {"name": name.text, "age": age.text}, where: "id = $upDateId");
                  debugPrint("updated count == $count");
                  name.clear();
                  age.clear();
                  upDateId = 0;
                  isUpdate = false;
                  userData.clear();
                  List<Map<String, dynamic>> data = await database.query("user", limit: offset, offset: 0);
                  userData = List<Map<String, dynamic>>.from(data);
                  setState(() {});
                } else {
                  database.rawInsert("INSERT INTO user (name,age) VALUES ('${name.text}','${age.text}')");
                  name.clear();
                  age.clear();
                  List<Map<String, dynamic>> data = await database.query("user");
                  userData = List<Map<String, dynamic>>.from(data);
                  setState(() {});
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.yellow,
                ),
                child: Text(
                  isUpdate ? "Update" : "Add",
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                // userData = await database.query("user", limit: 5, offset: 6);
                debugPrint("print data");
                List<Map<String, dynamic>> data = await database.rawQuery("SELECT * FROM user WHERE name = '${name.text}'");
                userData = List<Map<String, dynamic>>.from(data);
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.yellow,
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            expand()
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget expand() {
    return Expanded(
        child: Container(
      color: Colors.black.withOpacity(0.1),
      child: ListView.builder(
        controller: scroll,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(userData[index]['name'].toString()),
            subtitle: Text(userData[index]['age'].toString()),
            trailing: SizedBox(
              width: 50,
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () async {
                        database.rawDelete("DELETE FROM user WHERE id = ${userData[index]['id']}");
                        userData = await database.query("user");
                        setState(() {});
                      },
                      child: const Icon(Icons.delete)),
                  GestureDetector(
                      onTap: () async {
                        name.text = userData[index]['name'];
                        age.text = userData[index]['age'];
                        upDateId = userData[index]['id'];
                        isUpdate = true;
                        setState(() {});
                      },
                      child: const Icon(Icons.update)),
                ],
              ),
            ),
          );
        },
        itemCount: userData.length,
      ),
    ));
  }
}
