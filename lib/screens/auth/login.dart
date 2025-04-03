import 'package:flutter/material.dart';
import 'package:regrowth_mobile/utils/contants.dart';
import 'package:regrowth_mobile/widgets/cupertino_with_loading.dart';
import 'package:regrowth_mobile/widgets/input_field.dart';
import 'package:regrowth_mobile/services/auth_service.dart';
import 'package:regrowth_mobile/services/storage_service.dart';

class login_Screen extends StatefulWidget {
  const login_Screen({super.key});

  @override
  State<login_Screen> createState() => _login_ScreenState();
}

class _login_ScreenState extends State<login_Screen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storageService = StorageService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both username and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (result['success']) {
        final userData = result['data'];
        await _storageService.saveUserCredentials(
          userData['username'],
          userData['jwtToken'],
          userData['role'],
          _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.lightGradient,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/Regrowth_logo_1.PNG',
                width: 200,
              ),
              const SizedBox(height: 60),

              // Username field
              CustomInputField(
                hintText: 'Username',
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),

              // Password field
              CustomInputField(
                hintText: 'Password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 40),

              // Login button
              CustomCupertinoButton1(
                text: 'LOGIN',
                onPressed: _isLoading ? null : _handleLogin,
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
