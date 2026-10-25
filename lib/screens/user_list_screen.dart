import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';
import 'add_edit_user_screen.dart';
import 'chat_screen.dart';
import 'user_detail_screen.dart';

enum SortOption { none, nameAsc, district }

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<UserModel>> _usersFuture;
  List<UserModel> _allUsers = [];
  String _searchQuery = '';
  SortOption _sortOption = SortOption.none;
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAllUsers().then((users) {
      _allUsers = users;
      return users;
    });
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = ApiService.getAllUsers().then((users) {
        _allUsers = users;
        return users;
      });
    });
  }

  List<UserModel> get _visibleUsers {
    final query = _searchQuery.toLowerCase();
    final users = _allUsers.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.district.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.toLowerCase().contains(query);
    }).toList();

    if (_sortOption == SortOption.nameAsc) {
      users.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (_sortOption == SortOption.district) {
      users.sort(
        (a, b) => a.district.toLowerCase().compareTo(b.district.toLowerCase()),
      );
    }
    return users;
  }

  Future<void> _goToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditUserScreen()),
    );
    if (result == true && mounted) _loadUsers();
  }

  Future<void> _goToDetailScreen(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
    );
    if (result == true && mounted) _loadUsers();
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (!_selectedIds.add(id)) _selectedIds.remove(id);
    });
  }

  Future<void> _confirmAndDelete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete volunteer?'),
        content: Text('Remove ${user.name} from the directory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || user.id == null) return;

    try {
      await ApiService.deleteUser(user.id!);
      if (mounted) _loadUsers();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected volunteers?'),
        content: Text('This will remove $count people from the directory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      for (final id in _selectedIds.toList()) {
        await ApiService.deleteUser(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$count volunteers deleted')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        _toggleSelectionMode();
        _loadUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const BrandMark(
              size: 38,
              background: Colors.white,
              foreground: AppColors.emerald,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TLP Admin',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'TEHREEK-E-LABBAIK PAKISTAN',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 9,
                      letterSpacing: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_selectionMode)
            IconButton(
              tooltip: 'Information assistant',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
            ),
          IconButton(
            tooltip: _selectionMode ? 'Exit selection' : 'Select volunteers',
            onPressed: _toggleSelectionMode,
            icon: Icon(
              _selectionMode ? Icons.close_rounded : Icons.checklist_rounded,
            ),
          ),
          if (!_selectionMode)
            IconButton(
              tooltip: 'Refresh directory',
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 500;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, compact ? 12 : 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Volunteer directory',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (!compact) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your people and local teams',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!_selectionMode)
                            FilledButton.icon(
                              onPressed: _goToAddScreen,
                              icon: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 18,
                              ),
                              label: const Text('Add volunteer'),
                            ),
                        ],
                      ),
                      if (!compact) const SizedBox(height: 20),
                      if (!compact)
                        FutureBuilder<List<UserModel>>(
                          future: _usersFuture,
                          builder: (context, snapshot) {
                            final count = snapshot.hasData
                                ? snapshot.data!.length
                                : null;
                            final districtCount = snapshot.hasData
                                ? snapshot.data!
                                      .map(
                                        (user) =>
                                            user.district.trim().toLowerCase(),
                                      )
                                      .where((district) => district.isNotEmpty)
                                      .toSet()
                                      .length
                                : null;

                            return Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    icon: Icons.groups_2_outlined,
                                    label: 'Volunteers',
                                    value: count?.toString() ?? '—',
                                    accent: AppColors.emerald,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryCard(
                                    icon: Icons.location_on_outlined,
                                    label: 'Districts',
                                    value: districtCount?.toString() ?? '—',
                                    accent: AppColors.gold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      SizedBox(height: compact ? 8 : 18),
                      if (!_selectionMode)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value.trim()),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search name, district, phone or email',
                                  prefixIcon: Icon(Icons.search_rounded),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            PopupMenuButton<SortOption>(
                              tooltip: 'Sort directory',
                              initialValue: _sortOption,
                              onSelected: (value) =>
                                  setState(() => _sortOption = value),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: SortOption.none,
                                  child: Text('Recently added'),
                                ),
                                PopupMenuItem(
                                  value: SortOption.nameAsc,
                                  child: Text('Name A–Z'),
                                ),
                                PopupMenuItem(
                                  value: SortOption.district,
                                  child: Text('District'),
                                ),
                              ],
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: const Icon(Icons.tune_rounded),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${_selectedIds.length} selected',
                            style: const TextStyle(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(height: compact ? 8 : 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectionMode
                                  ? 'Select people'
                                  : 'All volunteers',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${_visibleUsers.length} shown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Expanded(
                        child: FutureBuilder<List<UserModel>>(
                          future: _usersFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return _MessagePanel(
                                icon: Icons.cloud_off_rounded,
                                title: 'Could not load the directory',
                                message: snapshot.error.toString(),
                                action: FilledButton.icon(
                                  onPressed: _loadUsers,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Try again'),
                                ),
                              );
                            }

                            final users = _visibleUsers;
                            if (users.isEmpty) {
                              return _MessagePanel(
                                icon: Icons.person_search_rounded,
                                title: _allUsers.isEmpty
                                    ? 'Your directory is ready'
                                    : 'No matching volunteers',
                                message: _allUsers.isEmpty
                                    ? 'Add your first volunteer to get started.'
                                    : 'Try another name, district, phone or email.',
                                action: _allUsers.isEmpty
                                    ? FilledButton.icon(
                                        onPressed: _goToAddScreen,
                                        icon: const Icon(
                                          Icons.person_add_alt_1_rounded,
                                        ),
                                        label: const Text('Add volunteer'),
                                      )
                                    : null,
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: users.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final selected =
                                    user.id != null &&
                                    _selectedIds.contains(user.id);
                                return _VolunteerTile(
                                  user: user,
                                  selected: selected,
                                  selectionMode: _selectionMode,
                                  onTap: () {
                                    if (_selectionMode) {
                                      if (user.id != null) {
                                        _toggleSelect(user.id!);
                                      }
                                    } else {
                                      _goToDetailScreen(user);
                                    }
                                  },
                                  onEdit: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditUserScreen(
                                          existingUser: user,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) _loadUsers();
                                  },
                                  onDelete: () => _confirmAndDelete(user),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _selectionMode
          ? FloatingActionButton.extended(
              onPressed: _bulkDelete,
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text('Delete (${_selectedIds.length})'),
            )
          : null,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerTile extends StatelessWidget {
  final UserModel user;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VolunteerTile({
    required this.user,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.name.trim().isEmpty
        ? '?'
        : user.name.trim()[0].toUpperCase();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: selectionMode
            ? Checkbox(
                value: selected,
                onChanged: user.id == null ? null : (_) => onTap(),
              )
            : CircleAvatar(
                radius: 23,
                backgroundColor: AppColors.emerald.withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (user.district.isNotEmpty) user.district,
              if (user.phone.isNotEmpty) user.phone,
            ].join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
        trailing: selectionMode
            ? null
            : PopupMenuButton<String>(
                tooltip: 'Volunteer actions',
                onSelected: (action) {
                  if (action == 'edit') onEdit();
                  if (action == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: AppColors.emerald),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}
