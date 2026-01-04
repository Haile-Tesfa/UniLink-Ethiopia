import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/enhanced_bottom_navbar.dart';
import '../../widgets/marketplace_item_card.dart';
import '../../models/marketplace_model.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../home/home_feed.dart';
import '../chat/chat_screen.dart';

class MarketplaceHome extends StatefulWidget {
  final int currentUserId;

  const MarketplaceHome({super.key, required this.currentUserId});

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

  RangeValues _priceRange = const RangeValues(0, 5000);

  int get _currentUserId => widget.currentUserId;

  // Using centralized API URL from constants

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
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/api/marketplace/items');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> itemsJson = data['items'] as List<dynamic>;

        setState(() {
          _items = itemsJson
              .map(
                (json) {
                  final itemJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
                  // Fix ImageUrl if it's a relative path
                  final imageUrlValue = itemJson['ImageUrl'];
                  if (imageUrlValue != null && imageUrlValue.toString().isNotEmpty) {
                    final imageUrl = imageUrlValue.toString();
                    if (!imageUrl.startsWith('http://') &&
                        !imageUrl.startsWith('https://') &&
                        !imageUrl.startsWith('assets/')) {
                      // If it starts with /, use as-is, otherwise add /
                      final fullUrl = imageUrl.startsWith('/')
                          ? '${AppConstants.apiBaseUrl}$imageUrl'
                          : '${AppConstants.apiBaseUrl}/$imageUrl';
                      itemJson['ImageUrl'] = fullUrl;
                    }
                  }
                  return MarketplaceItem.fromJson(itemJson);
                },
              )
              .toList();
          _isLoading = false;
        });
      } else {
        debugPrint('Marketplace items failed: ${response.statusCode} - ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Marketplace items error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MarketplaceItem> get _filteredItems {
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
    final scaffoldContext = context;

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
              _showFilterDialog(scaffoldContext);
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
                              _showItemDetails(item, scaffoldContext);
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeFeed(currentUserId: _currentUserId),
              ),
            );
          } else if (index == 1) {
            // already here
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(currentUserId: _currentUserId),
              ),
            );
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext scaffoldContext) {
    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter Items'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Price Range'),
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
                      onSelected: (selected) {},
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showItemDetails(MarketplaceItem item, BuildContext scaffoldContext) {
    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.8,
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
                        child: item.imageUrl.isNotEmpty && 
                               (item.imageUrl.startsWith('http://') || item.imageUrl.startsWith('https://'))
                            ? Image.network(
                                item.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, size: 50),
                                  );
                                },
                              )
                            : item.imageUrl.isNotEmpty
                                ? Image.asset(
                                    item.imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  )
                                : Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, size: 50),
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
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openMessageSeller(item, scaffoldContext);
                      },
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
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _confirmBuyNow(item, scaffoldContext);
                      },
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

  void _openMessageSeller(
      MarketplaceItem item, BuildContext scaffoldContext) {
    showModalBottomSheet(
      context: scaffoldContext,
      isScrollControlled: true,
      builder: (sheetContext) {
        final TextEditingController msgCtrl = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message ${item.sellerName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Hi, is ${item.title} still available?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = msgCtrl.text.trim();
                    if (text.isEmpty) return;

                    try {
                      final uri =
                          Uri.parse('${AppConstants.apiBaseUrl}/api/messages');
                      final body = jsonEncode({
                        'itemId': item.id,
                        'buyerId': _currentUserId,
                        'sellerId': item.sellerId,
                        'messageText': text,
                      });

                      final response = await http.post(
                        uri,
                        headers: {'Content-Type': 'application/json'},
                        body: body,
                      );

                      Navigator.pop(sheetContext);

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          const SnackBar(
                            content: Text('Message saved for seller.'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to send message: ${response.statusCode}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text('Error sending message: $e'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmBuyNow(MarketplaceItem item, BuildContext scaffoldContext) {
    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text(
            'Do you want to buy "${item.title}" for ETB ${item.price.toStringAsFixed(2)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                  const SnackBar(
                    content:
                        Text('System busy, please try again later.'),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
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
