// lib/screens/manage_system/model/complaint_model.dart

String _str(dynamic v) => v == null ? '' : v.toString();

int _int(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  return int.tryParse(_str(v)) ?? fallback;
}

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(_str(v));
}

String? _strOrNull(dynamic v) {
  final s = _str(v).trim();
  return s.isEmpty ? null : s;
}

/// Parses "2026-10-17 09:13:33.8568855" (7 fractional digits, space instead of
/// "T") which Dart's DateTime.tryParse would otherwise reject.
DateTime? _parseDate(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  final fixed = s
      .trim()
      .replaceFirst(' ', 'T')
      .replaceFirstMapped(RegExp(r'(\.\d{6})\d+'), (m) => m[1]!);
  return DateTime.tryParse(fixed);
}

class ComplaintModel {
  final int? complaintId;
  final String? createdAt;
  final String? updatedAt;
  final String neighborhood;
  final int repeatComplaintNumber;
  final String complaintSource;
  final String reporterName;
  final String reporterPhone;
  final String complaintAddress;
  final String complaintRepairStatus;
  final String approvalAuthority;
  final String pumpDiameter;
  final String seriousStatus;
  final String complaintStatus;
  final String complaintNote;
  final String recipientDestination;
  final String recipientUser;
  final int? reportNumber;
  final String recipientName;
  final String gisLink;
  final String longitude;
  final String latitude;
  final int isDeleted; // 0 / 1
  final int isFinished; // 0 / 1
  final int isTracked; // 0 / 1
  final String currentUsername;
  final String? deletedAt;
  final String? finishedAt;
  final String complaintType;
  final String sectorName;
  final int urgencyNumber;

  const ComplaintModel({
    this.complaintId,
    this.createdAt,
    this.updatedAt,
    this.neighborhood = '',
    this.repeatComplaintNumber = 0,
    this.complaintSource = '',
    this.reporterName = '',
    this.reporterPhone = '',
    this.complaintAddress = '',
    this.complaintRepairStatus = '',
    this.approvalAuthority = '',
    this.pumpDiameter = '',
    this.seriousStatus = '',
    this.complaintStatus = '',
    this.complaintNote = '',
    this.recipientDestination = '',
    this.recipientUser = '',
    this.reportNumber,
    this.recipientName = '',
    this.gisLink = '',
    this.longitude = '',
    this.latitude = '',
    this.isDeleted = 0,
    this.isFinished = 0,
    this.isTracked = 0,
    this.currentUsername = '',
    this.deletedAt,
    this.finishedAt,
    this.complaintType = '',
    this.sectorName = '',
    this.urgencyNumber = 0,
  });

  // ------------------------------------------------------------ helpers

  bool get finished => isFinished == 1;
  bool get deleted => isDeleted == 1;
  bool get tracked => isTracked == 1;

  double? get lat => double.tryParse(latitude);
  double? get lng => double.tryParse(longitude);
  bool get hasLocation => lat != null && lng != null;

  DateTime? get createdAtDate => _parseDate(createdAt);
  DateTime? get updatedAtDate => _parseDate(updatedAt);
  DateTime? get finishedAtDate => _parseDate(finishedAt);
  DateTime? get deletedAtDate => _parseDate(deletedAt);

  // --------------------------------------------------------------- JSON

