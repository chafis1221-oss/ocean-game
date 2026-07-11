// login_screen.dart - Login & Register

import 'package:flutter/material.dart';
import '../network/api.dart';
import '../core/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegister = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final result = _isRegister
          ? await Api.register(_usernameController.text, _passwordController.text)
          : await Api.login(_usernameController.text, _passwordController.text);
      
      if (result['success']) {
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Gagal!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('OCEAN COMMAND', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Username', hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Colors.blue[800]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Password', hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Colors.blue[800]),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isRegister ? 'REGISTER' : 'LOGIN', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isRegister = !_isRegister),
                          child: Text(_isRegister ? 'Sudah punya akun? Login' : 'Belum punya akun? Register', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
