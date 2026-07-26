
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
  //last lab test values (turbidity=العكارة, residual chlorine=الكلور المتبقى)
  final double? turbidity;
  final double? residualChlorine;
  final int? labCode;

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
    this.turbidity,
    this.residualChlorine,
    this.labCode,
  });
}
