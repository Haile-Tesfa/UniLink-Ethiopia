import 'package:flutter/material.dart';
import '../../widgets/enhanced_bottom_navbar.dart';
import '../../widgets/marketplace_item_card.dart';
import '../../models/marketplace_model.dart'; // Add this import
import '../../utils/colors.dart';

// REMOVE this entire class definition:
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

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  int _currentIndex = 1;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Books', 'Electronics', 'Furniture', 'Clothing', 'Services'];
  
  List<MarketplaceItem> _items = []; // Now uses the shared model
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _items = [
        MarketplaceItem(
          id: '1',
          title: 'Scientific Calculator',
          description: 'Texas Instruments scientific calculator, barely used',
          price: 1500.0,
          imageUrl: 'assets/images/marketplace/item_0.jpg',
          sellerName: 'Meklit Desalegn',
          category: 'Electronics',
          condition: 'Like New',
          postedDate: DateTime.now().subtract(const Duration(days: 2)),
          isFavorite: false,
        ),
        MarketplaceItem(
          id: '2',
          title: 'Textbooks Bundle',
          description: 'Engineering textbooks bundle for 2nd year',
          price: 2500.0,
          imageUrl: 'assets/images/marketplace/item_1.jpg',
          sellerName: 'Abebe Kebede',
          category: 'Books',
          condition: 'Good',
          postedDate: DateTime.now().subtract(const Duration(days: 5)),
          isFavorite: true,
        ),
        MarketplaceItem(
          id: '3',
          title: 'Desk Lamp',
          description: 'LED desk lamp with adjustable brightness',
          price: 350.0,
          imageUrl: 'assets/images/marketplace/item_2.jpg',
          sellerName: 'Sara Tesfaye',
          category: 'Electronics',
          condition: 'Excellent',
          postedDate: DateTime.now().subtract(const Duration(days: 1)),
          isFavorite: false,
        ),
        MarketplaceItem(
          id: '4',
          title: 'Study Table',
          description: 'Wooden study table with drawer',
          price: 1200.0,
          imageUrl: 'assets/images/marketplace/item_3.jpg',
          sellerName: 'John Doe',
          category: 'Furniture',
          condition: 'Good',
          postedDate: DateTime.now().subtract(const Duration(days: 3)),
          isFavorite: true,
        ),
      ];
      _isLoading = false;
    });
  }

  List<MarketplaceItem> get _filteredItems {
    if (_selectedCategory == 'All') return _items;
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  void _toggleFavorite(String itemId) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        _items[index] = MarketplaceItem(
          id: item.id,
          title: item.title,
          description: item.description,
          price: item.price,
          imageUrl: item.imageUrl,
          sellerName: item.sellerName,
          category: item.category,
          condition: item.condition,
          postedDate: item.postedDate,
          isNegotiable: item.isNegotiable,
          isFavorite: !item.isFavorite,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(child: Text('No items found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return MarketplaceItemCard(
                            item: item,
                            onTap: () {
                              _showItemDetails(item);
                            },
                            onFavorite: () => _toggleFavorite(item.id),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: EnhancedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chat');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Items'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Price Range'),
                RangeSlider(
                  values: const RangeValues(0, 5000),
                  min: 0,
                  max: 10000,
                  divisions: 10,
                  labels: const RangeLabels('0 ETB', '5000 ETB'),
                  onChanged: (RangeValues values) {},
                ),
                const SizedBox(height: 20),
                const Text('Condition'),
                Wrap(
                  spacing: 10,
                  children: ['New', 'Like New', 'Good', 'Fair'].map((condition) {
                    return FilterChip(
                      label: Text(condition),
                      selected: false,
                      onSelected: (selected) {},
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDetails(MarketplaceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ETB ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(item.description),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Text('Seller: ${item.sellerName}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 16),
                          const SizedBox(width: 8),
                          Text('Category: ${item.category}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 16),
                          const SizedBox(width: 8),
                          Text('Condition: ${item.condition}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 8),
                          Text('Posted: ${_formatDate(item.postedDate)}'),
                        ],
                      ),
                      if (item.isNegotiable) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.money_off, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Price is negotiable',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.message),
                      label: const Text('Message Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Buy Now'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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