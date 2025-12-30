import 'package:flutter/material.dart';
import '../../models/marketplace_model.dart'; // Add this import
import '../../utils/colors.dart';

// REMOVE this entire class definition from here:
// class MarketplaceItem {
//   final String id;
//   final String title;
//   final String description;
//   final double price;
//   final String imageUrl;
//   final String sellerName;
//   final String category;
//   final String condition;
//   final DateTime postedDate;
//   final bool isNegotiable;
//   final bool isFavorite;

//   const MarketplaceItem({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.price,
//     required this.imageUrl,
//     required this.sellerName,
//     required this.category,
//     this.condition = 'Good',
//     required this.postedDate,
//     this.isNegotiable = true,
//     this.isFavorite = false,
//   });
// }

class MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item; // Now uses the model from marketplace_model.dart
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool showSeller;

  const MarketplaceItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavorite,
    this.showSeller = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    item.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        item.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: item.isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (item.isNegotiable)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Negotiable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'ETB ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (showSeller)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.sellerName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(item.postedDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Condition: ${item.condition}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7}w ago';
    } else {
      return '${difference.inDays ~/ 30}mo ago';
    }
  }
}