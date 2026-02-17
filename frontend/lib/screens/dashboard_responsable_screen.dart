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

  @override
  void initState() {
    super.initState();
    loadDashboard();
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
          const Text(
            'Évolution des infractions (30 jours)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                    left: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        dashboard!.chartData
                            .map(
                              (e) =>
                                  FlSpot(e.day.toDouble(), e.count.toDouble()),
                            )
                            .toList(),
                    isCurved: true,
                    color: AppTheme.purpleAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.purpleAccent.withOpacity(0.2),
                    ),
                  ),
                ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dernières infractions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...dashboard!.recentInfractions
            .map((infraction) => _buildInfractionCard(infraction))
            .toList(),
      ],
    );
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
            '${infraction.motif} - Stationnement interdit',
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
                  onPressed: () async {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(
                        child: CircularProgressIndicator(color: AppTheme.purpleAccent),
                      ),
                    );

                    try {
                      // Fetch full contravention with media from backend API
                      final response = await ApiClient.dio.get('/contraventions/ref/${infraction.ref}');
                      Navigator.of(context).pop(); // dismiss loading

                      if (response.statusCode == 200) {
                        final apiData = response.data as Map<String, dynamic>;
                        
                        // Extract media from API response
                        final mediaList = (apiData['media'] as List<dynamic>? ?? [])
                            .map((e) => ContraventionMediaModels.fromJson(e as Map<String, dynamic>))
                            .toList();

                        // Build contravention using dashboard names (from CSV mock) + API media
                        final contravention = Contravention(
                          rowid: infraction.rowid,
                          description: infraction.description,
                          media: mediaList,
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
                            builder: (context) => ContraventionDetailsScreen(
                              contravention: contravention,
                            ),
                          ),
                        );
                      } else {
                        throw Exception('Failed to load contravention details');
                      }
                    } catch (e) {
                      Navigator.of(context).pop(); // dismiss loading
                      print('⚠️ Error fetching full contravention, falling back: $e');

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
                          builder: (context) => ContraventionDetailsScreen(
                            contravention: contravention,
                          ),
                        ),
                      );
                    }
                  },
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
                    // View details button
                    ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const Center(
                            child: CircularProgressIndicator(color: Colors.green),
                          ),
                        );
                        try {
                          final response = await ApiClient.dio.get('/contraventions/ref/${infraction.ref}');
                          Navigator.of(context).pop();
                          if (response.statusCode == 200) {
                            final apiData = response.data as Map<String, dynamic>;
                            final mediaList = (apiData['media'] as List<dynamic>? ?? [])
                                .map((e) => ContraventionMediaModels.fromJson(e as Map<String, dynamic>))
                                .toList();
                            final contravention = Contravention(
                              rowid: infraction.rowid,
                              description: infraction.description,
                              media: mediaList,
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
                                builder: (context) => ContraventionDetailsScreen(
                                  contravention: contravention,
                                ),
                              ),
                            );
                          } else {
                            throw Exception('Failed to load contravention');
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('Détails', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    // Download facture button
                    ElevatedButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const Center(
                            child: CircularProgressIndicator(color: Colors.orange),
                          ),
                        );
                        try {
                          final response = await ApiClient.dio.get('/contraventions/ref/${infraction.ref}');
                          Navigator.of(context).pop();
                          if (response.statusCode == 200) {
                            final apiData = response.data as Map<String, dynamic>;
                            final pdfUrl = apiData['facturePdfUrl'] as String?;
                            if (pdfUrl != null && pdfUrl.isNotEmpty) {
                              // Build full URL for the PDF
                              final baseUrl = ApiConfig.BACKEND_API_URL;
                              final fullUrl = '$baseUrl/$pdfUrl';
                              final uri = Uri.parse(fullUrl);
                              try {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Impossible d\'ouvrir le PDF'), backgroundColor: Colors.red),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aucune facture disponible'), backgroundColor: Colors.orange),
                              );
                            }
                          }
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      icon: const Icon(Icons.download, size: 14),
                      label: const Text('Facture', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
