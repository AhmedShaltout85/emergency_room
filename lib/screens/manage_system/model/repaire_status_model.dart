// lib/screens/manage_system/model/repaire_status_model.dart

class RepaireStatusModel {
  final int? id;
  final String repaireType;

  const RepaireStatusModel({this.id, required this.repaireType});

  /// Keys assume the default Jackson names of RepaireStatusDTO.
  /// Adjust them if your DTO uses different field names.
  factory RepaireStatusModel.fromJson(Map<String, dynamic> json) {
    return RepaireStatusModel(
      id: (json['id'] as num?)?.toInt(),
      repaireType: (json['repaireType'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'repaireType': repaireType,
      };

  RepaireStatusModel copyWith({int? id, String? repaireType}) =>
      RepaireStatusModel(
        id: id ?? this.id,
        repaireType: repaireType ?? this.repaireType,
      );
}
