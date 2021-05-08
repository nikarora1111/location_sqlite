import 'package:location_sqlite/model/Data.dart';

class Project{
  final String projectName;

  Project(this.projectName,);
  Map<String, dynamic> toMap() {
    return {
      'projectName' : projectName
    };
  }
}