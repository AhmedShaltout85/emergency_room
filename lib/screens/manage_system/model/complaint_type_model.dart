// lib/screens/manage_system/model/complaint_type_model.dart

class ComplaintTypeModel {
  final int? id;
  final String complaintName;

  const ComplaintTypeModel({this.id, required this.complaintName});

  /// Keys assume the default Jackson names of ComplaintTypeDTO.
  /// Adjust them if your DTO uses different field names.
  factory ComplaintTypeModel.fromJson(Map<String, dynamic> json) {
    return ComplaintTypeModel(
      id: (json['id'] as num?)?.toInt(),
      complaintName: (json['complaintName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'complaintName': complaintName,
      };

  ComplaintTypeModel copyWith({int? id, String? complaintName}) =>
      ComplaintTypeModel(
        id: id ?? this.id,
        complaintName: complaintName ?? this.complaintName,
      );
}
