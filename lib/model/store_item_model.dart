// class StoreItemModel {
//   final double itemId;
//   final String itemName;
//   final double quantity;
//   final String date;

//   StoreItemModel({
//     required this.itemId,
//     required this.itemName,
//     required this.quantity,
//     required this.date,
//   });
  
// }

class StoreItemModel {
  final int itemNumber;
  final String itemName;
  final int quantity;
  final String date;

  StoreItemModel({
    required this.itemNumber,
    required this.itemName,
    required this.quantity,
    required this.date,
  });

  factory StoreItemModel.fromJson(Map<String, dynamic> json) {
    return StoreItemModel(
      itemNumber: json['itemId'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      date: json['date'],
    );
  }
}
