import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  
  final List<String> categories = ['All', 'People', 'Posts', 'Marketplace', 'Events'];
  
  final List<Map<String, dynamic>> recentSearches = [
    {'text': 'Study Group', 'type': 'Posts'},
    {'text': 'John Doe', 'type': 'People'},
    {'text': 'Calculus Book', 'type': 'Marketplace'},
  ];
  
  final List<Map<String, dynamic>> trending = [
    {'title': '#ExamPrep2024', 'count': '245 posts'},
    {'title': '#CampusEvent', 'count': '120 posts'},
    {'title': '#StudyBuddy', 'count': '89 posts'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search posts, people, items...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
              const SizedBox(height: 20),
              
              if (_searchController.text.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recentSearches.map((search) => ListTile(
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(search['text']),
                      subtitle: Text(search['type']),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {},
                      ),
                    )).toList(),
                    
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Trending Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...trending.map((trend) => Card(
                      child: ListTile(
                        title: Text(trend['title']),
                        subtitle: Text(trend['count']),
                        trailing: const Icon(Icons.trending_up),
                      ),
                    )).toList(),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results for "${_searchController.text}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/profile/prof_1.jpg'),
                            ),
                            title: const Text('John Doe'),
                            subtitle: const Text('Computer Science, Year 3'),
                            trailing: TextButton(
                              onPressed: () {},
                              child: const Text('Follow'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}