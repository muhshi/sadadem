import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/dashboard/strategic_indicator_service.dart';
import 'package:Dalem/table/table.dart';
import 'package:Dalem/strategis/strategis.dart';
import 'package:Dalem/utils/page_transitions.dart';

class StrategicDashboardWidget extends StatefulWidget {
  const StrategicDashboardWidget({super.key});

  @override
  State<StrategicDashboardWidget> createState() =>
      _StrategicDashboardWidgetState();
}

class _StrategicDashboardWidgetState extends State<StrategicDashboardWidget> {
  late Future<List<StrategicIndicatorItem>> _indicatorsFuture;

  @override
  void initState() {
    super.initState();
    _indicatorsFuture = StrategicIndicatorService.fetchLiveIndicators();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INDIKATOR STRATEGIS DEMAK',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                      child: Strategis(
                        title: 'Data Strategis',
                        color: BpsTheme.current().cardGradient1.first,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primaryNavy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Indicator Cards Horizontal Carousel
        FutureBuilder<List<StrategicIndicatorItem>>(
          future: _indicatorsFuture,
          initialData: StrategicIndicatorService.getDefaultIndicators(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? StrategicIndicatorService.getDefaultIndicators();

            return SizedBox(
              height: 175,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 6),
                    child: _buildIndicatorCard(context, item),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIndicatorCard(BuildContext context, StrategicIndicatorItem item) {
    final isDeltaPositive = item.deltaPercent >= 0;
    final deltaSign = isDeltaPositive ? '+' : '';
    final deltaText = '$deltaSign${item.deltaPercent.toStringAsFixed(2)}% YoY';

    final Color badgeBg;
    final Color badgeText;
    final IconData trendIcon;

    if (item.isTrendGood) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
      trendIcon = isDeltaPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    } else {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
      trendIcon = isDeltaPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    }

    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              SmoothPageRoute(
                child: DataTableScreen(
                  id: item.id,
                  title: item.title,
                  tableType: item.tableType,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon + Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Big Value + Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      item.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.unit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                // Sparkline Graph
                SizedBox(
                  height: 28,
                  child: _buildMiniSparkline(item.sparklineData, item.gradient.last),
                ),

                // Bottom Row: Trend Arrow Pill + Year
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon, size: 12, color: badgeText),
                          const SizedBox(width: 3),
                          Text(
                            deltaText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: badgeText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.year,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSparkline(List<double> values, Color color) {
    if (values.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) > 0 ? (maxY - minY) * 0.2 : 1.0;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
