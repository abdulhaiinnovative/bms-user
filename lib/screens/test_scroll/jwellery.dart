class Item {
  final String name;
  final String description;
  final double price;
  final String image;

  Item({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
    );
  }
}

class CategoryJwellary {
  final String name;
  final List<Item> items;

  CategoryJwellary({
    required this.name,
    required this.items,
  });

  factory CategoryJwellary.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<Item> itemList = itemsList.map((i) => Item.fromJson(i)).toList();

    return CategoryJwellary(
      name: json['category'],
      items: itemList,
    );
  }
}
