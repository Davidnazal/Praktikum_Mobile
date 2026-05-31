import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'item_model.dart';

void main() {
  runApp(MyApp());
}

// 🌙 THEME
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme(bool val) {
    setState(() => isDark = val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: ItemListPage(isDark: isDark, toggleTheme: toggleTheme),
    );
  }
}

class ItemListPage extends StatefulWidget {
  final bool isDark;
  final Function(bool) toggleTheme;

  const ItemListPage({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];

  bool _showOnlyFavorite = false;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('items');

    if (data != null) {
      List list = json.decode(data);
      _items = list.map((e) => ItemModel.fromMap(e)).toList();
    } else {
      _items = [
        ItemModel(id: 1, name: 'Laptop', description: 'Laptop gaming'),
        ItemModel(id: 2, name: 'Mouse', description: 'Mouse wireless'),
      ];
    }

    _applyFilter();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'items',
      json.encode(_items.map((e) => e.toMap()).toList()),
    );
  }

  void _applyFilter() {
    List<ItemModel> temp = _items;

    if (_showOnlyFavorite) {
      temp = temp.where((e) => e.isFavorite).toList();
    }

    if (_searchController.text.isNotEmpty) {
      temp = temp.where((e) {
        return e.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            e.description.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    setState(() => _filteredItems = temp);
  }

  void _toggleFavorite(int id) async {
    final item = _items.firstWhere((e) => e.id == id);
    item.isFavorite = !item.isFavorite;
    await _saveData();
    _applyFilter();
  }

  void _delete(int id) async {
    _items.removeWhere((e) => e.id == id);
    await _saveData();
    _applyFilter();
  }

  void _confirmDelete(ItemModel item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Konfirmasi'),
                ],
              ),
              content: Text('Anda yakin ingin menghapus "${item.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    _delete(item.id);
                  },
                  child: Text('Hapus'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog({ItemModel? item}) {
    if (item != null) {
      _nameController.text = item.name;
      _descController.text = item.description;
    } else {
      _nameController.clear();
      _descController.clear();
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: 'Deskripsi'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (item == null) {
                      int id = _items.isEmpty ? 1 : _items.last.id + 1;

                      _items.add(
                        ItemModel(
                          id: id,
                          name: _nameController.text,
                          description: _descController.text,
                        ),
                      );
                    } else {
                      item.name = _nameController.text;
                      item.description = _descController.text;
                    }

                    await _saveData();
                    Navigator.pop(context);
                    _applyFilter();
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Favorit'),
              trailing: Switch(
                value: _showOnlyFavorite,
                onChanged: (v) {
                  setState(() => _showOnlyFavorite = v);
                  _applyFilter();
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Switch(
                value: widget.isDark,
                onChanged: widget.toggleTheme,
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text('My Items'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              decoration: InputDecoration(
                hintText: 'Cari...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (_, i) {
                final item = _filteredItems[i];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      onTap: () => _showDialog(item: item),
                      title: Text(
                        item.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              item.isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => _toggleFavorite(item.id),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmDelete(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        icon: Icon(Icons.add),
        label: Text('Tambah'),
      ),
    );
  }
}
