// lib/screens/manage_system/model/approval_authority_model.dart

class ApprovalAuthorityModel {
  final int? id;
  final String approvalName;

  const ApprovalAuthorityModel({this.id, required this.approvalName});

  /// Keys assume the default Jackson names of ApprovalAuthorityDTO.
  /// Adjust them if your DTO uses different field names.
  factory ApprovalAuthorityModel.fromJson(Map<String, dynamic> json) {
    return ApprovalAuthorityModel(
      id: (json['id'] as num?)?.toInt(),
      approvalName: (json['approvalName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'approvalName': approvalName,
      };

  ApprovalAuthorityModel copyWith({int? id, String? approvalName}) =>
      ApprovalAuthorityModel(
        id: id ?? this.id,
        approvalName: approvalName ?? this.approvalName,
      );
}
