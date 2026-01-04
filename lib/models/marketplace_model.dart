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
    // Handle ItemId as either int or string (backend returns string from ObjectId)
    int itemId;
    if (json['ItemId'] is int) {
      itemId = json['ItemId'] as int;
    } else if (json['ItemId'] is String) {
      // Try to parse as int, if fails use hash code
      itemId = int.tryParse(json['ItemId'] as String) ?? (json['ItemId'] as String).hashCode;
    } else {
      itemId = 0;
    }
    
    // Handle ImageUrl - keep as is, URL construction should happen in the UI layer
    String imageUrl = json['ImageUrl'] as String? ?? '';
    
    return MarketplaceItem(
      id: itemId,
      sellerId: json['SellerId'] as int,
      title: json['Title'] as String,
      description: json['Description'] as String,
      price: (json['Price'] as num).toDouble(),
      imageUrl: imageUrl,
      sellerName: 'Seller #${json['SellerId']}',
      category: json['Category'] as String,
      condition: json['Condition'] as String? ?? 'Good',
      postedDate: DateTime.parse(json['PostedDate'] as String),
      isNegotiable: (json['IsNegotiable'] as bool?) ?? true,
      isFavorite: false,
    );
  }
}
