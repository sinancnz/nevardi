import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'item.dart';

class StorageService {
  static const _key = 'items';

  Future<List<Item>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Item.fromJson(e)).toList();
  }

  Future<void> save(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
