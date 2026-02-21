import 'package:flutter/material.dart';
import 'package:mediar/pages/album_list.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverIpController = TextEditingController();
  final _serverPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServerSettings();
  }

  Future<void> _loadServerSettings() async {
    final auth = context.read<AuthProvider>();
    final settings = await auth.loadServerSettings();

    _serverIpController.text = settings['ip']!;
    _serverPortController.text = settings['port']!;
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

                TextField(
                  controller: _serverIpController,
                  decoration: const InputDecoration(labelText: 'Server IP Address'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _serverPortController,
                  decoration: const InputDecoration(labelText: 'Server Port'),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                if (auth.error != null) ...[
                  Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],

                auth.loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _login(auth),
                        child: const Text('Login'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(AuthProvider auth) async {
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      serverIp: _serverIpController.text.trim(),
      serverPort: _serverPortController.text.trim(),
    );

    if (!mounted || !success) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AlbumListPage(),
      ),
    );
  }
}
