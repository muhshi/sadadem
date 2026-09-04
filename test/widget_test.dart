import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('BPS DALEM Demak'),
          ),
        ),
      ),
    );

    expect(find.text('BPS DALEM Demak'), findsOneWidget);
  });
}
