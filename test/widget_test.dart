// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neighbour_services/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: '1:1234567890:android:abcdef',
          messagingSenderId: '1234567890',
          projectId: 'test-project',
        ),
      );
    }
    await tester.pumpWidget(
      const ProviderScope(child: NeighbourServicesApp()),
    );
    await tester.pump();
    expect(find.text('Phone verification'), findsOneWidget);
  }, skip: true);
}
