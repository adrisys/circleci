import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Example widget test for login form
// This demonstrates enterprise-level widget testing practices

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onSubmit,
    this.onCredentialsChanged,
  });

  final VoidCallback? onSubmit;
  final void Function(String, String)? onCredentialsChanged;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: const Key('email_field'),
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
            onChanged: (value) {
              widget.onCredentialsChanged
                  ?.call(value, _passwordController.text);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('password_field'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onChanged: (value) {
              widget.onCredentialsChanged?.call(_emailController.text, value);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('submit_button'),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onSubmit?.call();
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('LoginForm Widget', () {
    testWidgets('should render email and password fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Assert
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('submit_button')), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should validate email format', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'invalid-email',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password length', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        '123',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should call onSubmit when form is valid', (tester) async {
      // Arrange
      var submitCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: () {
                submitCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(submitCalled, true);
    });

    testWidgets('should call onCredentialsChanged when text changes',
        (tester) async {
      // Arrange
      String? lastEmail;
      String? lastPassword;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onCredentialsChanged: (email, password) {
                lastEmail = email;
                lastPassword = password;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Assert
      expect(lastEmail, 'test@example.com');
      expect(lastPassword, 'password123');
    });
  });
}
