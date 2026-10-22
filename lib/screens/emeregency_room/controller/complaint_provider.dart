// // lib/screens/manage_system/control/complaint_provider.dart

// import 'dart:async';
// import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
// import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
// import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
// import 'package:flutter/foundation.dart';

// import '../model/complaint_model.dart';

// import '../../../services/connectivity_service.dart';

// class ComplaintProvider extends ChangeNotifier {
//   ComplaintProvider(
//     this._repo, {
//     ConnectivityService? connectivity,
//     this.sortNewestFirst = true,
//   }) : _connectivity = connectivity ?? ConnectivityService.instance {
//     _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
//   }

//   /// true  → [visibleComplaints] is sorted newest first.
//   /// false → keeps the order the server returned (oldest first, usually).
//   final bool sortNewestFirst;

//   final ComplaintRepo _repo;
//   final ConnectivityService _connectivity;
//   StreamSubscription<bool>? _sub;

//   List<ComplaintModel> _items = [];

//   /// Remembers the last list request so a reconnect reloads the SAME list
//   /// (e.g. open complaints) instead of silently switching to "all".
//   Future<List<ComplaintModel>> Function()? _lastFetch;
//   bool _disposed = false;

//   // Local (client-side) filters applied on top of whatever list is loaded.
//   String _query = '';
//   String? _statusFilter; // complaintStatus
//   String? _neighborhoodFilter;
//   String? _typeFilter; // complaintType
//   String? _sectorFilter; // sectorName
//   bool? _finishedFilter; // null = all
//   bool _trackedOnly = false;
//   bool _showDeleted = false; // soft-deleted complaints are hidden by default

//   LoadState state = LoadState.idle;
//   AppFailure? failure;
//   bool isOffline = false;
//   bool isBusy = false;

//   // -------------------------------------------------------------- getters

//   /// Everything currently loaded (unfiltered).
//   List<ComplaintModel> get items => _items;

//   String get query => _query;
//   String? get statusFilter => _statusFilter;
//   String? get neighborhoodFilter => _neighborhoodFilter;
//   String? get typeFilter => _typeFilter;
//   String? get sectorFilter => _sectorFilter;
//   bool? get finishedFilter => _finishedFilter;
//   bool get trackedOnly => _trackedOnly;
//   bool get showDeleted => _showDeleted;

//   /// Arabic-aware: ignores tashkeel/tatweel and treats أ إ آ ا, ى ي and ة ه
//   /// as the same letters.
//   static String normalizeArabic(String s) => s
//       .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
//       .replaceAll(RegExp('[أإآٱ]'), 'ا')
//       .replaceAll('ى', 'ي')
//       .replaceAll('ة', 'ه')
//       .toLowerCase()
//       .trim();

//   /// Filtered + sorted (newest first) list for the UI.
//   List<ComplaintModel> get visibleComplaints {
//     final q = normalizeArabic(_query);
//     final list = _items.where((c) {
//       if (!_showDeleted && c.deleted) return false;
//       if (_statusFilter != null && c.complaintStatus != _statusFilter) {
//         return false;
//       }
//       if (_neighborhoodFilter != null &&
//           c.neighborhood != _neighborhoodFilter) {
//         return false;
//       }
//       if (_typeFilter != null && c.complaintType != _typeFilter) return false;
//       if (_sectorFilter != null && c.sectorName != _sectorFilter) return false;
//       if (_finishedFilter != null && c.finished != _finishedFilter)
//         return false;
//       if (_trackedOnly && !c.tracked) return false;
//       if (q.isEmpty) return true;
//       final haystack = normalizeArabic([
//         c.reporterName,
//         c.reporterPhone,
//         c.complaintAddress,
//         c.complaintNote,
//         c.neighborhood,
//         c.complaintType,
//         '${c.reportNumber ?? ''}',
//         '${c.complaintId ?? ''}',
//       ].join(' '));
//       return haystack.contains(q);
//     }).toList();

//     if (sortNewestFirst) {
//       list.sort((a, b) {
//         final da = a.createdAtDate, db = b.createdAtDate;
//         if (da != null && db != null) return db.compareTo(da);
//         return (b.complaintId ?? 0).compareTo(a.complaintId ?? 0);
//       });
//     }
//     return list;
//   }

//   // Distinct values for building filter dropdowns / chips.
//   List<String> get neighborhoods => _distinct((c) => c.neighborhood);
//   List<String> get statuses => _distinct((c) => c.complaintStatus);
//   List<String> get types => _distinct((c) => c.complaintType);
//   List<String> get sectors => _distinct((c) => c.sectorName);

//   List<String> _distinct(String Function(ComplaintModel) pick) {
//     final set = <String>{};
//     for (final c in _items) {
//       final v = pick(c).trim();
//       if (v.isNotEmpty) set.add(v);
//     }
//     return set.toList()..sort();
//   }

//   int get totalCount => _items.where((c) => !c.deleted).length;
//   int get finishedCount => _items.where((c) => !c.deleted && c.finished).length;
//   int get openCount => totalCount - finishedCount;
//   int get trackedCount => _items.where((c) => !c.deleted && c.tracked).length;

//   // ------------------------------------------------------ local filters

//   void setQuery(String v) {
//     _query = v;
//     notifyListeners();
//   }

//   void setStatusFilter(String? v) {
//     _statusFilter = v;
//     notifyListeners();
//   }

//   void setNeighborhoodFilter(String? v) {
//     _neighborhoodFilter = v;
//     notifyListeners();
//   }

//   void setTypeFilter(String? v) {
//     _typeFilter = v;
//     notifyListeners();
//   }

//   void setSectorFilter(String? v) {
//     _sectorFilter = v;
//     notifyListeners();
//   }

//   void setFinishedFilter(bool? v) {
//     _finishedFilter = v;
//     notifyListeners();
//   }

//   void setTrackedOnly(bool v) {
//     _trackedOnly = v;
//     notifyListeners();
//   }

//   void setShowDeleted(bool v) {
//     _showDeleted = v;
//     notifyListeners();
//   }

//   void clearFilters() {
//     _query = '';
//     _statusFilter = null;
//     _neighborhoodFilter = null;
//     _typeFilter = null;
//     _sectorFilter = null;
//     _finishedFilter = null;
//     _trackedOnly = false;
//     notifyListeners();
//   }

//   // ------------------------------------------------------------- loading

//   Future<void> loadAll() => _loadList(_repo.getAll);

//   /// Repeats the last list request (falls back to "all").
//   Future<void> reload() => _loadList(_lastFetch ?? _repo.getAll);

