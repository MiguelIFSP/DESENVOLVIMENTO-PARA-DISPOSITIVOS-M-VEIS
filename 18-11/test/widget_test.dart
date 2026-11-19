// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/trufas_app.dart';

void main() {
  testWidgets('Tela inicial mostra login e cadastro', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SistemaTrufasApp());
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);
  });
}
