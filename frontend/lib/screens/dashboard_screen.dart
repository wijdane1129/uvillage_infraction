import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/dashboard_provider.dart';
import '../config/app_theme.dart';
import '../models/dashboard_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      if (provider.state == DashboardState.loading) {
        provider.fetchStats();
      }
      // Start auto-refresh every 30 seconds
      provider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Contraventions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: () {
              final provider = Provider.of<DashboardProvider>(
                context,
                listen: false,
              );
              provider.refreshData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.state == DashboardState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == DashboardState.error ||
              provider.stats == null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          final stats = provider.stats!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopStatsRow(stats),
                const SizedBox(height: 16),
                _buildChartsRow(stats),
                const SizedBox(height: 16),
                _buildZoneAndBreakdownRow(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStatsRow(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total infractions',
            stats.totalInfractions.toString(),
            Icons.shield,
            AppTheme.purpleAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Infractions résolues',
            stats.resolvedInfractions.toString(),
            Icons.check_circle,
            AppTheme.cyanAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMonthlyInfractionsChart(stats.monthlyInfractions),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildTypeDistributionChart(stats.typeDistribution)),
      ],
    );
  }

  Widget _buildZoneAndBreakdownRow(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          stats.zoneInfractions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildZoneBreakdown(entry.key, entry.value),
            );
          }).toList(),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTheme.darkTheme.textTheme.bodyMedium),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.headlineMedium!.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyInfractionsChart(Map<String, int> monthlyData) {
    // Filter out months with 0 infractions for better visualization
    final filteredMonths = <String>[];
    final filteredCounts = <int>[];

    final monthNames = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];

    for (int i = 1; i <= 12; i++) {
      final count = monthlyData['$i'] ?? 0;
      if (count > 0) {
        filteredMonths.add(monthNames[i - 1]);
        filteredCounts.add(count);
      }
    }

    if (filteredCounts.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkBgAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aucune donnée',
            style: AppTheme.darkTheme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Infractions par mois',
            style: AppTheme.darkTheme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (filteredCounts.reduce((a, b) => a > b ? a : b) + 1)
                        .toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= filteredMonths.length) {
                          return const Text('');
                        }
                        return Text(
                          filteredMonths[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  filteredCounts.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: filteredCounts[index].toDouble(),
                        color: AppTheme.purpleAccent,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistributionChart(List<TypeDistribution> typeData) {
    if (typeData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkBgAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aucune donnée',
            style: AppTheme.darkTheme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    // Colors for pie chart
    final colors = [
      AppTheme.purpleAccent,
      AppTheme.cyanAccent,
      const Color(0xFF4CAF50),
      const Color(0xFFFFB84D),
      const Color(0xFFFF6B6B),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par type d\'infraction',
            style: AppTheme.darkTheme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: List.generate(
                        typeData.length,
                        (index) => PieChartSectionData(
                          value: typeData[index].count.toDouble(),
                          color: colors[index % colors.length],
                          title: typeData[index].count.toString(),
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      typeData.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                typeData[index].type,
                                style: AppTheme.darkTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneBreakdown(String zone, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(zone, style: AppTheme.darkTheme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (count / 600).clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.purpleAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(count.toString(), style: AppTheme.darkTheme.textTheme.bodyMedium),
      ],
    );
  }
}
