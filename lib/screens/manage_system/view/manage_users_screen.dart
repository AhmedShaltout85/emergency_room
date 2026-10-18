// lib/screens/manage_system/view/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';
// TODO: fix these imports to your real paths
import '../control/users_provider.dart';
import '../control/handasah_provider.dart' show LoadState;
import '../../../services/connection_dialog_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await context.read<UsersProvider>().loadAll();
    if (!mounted) return;
    if (context.read<UsersProvider>().failure?.isNoInternet == true) {
      _reportFailure(_load);
    }
  }

  void _reportFailure(VoidCallback retry) {
    if (!mounted) return;
    final f = context.read<UsersProvider>().failure;
    if (f == null) return;
    if (f.isNoInternet) {
      ConnectionDialogService.showNoInternetDialog(context, onRetry: retry);
    } else {
      _toast(f.message);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(msg, textAlign: TextAlign.center)),
      );
  }

  Future<void> _openDetails(UserModel user) async {
    final deleteRequested = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => _DetailsSheet(user: user),
    );
    if (deleteRequested == true && mounted) _confirmDelete(user);
  }

  Future<void> _confirmDelete(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف المستخدم "${user.userName}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;

    final done = await context.read<UsersProvider>().remove(user);
    if (!mounted) return;
    done
        ? _toast('تم حذف المستخدم')
        : _reportFailure(() => _confirmDelete(user));
  }

  Future<void> _openCreate() async {
    final user = await showDialog<UserModel>(
      context: context,
      builder: (_) => const _CreateDialog(),
    );
    if (user == null || !mounted) return;

    final ok = await context.read<UsersProvider>().create(user);
    if (!mounted) return;
    ok ? _toast('تمت إضافة المستخدم') : _reportFailure(_openCreate);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UsersProvider>();
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستخدمين', style: TextStyle(color: Colors.indigo)),
          centerTitle: true,
          bottom: p.isBusy
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: p.isBusy ? null : _openCreate,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('إضافة مستخدم'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Offline banner
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: p.isOffline
                      ? Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  color: cs.onErrorContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('لا يوجد اتصال بالإنترنت',
                                  style: TextStyle(color: cs.onErrorContainer)),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: p.setQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو الوحدة أو الرقم الوظيفي...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                p.setQuery('');
                              },
                            ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Role filter chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _roleChip(p, null, 'الكل', Icons.groups_rounded),
                      for (final r in UserRole.values)
                        _roleChip(p, r.code, r.label, r.icon),
                    ],
                  ),
                ),

                Expanded(child: _buildBody(p)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(UsersProvider p, int? role, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18),
        label: Text('$label (${p.countForRole(role)})'),
        selected: p.roleFilter == role,
        onSelected: (_) => p.setRoleFilter(role),
      ),
    );
  }

  Widget _buildBody(UsersProvider p) {
    if (p.state == LoadState.loading && p.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p.state == LoadState.error && p.users.isEmpty) {
      return _StateMessage(
        icon:
            p.isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        title: p.isOffline ? 'لا يوجد اتصال بالإنترنت' : 'حدث خطأ',
        message: p.failure?.message,
        onRetry: _load,
      );
    }

    final items = p.filteredUsers;
    if (items.isEmpty) {
      return _StateMessage(
        icon: Icons.person_search_rounded,
        title: p.users.isEmpty ? 'لا يوجد مستخدمون بعد' : 'لا توجد نتائج',
        message: p.users.isEmpty ? 'اضغط "إضافة مستخدم" للبدء' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 124,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _UserCard(
          user: items[i],
          onTap: () => _openDetails(items[i]),
        ),
      ),
    );
  }
}

// ======================================================================
// Helpers & widgets
// ======================================================================

(Color bg, Color fg) _roleColors(ColorScheme cs, UserRole? role) {
  switch (role) {
    case UserRole.controlRoom:
      return (cs.primaryContainer, cs.onPrimaryContainer);
    case UserRole.handasah:
      return (cs.tertiaryContainer, cs.onTertiaryContainer);
    case UserRole.technical:
      return (cs.secondaryContainer, cs.onSecondaryContainer);
    case null:
      return (cs.surfaceContainerHighest, cs.onSurfaceVariant);
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final role = user.roleType;
    final (bg, fg) = _roleColors(cs, role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role?.icon ?? Icons.help_outline_rounded, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            role?.label ?? 'غير معروف',
            style:
                TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = _roleColors(cs, user.roleType);
    final initial = user.userName.isEmpty
        ? '?'
        : user.userName.characters.first.toUpperCase();

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: bg,
                child: Text(initial,
                    style: TextStyle(
                        color: fg, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.controlUnit} • #${user.technicalId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    _RoleBadge(user: user),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.outline),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(user.userName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                _RoleBadge(user: user),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
                icon: Icons.apartment_rounded,
                label: 'وحدة التحكم',
                value: user.controlUnit),
            _InfoRow(
                icon: Icons.badge_rounded,
                label: 'الرقم الوظيفي',
                value: '${user.technicalId}'),
            if (user.id != null)
              _InfoRow(
                  icon: Icons.tag_rounded,
                  label: 'المعرّف',
                  value: '${user.id}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.person_remove_rounded),
                label: const Text('حذف المستخدم'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: cs.primary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _CreateDialog extends StatefulWidget {
  const _CreateDialog();

  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _controlUnit = TextEditingController();
  final _technicalId = TextEditingController();
  int _role = UserRole.technical.code;
  bool _obscure = true;

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    _controlUnit.dispose();
    _technicalId.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      UserModel(
        userName: _userName.text.trim(),
        password: _password.text,
        role: _role,
        controlUnit: _controlUnit.text.trim(),
        technicalId: int.parse(_technicalId.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة مستخدم'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _userName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'الدور',
                      prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final r in UserRole.values)
                        DropdownMenuItem(value: r.code, child: Text(r.label)),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? _role),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _controlUnit,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'وحدة التحكم',
                      prefixIcon: Icon(Icons.apartment_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _technicalId,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'الرقم الوظيفي',
                      prefixIcon: Icon(Icons.badge_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (_required(v) != null) return 'هذا الحقل مطلوب';
                      return int.tryParse(v!.trim()) == null
                          ? 'أدخل رقماً صحيحاً'
                          : null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(onPressed: _submit, child: const Text('حفظ')),
        ],
      ),
    );
  }
}
