// lib/features/handasah/providers/handasah_provider.dart

import 'dart:async';
import 'package:emergency_room/screens/manage_system/model/handasah_model.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:flutter/foundation.dart';


import '../../../services/connectivity_service.dart';

enum LoadState { idle, loading, loaded, error }

class HandasahProvider extends ChangeNotifier {
  HandasahProvider(this._repo, {ConnectivityService? connectivity})
      : _connectivity = connectivity ?? ConnectivityService.instance {
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  final HandasahRepo _repo;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  List<String> _names = [];
  String _query = '';

  LoadState state = LoadState.idle;
  AppFailure? failure;
  bool isOffline = false;
  bool isBusy = false; // for create / delete / detail fetch

  List<String> get names => _names;

  List<String> get filteredNames {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _names;
    return _names.where((n) => n.toLowerCase().contains(q)).toList();
  }

  void setQuery(String value) {
    _query = value;
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
      _names = await _repo.getAllNames();
      state = LoadState.loaded;
    } on AppFailure catch (e) {
      failure = e;
      state = LoadState.error;
    }
    notifyListeners();
  }

  Future<HandasahModel?> getByName(String name) =>
      _run(() => _repo.findByName(name));

  Future<bool> create(HandasahModel model) async {
    final created = await _run(() => _repo.create(model));
    if (created == null) return false;
    _names = [..._names, created.handasahName];
    notifyListeners();
    return true;
  }

  Future<bool> remove(HandasahModel model) async {
    final id = model.id;
    if (id == null) return false;
    final result = await _run(() => _repo.remove(id));
    if (result == null) return false;
    _names = _names.where((n) => n != model.handasahName).toList();
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

  /// Runs a mutation/fetch with connectivity check + busy flag.
  /// Returns null on failure (the reason is in [failure]).
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
    // Auto-reload when the connection comes back after a failed load.
    if (online && wasOffline && state == LoadState.error) loadAll();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