//   // Server-side finders: these REPLACE the loaded list with the server's
//   // result. Call loadAll() to get everything back.
//   Future<void> loadByNeighborhood(String v) =>
//       _loadList(() => _repo.findByNeighborhood(v));
//   Future<void> loadByStatus(String v) =>
//       _loadList(() => _repo.findByComplaintStatus(v));
//   Future<void> loadByUser(String username) =>
//       _loadList(() => _repo.findByCurrentUsername(username));
//   Future<void> loadByFinished(bool finished) =>
//       _loadList(() => _repo.findByIsFinished(finished ? 1 : 0));
//   Future<void> loadByType(String v) =>
//       _loadList(() => _repo.findByComplaintType(v));
//   Future<void> loadBySector(String v) =>
//       _loadList(() => _repo.findBySectorName(v));

//   Future<void> _loadList(Future<List<ComplaintModel>> Function() fetch) async {
//     _lastFetch = fetch;
//     state = LoadState.loading;
//     failure = null;
//     notifyListeners();

//     if (!await _ensureOnline()) {
//       state = LoadState.error;
//       notifyListeners();
//       return;
//     }

//     try {
//       _items = await fetch();
//       state = LoadState.loaded;
//     } on AppFailure catch (e) {
//       failure = e;
//       state = LoadState.error;
//     }
//     notifyListeners();
//   }

//   /// Local copy first; falls back to the server (and caches the result).
//   Future<ComplaintModel?> getById(int id, {bool forceRefresh = false}) async {
//     if (!forceRefresh) {
//       for (final c in _items) {
//         if (c.complaintId == id) return c;
//       }
//     }
//     final fetched = await _run(() => _repo.findById(id));
//     if (fetched != null) _upsert(fetched);
//     return fetched;
//   }

//   // ----------------------------------------------------------- mutations

//   Future<bool> create(ComplaintModel complaint) async {
//     final created = await _run(() => _repo.create(complaint));
//     if (created == null) return false;
//     _items = [created, ..._items];
//     notifyListeners();
//     return true;
//   }

//   Future<bool> update(ComplaintModel complaint) {
//     final id = complaint.complaintId;
//     if (id == null) return Future.value(false);
//     return _mutate(() => _repo.update(id, complaint));
//   }

//   Future<bool> setRepeatComplaintNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateRepeatComplaintNumber(
//           c.complaintId!, c.copyWith(repeatComplaintNumber: value)));

//   Future<bool> setUrgencyNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateUrgencyNumber(
//           c.complaintId!, c.copyWith(urgencyNumber: value)));

//   Future<bool> setRecipient(
//     ComplaintModel c, {
//     required String recipientName,
//     String? recipientUser,
//   }) =>
//       _mutate(() => _repo.updateRecipient(
//             c.complaintId!,
//             c.copyWith(
//               recipientName: recipientName,
//               recipientUser: recipientUser,
//             ),
//           ));

//   Future<bool> setTracked(ComplaintModel c, bool tracked) => _mutate(() => _repo
//       .updateTracked(c.complaintId!, c.copyWith(isTracked: tracked ? 1 : 0)));

//   Future<bool> setStatusFlags(
//     ComplaintModel c, {
//     bool? finished,
//     bool? deleted,
//     bool? tracked,
//   }) =>
//       _mutate(() => _repo.updateStatusFlags(
//             c.complaintId!,
//             c.copyWith(
//               isFinished: finished == null ? null : (finished ? 1 : 0),
//               isDeleted: deleted == null ? null : (deleted ? 1 : 0),
//               isTracked: tracked == null ? null : (tracked ? 1 : 0),
//             ),
//           ));

//   Future<bool> setApprovalAuthority(ComplaintModel c, String authority) =>
//       _mutate(() => _repo.updateApprovalAuthority(
//           c.complaintId!, c.copyWith(approvalAuthority: authority)));

//   Future<bool> setRecipientDestination(ComplaintModel c, String destination) =>
//       _mutate(() => _repo.updateRecipientDestination(
//           c.complaintId!, c.copyWith(recipientDestination: destination)));

//   Future<bool> finish(ComplaintModel c) =>
//       _mutate(() => _repo.finish(c.complaintId!));

//   /// Soft delete: the server flags it; it stays in the list but is hidden
//   /// unless [showDeleted] is true.
//   Future<bool> softDelete(ComplaintModel c) =>
//       _mutate(() => _repo.softDelete(c.complaintId!));

//   /// Permanent delete.
//   Future<bool> remove(ComplaintModel c) async {
//     final id = c.complaintId;
//     if (id == null) return false;
//     final result = await _run(() => _repo.remove(id));
//     if (result == null) return false;
//     _items = _items.where((x) => x.complaintId != id).toList();
//     notifyListeners();
//     return true;
//   }

//   // ------------------------------------------------------------- helpers

//   /// Runs an update that returns the changed complaint and swaps it in.
//   Future<bool> _mutate(Future<ComplaintModel> Function() action) async {
//     final updated = await _run(action);
//     if (updated == null) return false;
//     _upsert(updated);
//     return true;
//   }

//   void _upsert(ComplaintModel updated) {
//     final idx = _items.indexWhere((c) => c.complaintId == updated.complaintId);
//     if (idx == -1) {
//       _items = [updated, ..._items];
//     } else {
//       _items = [..._items]..[idx] = updated;
//     }
//     notifyListeners();
//   }

//   Future<bool> _ensureOnline() async {
//     final online = await _connectivity.hasConnection();
//     isOffline = !online;
//     if (!online) failure = AppFailure.noInternet();
//     return online;
//   }

//   Future<T?> _run<T>(Future<T> Function() action) async {
//     failure = null;
//     if (!await _ensureOnline()) {
//       notifyListeners();
//       return null;
//     }
//     isBusy = true;
//     notifyListeners();
//     try {
//       return await action();
//     } on AppFailure catch (e) {
//       failure = e;
//       return null;
//     } finally {
//       isBusy = false;
//       notifyListeners();
//     }
//   }

//   void _onConnectivityChanged(bool online) {
//     final wasOffline = isOffline;
//     isOffline = !online;
//     notifyListeners();
//     if (online && wasOffline && state == LoadState.error) reload();
//   }

//   @override
//   void notifyListeners() {
//     if (!_disposed) super.notifyListeners();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _sub?.cancel();
//     super.dispose();
//   }
// }
// // lib/screens/manage_system/control/complaint_provider.dart

// import 'dart:async';
// import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
// import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
// import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
// import 'package:flutter/foundation.dart';

// import '../model/complaint_model.dart';

// import '../../../services/connectivity_service.dart';

// class ComplaintProvider extends ChangeNotifier {
//   ComplaintProvider(
//     this._repo, {
//     ConnectivityService? connectivity,
//     this.sortNewestFirst = true,
//   }) : _connectivity = connectivity ?? ConnectivityService.instance {
//     _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
//   }

