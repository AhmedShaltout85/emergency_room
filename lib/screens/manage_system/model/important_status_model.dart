// lib/screens/manage_system/model/important_status_model.dart

class ImportantStatusModel {
  final int? id;
  final String importantName;

  const ImportantStatusModel({this.id, required this.importantName});

  /// Keys assume the default Jackson names of ImportantStatusDTO.
  /// Adjust them if your DTO uses different field names.
  factory ImportantStatusModel.fromJson(Map<String, dynamic> json) {
    return ImportantStatusModel(
      id: (json['id'] as num?)?.toInt(),
      importantName: (json['importantName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'importantName': importantName,
      };

  ImportantStatusModel copyWith({int? id, String? importantName}) =>
      ImportantStatusModel(
        id: id ?? this.id,
        importantName: importantName ?? this.importantName,
      );
}
