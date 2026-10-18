// lib/screens/manage_system/model/risk_status_model.dart

class RiskStatusModel {
  final int? id;
  final String riskName;

  const RiskStatusModel({this.id, required this.riskName});

  /// Keys assume the default Jackson names of RiskStatusDTO.
  /// Adjust them if your DTO uses different field names.
  factory RiskStatusModel.fromJson(Map<String, dynamic> json) {
    return RiskStatusModel(
      id: (json['id'] as num?)?.toInt(),
      riskName: (json['riskName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'riskName': riskName,
      };

  RiskStatusModel copyWith({int? id, String? riskName}) => RiskStatusModel(
        id: id ?? this.id,
        riskName: riskName ?? this.riskName,
      );
}