//   /// true  → [visibleComplaints] is sorted newest first.
//   /// false → keeps the order the server returned (oldest first, usually).
//   final bool sortNewestFirst;

//   final ComplaintRepo _repo;
//   final ConnectivityService _connectivity;
//   StreamSubscription<bool>? _sub;

//   List<ComplaintModel> _items = [];

//   /// Remembers the last list request so a reconnect reloads the SAME list
//   /// (e.g. open complaints) instead of silently switching to "all".
//   Future<List<ComplaintModel>> Function()? _lastFetch;
//   bool _disposed = false;

//   // Local (client-side) filters applied on top of whatever list is loaded.
//   String _query = '';
//   String? _statusFilter; // complaintStatus
//   String? _neighborhoodFilter;
//   String? _typeFilter; // complaintType
//   String? _sectorFilter; // sectorName
//   bool? _finishedFilter; // null = all
//   bool _trackedOnly = false;
//   bool _showDeleted = false; // soft-deleted complaints are hidden by default

//   LoadState state = LoadState.idle;
//   AppFailure? failure;
//   bool isOffline = false;
//   bool isBusy = false;

//   // -------------------------------------------------------------- getters

//   /// Everything currently loaded (unfiltered).
//   List<ComplaintModel> get items => _items;

//   String get query => _query;
//   String? get statusFilter => _statusFilter;
//   String? get neighborhoodFilter => _neighborhoodFilter;
//   String? get typeFilter => _typeFilter;
//   String? get sectorFilter => _sectorFilter;
//   bool? get finishedFilter => _finishedFilter;
//   bool get trackedOnly => _trackedOnly;
//   bool get showDeleted => _showDeleted;

//   /// Arabic-aware: ignores tashkeel/tatweel and treats أ إ آ ا, ى ي and ة ه
//   /// as the same letters.
//   static String normalizeArabic(String s) => s
//       .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
//       .replaceAll(RegExp('[أإآٱ]'), 'ا')
//       .replaceAll('ى', 'ي')
//       .replaceAll('ة', 'ه')
//       .toLowerCase()
//       .trim();

//   /// Filtered + sorted (newest first) list for the UI.
//   List<ComplaintModel> get visibleComplaints {
//     final q = normalizeArabic(_query);
//     final list = _items.where((c) {
//       if (!_showDeleted && c.deleted) return false;
//       if (_statusFilter != null && c.complaintStatus != _statusFilter) {
//         return false;
//       }
//       if (_neighborhoodFilter != null &&
//           c.neighborhood != _neighborhoodFilter) {
//         return false;
//       }
//       if (_typeFilter != null && c.complaintType != _typeFilter) return false;
//       if (_sectorFilter != null && c.sectorName != _sectorFilter) return false;
//       if (_finishedFilter != null && c.finished != _finishedFilter)
//         return false;
//       if (_trackedOnly && !c.tracked) return false;
//       if (q.isEmpty) return true;
//       final haystack = normalizeArabic([
//         c.reporterName,
//         c.reporterPhone,
//         c.complaintAddress,
//         c.complaintNote,
//         c.neighborhood,
//         c.complaintType,
//         '${c.reportNumber ?? ''}',
//         '${c.complaintId ?? ''}',
//       ].join(' '));
//       return haystack.contains(q);
//     }).toList();

//     if (sortNewestFirst) {
//       list.sort((a, b) {
//         final da = a.createdAtDate, db = b.createdAtDate;
//         if (da != null && db != null) return db.compareTo(da);
//         return (b.complaintId ?? 0).compareTo(a.complaintId ?? 0);
//       });
//     }
//     return list;
//   }

//   // ------------------------------------------------ per-handasah helpers

//   /// A technician value that means "nobody assigned yet".
//   static bool isFreeTechnician(String value) {
//     final v = value.trim();
//     return v.isEmpty || v == 'لم يدرج' || v == 'free';
//   }

//   /// Open (not finished, not deleted) complaints sent to [destination]
//   /// (a handasah name), in the order they were loaded.
//   List<ComplaintModel> openComplaintsFor(String destination) {
//     final d = destination.trim();
//     return _items
//         .where((c) =>
//             !c.deleted && !c.finished && c.recipientDestination.trim() == d)
//         .toList();
//   }

//   /// Open complaints of [destination] that still have no technician.
//   List<ComplaintModel> unassignedComplaintsFor(String destination) =>
//       openComplaintsFor(destination)
//           .where((c) => isFreeTechnician(c.recipientUser))
//           .toList();

//   // Distinct values for building filter dropdowns / chips.
//   List<String> get neighborhoods => _distinct((c) => c.neighborhood);
//   List<String> get statuses => _distinct((c) => c.complaintStatus);
//   List<String> get types => _distinct((c) => c.complaintType);
//   List<String> get sectors => _distinct((c) => c.sectorName);

//   List<String> _distinct(String Function(ComplaintModel) pick) {
//     final set = <String>{};
//     for (final c in _items) {
//       final v = pick(c).trim();
//       if (v.isNotEmpty) set.add(v);
//     }
//     return set.toList()..sort();
//   }

//   int get totalCount => _items.where((c) => !c.deleted).length;
//   int get finishedCount => _items.where((c) => !c.deleted && c.finished).length;
//   int get openCount => totalCount - finishedCount;
//   int get trackedCount => _items.where((c) => !c.deleted && c.tracked).length;

//   // ------------------------------------------------------ local filters

//   void setQuery(String v) {
//     _query = v;
//     notifyListeners();
//   }

//   void setStatusFilter(String? v) {
//     _statusFilter = v;
//     notifyListeners();
//   }

//   void setNeighborhoodFilter(String? v) {
//     _neighborhoodFilter = v;
//     notifyListeners();
//   }

//   void setTypeFilter(String? v) {
//     _typeFilter = v;
//     notifyListeners();
//   }

//   void setSectorFilter(String? v) {
//     _sectorFilter = v;
//     notifyListeners();
//   }

//   void setFinishedFilter(bool? v) {
//     _finishedFilter = v;
//     notifyListeners();
//   }

//   void setTrackedOnly(bool v) {
//     _trackedOnly = v;
//     notifyListeners();
//   }

//   void setShowDeleted(bool v) {
//     _showDeleted = v;
//     notifyListeners();
//   }

//   void clearFilters() {
//     _query = '';
//     _statusFilter = null;
//     _neighborhoodFilter = null;
//     _typeFilter = null;
//     _sectorFilter = null;
//     _finishedFilter = null;
//     _trackedOnly = false;
//     notifyListeners();
//   }

