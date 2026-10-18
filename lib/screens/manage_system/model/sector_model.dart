// lib/screens/manage_system/model/sector_model.dart

class SectorModel {
  final int? id;
  final String sectorName;

  const SectorModel({this.id, required this.sectorName});

  /// Keys assume the default Jackson names of SectorDTO.
  /// Adjust them if your DTO uses different field names.
  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: (json['id'] as num?)?.toInt(),
      sectorName: (json['sectorName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'sectorName': sectorName,
      };

  SectorModel copyWith({int? id, String? sectorName}) => SectorModel(
        id: id ?? this.id,
        sectorName: sectorName ?? this.sectorName,
      );
}
