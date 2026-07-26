
class StationData {
  final String name;
  final double? pressure;
  final int? rawPumps;
  final int? treatedPumps;
  final double? level;
  //update-for-scada-center-emergency
  final double? desginCapacity;
  final double? actualCapacity;
  final String? location;

  StationData({
    required this.name,
    this.pressure,
    this.rawPumps,
    this.treatedPumps,
    this.level,
    //update-for-scada-center-emergency
    this.desginCapacity,
    this.actualCapacity,
    this.location,
  });
}
