// lib/features/handasah/models/handasah_model.dart

class HandasahModel {
  final int? id;
  final String handasahName;
  final String storeName;
  final int storeNumber;

  const HandasahModel({
    this.id,
    required this.handasahName,
    required this.storeName,
    required this.storeNumber,
  });

  /// Keys assume the default Jackson names of PickLocationHandasahDTO.
  /// Adjust them if your DTO uses different field names.
  factory HandasahModel.fromJson(Map<String, dynamic> json) {
    return HandasahModel(
      id: (json['id'] as num?)?.toInt(),
      handasahName: (json['handasahName'] ?? '').toString(),
      storeName: (json['storeName'] ?? '').toString(),
      storeNumber: (json['storeNumber'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'handasahName': handasahName,
        'storeName': storeName,
        'storeNumber': storeNumber,
      };

  HandasahModel copyWith({
    int? id,
    String? handasahName,
    String? storeName,
    int? storeNumber,
  }) =>
      HandasahModel(
        id: id ?? this.id,
        handasahName: handasahName ?? this.handasahName,
        storeName: storeName ?? this.storeName,
        storeNumber: storeNumber ?? this.storeNumber,
      );
}
