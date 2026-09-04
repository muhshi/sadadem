import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/charts/chart_data_parser.dart';

enum ChartType { line, bar, pie }

class InteractiveChartView extends StatefulWidget {
  final String title;
  final List<ChartSeries> seriesList;
  final String? subtitle;

  const InteractiveChartView({
    super.key,
    required this.title,
    required this.seriesList,
    this.subtitle,
  });

  @override
  State<InteractiveChartView> createState() => _InteractiveChartViewState();
}

class _InteractiveChartViewState extends State<InteractiveChartView> {
  final GlobalKey _chartCaptureKey = GlobalKey();
  ChartType _selectedType = ChartType.line;
  int _selectedSeriesIndex = 0;
  int? _touchedPieIndex;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _autoSelectChartType();
  }

  @override
  void didUpdateWidget(covariant InteractiveChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seriesList != widget.seriesList) {
      _autoSelectChartType();
    }
  }

  void _autoSelectChartType() {
    if (widget.seriesList.isEmpty) return;
    final first = widget.seriesList.first;
    if (first.points.isEmpty) return;

    // Check if points are time-series (years or months/quarters)
    final isTimeSeries = first.points.every((p) {
      final l = p.label.trim();
      return RegExp(r'^(?:19|20)\d{2}$').hasMatch(l) ||
          RegExp(r'^(?:Jan|Feb|Mar|Apr|Mei|Jun|Jul|Agu|Sep|Okt|Nov|Des)', caseSensitive: false).hasMatch(l) ||
          RegExp(r'^\d{2}$').hasMatch(l) ||
          RegExp(r'\d{2}$').hasMatch(l);
    });

    if (!isTimeSeries) {
      _selectedType = ChartType.bar;
    } else {
      _selectedType = ChartType.line;
    }
  }

  ChartSeries? get _activeSeries {
    if (widget.seriesList.isEmpty) return null;
    if (_selectedSeriesIndex >= widget.seriesList.length) {
      return widget.seriesList.first;
    }
    return widget.seriesList[_selectedSeriesIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesList.isEmpty) {
      return _buildEmptyState();
    }

    final series = _activeSeries!;
    final yoy = ChartDataParser.calculateYoy(series);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Chart Type Selector & Export Bar
        _buildControlHeader(),
        const SizedBox(height: 12),

        // 2. Multi-Series Selector Chips (if > 1 series)
        if (widget.seriesList.length > 1) ...[
          _buildSeriesChips(),
          const SizedBox(height: 12),
        ],

        // 3. Capturable Chart Area (Wrapped in RepaintBoundary for PNG Export)
        RepaintBoundary(
          key: _chartCaptureKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart Title & Subtitle inside capture
                Text(
                  widget.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],

                // YoY Summary KPI Banner
                if (yoy != null) ...[
                  const SizedBox(height: 12),
                  _buildYoyBanner(yoy),
                ],

                const SizedBox(height: 20),

                // Core Chart Widget
                SizedBox(
                  height: 280,
                  child: _buildSelectedChart(series),
                ),

                const SizedBox(height: 12),
                // Footer inside capture (Watermark / Branding)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Satuan: ${series.unit.isNotEmpty ? series.unit : '-'}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BPS DALEM Kab. Demak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        // 4. Quick Actions (Export & Share)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined_rounded,
              size: 54, color: AppColors.primaryLight.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            'Data Grafik Tidak Tersedia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tabel ini tidak memiliki nilai numerik yang dapat divisualisasikan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlHeader() {
    return Row(
      children: [
        // Chart Type Segmented Buttons
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                _buildTypeSegment(
                  type: ChartType.line,
                  icon: Icons.show_chart_rounded,
                  label: 'Garis',
                ),
                _buildTypeSegment(
                  type: ChartType.bar,
                  icon: Icons.bar_chart_rounded,
                  label: 'Batang',
                ),
                _buildTypeSegment(
                  type: ChartType.pie,
                  icon: Icons.pie_chart_rounded,
                  label: 'Donut',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSegment({
    required ChartType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primaryNavy : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryNavy : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(widget.seriesList.length, (idx) {
          final s = widget.seriesList[idx];
          final isSelected = _selectedSeriesIndex == idx;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(s.name),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
              backgroundColor: const Color(0xFFF8FAFC),
              selectedColor: s.color,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? s.color : const Color(0xFFCBD5E1),
                ),
              ),
              onSelected: (val) {
                setState(() {
                  _selectedSeriesIndex = idx;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildYoyBanner(YoyComparison yoy) {
    final Color badgeBg;
    final Color badgeText;
    final IconData trendIcon;

    if (yoy.isPositive) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF059669);
      trendIcon = Icons.trending_up_rounded;
    } else if (yoy.isNegative) {
      badgeBg = const Color(0xFFFEF2F2);
      badgeText = const Color(0xFFDC2626);
      trendIcon = Icons.trending_down_rounded;
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = const Color(0xFF64748B);
      trendIcon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perubahan (${yoy.previousPeriod} ➔ ${yoy.currentPeriod})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ChartDataParser.formatIndonesianNumber(yoy.currentValue)} ${yoy.unit}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendIcon, size: 16, color: badgeText),
                const SizedBox(width: 4),
                Text(
                  yoy.deltaPercentText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChart(ChartSeries series) {
    switch (_selectedType) {
      case ChartType.line:
        return _buildLineChart(series);
      case ChartType.bar:
        return _buildBarChart(series);
      case ChartType.pie:
        return _buildPieChart(series);
    }
  }

  Widget _buildLineChart(ChartSeries series) {
    final spots = <FlSpot>[];
    for (int i = 0; i < series.points.length; i++) {
      spots.add(FlSpot(i.toDouble(), series.points[i].value));
    }

    final double rawMinY = series.minValue < 0 ? series.minValue * 1.15 : 0.0;
    double rawMaxY = series.maxValue > 0 ? series.maxValue * 1.15 : 10.0;
    if (rawMinY >= rawMaxY) {
      rawMaxY = rawMinY + 10.0;
    }

    final double yRange = (rawMaxY - rawMinY) <= 0 ? 10.0 : (rawMaxY - rawMinY);
    final double yInterval = ChartDataParser.calculateNiceYInterval(yRange, targetTicks: 4);
    final double minY = (rawMinY / yInterval).floorToDouble() * yInterval;
    final double maxY = (rawMaxY / yInterval).ceilToDouble() * yInterval;
    final int yDecimals = (yInterval < 0.1) ? 2 : (yInterval < 1.0 ? 1 : 0);
    final double leftReservedSize = series.maxValue >= 1000000
        ? 58.0
        : (series.maxValue >= 10000 || series.minValue <= -1000)
            ? 48.0
            : 36.0;

    final double minX = 0.0;
    final double maxX = spots.length > 1 ? (spots.length - 1).toDouble() : 1.0;
    final int count = series.points.length;

    // Calculate smart x-axis interval so at most 5 to 6 labels appear, preventing any overlap
    final double xInterval;
    if (count <= 6) {
      xInterval = 1.0;
    } else if (count <= 12) {
      xInterval = 2.0; // 6 labels
    } else if (count <= 24) {
      xInterval = 4.0; // 6 labels
    } else if (count <= 36) {
      xInterval = 6.0; // 6 labels
    } else if (count % 12 == 0) {
      // Full yearly monthly data (e.g. 48, 60, 72 months) -> step every 12 months (start of each year)
      xInterval = 12.0;
    } else {
      xInterval = ((count - 1) / 5.0).ceilToDouble();
    }

    return LineChart(
      key: ValueKey('${series.name}_${series.points.length}_line'),
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY <= minY ? minY + 10 : maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (val) => const FlLine(
            color: Color(0xFFE2E8F0),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: leftReservedSize,
              interval: yInterval,
              getTitlesWidget: (val, meta) {
                final remainder = (val % yInterval).abs();
                final isNearTick = remainder < (yInterval * 0.05) ||
                    (yInterval - remainder).abs() < (yInterval * 0.05);
                if (!isNearTick) {
                  return const SizedBox.shrink();
                }

                return Text(
                  ChartDataParser.formatIndonesianNumber(val, maxDecimals: yDecimals),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xInterval,
              getTitlesWidget: (val, meta) {
                final idx = val.round();
                if (idx < 0 || idx >= series.points.length) {
                  return const SizedBox.shrink();
                }

                // Strictly filter to exact ticks of xInterval to prevent intermediate or boundary clutter
                final remainder = val % xInterval;
                final isNearTick = remainder < 0.05 || (xInterval - remainder) < 0.05;
                if (!isNearTick) {
                  return const SizedBox.shrink();
                }

                final label = series.points[idx].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                final label = (idx >= 0 && idx < series.points.length)
                    ? series.points[idx].label
                    : '';
                final val = ChartDataParser.formatIndonesianNumber(spot.y);
                final unitStr = series.unit.isNotEmpty ? ' ${series.unit}' : '';
                return LineTooltipItem(
                  '$label\n$val$unitStr',
                  GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: spots.length > 1,
            curveSmoothness: 0.35,
            color: series.color,
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: series.points.length <= 16,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4.0,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: series.color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  series.color.withValues(alpha: 0.28),
                  series.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ChartSeries series) {
    final double rawMinY = series.minValue < 0 ? series.minValue * 1.18 : 0.0;
    double rawMaxY = series.maxValue > 0 ? series.maxValue * 1.18 : 10.0;
    if (rawMinY >= rawMaxY) {
      rawMaxY = rawMinY + 10.0;
    }

    final double yRange = (rawMaxY - rawMinY) <= 0 ? 10.0 : (rawMaxY - rawMinY);
    final double yInterval = ChartDataParser.calculateNiceYInterval(yRange, targetTicks: 4);
    final double minY = (rawMinY / yInterval).floorToDouble() * yInterval;
    final double maxY = (rawMaxY / yInterval).ceilToDouble() * yInterval;
    final int yDecimals = (yInterval < 0.1) ? 2 : (yInterval < 1.0 ? 1 : 0);
    final double leftReservedSize = series.maxValue >= 1000000
        ? 58.0
        : (series.maxValue >= 10000 || series.minValue <= -1000)
            ? 48.0
            : 36.0;

    final groups = <BarChartGroupData>[];
    final count = series.points.length;

    final double xInterval;
    if (count <= 6) {
      xInterval = 1.0;
    } else if (count <= 12) {
      xInterval = 2.0;
    } else if (count <= 24) {
      xInterval = 4.0;
    } else if (count <= 36) {
      xInterval = 6.0;
    } else if (count % 12 == 0) {
      xInterval = 12.0;
    } else {
      xInterval = ((count - 1) / 5.0).ceilToDouble();
    }

    final double barWidth = (count > 30)
        ? 3.5
        : (count > 15)
            ? 7.0
            : (count > 8)
                ? 13.0
                : 22.0;

    for (int i = 0; i < series.points.length; i++) {
      final p = series.points[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: p.value,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  series.color,
                  series.color.withValues(alpha: 0.75),
                ],
              ),
              width: barWidth,
              borderRadius: BorderRadius.vertical(top: Radius.circular(barWidth > 6 ? 6 : 2)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      key: ValueKey('${series.name}_${series.points.length}_bar'),
      BarChartData(
        minY: minY,
        maxY: maxY <= minY ? minY + 10 : maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (val) => const FlLine(
            color: Color(0xFFE2E8F0),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: leftReservedSize,
              interval: yInterval,
              getTitlesWidget: (val, meta) {
                final remainder = (val % yInterval).abs();
                final isNearTick = remainder < (yInterval * 0.05) ||
                    (yInterval - remainder).abs() < (yInterval * 0.05);
                if (!isNearTick) {
                  return const SizedBox.shrink();
                }

                return Text(
                  ChartDataParser.formatIndonesianNumber(val, maxDecimals: yDecimals),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: xInterval,
              getTitlesWidget: (val, meta) {
                final idx = val.round();
                if (idx < 0 || idx >= series.points.length) {
                  return const SizedBox.shrink();
                }
                final remainder = val % xInterval;
                final isNearTick = remainder < 0.05 || (xInterval - remainder) < 0.05;
                if (!isNearTick) {
                  return const SizedBox.shrink();
                }

                final label = series.points[idx].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = series.points[groupIndex].label;
              final val = ChartDataParser.formatIndonesianNumber(rod.toY);
              final unitStr = series.unit.isNotEmpty ? ' ${series.unit}' : '';
              return BarTooltipItem(
                '$label\n$val$unitStr',
                GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        barGroups: groups,
      ),
    );
  }

  Widget _buildPieChart(ChartSeries series) {
    // Only take top 6 slices + 'Lainnya' if series has too many points
    final total = series.points.fold<double>(0, (sum, p) => sum + (p.value > 0 ? p.value : 0));
    if (total <= 0) {
      return Center(
        child: Text(
          'Tidak dapat menampilkan porsi pie chart (total = 0).',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
        ),
      );
    }

    final maxSlices = 6;
    final displayPoints = <ChartDataPoint>[];

    if (series.points.length <= maxSlices) {
      displayPoints.addAll(series.points);
    } else {
      displayPoints.addAll(series.points.take(maxSlices - 1));
      final restSum = series.points.skip(maxSlices - 1).fold<double>(0, (s, p) => s + p.value);
      displayPoints.add(
        ChartDataPoint(
          label: 'Lainnya',
          value: restSum,
          formattedValue: ChartDataParser.formatIndonesianNumber(restSum),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < displayPoints.length; i++) {
      final p = displayPoints[i];
      final isTouched = i == _touchedPieIndex;
      final radius = isTouched ? 65.0 : 54.0;
      final percent = (p.value / total) * 100.0;
      final color = ChartDataParser.seriesColors[i % ChartDataParser.seriesColors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: p.value,
          title: percent >= 5 ? '${percent.toStringAsFixed(1)}%' : '',
          radius: radius,
          titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: isTouched ? 13 : 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            key: ValueKey('${series.name}_${series.points.length}_pie'),
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(displayPoints.length, (i) {
            final p = displayPoints[i];
            final color = ChartDataParser.seriesColors[i % ChartDataParser.seriesColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  p.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryNavy, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          onPressed: _isExporting ? null : _exportChartImage,
          icon: _isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.image_outlined, color: Colors.white, size: 20),
          label: Text(
            _isExporting ? 'Menyimpan Grafik...' : 'Simpan Grafik (.png)',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportChartImage() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // 1. Capture RepaintBoundary as PNG bytes
      final boundary =
          _chartCaptureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Gagal membaca canvas grafik.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Gagal mengonversi gambar.');
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Prepare file path in external storage / downloads
      Directory? targetDir;
      try {
        final extDir = Directory('/storage/emulated/0/Download/Dalem');
        if (await extDir.exists() || await extDir.create(recursive: true).then((_) => true)) {
          targetDir = extDir;
        }
      } catch (_) {}

      targetDir ??= await getApplicationDocumentsDirectory();

      final safeName = widget.title
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      final fileName = 'Grafik_${safeName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;

      // 3. Show Success Modal with Share & Open option
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Grafik Tersimpan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gambar grafik berhasil disimpan dengan resolusi tinggi di:\n',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF475569)),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    file.path,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Share.shareXFiles([XFile(file.path)], text: 'Grafik: ${widget.title}');
                },
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Bagikan'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor grafik: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