//   // ------------------------------------------------------------- loading

//   Future<void> loadAll() => _loadList(_repo.getAll);

//   /// Repeats the last list request (falls back to "all").
//   Future<void> reload() => _loadList(_lastFetch ?? _repo.getAll);

//   // Server-side finders: these REPLACE the loaded list with the server's
//   // result. Call loadAll() to get everything back.
//   Future<void> loadByNeighborhood(String v) =>
//       _loadList(() => _repo.findByNeighborhood(v));
//   Future<void> loadByStatus(String v) =>
//       _loadList(() => _repo.findByComplaintStatus(v));
//   Future<void> loadByUser(String username) =>
//       _loadList(() => _repo.findByCurrentUsername(username));
//   Future<void> loadByFinished(bool finished) =>
//       _loadList(() => _repo.findByIsFinished(finished ? 1 : 0));
//   Future<void> loadByType(String v) =>
//       _loadList(() => _repo.findByComplaintType(v));
//   Future<void> loadBySector(String v) =>
//       _loadList(() => _repo.findBySectorName(v));

//   Future<void> _loadList(Future<List<ComplaintModel>> Function() fetch) async {
//     _lastFetch = fetch;
//     state = LoadState.loading;
//     failure = null;
//     notifyListeners();

//     if (!await _ensureOnline()) {
//       state = LoadState.error;
//       notifyListeners();
//       return;
//     }

//     try {
//       _items = await fetch();
//       state = LoadState.loaded;
//     } on AppFailure catch (e) {
//       failure = e;
//       state = LoadState.error;
//     }
//     notifyListeners();
//   }

//   /// Local copy first; falls back to the server (and caches the result).
//   Future<ComplaintModel?> getById(int id, {bool forceRefresh = false}) async {
//     if (!forceRefresh) {
//       for (final c in _items) {
//         if (c.complaintId == id) return c;
//       }
//     }
//     final fetched = await _run(() => _repo.findById(id));
//     if (fetched != null) _upsert(fetched);
//     return fetched;
//   }

//   // ----------------------------------------------------------- mutations

//   Future<bool> create(ComplaintModel complaint) async {
//     final created = await _run(() => _repo.create(complaint));
//     if (created == null) return false;
//     _items = [created, ..._items];
//     notifyListeners();
//     return true;
//   }

//   Future<bool> update(ComplaintModel complaint) {
//     final id = complaint.complaintId;
//     if (id == null) return Future.value(false);
//     return _mutate(() => _repo.update(id, complaint));
//   }

//   Future<bool> setRepeatComplaintNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateRepeatComplaintNumber(
//           c.complaintId!, c.copyWith(repeatComplaintNumber: value)));

//   Future<bool> setUrgencyNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateUrgencyNumber(
//           c.complaintId!, c.copyWith(urgencyNumber: value)));

//   Future<bool> setRecipient(
//     ComplaintModel c, {
//     required String recipientName,
//     String? recipientUser,
//   }) =>
//       _mutate(() => _repo.updateRecipient(
//             c.complaintId!,
//             c.copyWith(
//               recipientName: recipientName,
//               recipientUser: recipientUser,
//             ),
//           ));

//   Future<bool> setTracked(ComplaintModel c, bool tracked) => _mutate(() => _repo
//       .updateTracked(c.complaintId!, c.copyWith(isTracked: tracked ? 1 : 0)));

//   Future<bool> setStatusFlags(
//     ComplaintModel c, {
//     bool? finished,
//     bool? deleted,
//     bool? tracked,
//   }) =>
//       _mutate(() => _repo.updateStatusFlags(
//             c.complaintId!,
//             c.copyWith(
//               isFinished: finished == null ? null : (finished ? 1 : 0),
//               isDeleted: deleted == null ? null : (deleted ? 1 : 0),
//               isTracked: tracked == null ? null : (tracked ? 1 : 0),
//             ),
//           ));

//   Future<bool> setApprovalAuthority(ComplaintModel c, String authority) =>
//       _mutate(() => _repo.updateApprovalAuthority(
//           c.complaintId!, c.copyWith(approvalAuthority: authority)));

//   Future<bool> setRecipientDestination(ComplaintModel c, String destination) =>
//       _mutate(() => _repo.updateRecipientDestination(
//           c.complaintId!, c.copyWith(recipientDestination: destination)));

//   Future<bool> finish(ComplaintModel c) =>
//       _mutate(() => _repo.finish(c.complaintId!));

//   /// Soft delete: the server flags it; it stays in the list but is hidden
//   /// unless [showDeleted] is true.
//   Future<bool> softDelete(ComplaintModel c) =>
//       _mutate(() => _repo.softDelete(c.complaintId!));

//   /// Permanent delete.
//   Future<bool> remove(ComplaintModel c) async {
//     final id = c.complaintId;
//     if (id == null) return false;
//     final result = await _run(() => _repo.remove(id));
//     if (result == null) return false;
//     _items = _items.where((x) => x.complaintId != id).toList();
//     notifyListeners();
//     return true;
//   }

//   // ------------------------------------------------------------- helpers

//   /// Runs an update that returns the changed complaint and swaps it in.
//   Future<bool> _mutate(Future<ComplaintModel> Function() action) async {
//     final updated = await _run(action);
//     if (updated == null) return false;
//     _upsert(updated);
//     return true;
//   }

//   void _upsert(ComplaintModel updated) {
//     final idx = _items.indexWhere((c) => c.complaintId == updated.complaintId);
//     if (idx == -1) {
//       _items = [updated, ..._items];
//     } else {
//       _items = [..._items]..[idx] = updated;
//     }
//     notifyListeners();
//   }

//   Future<bool> _ensureOnline() async {
//     final online = await _connectivity.hasConnection();
//     isOffline = !online;
//     if (!online) failure = AppFailure.noInternet();
//     return online;
//   }

//   Future<T?> _run<T>(Future<T> Function() action) async {
//     failure = null;
//     if (!await _ensureOnline()) {
//       notifyListeners();
//       return null;
//     }
//     isBusy = true;
//     notifyListeners();
//     try {
//       return await action();
//     } on AppFailure catch (e) {
//       failure = e;
//       return null;
//     } finally {
//       isBusy = false;
//       notifyListeners();
//     }
//   }

//   void _onConnectivityChanged(bool online) {
//     final wasOffline = isOffline;
//     isOffline = !online;
//     notifyListeners();
//     if (online && wasOffline && state == LoadState.error) reload();
//   }

//   @override
//   void notifyListeners() {
//     if (!_disposed) super.notifyListeners();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _sub?.cancel();
//     super.dispose();
//   }
// }
// lib/screens/manage_system/control/complaint_provider.dart

