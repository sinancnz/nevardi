import 'dart:convert';

class Item {
  String id;
  String name;
  int quantity;
  DateTime expiry;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiry,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'],
        expiry: DateTime.parse(json['expiry']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'expiry': expiry.toIso8601String(),
      };
}
