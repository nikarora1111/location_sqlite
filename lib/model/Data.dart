class Data{
  final int dateTime;
  final double longitude;
  final double latitude;

  Data(this.dateTime, this.longitude, this.latitude);
  Map<String, dynamic> toMap() {
    return {
      'dateTime' : dateTime,
      'longitude' : longitude,
      'latitude' : latitude
    };
  }
}