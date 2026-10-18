// lib/screens/manage_system/model/user_model.dart

import 'package:flutter/material.dart';

/// Matches the backend comment: control-room = 1, handasah = 2, technical = 3
enum UserRole {
  controlRoom(1, 'غرفة التحكم', Icons.dashboard_customize_rounded),
  handasah(2, 'هندسة', Icons.engineering_rounded),
  technical(3, 'فني', Icons.build_rounded);

  const UserRole(this.code, this.label, this.icon);

  final int code;
  final String label;
  final IconData icon;

  static UserRole? fromCode(int code) {
    for (final r in UserRole.values) {
      if (r.code == code) return r;
    }
    return null;
  }
}

class UserModel {
  final int? id;
  final String userName;

  /// Only used when CREATING a user. It is intentionally never read back from
  /// the server response so it can't end up in memory/UI by accident.
  final String? password;
  final int role;
  final String controlUnit;
  final int technicalId; // employee number

  const UserModel({
    this.id,
    required this.userName,
    this.password,
    required this.role,
    required this.controlUnit,
    required this.technicalId,
  });

  UserRole? get roleType => UserRole.fromCode(role);

  /// Keys assume the default Jackson names of PickLocationUsersDTO.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt(),
      userName: (json['username'] ?? '').toString(),
      role: (json['role'] as num?)?.toInt() ?? 0,
      controlUnit: (json['controlUnit'] ?? '').toString(),
      technicalId: (json['technicalId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'username': userName,
        if (password != null) 'password': password,
        'role': role,
        'controlUnit': controlUnit,
        'technicalId': technicalId,
      };
}
