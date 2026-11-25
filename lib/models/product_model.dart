class Product {
  final int productId;
  final String name;
  final double price;
  final int stock;
  final bool active;
  final String categoryName;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.active,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      active: json['active'] ?? true,
      categoryName: json['category'] != null
          ? (json['category']['category'] ?? 'Sin categoría')
          : 'Sin categoría',
    );
  }
}