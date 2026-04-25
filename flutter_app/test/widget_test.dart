import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/api/app_api_client.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('renders the Flutter concept shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      AncientOccupationFlutterApp(
        apiClient: AppApiClient(baseUrl: '', debugUserId: '', bearerToken: ''),
      ),
    );

    expect(find.text('Ancient Occupation to App'), findsOneWidget);
    expect(find.text('Whipping Boy'), findsWidgets);
    expect(find.text('Royal Taster'), findsOneWidget);
  });
}
