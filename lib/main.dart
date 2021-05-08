import 'package:flutter/material.dart';
import 'package:location_sqlite/DataCollection.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:location_sqlite/model/Project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Project> projectList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loader();
  }

  void loader() async {
    WidgetsFlutterBinding.ensureInitialized();
    final Future<Database> projectDatabase = openDatabase(
      join(await getDatabasesPath(), 'ProjectList.db'),
      onCreate: (db, version) {
        print('DB created');
        return db.execute(
          "CREATE TABLE ProjectName(id INTEGER PRIMARY KEY, projectName TEXT)",
        );
      },
      version: 1,
    );
    print('DB Loaded');
    projectList = await projects(projectDatabase);
    setState(() {
    });
  }

  Future<List<Project>> projects(Future<Database> projectDatabase) async {
    // Get a reference to the database.
    final Database db = await projectDatabase;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('ProjectName');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Project(
        maps[i]['projectName'],
      );
    });
  }

  Future<void> insertProject(
      Project project, Future<Database> projectDatabase) async {
    // Get a reference to the database.
    final Database db = await projectDatabase;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'ProjectName',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final TextEditingController projectNameTextEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    void addProject() async {
      await showDialog(
        barrierDismissible: false,
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Enter Project Name'),
                content: TextFormField(
                  controller: projectNameTextEditingController,
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red, onPrimary: Colors.white),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          print(projectNameTextEditingController.text);
                          final Future<Database> projectDatabase = openDatabase(
                            join(await getDatabasesPath(), 'ProjectList.db'),
                            onCreate: (db, version) {
                              print('DB created');
                              return db.execute(
                                "CREATE TABLE ProjectName(id INTEGER PRIMARY KEY, projectName TEXT)",
                              );
                            },
                            version: 1,
                          );
                          await insertProject(
                              Project(projectNameTextEditingController.text),
                              projectDatabase);
                          projectNameTextEditingController.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green, onPrimary: Colors.white),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                    ],
                  )
                ],
              ));
      setState(() {
        loader();
      });
    }

    return Scaffold(
      // backgroundColor: Colors.grey,
      appBar: AppBar(
        actions: [],
        title: Center(child: Text('Project Section',textScaleFactor: 1.25,)),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            shape: StadiumBorder(side: BorderSide(width: 0.75,style: BorderStyle.solid)),
            child: ListTile(
              leading: Text((index + 1).toString(), textScaleFactor: 2),
              title: Text(
                projectList[index].projectName,
                textScaleFactor: 2,
              ),
              trailing: Icon(Icons.navigate_next),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return DataCollection(projectList[index].projectName);
                }));
              },
            ),
          )
        ),
        itemCount: projectList.length,
        padding: EdgeInsets.all(15),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProject,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
//
// Location location = new Location();
//
// bool _serviceEnabled;
// PermissionStatus _permissionGranted;
// LocationData _locationData;
//
// _serviceEnabled = await location.serviceEnabled();
// if (!_serviceEnabled) {
// _serviceEnabled = await location.requestService();
// if (!_serviceEnabled) {
// return;
// }
// }
//
// _permissionGranted = await location.hasPermission();
// if (_permissionGranted == PermissionStatus.denied) {
// _permissionGranted = await location.requestPermission();
// if (_permissionGranted != PermissionStatus.granted) {
// return;
// }
// }
//
// _locationData = await location.getLocation();
// print(_locationData.toString());
// print(_locationData.time);
// var dateUtc = DateTime.fromMillisecondsSinceEpoch(
//   _locationData.time.toInt(),
// );
// print(dateUtc);
// var dateInMyTimezone = dateUtc.add(Duration(hours: 8));
// var secondsOfDay = dateInMyTimezone.hour * 3600 +
//     dateInMyTimezone.minute * 60 +
//     dateInMyTimezone.second;
//
