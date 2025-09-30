import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Example integration test
// This demonstrates enterprise-level integration testing practices

// Mock app for demonstration
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Flutter App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  bool _isLoggedIn = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleLogin() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise App'),
        actions: [
          TextButton(
            key: const Key('login_button'),
            onPressed: _toggleLogin,
            child: Text(_isLoggedIn ? 'Logout' : 'Login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoggedIn) ...[
              const Text(
                'Welcome! You are logged in.',
                key: Key('welcome_message'),
              ),
              const SizedBox(height: 20),
            ],
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              key: const Key('counter_text'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment_button'),
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Enterprise Flutter App Integration Tests', () {
    testWidgets('should complete full user flow', (tester) async {
      // Launch the app
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Enterprise App'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byKey(const Key('welcome_message')), findsNothing);

      // Test counter functionality
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      // Test login functionality
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // Verify login state
      expect(find.byKey(const Key('welcome_message')), findsOneWidget);
      expect(find.text('Welcome! You are logged in.'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Test logout functionality
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // Verify logout state
      expect(find.byKey(const Key('welcome_message')), findsNothing);
      expect(find.text('Login'), findsOneWidget);

      // Test multiple increments
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('increment_button')));
        await tester.pumpAndSettle();
      }
      
      expect(find.text('6'), findsOneWidget); // 1 from earlier + 5 more
    });

    testWidgets('should handle rapid user interactions', (tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Rapid button presses
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byKey(const Key('increment_button')));
      }
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('should maintain state during navigation', (tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pumpAndSettle();

      // Increment counter
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      // Login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify counter state is maintained
      expect(find.text('1'), findsOneWidget);
      expect(find.byKey(const Key('welcome_message')), findsOneWidget);
    });
  });
}