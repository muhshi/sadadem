import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Dalem/charts/chart_data_parser.dart';

void main() {
  group('ChartDataParser Tests', () {
    test('parseNumeric correctly parses various number formats', () {
      expect(ChartDataParser.parseNumeric(123), 123.0);
      expect(ChartDataParser.parseNumeric('123.45'), 123.45);
      expect(ChartDataParser.parseNumeric('1.234,56'), 1234.56);
      expect(ChartDataParser.parseNumeric('1,234.56'), 1234.56);
      expect(ChartDataParser.parseNumeric('1,837'), 1837.0);
      expect(ChartDataParser.parseNumeric('3,636'), 3636.0);
      expect(ChartDataParser.parseNumeric('42,82'), 42.82);
      expect(ChartDataParser.parseNumeric('12,5'), 12.5);
      expect(ChartDataParser.parseNumeric('-'), isNull);
      expect(ChartDataParser.parseNumeric('null'), isNull);
      expect(ChartDataParser.parseNumeric(''), isNull);
    });

    test('formatIndonesianNumber correctly formats integers and decimals', () {
      expect(ChartDataParser.formatIndonesianNumber(1000), '1.000');
      expect(ChartDataParser.formatIndonesianNumber(1234567), '1.234.567');
      expect(ChartDataParser.formatIndonesianNumber(12.34), '12,34');
      expect(ChartDataParser.formatIndonesianNumber(12.30), '12,3');
    });

    test('calculateYoy computes growth rate correctly for temporal data', () {
      final series = ChartSeries(
        name: 'Penduduk',
        unit: 'ribu',
        points: const [
          ChartDataPoint(label: '2023', value: 100, formattedValue: '100'),
          ChartDataPoint(label: '2024', value: 110, formattedValue: '110'),
        ],
        color: const Color(0xFF000000),
      );

      final yoy = ChartDataParser.calculateYoy(series);
      expect(yoy, isNotNull);
      expect(yoy!.currentValue, 110.0);
      expect(yoy.previousValue, 100.0);
      expect(yoy.deltaPercent, 10.0);
      expect(yoy.isPositive, isTrue);
      expect(yoy.deltaPercentText, '+10.00%');
    });

    test('calculateYoy returns null for non-temporal labels (categories/regions)', () {
      final series = ChartSeries(
        name: 'Penduduk Bonang',
        unit: 'Jiwa',
        points: const [
          ChartDataPoint(label: 'Jatimulyo', value: 1837, formattedValue: '1.837'),
          ChartDataPoint(label: 'Krajanbogo', value: 2034, formattedValue: '2.034'),
        ],
        color: const Color(0xFF000000),
      );

      final yoy = ChartDataParser.calculateYoy(series);
      expect(yoy, isNull);
    });

    test('parseSimdasi extracts columns and rows into plottable series', () {
      final sampleSimdasi = {
        'kolom': {
          '1': {
            'nama_variabel': 'Jumlah Penduduk',
            'satuan': 'Jiwa',
            'unit_multiplier_desc': 'ribu',
          }
        },
        'data': [
          {'label': 'Ignored header row'},
          {
            'label': 'Mranggen',
            'variables': {
              '1': {'value': 175.5}
            }
          },
          {
            'label': 'Karangawen',
            'variables': {
              '1': {'value': 98.2}
            }
          }
        ]
      };

      final seriesList = ChartDataParser.parseSimdasi(sampleSimdasi);
      expect(seriesList.length, 1);
      expect(seriesList.first.name, 'Jumlah Penduduk');
      expect(seriesList.first.unit, 'ribu Jiwa');
      expect(seriesList.first.points.length, 2);
      expect(seriesList.first.points[0].label, 'Mranggen');
      expect(seriesList.first.points[0].value, 175.5);
      expect(seriesList.first.points[1].label, 'Karangawen');
      expect(seriesList.first.points[1].value, 98.2);
    });

    test('parseDynamic filters out years below 2023 (n-3 rule, min 2023)', () {
      final sampleDynamic = {
        'var': [
          {'val': 1, 'label': 'IPM', 'unit': ''}
        ],
        'vervar': [
          {'val': 1, 'label': 'Demak'}
        ],
        'turvar': <Map<String, dynamic>>[],
        'turtahun': <Map<String, dynamic>>[],
        'tahun': [
          {'val': 100, 'label': '2019'},
          {'val': 101, 'label': '2020'},
          {'val': 102, 'label': '2021'},
          {'val': 103, 'label': '2022'},
          {'val': 104, 'label': '2023'},
          {'val': 105, 'label': '2024'},
          {'val': 106, 'label': '2025'},
        ],
        'datacontent': {
          '1101000': '71.5',
          '1101010': '72.0',
          '1101020': '72.8',
          '1101030': '73.4',
          '1101040': '74.2',
          '1101050': '74.8',
          '1101060': '75.08',
        }
      };

      final seriesList = ChartDataParser.parseDynamic(sampleDynamic);
      expect(seriesList.length, 1);
      final points = seriesList.first.points;
      final labels = points.map((p) => p.label).toList();
      expect(labels, ['2023', '2024', '2025']);
      expect(labels.contains('2019'), isFalse);
      expect(labels.contains('2020'), isFalse);
      expect(labels.contains('2021'), isFalse);
      expect(labels.contains('2022'), isFalse);
    });

    test('parseDynamic separates turvar cleanly without duplicate year labels', () {
      final sampleMultiTurvar = {
        'var': [
          {'val': 10, 'label': 'Penduduk', 'unit': 'Jiwa'}
        ],
        'vervar': [
          {'val': 1, 'label': 'Demak'}
        ],
        'turvar': [
          {'val': 21, 'label': 'Laki-laki'},
          {'val': 22, 'label': 'Perempuan'},
        ],
        'turtahun': <Map<String, dynamic>>[],
        'tahun': [
          {'val': 104, 'label': '2023'},
          {'val': 105, 'label': '2024'},
        ],
        'datacontent': {
          '110211040': '500',
          '110211050': '520',
          '110221040': '490',
          '110221050': '510',
        }
      };

      final seriesList = ChartDataParser.parseDynamic(sampleMultiTurvar);
      expect(seriesList.length, 2);
      expect(seriesList[0].name, 'Laki-laki');
      expect(seriesList[0].points.map((p) => p.label).toList(), ['2023', '2024']);
      expect(seriesList[0].points.map((p) => p.value).toList(), [500.0, 520.0]);

      expect(seriesList[1].name, 'Perempuan');
      expect(seriesList[1].points.map((p) => p.label).toList(), ['2023', '2024']);
      expect(seriesList[1].points.map((p) => p.value).toList(), [490.0, 510.0]);
    });

    test('parseDynamic supports monthly sub-annual turtahun (e.g. Inflasi)', () {
      final sampleMonthly = {
        'var': [
          {'val': 5, 'label': 'Laju Inflasi', 'unit': '%'}
        ],
        'vervar': [
          {'val': 1, 'label': 'Jawa Tengah'}
        ],
        'turvar': <Map<String, dynamic>>[],
        'turtahun': [
          {'val': 1, 'label': 'Januari'},
          {'val': 2, 'label': 'Februari'},
          {'val': 13, 'label': 'Tahunan'}, // should be excluded from monthly trend
        ],
        'tahun': [
          {'val': 104, 'label': '2024'},
        ],
        'datacontent': {
          '1501041': '0.15',
          '1501042': '0.35',
          '15010413': '2.10',
        }
      };

      final seriesList = ChartDataParser.parseDynamic(sampleMonthly);
      expect(seriesList.length, 1);
      final points = seriesList.first.points;
      expect(points.length, 2); // Jan & Feb, excluding Tahunan
      expect(points[0].label, 'Jan');
      expect(points[0].value, 0.15);
      expect(points[1].label, 'Feb');
      expect(points[1].value, 0.35);
    });

    test('parseStaticHtml extracts series from HTML table with numeric columns', () {
      const sampleHtml = '''
        <table class="excel">
          <tr><td>Judul Tabel Laporan</td><td></td><td></td></tr>
          <tr><td>Nama Desa</td><td>Laki-laki</td><td>Perempuan</td><td>Jumlah</td></tr>
          <tr><td>Desa A</td><td>1,250</td><td>1,200</td><td>2,450</td></tr>
          <tr><td>Desa B</td><td>2,100</td><td>2,050</td><td>4,150</td></tr>
          <tr><td>Catatan: Sumber data BPS</td><td></td><td></td><td></td></tr>
        </table>
      ''';

      final seriesList = ChartDataParser.parseStaticHtml(sampleHtml);
      expect(seriesList.length, 3);
      expect(seriesList[0].name, 'Laki-laki');
      expect(seriesList[0].points.length, 2);
      expect(seriesList[0].points[0].label, 'Desa A');
      expect(seriesList[0].points[0].value, 1250.0);
      expect(seriesList[0].points[1].label, 'Desa B');
      expect(seriesList[0].points[1].value, 2100.0);

      expect(seriesList[2].name, 'Jumlah');
      expect(seriesList[2].points[0].value, 2450.0);
      expect(seriesList[2].points[1].value, 4150.0);
    });

    test('parseStaticHtml returns empty list for narrative HTML without numeric table', () {
      const narrativeHtml = '<p>Berdasarkan keputusan kepala BPS nomor 123 tahun 2024 tentang pedoman kerja...</p>';
      final seriesList = ChartDataParser.parseStaticHtml(narrativeHtml);
      expect(seriesList.isEmpty, isTrue);
    });

    test('isAggregateRowLabel detects all variants of total and summary rows', () {
      expect(ChartDataParser.isAggregateRowLabel('Jumlah'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Total'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Jumlah/<i>Total</i>'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Jumlah / Total'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Jumlah (Total)'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Total / Jumlah'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Jumlah Total'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Grand Total'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Rata-rata'), isTrue);
      expect(ChartDataParser.isAggregateRowLabel('Average'), isTrue);

      // Non-aggregates
      expect(ChartDataParser.isAggregateRowLabel('0-4'), isFalse);
      expect(ChartDataParser.isAggregateRowLabel('20-24'), isFalse);
      expect(ChartDataParser.isAggregateRowLabel('Kecamatan Sayung'), isFalse);
      expect(ChartDataParser.isAggregateRowLabel('Jumlah Penduduk Laki-Laki'), isFalse);
    });

    test('parseSimdasi filters out Jumlah/<i>Total</i> from points and saves totalValue', () {
      final samplePopulationTable = {
        'kolom': {
          '1': {
            'nama_variabel': 'Penduduk (Laki-Laki)',
            'satuan': 'ribu',
          }
        },
        'data': [
          {
            'label': '0-4',
            'variables': {'1': {'value': '45.2'}}
          },
          {
            'label': '5-9',
            'variables': {'1': {'value': '46.1'}}
          },
          {
            'label': '10-14',
            'variables': {'1': {'value': '47.8'}}
          },
          {
            'label': 'Jumlah/<i>Total</i>',
            'variables': {'1': {'value': '643.6'}}
          }
        ]
      };

      final seriesList = ChartDataParser.parseSimdasi(samplePopulationTable);
      expect(seriesList.length, 1);
      final series = seriesList.first;

      // Ensure points ONLY contain the 3 age groups, not the 643.6k total!
      expect(series.points.length, 3);
      expect(series.points.map((p) => p.label).toList(), ['0-4', '5-9', '10-14']);
      expect(series.points.map((p) => p.value).toList(), [45.2, 46.1, 47.8]);

      // Ensure totalValue is captured for the KPI banner
      expect(series.totalValue, 643.6);
      expect(series.totalLabel, 'Jumlah/Total');
      expect(series.maxValue, 47.8); // Not 643.6! Scale is preserved!
    });

    test('sanitizeSeries removes subdistrict aggregate row (e.g. Kecamatan Sayung) based on sum matching', () {
      // 3 villages totaling 12000, plus a 4th row "KECAMATAN SAYUNG" = 12000
      final rawSeries = ChartSeries(
        name: 'Laki-laki',
        unit: 'Jiwa',
        points: const [
          ChartDataPoint(label: 'Bulusari', value: 3000, formattedValue: '3.000'),
          ChartDataPoint(label: 'Karangasem', value: 4000, formattedValue: '4.000'),
          ChartDataPoint(label: 'Loireng', value: 5000, formattedValue: '5.000'),
          ChartDataPoint(label: 'KECAMATAN SAYUNG', value: 12000, formattedValue: '12.000'),
        ],
        color: const Color(0xFFE8611A),
      );

      final sanitized = ChartDataParser.sanitizeSeries(rawSeries);
      expect(sanitized.points.length, 3);
      expect(sanitized.points.map((p) => p.label).toList(), ['Bulusari', 'Karangasem', 'Loireng']);
      expect(sanitized.totalValue, 12000);
      expect(sanitized.totalLabel, 'KECAMATAN SAYUNG');
      expect(sanitized.maxValue, 5000);
    });

    test('ChartSeries.shouldHideBottomTitles accurately detects dense categorical data vs temporal', () {
      // Temporal series with 4 years -> should NOT hide
      final temporalSeries = ChartSeries(
        name: 'Temporal',
        unit: '',
        points: const [
          ChartDataPoint(label: '2023', value: 10, formattedValue: '10'),
          ChartDataPoint(label: '2024', value: 12, formattedValue: '12'),
          ChartDataPoint(label: '2025', value: 14, formattedValue: '14'),
          ChartDataPoint(label: '2026', value: 16, formattedValue: '16'),
        ],
        color: Colors.blue,
      );
      expect(temporalSeries.shouldHideBottomTitles, isFalse);

      // Categorical with 19 villages -> should hide
      final denseVillages = ChartSeries(
        name: 'Villages',
        unit: 'Jiwa',
        points: List.generate(
          19,
          (i) => ChartDataPoint(label: 'Desa $i', value: 100.0 * i, formattedValue: '${100 * i}'),
        ),
        color: Colors.orange,
      );
      expect(denseVillages.shouldHideBottomTitles, isTrue);

      // Categorical with long labels (e.g. "Karangasem" is 10 chars > 7 chars) -> should hide
      final longLabelVillages = ChartSeries(
        name: 'Villages',
        unit: 'Jiwa',
        points: const [
          ChartDataPoint(label: 'Karangasem', value: 100, formattedValue: '100'),
          ChartDataPoint(label: 'Purwosari', value: 120, formattedValue: '120'),
        ],
        color: Colors.green,
      );
      expect(longLabelVillages.shouldHideBottomTitles, isTrue);

      // Categorical with few short labels (e.g. "Kota", "Desa") -> should NOT hide
      final shortLabel = ChartSeries(
        name: 'Area',
        unit: '',
        points: const [
          ChartDataPoint(label: 'Kota', value: 50, formattedValue: '50'),
          ChartDataPoint(label: 'Desa', value: 50, formattedValue: '50'),
        ],
        color: Colors.teal,
      );
      expect(shortLabel.shouldHideBottomTitles, isFalse);
    });
  });
}
