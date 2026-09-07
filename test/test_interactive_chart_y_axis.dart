import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Dalem/charts/chart_data_parser.dart';
import 'package:Dalem/charts/interactive_chart_view.dart';

void main() {
  testWidgets('InteractiveChartView renders clean Y axis and X axis without duplicate titles', (tester) async {
    // Generate 60 points representing monthly inflation across 5 years:
    // 2012, 2013, 2014, 2015, 2018
    final years = ['2012', '2013', '2014', '2015', '2018'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final points = <ChartDataPoint>[];
    
    int index = 0;
    for (final year in years) {
      final shortYear = year.substring(2);
      for (final month in months) {
        // Values fluctuating between -0.8 and 3.8
        double val = 0.5 + (index % 5 == 0 ? 3.0 : (index % 7 == 0 ? -1.0 : 0.4));
        if (index == 15) val = 3.8;
        if (index == 20) val = -0.9;
        points.add(ChartDataPoint(
          label: "$month '$shortYear",
          value: val,
          formattedValue: val.toStringAsFixed(2),
        ));
        index++;
      }
    }

    final series = ChartSeries(
      name: 'Inflasi (Persen)',
      unit: 'Persen',
      points: points,
      color: Colors.orange,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              height: 700,
              child: InteractiveChartView(
                title: 'Inflasi (Persen)',
                seriesList: [series],
                subtitle: 'Sumber Data BPS Kabupaten Demak',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find all Text widgets
    final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();
    final texts = textWidgets.map((t) => t.data ?? '').where((s) => s.isNotEmpty).toList();
    
    print('=== ALL RENDERED TEXTS ===');
    for (final t in texts) {
      print('TEXT: "$t"');
    }
  });

  testWidgets('InteractiveChartView renders BarChart with negative values cleanly', (tester) async {
    final pdrbSeries = ChartSeries(
      name: 'Laju Pertumbuhan PDRB ADHK Seri 2010 Menurut Lapangan Usaha (Persen)',
      unit: 'Persen',
      points: [
        ChartDataPoint(label: '2023', value: 4.9, formattedValue: '4,90'),
        ChartDataPoint(label: '2024', value: 2.1, formattedValue: '2,10'),
        ChartDataPoint(label: '2025', value: -1.27, formattedValue: '-1,27'),
      ],
      color: Colors.orange,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: InteractiveChartView(
                title: 'Laju Pertumbuhan PDRB ADHK Seri 2010 Menurut Lapangan Usaha (Persen)',
                seriesList: [pdrbSeries],
                subtitle: 'Sumber Data BPS Kabupaten Demak',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap "Batang"
    await tester.tap(find.text('Batang'));
    await tester.pumpAndSettle();

    expect(find.byType(BarChart), findsOneWidget);

    final barChart = tester.widget<BarChart>(find.byType(BarChart));
    expect(barChart.data.minY, lessThanOrEqualTo(-2.0));
    expect(barChart.data.maxY, greaterThanOrEqualTo(6.0));

    // Positive rod (2023, value 4.9): top is rounded, bottom is flat at baseline
    final posRod = barChart.data.barGroups[0].barRods[0];
    expect(posRod.borderRadius!.topLeft.x, greaterThan(0));
    expect(posRod.borderRadius!.bottomLeft.x, equals(0));

    // Negative rod (2025, value -1.27): bottom is rounded, top is flat at baseline
    final negRod = barChart.data.barGroups[2].barRods[0];
    expect(negRod.borderRadius!.topLeft.x, equals(0));
    expect(negRod.borderRadius!.bottomLeft.x, greaterThan(0));
  });
}

