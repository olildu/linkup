import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/utils/debouncer_class.dart';

void main() {
  test('run executes the action after the delay', () async {
    final debouncer = Debouncer(milliseconds: 10);
    var ran = 0;
    debouncer.run(() => ran++);
    expect(ran, 0);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(ran, 1);
  });

  test('rapid calls cancel the previous timer so only the last action runs', () async {
    final debouncer = Debouncer(milliseconds: 20);
    final calls = <String>[];
    debouncer.run(() => calls.add('first'));
    debouncer.run(() => calls.add('second'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(calls, ['second']);
  });
}