  /// Keys match ComplaintDTO (confirmed against the real API response).
  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      complaintId: _intOrNull(json['complaintId']),
      createdAt: _strOrNull(json['createdAt']),
      updatedAt: _strOrNull(json['updatedAt']),
      neighborhood: _str(json['neighborhood']),
      repeatComplaintNumber: _int(json['repeatComplaintNumber']),
      complaintSource: _str(json['complaintSource']),
      reporterName: _str(json['reporterName']),
      reporterPhone: _str(json['reporterPhone']),
      complaintAddress: _str(json['complaintAddress']),
      complaintRepairStatus: _str(json['complaintRepairStatus']),
      approvalAuthority: _str(json['approvalAuthority']),
      pumpDiameter: _str(json['pumpDiameter']),
      seriousStatus: _str(json['seriousStatus']),
      complaintStatus: _str(json['complaintStatus']),
      complaintNote: _str(json['complaintNote']),
      recipientDestination: _str(json['recipientDestination']),
      recipientUser: _str(json['recipientUser']),
      reportNumber: _intOrNull(json['reportNumber']),
      recipientName: _str(json['recipientName']),
      gisLink: _str(json['gisLink']),
      longitude: _str(json['longitude']),
      latitude: _str(json['latitude']),
      isDeleted: _int(json['isDeleted']),
      isFinished: _int(json['isFinished']),
      isTracked: _int(json['isTracked']),
      currentUsername: _str(json['currentUsername']),
      deletedAt: _strOrNull(json['deletedAt']),
      finishedAt: _strOrNull(json['finishedAt']),
      complaintType: _str(json['complaintType']),
      sectorName: _str(json['sectorName']),
      urgencyNumber: _int(json['urgencyNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (complaintId != null) 'complaintId': complaintId,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
        'neighborhood': neighborhood,
        'repeatComplaintNumber': repeatComplaintNumber,
        'complaintSource': complaintSource,
        'reporterName': reporterName,
        'reporterPhone': reporterPhone,
        'complaintAddress': complaintAddress,
        'complaintRepairStatus': complaintRepairStatus,
        'approvalAuthority': approvalAuthority,
        'pumpDiameter': pumpDiameter,
        'seriousStatus': seriousStatus,
        'complaintStatus': complaintStatus,
        'complaintNote': complaintNote,
        'recipientDestination': recipientDestination,
        'recipientUser': recipientUser,
        if (reportNumber != null) 'reportNumber': reportNumber,
        'recipientName': recipientName,
        'gisLink': gisLink,
        'longitude': longitude,
        'latitude': latitude,
        'isDeleted': isDeleted,
        'isFinished': isFinished,
        'isTracked': isTracked,
        'currentUsername': currentUsername,
        if (deletedAt != null) 'deletedAt': deletedAt,
        if (finishedAt != null) 'finishedAt': finishedAt,
        'complaintType': complaintType,
        'sectorName': sectorName,
        'urgencyNumber': urgencyNumber,
      };

  ComplaintModel copyWith({
    int? complaintId,
    String? createdAt,
    String? updatedAt,
    String? neighborhood,
    int? repeatComplaintNumber,
    String? complaintSource,
    String? reporterName,
    String? reporterPhone,
    String? complaintAddress,
    String? complaintRepairStatus,
    String? approvalAuthority,
    String? pumpDiameter,
    String? seriousStatus,
    String? complaintStatus,
    String? complaintNote,
    String? recipientDestination,
    String? recipientUser,
    int? reportNumber,
    String? recipientName,
    String? gisLink,
    String? longitude,
    String? latitude,
    int? isDeleted,
    int? isFinished,
    int? isTracked,
    String? currentUsername,
    String? deletedAt,
    String? finishedAt,
    String? complaintType,
    String? sectorName,
    int? urgencyNumber,
  }) {
    return ComplaintModel(
      complaintId: complaintId ?? this.complaintId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      neighborhood: neighborhood ?? this.neighborhood,
      repeatComplaintNumber:
          repeatComplaintNumber ?? this.repeatComplaintNumber,
      complaintSource: complaintSource ?? this.complaintSource,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      complaintAddress: complaintAddress ?? this.complaintAddress,
      complaintRepairStatus:
          complaintRepairStatus ?? this.complaintRepairStatus,
      approvalAuthority: approvalAuthority ?? this.approvalAuthority,
      pumpDiameter: pumpDiameter ?? this.pumpDiameter,
      seriousStatus: seriousStatus ?? this.seriousStatus,
      complaintStatus: complaintStatus ?? this.complaintStatus,
      complaintNote: complaintNote ?? this.complaintNote,
      recipientDestination: recipientDestination ?? this.recipientDestination,
      recipientUser: recipientUser ?? this.recipientUser,
      reportNumber: reportNumber ?? this.reportNumber,
      recipientName: recipientName ?? this.recipientName,
      gisLink: gisLink ?? this.gisLink,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      isDeleted: isDeleted ?? this.isDeleted,
      isFinished: isFinished ?? this.isFinished,
      isTracked: isTracked ?? this.isTracked,
      currentUsername: currentUsername ?? this.currentUsername,
      deletedAt: deletedAt ?? this.deletedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      complaintType: complaintType ?? this.complaintType,
      sectorName: sectorName ?? this.sectorName,
      urgencyNumber: urgencyNumber ?? this.urgencyNumber,
    );
  }
}
