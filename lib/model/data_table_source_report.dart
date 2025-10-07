class ApiListModel<T> {
  final List<T> items;
  final int totalCount;

  ApiListModel({required this.items, required this.totalCount});

  factory ApiListModel.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiListModel(
      items: (json['data'] as List).map((item) => fromJson(item)).toList(),
      totalCount: json['total_count'] ?? 0,
    );
  }
}

