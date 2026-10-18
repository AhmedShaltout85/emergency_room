// lib/screens/manage_system/control/users_provider.dart

import 'dart:async';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/users_repo.dart';
import 'package:flutter/foundation.dart';

import '../model/user_model.dart';

// TODO: fix these imports to your real paths
// import 'handasah_repo.dart' show AppFailure;
import 'handasah_provider.dart' show LoadState;
import '../../../services/connectivity_service.dart';

class UsersProvider extends ChangeNotifier {
  UsersProvider(this._repo, {ConnectivityService? connectivity})
      : _connectivity = connectivity ?? ConnectivityService.instance {
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  final UsersRepo _repo;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  List<UserModel> _users = [];
  String _query = '';
  int? _roleFilter; // null = all

  LoadState state = LoadState.idle;
  AppFailure? failure;
  bool isOffline = false;
  bool isBusy = false;

  List<UserModel> get users => _users;
  int? get roleFilter => _roleFilter;

  int countForRole(int? role) =>
      role == null ? _users.length : _users.where((u) => u.role == role).length;

  List<UserModel> get filteredUsers {
    final q = _query.trim().toLowerCase();
    return _users.where((u) {
      if (_roleFilter != null && u.role != _roleFilter) return false;
      if (q.isEmpty) return true;
      return u.userName.toLowerCase().contains(q) ||
          u.controlUnit.toLowerCase().contains(q) ||
          u.technicalId.toString().contains(q);
    }).toList();
  }

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void setRoleFilter(int? role) {
    _roleFilter = role;
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
      _users = await _repo.getAllUsers();
      state = LoadState.loaded;
    } on AppFailure catch (e) {
      failure = e;
      state = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> create(UserModel user) async {
    final created = await _run(() => _repo.create(user));
    if (created == null) return false;
    _users = [..._users, created];
    notifyListeners();
    return true;
  }

  Future<bool> remove(UserModel user) async {
    final id = user.id;
    if (id == null) return false;
    final result = await _run(() => _repo.remove(id));
    if (result == null) return false;
    _users = _users.where((u) => u.id != id).toList();
    notifyListeners();
    return true;
  }

  Future<List<String>?> namesByRoleAndUnit(int role, String unit) =>
      _run(() => _repo.getNamesByRoleAndControlUnit(role, unit));

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