// import 'dart:async';
// import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
// import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
// import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
// import 'package:flutter/foundation.dart';

// import '../model/complaint_model.dart';

// import '../../../services/connectivity_service.dart';

// class ComplaintProvider extends ChangeNotifier {
//   ComplaintProvider(
//     this._repo, {
//     ConnectivityService? connectivity,
//     this.sortNewestFirst = true,
//   }) : _connectivity = connectivity ?? ConnectivityService.instance {
//     _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
//   }

//   /// true  → [visibleComplaints] is sorted newest first.
//   /// false → keeps the order the server returned (oldest first, usually).
//   final bool sortNewestFirst;

//   final ComplaintRepo _repo;
//   final ConnectivityService _connectivity;
//   StreamSubscription<bool>? _sub;

//   List<ComplaintModel> _items = [];

//   /// Remembers the last list request so a reconnect reloads the SAME list
//   /// (e.g. open complaints) instead of silently switching to "all".
//   Future<List<ComplaintModel>> Function()? _lastFetch;
//   bool _disposed = false;

//   // Local (client-side) filters applied on top of whatever list is loaded.
//   String _query = '';
//   String? _statusFilter; // complaintStatus
//   String? _neighborhoodFilter;
//   String? _typeFilter; // complaintType
//   String? _sectorFilter; // sectorName
//   bool? _finishedFilter; // null = all
//   bool _trackedOnly = false;
//   bool _showDeleted = false; // soft-deleted complaints are hidden by default

//   LoadState state = LoadState.idle;
//   AppFailure? failure;
//   bool isOffline = false;
//   bool isBusy = false;

//   // -------------------------------------------------------------- getters

//   /// Everything currently loaded (unfiltered).
//   List<ComplaintModel> get items => _items;

//   String get query => _query;
//   String? get statusFilter => _statusFilter;
//   String? get neighborhoodFilter => _neighborhoodFilter;
//   String? get typeFilter => _typeFilter;
//   String? get sectorFilter => _sectorFilter;
//   bool? get finishedFilter => _finishedFilter;
//   bool get trackedOnly => _trackedOnly;
//   bool get showDeleted => _showDeleted;

//   /// Arabic-aware: ignores tashkeel/tatweel and treats أ إ آ ا, ى ي and ة ه
//   /// as the same letters.
//   static String normalizeArabic(String s) => s
//       .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
//       .replaceAll(RegExp('[أإآٱ]'), 'ا')
//       .replaceAll('ى', 'ي')
//       .replaceAll('ة', 'ه')
//       .toLowerCase()
//       .trim();

//   /// Filtered + sorted (newest first) list for the UI.
//   List<ComplaintModel> get visibleComplaints {
//     final q = normalizeArabic(_query);
//     final list = _items.where((c) {
//       if (!_showDeleted && c.deleted) return false;
//       if (_statusFilter != null && c.complaintStatus != _statusFilter) {
//         return false;
//       }
//       if (_neighborhoodFilter != null &&
//           c.neighborhood != _neighborhoodFilter) {
//         return false;
//       }
//       if (_typeFilter != null && c.complaintType != _typeFilter) return false;
//       if (_sectorFilter != null && c.sectorName != _sectorFilter) return false;
//       if (_finishedFilter != null && c.finished != _finishedFilter)
//         return false;
//       if (_trackedOnly && !c.tracked) return false;
//       if (q.isEmpty) return true;
//       final haystack = normalizeArabic([
//         c.reporterName,
//         c.reporterPhone,
//         c.complaintAddress,
//         c.complaintNote,
//         c.neighborhood,
//         c.complaintType,
//         '${c.reportNumber ?? ''}',
//         '${c.complaintId ?? ''}',
//       ].join(' '));
//       return haystack.contains(q);
//     }).toList();

//     if (sortNewestFirst) {
//       list.sort((a, b) {
//         final da = a.createdAtDate, db = b.createdAtDate;
//         if (da != null && db != null) return db.compareTo(da);
//         return (b.complaintId ?? 0).compareTo(a.complaintId ?? 0);
//       });
//     }
//     return list;
//   }

//   // ------------------------------------------------ per-handasah helpers

//   /// A technician value that means "nobody assigned yet".
//   static bool isFreeTechnician(String value) {
//     final v = value.trim();
//     return v.isEmpty || v == 'لم يدرج' || v == 'free';
//   }

//   /// Open (not finished, not deleted) complaints sent to [destination]
//   /// (a handasah name), in the order they were loaded.
//   List<ComplaintModel> openComplaintsFor(String destination) {
//     final d = destination.trim();
//     return _items
//         .where((c) =>
//             !c.deleted && !c.finished && c.recipientDestination.trim() == d)
//         .toList();
//   }

//   /// Open complaints of [destination] that still have no technician.
//   List<ComplaintModel> unassignedComplaintsFor(String destination) =>
//       openComplaintsFor(destination)
//           .where((c) => isFreeTechnician(c.recipientUser))
//           .toList();

//   /// Open complaints sent to [destination] and assigned to [technician]
//   /// (the technician is stored in `recipientUser`).
//   List<ComplaintModel> assignedToTechnician(
//     String destination,
//     String technician,
//   ) {
//     final t = technician.trim();
//     if (t.isEmpty) return const [];
//     return openComplaintsFor(destination)
//         .where((c) => c.recipientUser.trim() == t)
//         .toList();
//   }

//   // Distinct values for building filter dropdowns / chips.
//   List<String> get neighborhoods => _distinct((c) => c.neighborhood);
//   List<String> get statuses => _distinct((c) => c.complaintStatus);
//   List<String> get types => _distinct((c) => c.complaintType);
//   List<String> get sectors => _distinct((c) => c.sectorName);

//   List<String> _distinct(String Function(ComplaintModel) pick) {
//     final set = <String>{};
//     for (final c in _items) {
//       final v = pick(c).trim();
//       if (v.isNotEmpty) set.add(v);
//     }
//     return set.toList()..sort();
//   }

//   int get totalCount => _items.where((c) => !c.deleted).length;
//   int get finishedCount => _items.where((c) => !c.deleted && c.finished).length;
//   int get openCount => totalCount - finishedCount;
//   int get trackedCount => _items.where((c) => !c.deleted && c.tracked).length;

//   // ------------------------------------------------------ local filters

//   void setQuery(String v) {
//     _query = v;
//     notifyListeners();
//   }

//   void setStatusFilter(String? v) {
//     _statusFilter = v;
//     notifyListeners();
//   }

//   void setNeighborhoodFilter(String? v) {
//     _neighborhoodFilter = v;
//     notifyListeners();
//   }

//   void setTypeFilter(String? v) {
//     _typeFilter = v;
//     notifyListeners();
//   }

