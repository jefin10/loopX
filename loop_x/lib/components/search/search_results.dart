import "package:flutter/material.dart";

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop_x/providers/search_results_providers.dart';


class SearchResultsComponent extends ConsumerWidget {
  final String query;

  const SearchResultsComponent({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(userSearchResultsProvider(query));

    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar_url'] ?? ''),
              ),
              title: Text(user['username']),
              subtitle: Text(user['bio'] ?? ''),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}