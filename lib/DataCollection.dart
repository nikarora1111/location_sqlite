import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:location_sqlite/model/Data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataCollection extends StatefulWidget {
  final String projectName;

  DataCollection(this.projectName);

  @override
  _DataCollectionState createState() => _DataCollectionState();
}

class _DataCollectionState extends State<DataCollection> {
  List<Data> dataList = [];
  bool isCollected = false;
  double longitude = 0.0;
  double latitude = 0.0;
  double altitude = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Loader();
  }

  void Loader() async {
    WidgetsFlutterBinding.ensureInitialized();
    final Future<Database> locationDatabase = openDatabase(
      join(await getDatabasesPath(), 'DataOf_${widget.projectName}.db'),
      onCreate: (db, version) {
        print('${widget.projectName} DB created');
        return db.execute(
          "CREATE TABLE Data(id INTEGER PRIMARY KEY, dateTime INTEGER, longitude REAL, latitude REAL)",
        );
      },
      version: 1,
    );
    print('DB Loaded');
    dataList = await projects(locationDatabase);
    setState(() {});
  }

  Future<List<Data>> projects(Future<Database> locationDatabase) async {
    // Get a reference to the database.
    final Database db = await locationDatabase;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('Data');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Data(
          maps[i]['dateTime'], maps[i]['longitude'], maps[i]['latitude']);
    });
  }

  Future<void> insertData(Data data, Future<Database> locationDatabase) async {
    // Get a reference to the database.
    final Database db = await locationDatabase;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'Data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;
    return Scaffold(
      appBar: AppBar(title: Text('Data for ${widget.projectName}')),
      body: dataList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 4, right: 4),
              child: SingleChildScrollView(
                child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(5),
                      2: FlexColumnWidth(5),
                      3: FlexColumnWidth(4),
                      4: FlexColumnWidth(4)
                    },
                    // defaultVerticalAlignment: TableCellVerticalAlignment.fill,
                    border: TableBorder(
                      verticalInside: BorderSide(width: 0.5),
                      horizontalInside: BorderSide(width: 0.5),
                      top: BorderSide(width: 0.5),
                      bottom: BorderSide(width: 0.5),
                      left: BorderSide(width: 0.5),
                      right: BorderSide(width: 0.5),
                    ),
                    children: [
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Text(
                            'S No.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Text(
                            'Longitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Text('Latitude',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Text('Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Center(
                              child: Text('Time',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        )
                      ]),
                      ...dataList
                          .map(
                            (data) => TableRow(children: [
                              // Text((index++).toString()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child:
                                    Center(child: Text((index++).toString())),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                    child: Text(data.longitude.toString())),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                    child: Text(data.latitude.toString())),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                  child: Text(DateFormat("dd-MM-yyyy").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                    data.dateTime.toInt(),
                                  ))),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Center(
                                  child: Text(DateFormat.jm().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                    data.dateTime.toInt(),
                                  ))),
                                ),
                              )
                            ]),
                          )
                          .toList()
                    ]),
              ),
            )
          : Center(
              child: Text('To collect Data please click on collect button')),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 25,
                    ),
                    Text(
                      'Cancel',
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.blue,
                      size: 25,
                    ),
                    Text('Collect', style: TextStyle(fontSize: 20))
                  ],
                ),
                onTap: () async {
                  Location location = new Location();

                  bool _serviceEnabled;
                  PermissionStatus _permissionGranted;
                  LocationData _locationData;

                  _serviceEnabled = await location.serviceEnabled();
                  if (!_serviceEnabled) {
                    _serviceEnabled = await location.requestService();
                    if (!_serviceEnabled) {
                      return;
                    }
                  }

                  _permissionGranted = await location.hasPermission();
                  if (_permissionGranted == PermissionStatus.denied) {
                    _permissionGranted = await location.requestPermission();
                    if (_permissionGranted != PermissionStatus.granted) {
                      return;
                    }
                  }

                  _locationData = await location.getLocation();

                  WidgetsFlutterBinding.ensureInitialized();
                  final Future<Database> locationDatabase = openDatabase(
                    join(await getDatabasesPath(),
                        'DataOf_${widget.projectName}.db'),
                    onCreate: (db, version) {
                      print('${widget.projectName} DB created');
                      return db.execute(
                        "CREATE TABLE Data(id INTEGER PRIMARY KEY, dateTime INTEGER, longitude REAL, latitude REAL)",
                      );
                    },
                    version: 1,
                  );
                  print('DB Loaded for collecting Data');
                  Data collectedData = Data(_locationData.time.toInt(),
                      _locationData.longitude, _locationData.latitude);
                  dataList.add(collectedData);

                  await insertData(collectedData, locationDatabase);

                  print(_locationData.toString());
                  print(_locationData.time);
                  var dateUtc = DateTime.fromMillisecondsSinceEpoch(
                    _locationData.time.toInt(),
                  );
                  print(DateFormat.jm().format(dateUtc));
                  print(DateFormat("dd-MM-yyyy").format(dateUtc));
                  setState(() {
                    isCollected = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
