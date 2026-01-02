import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/chat_message_model.dart';
import '../../utils/colors.dart';
import 'chat_screen.dart'; // for ChatDetailScreen import

class UserSearchScreen extends StatefulWidget {
  final int currentUserId;

  const UserSearchScreen({super.key, required this.currentUserId});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  static const String _baseUrl = 'http://localhost:5000';

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<UserSearchResult> _results = [];

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/api/users/search?q=$q');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['users'] as List<dynamic>? ?? [];

        setState(() {
          _results = list
              .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
              .where((u) => u.userId != widget.currentUserId)
              .toList();
        });
      } else {
        debugPrint('Search users failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Search users error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChat(UserSearchResult user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          currentUserId: widget.currentUserId,
          otherUserId: user.userId,
          userName: user.fullName,
          userImage: user.profileImageUrl ?? '',
          isGroup: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search users'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onSubmitted: _search,
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('No users'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final u = _results[index];
                      return ListTile(
                        onTap: () => _openChat(u),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          backgroundImage: u.profileImageUrl != null &&
                                  u.profileImageUrl!.isNotEmpty
                              ? NetworkImage(u.profileImageUrl!)
                              : null,
                          child: (u.profileImageUrl == null ||
                                  u.profileImageUrl!.isEmpty)
                              ? Text(
                                  u.fullName.isNotEmpty
                                      ? u.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(u.fullName),
                        subtitle: Text(u.email),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
