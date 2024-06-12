import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final url =
        Uri.parse('http://10.143.10.37/ApiPhamacySmartLabel/PatientVerify');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
        {'emplid': _usernameController.text, 'pass': _passwordController.text});
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Login Response: $jsonResponse'); // Debugging output
      final userlogin = jsonResponse['userlogin'];
      if (userlogin is List && userlogin.isNotEmpty) {
        final visitId = userlogin[0]['visit_id'];
        print('visit_id type: ${visitId.runtimeType}');
        print('visit_id: $visitId'); // Debugging output

        if (visitId != null) {
          _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
            builder: (context) => PatientDetailsPage(visitId: visitId,),
          ));
        }else if (response.statusCode == 404) {
         _showSnackBar('Login Failed');
        }
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('images/logo.png',
                                  width: 200, height: 150),
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your HN';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your 4 Ids';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _login();
                                    }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
                                  ))
                            ],
                          ),
                        )),
                  ),
                ));
      },
    );
  }
}
