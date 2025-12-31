class MarketplaceItem {
  final int id; // SQL ItemId
  final int sellerId;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerName;
  final String category;
  final String condition;
  final DateTime postedDate;
  final bool isNegotiable;
  final bool isFavorite;

  const MarketplaceItem({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerName,
    required this.category,
    this.condition = 'Good',
    required this.postedDate,
    this.isNegotiable = true,
    this.isFavorite = false,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['ItemId'] as int,
      sellerId: json['SellerId'] as int,
      title: json['Title'] as String,
      description: json['Description'] as String,
      price: (json['Price'] as num).toDouble(),
      imageUrl: json['ImageUrl'] as String? ?? '',
      sellerName: 'Seller #${json['SellerId']}',
      category: json['Category'] as String,
      condition: json['Condition'] as String? ?? 'Good',
      postedDate: DateTime.parse(json['PostedDate'] as String),
      isNegotiable: (json['IsNegotiable'] as bool?) ?? true,
      isFavorite: false,
    );
  }
}
