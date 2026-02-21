import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mediar/models/user.dart';
import 'package:mediar/pages/login.dart';
import 'package:mediar/pages/register.dart';
import 'package:mediar/services/auth_service.dart';
import 'package:mediar/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<List<UserModel>> _usersFuture;
  int? userId;
  String? email;
  String? name;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadUserFromJwt();
    _usersFuture = AuthService.fetchUsers();
  }

  void _showEditProfileDialog(BuildContext context) {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController(text: name ?? '');
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Requires re-login',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Old Password',
                  ),
                ),

                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Change your password below (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),


                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: repeatPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Repeat New Password',
                  ),
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              try {
                await AuthService.updateUser(
                  userId: userId!,
                  name: nameController.text.trim(),
                  password: oldPasswordController.text,
                  newPassword: newPasswordController.text.isEmpty
                      ? null
                      : newPasswordController.text,
                );

                Navigator.of(context).pop();

                AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } catch (e) {
                if (e.toString().contains('WRONG_PASSWORD')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Old password is incorrect'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update profile'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  Future<void> _loadUserFromJwt() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    

    if (token == null) return;

    final payload = Jwt.parseJwt(token);
    const claimName = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
    const claimRole = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
    const claimId = 'sub';

    setState(() {
      userId = int.parse(payload[claimId].toString());
      email = payload['email'];
      name = payload[claimName];
      role = payload[claimRole];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Account", 
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 22,
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile", 
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _profileRow("Name", name),
                    const SizedBox(height: 8),
                    _profileRow("Email", email),
                    const SizedBox(height: 8),
                    _profileRow("Permission", role),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Text('Edit'),
                        ),

                        TextButton(
                          onPressed: () {
                            AuthService.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Settings", 
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 22,
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Theme Color",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildColorPicker(Colors.orange),
                        _buildColorPicker(Colors.blue),
                        _buildColorPicker(Colors.green),
                        _buildColorPicker(Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 16),

            Text(
              "Accounts", 
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 22,
              ),
            ),
            FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return Column(
                  children: users.map((user) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          user.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.email,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              user.permission,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(user),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Register a new account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String? value) {
    return Row(
      children: [
        Text(
          "$label: ", 
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value ?? "—", 
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(user);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      await AuthService.deleteUser(userId: user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} deleted')),
      );

      setState(() {
        _usersFuture = AuthService.fetchUsers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  Widget _buildColorPicker(Color color) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeProvider>().setSeedColor(color); 
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color,
      ),
    );
  }
}
