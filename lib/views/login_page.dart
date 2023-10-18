import 'package:appteste/data/dummy_users.dart';
import 'package:appteste/views/home_page.dart';
import 'package:appteste/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? userLog;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    userLog = null;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                        child: Text(
                          'Emprestaí',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                            fontSize: 56,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
//Email Form
                  Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return ('Usuário não válido');
                          }
                          if (dummyUsers.values
                              .any((user) => user.email == value)) {
                            return null;
                          } else {
                            return ('Usuário não existe');
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Password Form
                      TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return ('Senha não válida');
                          }

                          userLog = dummyUsers.values.firstWhere(
                            (user) => user.email == emailController.text,
                          );

                          if (userLog?.password == value) {
                            return null; // Senha válida
                          } else {
                            return 'Senha incorreta';
                          }
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
//Login Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        userLog ??= dummyUsers.values.firstWhere(
                          (user) => user.email == emailController.text,
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(idUsuario: userLog?.id),
                          ),
                        );
                      }
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
