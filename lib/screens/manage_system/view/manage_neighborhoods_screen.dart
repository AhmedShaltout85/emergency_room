// lib/screens/manage_system/view/manage_neighborhoods_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/neighborhood_model.dart';
// TODO: fix these imports to your real paths
import '../control/neighborhood_provider.dart';
import '../control/handasah_provider.dart' show LoadState;
import '../../../services/connection_dialog_service.dart';

class ManageNeighborhoodsScreen extends StatefulWidget {
  const ManageNeighborhoodsScreen({super.key});

  @override
  State<ManageNeighborhoodsScreen> createState() =>
      _ManageNeighborhoodsScreenState();
}

class _ManageNeighborhoodsScreenState extends State<ManageNeighborhoodsScreen> {
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
    await context.read<NeighborhoodProvider>().loadAll();
    if (!mounted) return;
    if (context.read<NeighborhoodProvider>().failure?.isNoInternet == true) {
      _reportFailure(_load);
    }
  }

  void _reportFailure(VoidCallback retry) {
    if (!mounted) return;
    final f = context.read<NeighborhoodProvider>().failure;
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

  /// Opens the shared create / edit dialog.
  /// NOTE: dialogs are built under the root Navigator, which is ABOVE the
  /// route-scoped provider, so the data they need is passed in as arguments
  /// instead of being read with context.read.
  Future<void> _openForm({NeighborhoodModel? existing}) async {
    final p = context.read<NeighborhoodProvider>();
    final takenNames = p.items
        .where((i) => i.id != existing?.id)
        .map((i) => NeighborhoodProvider.normalizeArabic(i.neighborhoodName))
        .toSet();

    final result = await showDialog<NeighborhoodModel>(
      context: context,
      builder: (_) => _FormDialog(existing: existing, takenNames: takenNames),
    );
    if (result == null || !mounted) return;

    final provider = context.read<NeighborhoodProvider>();
    final bool ok;
    if (existing?.id != null) {
      ok = await provider.update(existing!.id!, result);
    } else {
      ok = await provider.create(result);
    }
    if (!mounted) return;
    if (ok) {
      _toast(existing == null ? 'تمت إضافة الحي' : 'تم تحديث الحي');
    } else {
      _reportFailure(() => _openForm(existing: existing));
    }
  }

  Future<void> _confirmDelete(NeighborhoodModel item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف "${item.neighborhoodName}"؟'),
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

    final done = await context.read<NeighborhoodProvider>().remove(item);
    if (!mounted) return;
    done ? _toast('تم حذف الحي') : _reportFailure(() => _confirmDelete(item));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NeighborhoodProvider>();
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الأحياء', style: TextStyle(color: Colors.indigo)),
          centerTitle: true,
          bottom: p.isBusy
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null, // ← add this to EVERY FloatingActionButton
          onPressed: p.isBusy ? null : () => _openForm(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة حي'),
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: p.setQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن حي...',
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

                // Count
                if (p.items.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Text(
                        'عدد الأحياء: ${p.filteredItems.length}'
                        '${p.filteredItems.length != p.items.length ? ' من ${p.items.length}' : ''}',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
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

  Widget _buildBody(NeighborhoodProvider p) {
    if (p.state == LoadState.loading && p.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p.state == LoadState.error && p.items.isEmpty) {
      return _StateMessage(
        icon:
            p.isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        title: p.isOffline ? 'لا يوجد اتصال بالإنترنت' : 'حدث خطأ',
        message: p.failure?.message,
        onRetry: _load,
      );
    }

    final list = p.filteredItems;
    if (list.isEmpty) {
      return _StateMessage(
        icon: Icons.search_off_rounded,
        title: p.items.isEmpty ? 'لا توجد أحياء بعد' : 'لا توجد نتائج',
        message: p.items.isEmpty ? 'اضغط "إضافة حي" للبدء' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 84,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => _NeighborhoodCard(
          item: list[i],
          onEdit: () => _openForm(existing: list[i]),
          onDelete: () => _confirmDelete(list[i]),
        ),
      ),
    );
  }
}

// ======================================================================
// Widgets
// ======================================================================

enum _CardAction { edit, delete }

class _NeighborhoodCard extends StatelessWidget {
  const _NeighborhoodCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final NeighborhoodModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_city_rounded,
                    color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.neighborhoodName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<_CardAction>(
                tooltip: 'خيارات',
                icon: Icon(Icons.more_vert_rounded, color: cs.outline),
                onSelected: (a) =>
                    a == _CardAction.edit ? onEdit() : onDelete(),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _CardAction.edit,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_rounded),
                      title: Text('تعديل'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CardAction.delete,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading:
                          Icon(Icons.delete_outline_rounded, color: cs.error),
                      title: Text('حذف', style: TextStyle(color: cs.error)),
                    ),
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

class _FormDialog extends StatefulWidget {
  const _FormDialog({this.existing, required this.takenNames});

  final NeighborhoodModel? existing;

  /// Normalized names already used by OTHER neighborhoods (duplicate check).
  final Set<String> takenNames;

  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.neighborhoodName ?? '');

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'هذا الحقل مطلوب';
    if (text.length < 2) return 'الاسم قصير جداً';
    if (widget.takenNames
        .contains(NeighborhoodProvider.normalizeArabic(text))) {
      return 'الحي موجود بالفعل';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      NeighborhoodModel(
        id: widget.existing?.id,
        neighborhoodName: _name.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(_isEdit ? 'تعديل الحي' : 'إضافة حي'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: TextFormField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'اسم الحي',
                prefixIcon: Icon(Icons.location_city_rounded),
                border: OutlineInputBorder(),
              ),
              validator: _validate,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _submit,
            child: Text(_isEdit ? 'تحديث' : 'حفظ'),
          ),
        ],
      ),
    );
  }
}
