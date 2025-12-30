class MarketplaceItem {
  final String id;
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
}