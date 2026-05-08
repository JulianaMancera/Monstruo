import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/watchlist_provider.dart';
import '../models/watchlist_model.dart';
import '../../pet/providers/pet_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _tabKeys   = ['watching', 'want', 'completed', 'dropped'];
  static const _tabLabels = ['👁 Watching', '⭐ Want', '✅ Done', '💀 Dropped'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byStatus = ref.watch(watchlistByStatusProvider);
    final all      = ref.watch(watchlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Track It',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('The List',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 24)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.secondary.withOpacity(0.3)),
                    ),
                    child: Text('${all.length} items',
                        style: const TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: _tabKeys.map((status) {
                  final items = byStatus[status] ?? [];
                  return _ItemList(
                    items: items,
                    status: status,
                    onStatusChange: _changeStatus,
                    onDelete: (item) =>
                        ref.read(watchlistProvider.notifier).deleteItem(item),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add to List',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _changeStatus(WatchlistItem item, String newStatus) async {
    final earnedXp = await ref
        .read(watchlistProvider.notifier)
        .updateStatus(item, newStatus);
    if (earnedXp) {
      await ref
          .read(petProvider.notifier)
          .awardXp(AppConstants.xpWatchlistComplete);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Completed! +${AppConstants.xpWatchlistComplete} XP ⚡'),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddItemSheet(ref: ref),
    );
  }
}

// ─── Item List (per tab) ─────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final List<WatchlistItem> items;
  final String status;
  final Future<void> Function(WatchlistItem, String) onStatusChange;
  final void Function(WatchlistItem) onDelete;

  const _ItemList({
    required this.items,
    required this.status,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_emptyEmoji(status),
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(_emptyMessage(status),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => _ItemCard(
        item: items[i],
        onStatusChange: onStatusChange,
        onDelete: onDelete,
      ),
    );
  }

  String _emptyEmoji(String s) {
    switch (s) {
      case 'watching':  return '📺';
      case 'want':      return '⭐';
      case 'completed': return '✅';
      case 'dropped':   return '💀';
      default:          return '🎬';
    }
  }

  String _emptyMessage(String s) {
    switch (s) {
      case 'watching':  return 'Nothing in progress.\nStart something!';
      case 'want':      return 'Your list is empty.\nAdd something!';
      case 'completed': return 'Nothing completed yet.\nFinish something!';
      case 'dropped':   return 'Nothing dropped.\nYou\'re on a roll!';
      default:          return 'Nothing here yet.';
    }
  }
}

// ─── Item Card ───────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final WatchlistItem item;
  final Future<void> Function(WatchlistItem, String) onStatusChange;
  final void Function(WatchlistItem) onDelete;

  static const _mediaEmojis = {
    'show':  '📺',
    'anime': '🎌',
    'movie': '🎬',
    'book':  '📚',
    'game':  '🎮',
  };

  static const _statusColors = {
    'watching':  AppTheme.primary,
    'want':      AppTheme.accent,
    'completed': AppTheme.success,
    'dropped':   AppTheme.danger,
  };

  static const _statusLabels = {
    'watching':  '👁 Watching',
    'want':      '⭐ Want',
    'completed': '✅ Done',
    'dropped':   '💀 Dropped',
  };

  static const _otherStatuses = {
    'watching':  ['want', 'completed', 'dropped'],
    'want':      ['watching', 'completed', 'dropped'],
    'completed': ['watching', 'want', 'dropped'],
    'dropped':   ['want', 'watching', 'completed'],
  };

  const _ItemCard(
      {required this.item,
      required this.onStatusChange,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color      = _statusColors[item.status] ?? AppTheme.primary;
    final mediaEmoji = _mediaEmojis[item.mediaType] ?? '🎬';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      onDismissed: (_) => onDelete(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceLight),
        ),
        child: Row(
          children: [
            Text(mediaEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            GestureDetector(
              onTap: () => _showStatusPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                    _statusLabels[item.status] ?? item.status,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final others = _otherStatuses[item.status] ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move "${item.title}" to...',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...others.map((s) {
              final c = _statusColors[s] ?? AppTheme.primary;
              return ListTile(
                leading: Text(_statusLabels[s] ?? s,
                    style: TextStyle(
                        color: c, fontWeight: FontWeight.w700)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  onStatusChange(item, s);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Add Item Sheet ──────────────────────────────────────────────

class _AddItemSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddItemSheet({required this.ref});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _ctrl   = TextEditingController();
  String _type   = 'show';
  String _status = 'want';

  static const _types = [
    {'key': 'show',  'label': '📺 Show'},
    {'key': 'anime', 'label': '🎌 Anime'},
    {'key': 'movie', 'label': '🎬 Movie'},
    {'key': 'book',  'label': '📚 Book'},
    {'key': 'game',  'label': '🎮 Game'},
  ];

  static const _statuses = [
    {'key': 'want',      'label': '⭐ Want'},
    {'key': 'watching',  'label': '👁 Watching'},
    {'key': 'completed', 'label': '✅ Done'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add to List',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Title...'),
          ),
          const SizedBox(height: 16),

          Text('Type', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _types.map((t) {
              final isSelected = _type == t['key'];
              return ChoiceChip(
                label: Text(t['label']!),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _type = t['key']!),
                selectedColor: AppTheme.primary.withOpacity(0.25),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
                side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : Colors.transparent),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text('Status',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _statuses.map((s) {
              final isSelected = _status == s['key'];
              return ChoiceChip(
                label: Text(s['label']!),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _status = s['key']!),
                selectedColor: AppTheme.secondary.withOpacity(0.25),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.secondary
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
                side: BorderSide(
                    color: isSelected
                        ? AppTheme.secondary
                        : Colors.transparent),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Add ✨'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    widget.ref.read(watchlistProvider.notifier).addItem(
        title: title, mediaType: _type, status: _status);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
