// lib/screens/manage_system/control/risk_status_provider.dart

import 'dart:async';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/risk_status_repo.dart';
import 'package:flutter/foundation.dart';

import '../model/risk_status_model.dart';

import 'handasah_provider.dart' show LoadState;
import '../../../services/connectivity_service.dart';

class RiskStatusProvider extends ChangeNotifier {
  RiskStatusProvider(this._repo, {ConnectivityService? connectivity})
      : _connectivity = connectivity ?? ConnectivityService.instance {
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  final RiskStatusRepo _repo;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  List<RiskStatusModel> _items = [];
  String _query = '';

  LoadState state = LoadState.idle;
  AppFailure? failure;
  bool isOffline = false;
  bool isBusy = false;

  List<RiskStatusModel> get items => _items;

  /// Arabic-aware search: ignores tashkeel/tatweel and treats
  /// أ إ آ ا, ى ي and ة ه as the same letters.
  static String normalizeArabic(String s) => s
      .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .toLowerCase()
      .trim();

  List<RiskStatusModel> get filteredItems {
    final q = normalizeArabic(_query);
    if (q.isEmpty) return _items;
    return _items
        .where((i) => normalizeArabic(i.riskName).contains(q))
        .toList();
  }

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------- loads

  Future<void> loadAll() async {
    state = LoadState.loading;
    failure = null;
    notifyListeners();

    if (!await _ensureOnline()) {
      state = LoadState.error;
      notifyListeners();
      return;
    }

    try {
      _items = await _repo.getAll();
      state = LoadState.loaded;
    } on AppFailure catch (e) {
      failure = e;
      state = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> create(RiskStatusModel model) async {
    final created = await _run(() => _repo.create(model));
    if (created == null) return false;
    _items = [..._items, created];
    notifyListeners();
    return true;
  }

  Future<bool> update(int id, RiskStatusModel model) async {
    final updated = await _run(() => _repo.update(id, model));
    if (updated == null) return false;
    _items =
        _items.map((i) => i.id == id ? updated.copyWith(id: id) : i).toList();
    notifyListeners();
    return true;
  }

  Future<bool> remove(RiskStatusModel model) async {
    final id = model.id;
    if (id == null) return false;
    final result = await _run(() => _repo.remove(id));
    if (result == null) return false;
    _items = _items.where((i) => i.id != id).toList();
    notifyListeners();
    return true;
  }

  // -------------------------------------------------------------- helpers

  Future<bool> _ensureOnline() async {
    final online = await _connectivity.hasConnection();
    isOffline = !online;
    if (!online) failure = AppFailure.noInternet();
    return online;
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    failure = null;
    if (!await _ensureOnline()) {
      notifyListeners();
      return null;
    }
    isBusy = true;
    notifyListeners();
    try {
      return await action();
    } on AppFailure catch (e) {
      failure = e;
      return null;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _onConnectivityChanged(bool online) {
    final wasOffline = isOffline;
    isOffline = !online;
    notifyListeners();
    if (online && wasOffline && state == LoadState.error) loadAll();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
