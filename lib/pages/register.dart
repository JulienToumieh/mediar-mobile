import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import 'profile.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverIpController = TextEditingController();
  final _serverPortController = TextEditingController();

  String _permission = 'view';

  @override
  void initState() {
    super.initState();
    _loadServerSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  Future<void> _loadServerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverIpController.text = prefs.getString('serverIp') ?? '';
    _serverPortController.text = prefs.getString('serverPort') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(
            width: 300,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mediar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _serverIpController,
                    decoration: const InputDecoration(labelText: 'Server IP Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Server IP is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _serverPortController,
                    decoration: const InputDecoration(labelText: 'Server Port'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Server Port is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Port must be a number';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _permission,
                    decoration: const InputDecoration(labelText: 'Permission'),
                    items: const [
                      DropdownMenuItem(value: 'view', child: Text('View')),
                      DropdownMenuItem(value: 'edit', child: Text('Edit')),
                      DropdownMenuItem(value: 'delete', child: Text('Delete')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() => _permission = value!);
                    },
                  ),
                  const SizedBox(height: 24),

                  if (auth.error != null) ...[
                    Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                  ],

                  auth.loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('Register'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) return;

    await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      permission: _permission,
      serverIp: _serverIpController.text.trim(),
      serverPort: _serverPortController.text.trim(),
    );

    if (!mounted || auth.error != null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }
}
