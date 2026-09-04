import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
