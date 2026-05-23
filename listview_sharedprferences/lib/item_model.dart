class ItemModel {
  final int id;
  String name;
  String description;
  bool isFavorite;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isFavorite': isFavorite,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
