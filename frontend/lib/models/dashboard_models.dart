import 'package:flutter/material.dart';

class DashboardStats {
  final int totalInfractions;
  final int resolvedInfractions;
  final Map<String, int> monthlyInfractions;
  final List<TypeDistribution> typeDistribution;
  final Map<String, int> zoneInfractions;
  DashboardStats({
    required this.totalInfractions,
    required this.resolvedInfractions,
    required this.monthlyInfractions,
    required this.typeDistribution,
    required this.zoneInfractions,
  });
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final Map<String, int> parsedMonthly = (json['monthlyInfractions']
            as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    final Map<String, int> parsedZone = (json['zoneInfractions']
            as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    return DashboardStats(
      totalInfractions: json['totalInfractions'] as int,
      resolvedInfractions: json['resolvedInfractions'] as int,
      monthlyInfractions: parsedMonthly,
      typeDistribution:
          (json['typeDistribution'] as List)
              .map((i) => TypeDistribution.fromJson(i as Map<String, dynamic>))
              .toList(),
      zoneInfractions: parsedZone,
    );
  }
}

class TypeDistribution {
  final String type;
  final int count;

  TypeDistribution({required this.type, required this.count});

  factory TypeDistribution.fromJson(Map<String, dynamic> json) {
    return TypeDistribution(
      type: json['type'] as String,
      count: json['count'] as int,
    );
  }
}

// Responsable Dashboard Models
class DashboardResponsable {
  final int totalInfractions;
  final int pendingInfractions;
  final int acceptedThisMonth;
  final double totalFines;
  final List<ChartDataPoint> chartData;
  final List<RecentContravention> recentInfractions;
  final Map<String, int> statusDistribution;

  DashboardResponsable({
    required this.totalInfractions,
    required this.pendingInfractions,
    required this.acceptedThisMonth,
    required this.totalFines,
    required this.chartData,
    required this.recentInfractions,
    required this.statusDistribution,
  });

  factory DashboardResponsable.fromJson(Map<String, dynamic> json) {
    try {
      final Map<String, int> parsedStatus =
          ((json['statusDistribution'] as Map<String, dynamic>?) ?? {}).map(
            (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
          );

      final List<dynamic> chartList = (json['chartData'] as List?) ?? [];
      final List<dynamic> infractionList =
          (json['recentInfractions'] as List?) ?? [];

      return DashboardResponsable(
        totalInfractions: (json['totalInfractions'] as num?)?.toInt() ?? 0,
        pendingInfractions: (json['pendingInfractions'] as num?)?.toInt() ?? 0,
        acceptedThisMonth: (json['acceptedThisMonth'] as num?)?.toInt() ?? 0,
        totalFines: (json['totalFines'] as num?)?.toDouble() ?? 0.0,
        chartData:
            chartList
                .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
                .toList(),
        recentInfractions:
            infractionList
                .map(
                  (e) =>
                      RecentContravention.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
        statusDistribution: parsedStatus,
      );
    } catch (e) {
      print('Error parsing DashboardResponsable: $e');
      // Return a default empty dashboard
      return DashboardResponsable(
        totalInfractions: 0,
        pendingInfractions: 0,
        acceptedThisMonth: 0,
        totalFines: 0.0,
        chartData: [],
        recentInfractions: [],
        statusDistribution: {},
      );
    }
  }
}

class ChartDataPoint {
  final int day;
  final int count;

  ChartDataPoint({required this.day, required this.count});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(day: json['day'] as int, count: json['count'] as int);
  }
}

class RecentContravention {
  final int rowid;
  final String ref;
  final String motif;
  final String description;
  final String dateCreation;
  final String statut;
  final String agentName;
  final String residentName;
  final String? residentAdresse;
  final double montantAmende;

  RecentContravention({
    required this.rowid,
    required this.ref,
    required this.motif,
    required this.description,
    required this.dateCreation,
    required this.statut,
    required this.agentName,
    required this.residentName,
    this.residentAdresse,
    required this.montantAmende,
  });

  factory RecentContravention.fromJson(Map<String, dynamic> json) {
    return RecentContravention(
      rowid: json['rowid'] as int? ?? 0,
      ref: json['ref'] as String? ?? 'N/A',
      motif: json['motif'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      dateCreation:
          json['dateCreation'] as String? ?? DateTime.now().toIso8601String(),
      statut: json['statut'] as String? ?? 'SOUS_VERIFICATION',
      agentName: json['agentName'] as String? ?? 'Unknown',
      residentName: json['residentName'] as String? ?? 'Unknown',
      residentAdresse: json['residentAdresse'] as String?,
      montantAmende: (json['montantAmende'] as num? ?? 0).toDouble(),
    );
  }

  // Helper for status color
  Color getStatusColor() {
    switch (statut.toUpperCase()) {
      case 'ACCEPTEE':
        return const Color(0xFF4CAF50);
      case 'SOUS_VERIFICATION':
        return const Color(0xFFFFC107);
      case 'CLASSEE_SANS_SUITE':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // Helper for status label
  String getStatusLabel() {
    switch (statut.toUpperCase()) {
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'SOUS_VERIFICATION':
        return 'En attente';
      case 'CLASSEE_SANS_SUITE':
        return 'Rejetée';
      default:
        return statut;
    }
  }
}
