
class StationData {
  final String name;
  final double? pressure;
  final int? rawPumps;
  final int? treatedPumps;
  final double? level;

  StationData({
    required this.name,
    this.pressure,
    this.rawPumps,
    this.treatedPumps,
    this.level,
  });
}
