import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlp_admin/theme/app_theme.dart';
import 'package:tlp_admin/widgets/brand_mark.dart';

void main() {
  test('the app theme uses the TLP admin palette', () {
    expect(AppTheme.light.colorScheme.primary, AppColors.emerald);
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.canvas);
  });

  testWidgets('the brand mark paints without layout errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BrandMark(size: 48, background: AppColors.forest),
          ),
        ),
      ),
    );

    expect(find.byType(BrandMark), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BrandMark),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
