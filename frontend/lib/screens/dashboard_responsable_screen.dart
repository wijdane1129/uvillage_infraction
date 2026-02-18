import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/dashboard_models.dart';
import '../models/contravention_models.dart';
import '../services/api_service.dart';
import '../services/api_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gen_l10n/app_localizations.dart';
import 'contravention_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

class DashboardResponsableScreen extends StatefulWidget {
  const DashboardResponsableScreen({Key? key}) : super(key: key);

  @override
  State<DashboardResponsableScreen> createState() =>
      _DashboardResponsableScreenState();
}

class _DashboardResponsableScreenState
    extends State<DashboardResponsableScreen> {
  DashboardResponsable? dashboard;
  bool isLoading = true;
  String? error;
  String _selectedStatusFilter = 'TOUS'; // Filter state

  // Auto-refresh timer
  late final _autoRefreshTimer = Stream.periodic(const Duration(seconds: 30));
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    loadDashboard();
    // Start auto-refresh every 30 seconds
    _autoRefreshTimer.listen((_) {
      if (!_disposed && mounted) {
        loadDashboard();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ApiService();
      final response = await apiService.get('/dashboard/responsable');

      if (response.statusCode == 200) {
        final data = DashboardResponsable.fromJson(response.data);
        setState(() {
          dashboard = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur de chargement';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.purpleAccent),
              )
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: loadDashboard,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: loadDashboard,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(child: _buildHeader(context)),
                        const SizedBox(height: 32),
                        // Stats Cards
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        // Chart
                        _buildChartSection(),
                        const SizedBox(height: 24),
                        // Recent Infractions
                        _buildRecentInfractions(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.dashboard,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: AppTheme.purpleAccent.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    if (dashboard == null) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total infractions',
          dashboard!.totalInfractions.toString(),
          Icons.warning_amber_rounded,
          const Color(0xFF5C6BC0),
        ),
        _buildStatCard(
          'En attente',
          dashboard!.pendingInfractions.toString(),
          Icons.schedule,
          const Color(0xFFFFC107),
        ),
        _buildStatCard(
          'Acceptées ce mois',
          dashboard!.acceptedThisMonth.toString(),
          Icons.check_circle,
          const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          'Rejetées ce mois',
          dashboard!.rejectedThisMonth.toString(),
          Icons.cancel,
          const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (dashboard == null || dashboard!.chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get current month name
    final now = DateTime.now();
    const monthNames = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    final currentMonth = monthNames[now.month - 1];

    // Find max count for Y axis
    final maxCount = dashboard!.chartData
        .map((e) => e.count)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final yMax = (maxCount + 2).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Infractions par jour - $currentMonth ${now.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: yMax,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = dashboard!.chartData[groupIndex].day;
                      final count = rod.toY.toInt();
                      return BarTooltipItem(
                        'Jour $day\n$count infraction${count > 1 ? 's' : ''}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == value.roundToDouble() && value >= 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < dashboard!.chartData.length) {
                          final day = dashboard!.chartData[idx].day;
                          // Show every 5th day + 1st day
                          if (day == 1 || day % 5 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                    left: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                barGroups:
                    dashboard!.chartData.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final point = entry.value;
                      final today = DateTime.now().day;
                      final isToday = point.day == today;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: point.count.toDouble(),
                            color:
                                isToday
                                    ? const Color(0xFF00d4ff)
                                    : AppTheme.purpleAccent,
                            width: dashboard!.chartData.length > 20 ? 4 : 8,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bgColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInfractions() {
    if (dashboard == null || dashboard!.recentInfractions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter infractions by selected status
    final filtered =
        _selectedStatusFilter == 'TOUS'
            ? dashboard!.recentInfractions
            : dashboard!.recentInfractions
                .where((i) => i.statut == _selectedStatusFilter)
                .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Toutes les infractions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Status filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'TOUS',
                'Tous',
                Colors.blueGrey,
                dashboard!.recentInfractions.length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'SOUS_VERIFICATION',
                'En attente',
                const Color(0xFFFFC107),
                dashboard!.recentInfractions
                    .where((i) => i.statut == 'SOUS_VERIFICATION')
                    .length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'ACCEPTEE',
                'Acceptées',
                const Color(0xFF4CAF50),
                dashboard!.recentInfractions
                    .where((i) => i.statut == 'ACCEPTEE')
                    .length,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'CLASSEE_SANS_SUITE',
                'Rejetées',
                const Color(0xFFE53935),
                dashboard!.recentInfractions
                    .where((i) => i.statut == 'CLASSEE_SANS_SUITE')
                    .length,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkBgAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Aucune infraction avec ce statut',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...filtered
              .map((infraction) => _buildInfractionCard(infraction))
              .toList(),
      ],
    );
  }

  Widget _buildFilterChip(String status, String label, Color color, int count) {
    final isSelected = _selectedStatusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : AppTheme.darkBgAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.4 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open contravention details screen
  Future<void> _openContraventionDetails(RecentContravention infraction) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const Center(
            child: CircularProgressIndicator(color: AppTheme.purpleAccent),
          ),
    );
    try {
      final response = await ApiClient.dio.get(
        '/contraventions/ref/${infraction.ref}',
      );
      Navigator.of(context).pop(); // dismiss loading
      if (response.statusCode == 200) {
        final apiData = response.data as Map<String, dynamic>;
        final contravention = Contravention.fromJson(apiData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ContraventionDetailsScreen(contravention: contravention),
          ),
        );
      } else {
        throw Exception('Failed to load contravention details');
      }
    } catch (e) {
      Navigator.of(context).pop();
      // Fallback: navigate with available data (no media)
      final contravention = Contravention(
        rowid: infraction.rowid,
        description: infraction.description,
        media: [],
        status: infraction.statut,
        dateTime: infraction.dateCreation,
        ref: infraction.ref,
        userAuthor: infraction.agentName,
        tiers: infraction.residentName,
        motif: infraction.motif,
        residentAdresse: infraction.residentAdresse,
        residentName: infraction.residentName,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ContraventionDetailsScreen(contravention: contravention),
        ),
      );
    }
  }

  /// Download facture PDF for a contravention
  Future<void> _downloadFacture(RecentContravention infraction) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
    );
    try {
      final response = await ApiClient.dio.get(
        '/contraventions/ref/${infraction.ref}',
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        final apiData = response.data as Map<String, dynamic>;
        final pdfUrl = apiData['facturePdfUrl'] as String?;
        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          final baseUrl = ApiConfig.BACKEND_API_URL;
          final fullUrl = '$baseUrl/$pdfUrl';
          final uri = Uri.parse(fullUrl);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossible d\'ouvrir le PDF'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune facture disponible'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInfractionCard(RecentContravention infraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                infraction.ref,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: infraction.getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  infraction.getStatusLabel(),
                  style: TextStyle(
                    color: infraction.getStatusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            infraction.dateCreation.split('T')[0],
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          Text(
            infraction.motif,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agent: ${infraction.agentName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Résident: ${infraction.residentName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (infraction.statut == 'SOUS_VERIFICATION')
                ElevatedButton(
                  onPressed: () => _openContraventionDetails(infraction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Traiter',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                )
              else if (infraction.statut == 'ACCEPTEE')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openContraventionDetails(infraction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text(
                        'Détails',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () => _downloadFacture(infraction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.download, size: 14),
                      label: const Text(
                        'Facture',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              else
                // CLASSEE_SANS_SUITE or any other status
                ElevatedButton.icon(
                  onPressed: () => _openContraventionDetails(infraction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(Icons.visibility, size: 14),
                  label: const Text(
                    'Détails',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
