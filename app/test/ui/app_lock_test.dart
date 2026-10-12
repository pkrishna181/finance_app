import 'package:arth/core/security/app_lock.dart';
import 'package:arth/ui/screens/privacy_settings_screen.dart';
import 'package:arth/ui/widgets/app_lock_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuth implements Authenticator {
  FakeAuth({this.available = true, this.result = true});
  bool available;
  bool result;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    calls++;
    return result;
  }
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 5; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await t.pump();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget app(FakeAuth auth, DateTime Function() clock) => MaterialApp(
        home: AppLockGate(
          authenticator: auth,
          clock: clock,
          child: const Scaffold(body: Text('SECRET LEDGER')),
        ),
      );

  testWidgets('no lock unless enabled', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(app(auth, DateTime.now));
    await settle(tester);
    expect(find.text('SECRET LEDGER'), findsOneWidget);
    expect(auth.calls, 0);
  });

  testWidgets('locked at launch until unlocked; failed unlock stays locked',
      (tester) async {
    await AppLockSettings().setEnabled(true);
    final auth = FakeAuth(result: false);
    await tester.pumpWidget(app(auth, DateTime.now));
    await settle(tester);
    expect(find.text('Arth is locked'), findsOneWidget);
    expect(find.text('SECRET LEDGER'), findsNothing); // offstage
    expect(auth.calls, 1);

    auth.result = true;
    await tester.tap(find.text('Unlock'));
    await settle(tester);
    expect(find.text('Arth is locked'), findsNothing);
    expect(find.text('SECRET LEDGER'), findsOneWidget);
  });

  testWidgets('re-locks after the timeout in the background only',
      (tester) async {
    await AppLockSettings().setEnabled(true);
    await AppLockSettings().setTimeoutSeconds(60);
    var now = DateTime(2026, 10, 12, 10);
    final auth = FakeAuth();
    await tester.pumpWidget(app(auth, () => now));
    await settle(tester);
    expect(find.text('SECRET LEDGER'), findsOneWidget);

    void cycle(Duration away) {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = now.add(away);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }

    cycle(const Duration(seconds: 20));
    await settle(tester);
    expect(auth.calls, 1); // only the launch unlock

    auth.result = false;
    cycle(const Duration(minutes: 2));
    await settle(tester);
    expect(auth.calls, 2);
    expect(find.text('Arth is locked'), findsOneWidget);
  });

  testWidgets('turning the lock on needs a successful unlock first',
      (tester) async {
    final auth = FakeAuth(available: false);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ListView(children: [AppLockTiles(authenticator: auth)])),
    ));
    await settle(tester);
    await tester.tap(find.text('App lock'));
    await settle(tester);
    expect(await AppLockSettings().isEnabled(), isFalse);
    expect(find.textContaining('Set up a screen lock'), findsOneWidget);

    auth.available = true;
    auth.result = false;
    await tester.tap(find.text('App lock'));
    await settle(tester);
    expect(await AppLockSettings().isEnabled(), isFalse);

    auth.result = true;
    await tester.tap(find.text('App lock'));
    await settle(tester);
    expect(await AppLockSettings().isEnabled(), isTrue);
    expect(find.text('Lock again'), findsOneWidget);
  });

  testWidgets('re-lock covers screens pushed above home', (tester) async {
    await AppLockSettings().setEnabled(true);
    await AppLockSettings().setTimeoutSeconds(0);
    var now = DateTime(2026, 10, 12, 10);
    final auth = FakeAuth();
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('LOAN DETAILS')),
          )),
          child: const Text('open'),
        ),
      ),
      builder: (context, child) => AppLockGate(
        initiallyEnabled: true,
        authenticator: auth,
        clock: () => now,
        child: child!,
      ),
    ));
    await settle(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('LOAN DETAILS'), findsOneWidget);

    auth.result = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(find.text('Arth is locked'), findsOneWidget);
    expect(find.text('LOAN DETAILS'), findsNothing);
  });
}
