import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/enhanced_bottom_navbar.dart';
import '../../widgets/marketplace_item_card.dart';
import '../../models/marketplace_model.dart';
import '../../utils/colors.dart';

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  int _currentIndex = 1;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Books',
    'Electronics',
    'Furniture',
    'Clothing',
    'Services',
  ];

  List<MarketplaceItem> _items = [];
  bool _isLoading = false;

  // NEW: state for price range filter
  RangeValues _priceRange = const RangeValues(0, 5000);

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For Chrome / Windows: use localhost instead of 10.0.2.2
      final uri = Uri.parse('http://localhost:5000/api/marketplace/items');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> itemsJson = data['items'] as List<dynamic>;

        setState(() {
          _items = itemsJson
              .map(
                (json) =>
                    MarketplaceItem.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // optional: show error SnackBar
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // optional: show error SnackBar
    }
  }

  List<MarketplaceItem> get _filteredItems {
    // Currently only filters by category; later you can also use _priceRange
    if (_selectedCategory == 'All') return _items;
    return _items
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  void _toggleFavorite(int itemId) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _items[index];
        _items[index] = MarketplaceItem(
          id: item.id,
          sellerId: item.sellerId,
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
                      color: _selectedCategory == category
                          ? Colors.white
                          : AppColors.textPrimary,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                // FIXED: non-const RangeSlider using state
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000,
                  divisions: 10,
                  labels: RangeLabels(
                    '${_priceRange.start.toInt()} ETB',
                    '${_priceRange.end.toInt()} ETB',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Condition'),
                Wrap(
                  spacing: 10,
                  children: ['New', 'Like New', 'Good', 'Fair'].map((cond) {
                    return FilterChip(
                      label: Text(cond),
                      selected: false,
                      onSelected: (selected) {
                        // later you can add condition filter state here
                      },
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
                // later you can apply price/condition filters here
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
