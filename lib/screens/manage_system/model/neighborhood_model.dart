// lib/screens/manage_system/model/neighborhood_model.dart

class NeighborhoodModel {
  final int? id;
  final String neighborhoodName;

  const NeighborhoodModel({this.id, required this.neighborhoodName});

  /// Keys assume the default Jackson names of NeighborhoodDTO.
  /// Adjust them if your DTO uses different field names.
  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    return NeighborhoodModel(
      id: (json['id'] as num?)?.toInt(),
      neighborhoodName: (json['neighborhoodName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'neighborhoodName': neighborhoodName,
      };

  NeighborhoodModel copyWith({int? id, String? neighborhoodName}) =>
      NeighborhoodModel(
        id: id ?? this.id,
        neighborhoodName: neighborhoodName ?? this.neighborhoodName,
      );
}
