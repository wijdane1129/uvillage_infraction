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
  factory DashboardStats.fromJson(Map<String,dynamic> json){
    final Map<String, int> parsedMonthly = (json['monthlyInfractions'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));
    
    final Map<String, int> parsedZone = (json['zoneInfractions'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    return DashboardStats(
      totalInfractions: json['totalInfractions'] as int,
      resolvedInfractions: json['resolvedInfractions'] as int,
      monthlyInfractions: parsedMonthly,
      typeDistribution: (json['typeDistribution'] as List)
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
  
