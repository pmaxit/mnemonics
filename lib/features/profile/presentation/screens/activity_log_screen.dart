import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/providers.dart';
import '../../../home/domain/review_activity.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  String _ratingFilter = 'all';
  String _dateFilter = 'all';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(reviewActivityListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: activityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(child: Text('No review activity yet.'));
          }
          final sorted = activities.toList()
            ..sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));

          // Filtering
          final now = DateTime.now();
          final filtered = sorted.where((a) {
            final matchesRating = _ratingFilter == 'all' || a.rating == _ratingFilter;
            final matchesDate = _dateFilter == 'all' ||
              (_dateFilter == 'today' && _isSameDay(a.reviewedAt, now)) ||
              (_dateFilter == 'week' && _isSameWeek(a.reviewedAt, now));
            final matchesSearch = _search.isEmpty || a.word.toLowerCase().contains(_search.toLowerCase());
            return matchesRating && matchesDate && matchesSearch;
          }).toList();

          // Stats
          final total = sorted.length;
          final hard = sorted.where((a) => a.rating == 'hard').length;
          final medium = sorted.where((a) => a.rating == 'medium').length;
          final easy = sorted.where((a) => a.rating == 'easy').length;

          // Group by date
          final grouped = <String, List<ReviewActivity>>{};
          for (final a in filtered) {
            final dateStr = _formatDate(a.reviewedAt);
            grouped.putIfAbsent(dateStr, () => []).add(a);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(total, hard, medium, easy),
                    const SizedBox(height: 8),
                    _buildFilters(),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by word',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No activity matches your filters.'))
                    : ListView(
                        children: grouped.entries.expand((entry) {
                          return [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            ...entry.value.map((activity) => ListTile(
                                  title: Text(activity.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(_formatDateTime(activity.reviewedAt)),
                                  trailing: _buildRatingChip(activity.rating),
                                )),
                          ];
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStats(int total, int hard, int medium, int easy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Total', total, Colors.blue),
        _buildStatCard('Hard', hard, Colors.redAccent),
        _buildStatCard('Medium', medium, Colors.orangeAccent),
        _buildStatCard('Easy', easy, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterChip('All', 'all', _ratingFilter == 'all', (v) => setState(() => _ratingFilter = v)),
        _buildFilterChip('Hard', 'hard', _ratingFilter == 'hard', (v) => setState(() => _ratingFilter = v), color: Colors.redAccent),
        _buildFilterChip('Medium', 'medium', _ratingFilter == 'medium', (v) => setState(() => _ratingFilter = v), color: Colors.orangeAccent),
        _buildFilterChip('Easy', 'easy', _ratingFilter == 'easy', (v) => setState(() => _ratingFilter = v), color: Colors.green),
        const SizedBox(width: 16),
        _buildFilterChip('All Dates', 'all', _dateFilter == 'all', (v) => setState(() => _dateFilter = v)),
        _buildFilterChip('Today', 'today', _dateFilter == 'today', (v) => setState(() => _dateFilter = v)),
        _buildFilterChip('This Week', 'week', _dateFilter == 'week', (v) => setState(() => _dateFilter = v)),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, bool selected, void Function(String) onSelected, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(value),
        selectedColor: (color ?? Colors.blue).withOpacity(0.15),
        labelStyle: TextStyle(color: color ?? Colors.blue),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final diff = b.difference(a).inDays;
    return diff >= 0 && diff < 7 && a.weekday <= b.weekday;
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildRatingChip(String rating) {
    Color color;
    switch (rating) {
      case 'hard':
        color = Colors.redAccent;
        break;
      case 'medium':
        color = Colors.orangeAccent;
        break;
      case 'easy':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(rating[0].toUpperCase() + rating.substring(1)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
} 