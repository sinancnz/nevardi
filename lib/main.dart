import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'item.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const NeVardiApp());
}

class NeVardiApp extends StatelessWidget {
  const NeVardiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ne Vardı?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  List<Item> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _storage.load();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _storage.save(_items);
  }

  void _addItem() async {
    final result = await showDialog<Item>(
      context: context,
      builder: (_) => const AddItemDialog(),
    );
    if (result != null) {
      setState(() {
        _items.add(result);
      });
      _save();
    }
  }

  void _deleteItem(Item item) {
    setState(() {
      _items.removeWhere((i) => i.id == item.id);
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    _items.sort((a, b) => a.expiry.compareTo(b.expiry));
    return Scaffold(
      appBar: AppBar(title: const Text('Ne Vardı?')),
      body: ListView(
        children: _items.map((item) {
          final daysLeft = item.expiry.difference(DateTime.now()).inDays;
          final expired = daysLeft < 0;
          return ListTile(
            title: Text(item.name,
                style: TextStyle(
                    decoration:
                        expired ? TextDecoration.lineThrough : null)),
            subtitle: Text(
                'Miktar: ${item.quantity} · SKT: ${DateFormat.yMd().format(item.expiry)} · ${expired ? 'S Ü R E   D O L D U!' : 'Kalan: $daysLeft gün'}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteItem(item),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  DateTime _expiry = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ürün adı'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Gerekli' : null,
            ),
            TextFormField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Miktar'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Sayı gir' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('SKT: ${DateFormat.yMd().format(_expiry)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiry,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() {
                        _expiry = picked;
                      });
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final uuid = const Uuid().v4();
              Navigator.pop(
                  context,
                  Item(
                    id: uuid,
                    name: _nameController.text.trim(),
                    quantity: int.parse(_qtyController.text),
                    expiry: _expiry,
                  ));
            }
          },
          child: const Text('Ekle'),
        )
      ],
    );
  }
}
