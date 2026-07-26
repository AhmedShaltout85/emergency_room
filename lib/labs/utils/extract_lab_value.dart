// Shared helpers used by lab test consumers to extract the numeric test value
// and the test date from the loosely-typed response of the labs API.
//
// The labs endpoint returns `List<Map<String, dynamic>>` without a strict
// schema, so we detect the value/date keys by trying common names and falling
// back to a numeric field / date-shaped string.
//
// This logic is duplicated in `lib/labs/charts/*.dart` for chart rendering;
// this utility is the canonical version used by the SCADA dashboard table.

const List<String> _valueKeyCandidates = [
  'actualTestValue',
  'testValue',
  'value',
  'resultValue',
  'measurement',
  'numericValue',
  'labValue',
  'testResult',
];

const List<String> _dateKeyCandidates = [
  'testDate',
  'date',
  'collectionDate',
  'resultDate',
  'testTime',
  'timestamp',
  'createdAt',
  'collectionTime',
];

bool _looksLikeDate(String value) {
  return RegExp(r'\d{4}[-/]\d{2}[-/]\d{2}').hasMatch(value) ||
      RegExp(r'\d{2}[-/]\d{2}[-/]\d{4}').hasMatch(value);
}

String findValueKey(List<Map<String, dynamic>> data) {
  if (data.isEmpty) return 'testValue';
  final firstItem = data.first;
  for (final key in _valueKeyCandidates) {
    if (firstItem.containsKey(key)) return key;
  }
  for (final key in firstItem.keys) {
    if (firstItem[key] is num) return key;
  }
  return 'testValue';
}

String findDateKey(List<Map<String, dynamic>> data) {
  if (data.isEmpty) return 'testDate';
  final firstItem = data.first;
  for (final key in _dateKeyCandidates) {
    if (firstItem.containsKey(key)) return key;
  }
  for (final key in firstItem.keys) {
    final value = firstItem[key];
    if (value is String && _looksLikeDate(value)) return key;
  }
  return 'testDate';
}

double? extractLabValue(List<Map<String, dynamic>> items) {
  if (items.isEmpty) return null;
  final valueKey = findValueKey(items);
  final raw = items.first[valueKey];
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString());
}

DateTime? extractLabDate(Map<String, dynamic> item, String dateKey) {
  final raw = item[dateKey];
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

/// Returns the value from the item with the most recent detected date.
/// If dates cannot be parsed, falls back to the first item.
double? extractLastLabValueByDate(List<Map<String, dynamic>> items) {
  if (items.isEmpty) return null;
  if (items.length == 1) {
    final v = items.first[findValueKey(items)];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
  final dateKey = findDateKey(items);
  Map<String, dynamic>? best;
  DateTime? bestDate;
  for (final item in items) {
    final d = extractLabDate(item, dateKey);
    if (d == null) continue;
    if (bestDate == null || d.isAfter(bestDate)) {
      bestDate = d;
      best = item;
    }
  }
  best ??= items.first;
  final valueKey = findValueKey(items);
  final raw = best[valueKey];
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '');
}