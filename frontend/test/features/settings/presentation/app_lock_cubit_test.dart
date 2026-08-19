import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/settings/presentation/app_lock_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads the persisted flag on construction', () async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
    final cubit = AppLockCubit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, isTrue);
    await cubit.close();
  });

  test('defaults to false, setEnabled persists, toggle flips', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = AppLockCubit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, isFalse);

    await cubit.setEnabled(true);
    expect(cubit.state, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_lock_enabled'), isTrue);

    await cubit.toggle();
    expect(cubit.state, isFalse);
    await cubit.close();
  });
}
