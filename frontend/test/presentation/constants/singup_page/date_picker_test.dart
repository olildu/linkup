import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/constants/singup_page/date_picker.dart';
import 'package:linkup/presentation/components/signup_page/picker_builder_component.dart';
import '../../../test_helper.dart';

void main() {
  group('DatePicker', () {
    testWidgets('renders 3 pickers (Month, Day, Year) and Age text', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DatePicker(onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      // BuildPicker is used 3 times
      expect(find.byType(BuildPicker), findsNWidgets(3));
      // Check for the main calculated text
      expect(find.textContaining('Age'), findsOneWidget);
    });

    testWidgets('calls onChanged with a valid initial date', (tester) async {
      DateTime? initialDate;
      await tester.pumpWidget(buildTestWidget(
        DatePicker(onChanged: (date) => initialDate = date),
      ));
      await tester.pumpAndSettle();

      expect(initialDate, isNotNull);
      // The max allowed age is 18, so the initial date must be before 18 years ago.
      expect(initialDate!.isBefore(DateTime.now().subtract(const Duration(days: 365 * 18))), isTrue);
    });
  });
}