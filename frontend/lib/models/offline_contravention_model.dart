import 'package:hive/hive.dart';
import 'dart:convert';

part 'offline_contravention_model.g.dart';

@HiveType(typeId: 1)
class OfflineContravention extends HiveObject {
  @HiveField(0)
  late String id; // UUID

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String typeLabel; // motif

  @HiveField(3)
  late int userAuthorId;

  @HiveField(4)
  late int? tiersId; // resident id (optional)

  @HiveField(5)
  late List<String> mediaUrls; // file paths of local media

  @HiveField(6)
  late List<String> mediaTypes; // corresponding media types

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  @HiveField(9)
  late bool isSynced; // false = pending, true = synced

  @HiveField(10)
  late String? syncError; // Error message if sync failed

  @HiveField(11)
  late int syncAttempts; // Number of sync attempts

  OfflineContravention({
    required this.id,
    required this.description,
    required this.typeLabel,
    required this.userAuthorId,
    this.tiersId,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.syncError,
    this.syncAttempts = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'typeLabel': typeLabel,
      'userAuthorId': userAuthorId,
      'tiersId': tiersId,
      'mediaUrls': mediaUrls,
      'mediaTypes': mediaTypes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'syncError': syncError,
      'syncAttempts': syncAttempts,
    };
  }

  factory OfflineContravention.fromJson(Map<String, dynamic> json) {
    return OfflineContravention(
      id: json['id'] as String,
      description: json['description'] as String,
      typeLabel: json['typeLabel'] as String,
      userAuthorId: json['userAuthorId'] as int,
      tiersId: json['tiersId'] as int?,
      mediaUrls: List<String>.from(json['mediaUrls'] as List? ?? []),
      mediaTypes: List<String>.from(json['mediaTypes'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      syncError: json['syncError'] as String?,
      syncAttempts: json['syncAttempts'] as int? ?? 0,
    );
  }
}