//   void setSectorFilter(String? v) {
//     _sectorFilter = v;
//     notifyListeners();
//   }

//   void setFinishedFilter(bool? v) {
//     _finishedFilter = v;
//     notifyListeners();
//   }

//   void setTrackedOnly(bool v) {
//     _trackedOnly = v;
//     notifyListeners();
//   }

//   void setShowDeleted(bool v) {
//     _showDeleted = v;
//     notifyListeners();
//   }

//   void clearFilters() {
//     _query = '';
//     _statusFilter = null;
//     _neighborhoodFilter = null;
//     _typeFilter = null;
//     _sectorFilter = null;
//     _finishedFilter = null;
//     _trackedOnly = false;
//     notifyListeners();
//   }

//   // ------------------------------------------------------------- loading

//   Future<void> loadAll() => _loadList(_repo.getAll);

//   /// Repeats the last list request (falls back to "all").
//   Future<void> reload() => _loadList(_lastFetch ?? _repo.getAll);

//   // Server-side finders: these REPLACE the loaded list with the server's
//   // result. Call loadAll() to get everything back.
//   Future<void> loadByNeighborhood(String v) =>
//       _loadList(() => _repo.findByNeighborhood(v));
//   Future<void> loadByStatus(String v) =>
//       _loadList(() => _repo.findByComplaintStatus(v));
//   Future<void> loadByUser(String username) =>
//       _loadList(() => _repo.findByCurrentUsername(username));
//   Future<void> loadByFinished(bool finished) =>
//       _loadList(() => _repo.findByIsFinished(finished ? 1 : 0));
//   Future<void> loadByType(String v) =>
//       _loadList(() => _repo.findByComplaintType(v));
//   Future<void> loadBySector(String v) =>
//       _loadList(() => _repo.findBySectorName(v));

//   Future<void> _loadList(Future<List<ComplaintModel>> Function() fetch) async {
//     _lastFetch = fetch;
//     state = LoadState.loading;
//     failure = null;
//     notifyListeners();

//     if (!await _ensureOnline()) {
//       state = LoadState.error;
//       notifyListeners();
//       return;
//     }

//     try {
//       _items = await fetch();
//       state = LoadState.loaded;
//     } on AppFailure catch (e) {
//       failure = e;
//       state = LoadState.error;
//     }
//     notifyListeners();
//   }

//   /// Local copy first; falls back to the server (and caches the result).
//   Future<ComplaintModel?> getById(int id, {bool forceRefresh = false}) async {
//     if (!forceRefresh) {
//       for (final c in _items) {
//         if (c.complaintId == id) return c;
//       }
//     }
//     final fetched = await _run(() => _repo.findById(id));
//     if (fetched != null) _upsert(fetched);
//     return fetched;
//   }

//   // ----------------------------------------------------------- mutations

//   Future<bool> create(ComplaintModel complaint) async {
//     final created = await _run(() => _repo.create(complaint));
//     if (created == null) return false;
//     _items = [created, ..._items];
//     notifyListeners();
//     return true;
//   }

//   Future<bool> update(ComplaintModel complaint) {
//     final id = complaint.complaintId;
//     if (id == null) return Future.value(false);
//     return _mutate(() => _repo.update(id, complaint));
//   }

//   Future<bool> setRepeatComplaintNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateRepeatComplaintNumber(
//           c.complaintId!, c.copyWith(repeatComplaintNumber: value)));

//   Future<bool> setUrgencyNumber(ComplaintModel c, int value) =>
//       _mutate(() => _repo.updateUrgencyNumber(
//           c.complaintId!, c.copyWith(urgencyNumber: value)));

//   Future<bool> setRecipient(
//     ComplaintModel c, {
//     required String recipientName,
//     String? recipientUser,
//   }) =>
//       _mutate(() => _repo.updateRecipient(
//             c.complaintId!,
//             c.copyWith(
//               recipientName: recipientName,
//               recipientUser: recipientUser,
//             ),
//           ));

//   Future<bool> setTracked(ComplaintModel c, bool tracked) => _mutate(() => _repo
//       .updateTracked(c.complaintId!, c.copyWith(isTracked: tracked ? 1 : 0)));

//   Future<bool> setStatusFlags(
//     ComplaintModel c, {
//     bool? finished,
//     bool? deleted,
//     bool? tracked,
//   }) =>
//       _mutate(() => _repo.updateStatusFlags(
//             c.complaintId!,
//             c.copyWith(
//               isFinished: finished == null ? null : (finished ? 1 : 0),
//               isDeleted: deleted == null ? null : (deleted ? 1 : 0),
//               isTracked: tracked == null ? null : (tracked ? 1 : 0),
//             ),
//           ));

//   Future<bool> setApprovalAuthority(ComplaintModel c, String authority) =>
//       _mutate(() => _repo.updateApprovalAuthority(
//           c.complaintId!, c.copyWith(approvalAuthority: authority)));

//   Future<bool> setRecipientDestination(ComplaintModel c, String destination) =>
//       _mutate(() => _repo.updateRecipientDestination(
//           c.complaintId!, c.copyWith(recipientDestination: destination)));

//   Future<bool> finish(ComplaintModel c) =>
//       _mutate(() => _repo.finish(c.complaintId!));

//   /// Soft delete: the server flags it; it stays in the list but is hidden
//   /// unless [showDeleted] is true.
//   Future<bool> softDelete(ComplaintModel c) =>
//       _mutate(() => _repo.softDelete(c.complaintId!));

//   /// Permanent delete.
//   Future<bool> remove(ComplaintModel c) async {
//     final id = c.complaintId;
//     if (id == null) return false;
//     final result = await _run(() => _repo.remove(id));
//     if (result == null) return false;
//     _items = _items.where((x) => x.complaintId != id).toList();
//     notifyListeners();
//     return true;
//   }

//   // ------------------------------------------------------------- helpers

//   /// Runs an update that returns the changed complaint and swaps it in.
//   Future<bool> _mutate(Future<ComplaintModel> Function() action) async {
//     final updated = await _run(action);
//     if (updated == null) return false;
//     _upsert(updated);
//     return true;
//   }

//   void _upsert(ComplaintModel updated) {
//     final idx = _items.indexWhere((c) => c.complaintId == updated.complaintId);
//     if (idx == -1) {
//       _items = [updated, ..._items];
//     } else {
//       _items = [..._items]..[idx] = updated;
//     }
//     notifyListeners();
//   }

//   Future<bool> _ensureOnline() async {
//     final online = await _connectivity.hasConnection();
//     isOffline = !online;
//     if (!online) failure = AppFailure.noInternet();
//     return online;
//   }

