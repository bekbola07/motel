
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // This is a simulation. In a real app, you would only use the AuthService.
    final Map<String, dynamic> result;
    User? user;

    if (email.contains('admin')) {
      user = User(id: 'admin-id', email: email, role: UserRole.ADMIN, passwordHash: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
      result = {'success': true, 'user': user};
    } else if (email.contains('staff')) {
      user = User(id: 'staff-id', email: email, role: UserRole.STAFF, passwordHash: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
      result = {'success': true, 'user': user};
    } else {
      // For students, we need to get the linked ID from the database
      // This is still a partial simulation, assuming the student exists
      final studentUser = await AuthService.instance.login(email, password);
      if(studentUser['success']){
        user = studentUser['user'];
        result = {'success': true, 'user': user!};
      } else {
        result = studentUser;
      }
    }

    if (user != null) {
      AuthService.instance.setCurrentUser(user);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      final loggedInUser = result['user'] as User;
      switch (loggedInUser.role) {
        case UserRole.ADMIN:
          Navigator.of(context).pushReplacementNamed('/admin-dashboard');
          break;
        case UserRole.STAFF:
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
          break;
        case UserRole.STUDENT:
        default:
          Navigator.of(context).pushReplacementNamed('/student-dashboard');
          break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
