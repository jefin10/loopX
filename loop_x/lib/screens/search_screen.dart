import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop_x/providers/search_provider.dart';
import 'package:loop_x/providers/search_results_providers.dart';
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeQuery = ''; // Track the current search query

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _activeQuery = query; // Update the active query
    });
    await ref
        .read(searchHistoryControllerProvider)
        .addSearch(query);
  }
  void _clearSearch() {
  setState(() {
    _activeQuery = '';
  });
  _searchController.clear();
}
  void _deleteSearch(int id) async {
    await ref.read(searchHistoryControllerProvider).deleteSearch(id);
  }

  @override
  Widget build(BuildContext context) {
    final searchHistoryAsync = ref.watch(searchHistoryProvider);
    
    // Only watch search results when we have an active query
    final searchResultsAsync = _activeQuery.isNotEmpty 
        ? ref.watch(userSearchResultsProvider(_activeQuery))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          if (_activeQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _handleSearch,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 32.0,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _activeQuery.isNotEmpty
                  ? _buildSearchResults(searchResultsAsync)
                  : _buildSearchHistory(searchHistoryAsync),
            ),
          ],
        ),
      ),
    );
  }

  // Extract search results widget
  Widget _buildSearchResults(AsyncValue<List<Map<String, dynamic>>>? resultsAsync) {
    if (resultsAsync == null) {
      return const Center(child: Text("Enter a search query"));
    }
    
    return resultsAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text("No users found"));
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? Text((user['username'] as String).isNotEmpty 
                        ? (user['username'] as String)[0].toUpperCase()
                        : '?')
                    : null,
              ),
              title: Text(user['username'] ?? 'Unknown'),
              onTap: () {
                context.push(
                  '/profile/${user['id']}',
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  // Extract search history widget
  Widget _buildSearchHistory(AsyncValue<List<Map<String, dynamic>>> historyAsync) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text("No search history"));
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              title: Text(item['query']),
              subtitle: Text(item['searched_at']),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _deleteSearch(item['id']),
              ),
              onTap: () {
                // Fill search field with history item
                _searchController.text = item['query'];
                _handleSearch();
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