//   Future<T?> _run<T>(Future<T> Function() action) async {
//     failure = null;
//     if (!await _ensureOnline()) {
//       notifyListeners();
//       return null;
//     }
//     isBusy = true;
//     notifyListeners();
//     try {
//       return await action();
//     } on AppFailure catch (e) {
//       failure = e;
//       return null;
//     } finally {
//       isBusy = false;
//       notifyListeners();
//     }
//   }

//   void _onConnectivityChanged(bool online) {
//     final wasOffline = isOffline;
//     isOffline = !online;
//     notifyListeners();
//     if (online && wasOffline && state == LoadState.error) reload();
//   }

//   @override
//   void notifyListeners() {
//     if (!_disposed) super.notifyListeners();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _sub?.cancel();
//     super.dispose();
//   }
// }
// lib/screens/manage_system/control/complaint_provider.dart

import 'dart:async';
import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:flutter/foundation.dart';

import '../model/complaint_model.dart';

import '../../../services/connectivity_service.dart';

class ComplaintProvider extends ChangeNotifier {
  ComplaintProvider(
    this._repo, {
    ConnectivityService? connectivity,
    this.sortNewestFirst = true,
  }) : _connectivity = connectivity ?? ConnectivityService.instance {
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// true  → [visibleComplaints] is sorted newest first.
  /// false → keeps the order the server returned (oldest first, usually).
  final bool sortNewestFirst;

  final ComplaintRepo _repo;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  List<ComplaintModel> _items = [];

  /// Remembers the last list request so a reconnect reloads the SAME list
  /// (e.g. open complaints) instead of silently switching to "all".
  Future<List<ComplaintModel>> Function()? _lastFetch;
  bool _disposed = false;

  // Local (client-side) filters applied on top of whatever list is loaded.
  String _query = '';
  String? _statusFilter; // complaintStatus
  String? _neighborhoodFilter;
  String? _typeFilter; // complaintType
  String? _sectorFilter; // sectorName
  bool? _finishedFilter; // null = all
  bool _trackedOnly = false;
  bool _showDeleted = false; // soft-deleted complaints are hidden by default

  LoadState state = LoadState.idle;
  AppFailure? failure;
  bool isOffline = false;
  bool isBusy = false;

  // -------------------------------------------------------------- getters

  /// Everything currently loaded (unfiltered).
  List<ComplaintModel> get items => _items;

  String get query => _query;
  String? get statusFilter => _statusFilter;
  String? get neighborhoodFilter => _neighborhoodFilter;
  String? get typeFilter => _typeFilter;
  String? get sectorFilter => _sectorFilter;
  bool? get finishedFilter => _finishedFilter;
  bool get trackedOnly => _trackedOnly;
  bool get showDeleted => _showDeleted;

  /// Arabic-aware: ignores tashkeel/tatweel and treats أ إ آ ا, ى ي and ة ه
  /// as the same letters.
  static String normalizeArabic(String s) => s
      .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .toLowerCase()
      .trim();

  /// Filtered + sorted (newest first) list for the UI.
  List<ComplaintModel> get visibleComplaints {
    final q = normalizeArabic(_query);
    final list = _items.where((c) {
      if (!_showDeleted && c.deleted) return false;
      if (_statusFilter != null && c.complaintStatus != _statusFilter) {
        return false;
      }
      if (_neighborhoodFilter != null &&
          c.neighborhood != _neighborhoodFilter) {
        return false;
      }
      if (_typeFilter != null && c.complaintType != _typeFilter) return false;
      if (_sectorFilter != null && c.sectorName != _sectorFilter) return false;
      if (_finishedFilter != null && c.finished != _finishedFilter)
        return false;
      if (_trackedOnly && !c.tracked) return false;
      if (q.isEmpty) return true;
      final haystack = normalizeArabic([
        c.reporterName,
        c.reporterPhone,
        c.complaintAddress,
        c.complaintNote,
        c.neighborhood,
        c.complaintType,
        '${c.reportNumber ?? ''}',
        '${c.complaintId ?? ''}',
      ].join(' '));
      return haystack.contains(q);
    }).toList();

    if (sortNewestFirst) {
      list.sort((a, b) {
        final da = a.createdAtDate, db = b.createdAtDate;
        if (da != null && db != null) return db.compareTo(da);
        return (b.complaintId ?? 0).compareTo(a.complaintId ?? 0);
      });
    }
    return list;
  }

  // ------------------------------------------------ per-handasah helpers

  /// A technician value that means "nobody assigned yet".
  static bool isFreeTechnician(String value) {
    final v = value.trim();
    return v.isEmpty || v == 'لم يدرج' || v == 'free';
  }

  /// Open (not finished, not deleted) complaints sent to [destination]
  /// (a handasah name), in the order they were loaded.
  List<ComplaintModel> openComplaintsFor(String destination) {
    final d = destination.trim();
    return _items
        .where((c) =>
            !c.deleted && !c.finished && c.recipientDestination.trim() == d)
        .toList();
  }

  /// Open complaints of [destination] that still have no technician.
  List<ComplaintModel> unassignedComplaintsFor(String destination) =>
      openComplaintsFor(destination)
          .where((c) => isFreeTechnician(c.recipientUser))
          .toList();

  /// Open complaints sent to [destination] and assigned to [technician]
  /// (the technician is stored in `recipientUser`).
  List<ComplaintModel> assignedToTechnician(
    String destination,
    String technician,
  ) {
    final t = technician.trim();
    if (t.isEmpty) return const [];
    return openComplaintsFor(destination)
        .where((c) => c.recipientUser.trim() == t)
        .toList();
  }

  // Distinct values for building filter dropdowns / chips.
  List<String> get neighborhoods => _distinct((c) => c.neighborhood);
  List<String> get statuses => _distinct((c) => c.complaintStatus);
  List<String> get types => _distinct((c) => c.complaintType);
  List<String> get sectors => _distinct((c) => c.sectorName);

  List<String> _distinct(String Function(ComplaintModel) pick) {
    final set = <String>{};
    for (final c in _items) {
      final v = pick(c).trim();
      if (v.isNotEmpty) set.add(v);
    }
    return set.toList()..sort();
  }

  int get totalCount => _items.where((c) => !c.deleted).length;
  int get finishedCount => _items.where((c) => !c.deleted && c.finished).length;
  int get openCount => totalCount - finishedCount;
  int get trackedCount => _items.where((c) => !c.deleted && c.tracked).length;

  // ------------------------------------------------------ local filters

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void setStatusFilter(String? v) {
    _statusFilter = v;
    notifyListeners();
  }

  void setNeighborhoodFilter(String? v) {
    _neighborhoodFilter = v;
    notifyListeners();
  }

  void setTypeFilter(String? v) {
    _typeFilter = v;
    notifyListeners();
  }

  void setSectorFilter(String? v) {
    _sectorFilter = v;
    notifyListeners();
  }

  void setFinishedFilter(bool? v) {
    _finishedFilter = v;
    notifyListeners();
  }

  void setTrackedOnly(bool v) {
    _trackedOnly = v;
    notifyListeners();
  }

  void setShowDeleted(bool v) {
    _showDeleted = v;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _statusFilter = null;
    _neighborhoodFilter = null;
    _typeFilter = null;
    _sectorFilter = null;
    _finishedFilter = null;
    _trackedOnly = false;
    notifyListeners();
  }

  // ------------------------------------------------------------- loading

  Future<void> loadAll() => _loadList(_repo.getAll);

  /// Repeats the last list request (falls back to "all").
  Future<void> reload() => _loadList(_lastFetch ?? _repo.getAll);

  /// Same as [reload] but SILENT: no loading state (so no spinner), and a
  /// failed request just keeps the list that is already on screen. Used for
  /// live updates pushed by the server.
  Future<void> refreshQuietly() async {
    if (_disposed) return;
    if (!await _connectivity.hasConnection()) return;
    try {
      final fresh = await (_lastFetch ?? _repo.getAll)();
      if (_disposed) return;
      _items = fresh;
      state = LoadState.loaded;
      failure = null;
      notifyListeners();
    } on AppFailure {
      // keep the current list; the next event / poll will try again
    }
  }

  // Server-side finders: these REPLACE the loaded list with the server's
  // result. Call loadAll() to get everything back.
  Future<void> loadByNeighborhood(String v) =>
      _loadList(() => _repo.findByNeighborhood(v));
  Future<void> loadByStatus(String v) =>
      _loadList(() => _repo.findByComplaintStatus(v));
  Future<void> loadByUser(String username) =>
      _loadList(() => _repo.findByCurrentUsername(username));
  Future<void> loadByFinished(bool finished) =>
      _loadList(() => _repo.findByIsFinished(finished ? 1 : 0));
  Future<void> loadByType(String v) =>
      _loadList(() => _repo.findByComplaintType(v));
  Future<void> loadBySector(String v) =>
      _loadList(() => _repo.findBySectorName(v));

  Future<void> _loadList(Future<List<ComplaintModel>> Function() fetch) async {
    _lastFetch = fetch;
    state = LoadState.loading;
    failure = null;
    notifyListeners();

    if (!await _ensureOnline()) {
      state = LoadState.error;
      notifyListeners();
      return;
    }

    try {
      _items = await fetch();
      state = LoadState.loaded;
    } on AppFailure catch (e) {
      failure = e;
      state = LoadState.error;
    }
    notifyListeners();
  }

  /// Local copy first; falls back to the server (and caches the result).
  Future<ComplaintModel?> getById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      for (final c in _items) {
        if (c.complaintId == id) return c;
      }
    }
    final fetched = await _run(() => _repo.findById(id));
    if (fetched != null) _upsert(fetched);
    return fetched;
  }

  // ----------------------------------------------------------- mutations

  Future<bool> create(ComplaintModel complaint) async {
    final created = await _run(() => _repo.create(complaint));
    if (created == null) return false;
    _items = [created, ..._items];
    notifyListeners();
    return true;
  }

  Future<bool> update(ComplaintModel complaint) {
    final id = complaint.complaintId;
    if (id == null) return Future.value(false);
    return _mutate(() => _repo.update(id, complaint));
  }

  Future<bool> setRepeatComplaintNumber(ComplaintModel c, int value) =>
      _mutate(() => _repo.updateRepeatComplaintNumber(
          c.complaintId!, c.copyWith(repeatComplaintNumber: value)));

  Future<bool> setUrgencyNumber(ComplaintModel c, int value) =>
      _mutate(() => _repo.updateUrgencyNumber(
          c.complaintId!, c.copyWith(urgencyNumber: value)));

  Future<bool> setRecipient(
    ComplaintModel c, {
    required String recipientName,
    String? recipientUser,
  }) =>
      _mutate(() => _repo.updateRecipient(
            c.complaintId!,
            c.copyWith(
              recipientName: recipientName,
              recipientUser: recipientUser,
            ),
          ));

  Future<bool> setTracked(ComplaintModel c, bool tracked) => _mutate(() => _repo
      .updateTracked(c.complaintId!, c.copyWith(isTracked: tracked ? 1 : 0)));

  Future<bool> setStatusFlags(
    ComplaintModel c, {
    bool? finished,
    bool? deleted,
    bool? tracked,
  }) =>
      _mutate(() => _repo.updateStatusFlags(
            c.complaintId!,
            c.copyWith(
              isFinished: finished == null ? null : (finished ? 1 : 0),
              isDeleted: deleted == null ? null : (deleted ? 1 : 0),
              isTracked: tracked == null ? null : (tracked ? 1 : 0),
            ),
          ));

  Future<bool> setApprovalAuthority(ComplaintModel c, String authority) =>
      _mutate(() => _repo.updateApprovalAuthority(
          c.complaintId!, c.copyWith(approvalAuthority: authority)));

  Future<bool> setRecipientDestination(ComplaintModel c, String destination) =>
      _mutate(() => _repo.updateRecipientDestination(
          c.complaintId!, c.copyWith(recipientDestination: destination)));

  Future<bool> finish(ComplaintModel c) =>
      _mutate(() => _repo.finish(c.complaintId!));

  /// Soft delete: the server flags it; it stays in the list but is hidden
  /// unless [showDeleted] is true.
  Future<bool> softDelete(ComplaintModel c) =>
      _mutate(() => _repo.softDelete(c.complaintId!));

  /// Permanent delete.
  Future<bool> remove(ComplaintModel c) async {
    final id = c.complaintId;
    if (id == null) return false;
    final result = await _run(() => _repo.remove(id));
    if (result == null) return false;
    _items = _items.where((x) => x.complaintId != id).toList();
    notifyListeners();
    return true;
  }

  // ------------------------------------------------------------- helpers

  /// Runs an update that returns the changed complaint and swaps it in.
  Future<bool> _mutate(Future<ComplaintModel> Function() action) async {
    final updated = await _run(action);
    if (updated == null) return false;
    _upsert(updated);
    return true;
  }

  void _upsert(ComplaintModel updated) {
    final idx = _items.indexWhere((c) => c.complaintId == updated.complaintId);
    if (idx == -1) {
      _items = [updated, ..._items];
    } else {
      _items = [..._items]..[idx] = updated;
    }
    notifyListeners();
  }

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
    if (online && wasOffline && state == LoadState.error) reload();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
