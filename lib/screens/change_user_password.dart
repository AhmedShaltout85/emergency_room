// lib/screens/manage_system/control/change_user_password.dart

import 'package:emergency_room/screens/manage_system/control/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeUserPassword extends StatefulWidget {
  const ChangeUserPassword({
    super.key,
    required this.userName,
  });

  /// The username whose password will be changed.
  /// Comes from `state.extra` (a String read from cache).
  final String userName;

  @override
  State<ChangeUserPassword> createState() => _ChangeUserPasswordState();
}

class _ChangeUserPasswordState extends State<ChangeUserPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  String? _inlineError;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _inlineError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final provider = context.read<UsersProvider>();
    final ok = await provider.changePassword(
      userName: widget.userName,
      oldPassword: _oldCtrl.text,
      newPassword: _newCtrl.text,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث كلمة المرور بنجاح',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final msg = provider.failure?.message ?? 'تعذر تحديث كلمة المرور';
      setState(() => _inlineError = msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تغيير كلمة المرور'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UserCard(userName: widget.userName),
                          const SizedBox(height: 24),
                          if (_inlineError != null) ...[
                            _ErrorBanner(
                              message: _inlineError!,
                              onDismiss: () =>
                                  setState(() => _inlineError = null),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _oldCtrl,
                            obscureText: _obscureOld,
                            enabled: !_submitting,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور الحالية',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscureOld ? 'إظهار' : 'إخفاء',
                                icon: Icon(_obscureOld
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscureOld = !_obscureOld),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'مطلوب إدخال كلمة المرور الحالية';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newCtrl,
                            obscureText: _obscureNew,
                            enabled: !_submitting,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور الجديدة',
                              prefixIcon: const Icon(Icons.lock_reset),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscureNew ? 'إظهار' : 'إخفاء',
                                icon: Icon(_obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'مطلوب إدخال كلمة المرور الجديدة';
                              }
                              if (v.length < 6) {
                                return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                              }
                              if (v == _oldCtrl.text) {
                                return 'يجب أن تكون الكلمة الجديدة مختلفة عن الحالية';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            enabled: !_submitting,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_submitting) _submit();
                            },
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور الجديدة',
                              prefixIcon:
                                  const Icon(Icons.check_circle_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirm ? 'إظهار' : 'إخفاء',
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'مطلوب تأكيد كلمة المرور';
                              }
                              if (v != _newCtrl.text) {
                                return 'كلمتا المرور غير متطابقتين';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _submitting ? null : _submit,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _submitting ? 'جارٍ الحفظ…' : 'حفظ',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ملاحظة: كلمة المرور الجديدة يجب ألا تقل عن 6 أحرف.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_submitting)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small private widgets
// ---------------------------------------------------------------------------

class _UserCard extends StatelessWidget {
  const _UserCard({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                (userName.isNotEmpty ? userName.characters.first : '?')
                    .toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تغيير كلمة المرور لهذا الحساب',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
          IconButton(
            tooltip: 'إغلاق',
            icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
