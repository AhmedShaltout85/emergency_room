// lib/features/handasah/screens/handasah_screen.dart

import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
import 'package:emergency_room/screens/manage_system/model/handasah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../services/connection_dialog_service.dart';

class ManageHandasahScreen extends StatefulWidget {
  const ManageHandasahScreen({super.key});

  @override
  State<ManageHandasahScreen> createState() => _ManageHandasahScreenState();
}

class _ManageHandasahScreenState extends State<ManageHandasahScreen> {
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
    await context.read<HandasahProvider>().loadAll();
    if (!mounted) return;
    final f = context.read<HandasahProvider>().failure;
    if (f?.isNoInternet == true) _reportFailure(_load);
  }

  /// Shows the shared no-internet dialog, or a snackbar for other errors.
  void _reportFailure(VoidCallback retry) {
    if (!mounted) return;
    final f = context.read<HandasahProvider>().failure;
    if (f == null) return;
    if (f.isNoInternet) {
      ConnectionDialogService.showNoInternetDialog(context, onRetry: retry);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(f.message),
        ));
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              msg,
              textAlign: TextAlign.center,
            )),
      );
  }

  Future<void> _openDetails(String name) async {
    final p = context.read<HandasahProvider>();
    final model = await p.getByName(name);
    if (!mounted) return;
    if (model == null) {
      _reportFailure(() => _openDetails(name));
      return;
    }

    final deleteRequested = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => _DetailsSheet(model: model),
    );

    if (deleteRequested == true && mounted) _confirmDelete(model);
  }

  Future<void> _confirmDelete(HandasahModel model) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف "${model.handasahName}"؟'),
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

    final done = await context.read<HandasahProvider>().remove(model);
    if (!mounted) return;
    done
        ? _toast('تم الحذف بنجاح')
        : _reportFailure(() => _confirmDelete(model));
  }

  Future<void> _openCreate() async {
    final model = await showDialog<HandasahModel>(
      context: context,
      builder: (_) => const _CreateDialog(),
    );
    if (model == null || !mounted) return;

    final ok = await context.read<HandasahProvider>().create(model);
    if (!mounted) return;
    ok ? _toast('تمت الإضافة بنجاح') : _reportFailure(_openCreate);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HandasahProvider>();
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الهندسات', style: TextStyle(color: Colors.indigo)),
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
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة هندسة'),
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
                      hintText: 'ابحث عن هندسة...',
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

                Expanded(child: _buildBody(p)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(HandasahProvider p) {
    if (p.state == LoadState.loading && p.names.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p.state == LoadState.error && p.names.isEmpty) {
      return _StateMessage(
        icon:
            p.isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        title: p.isOffline ? 'لا يوجد اتصال بالإنترنت' : 'حدث خطأ',
        message: p.failure?.message,
        onRetry: _load,
      );
    }

    final items = p.filteredNames;
    if (items.isEmpty) {
      return _StateMessage(
        icon: Icons.search_off_rounded,
        title: p.names.isEmpty ? 'لا توجد هندسات بعد' : 'لا توجد نتائج',
        message: p.names.isEmpty ? 'اضغط "إضافة هندسة" للبدء' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        // 1 column on phones, 2-3 on tablet/web — no breakpoints needed.
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 380,
          mainAxisExtent: 80,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _HandasahCard(
          name: items[i],
          onTap: () => _openDetails(items[i]),
        ),
      ),
    );
  }
}

// ======================================================================
// Widgets
// ======================================================================

class _HandasahCard extends StatelessWidget {
  const _HandasahCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.engineering_rounded,
                    color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
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
  const _DetailsSheet({required this.model});

  final HandasahModel model;

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
            Text(model.handasahName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _InfoRow(
                icon: Icons.store_rounded,
                label: 'اسم المخزن',
                value: model.storeName),
            _InfoRow(
                icon: Icons.pin_rounded,
                label: 'رقم المخزن',
                value: '${model.storeNumber}'),
            if (model.id != null)
              _InfoRow(
                  icon: Icons.tag_rounded,
                  label: 'المعرّف',
                  value: '${model.id}'),
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
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('حذف'),
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
  final _name = TextEditingController();
  final _store = TextEditingController();
  final _number = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _store.dispose();
    _number.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      HandasahModel(
        handasahName: _name.text.trim(),
        storeName: _store.text.trim(),
        storeNumber: int.parse(_number.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إضافة هندسة'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'اسم الهندسة',
                      prefixIcon: Icon(Icons.engineering_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _store,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'اسم المخزن',
                      prefixIcon: Icon(Icons.store_rounded),
                      border: OutlineInputBorder(),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _number,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'رقم المخزن',
                      prefixIcon: Icon(Icons.pin_rounded),
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
