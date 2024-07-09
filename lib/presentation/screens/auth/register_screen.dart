import 'package:flutter/material.dart';
import 'package:FAB/feactures/services/services.dart';
import 'package:FAB/presentation/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterAuthService authService = RegisterAuthService();
  String name = '';
  String email = '';
  String password = '';
  String errorMessage = '';
  Map<String, List<String>> errors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: BackgroundPainter(),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Image.asset(
                      'assets/logotipo.png',
                      width: 350, // Ajusta el ancho según sea necesario
                      height: 200, // Ajusta la altura según sea necesario
                    ),
                    SizedBox(height: 40),
                    CustomTextField(
                      label: 'Name',
                      onChanged: (value) => setState(() => name = value),
                    ),
                    CustomTextField(
                      label: 'Email',
                      onChanged: (value) => setState(() => email = value),
                    ),
                    CustomTextField(
                      label: 'Password',
                      isPassword: true,
                      onChanged: (value) => setState(() => password = value),
                    ),
                    CustomButton(
                      text: 'Registrar',
                      onPressed: () async {
                        var response =
                            await authService.register(name, email, password);
                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Registro exitoso'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacementNamed(context, '/');
                        } else {
                          setState(() {
                            errors = response['errors'] ?? {};
                          });
                          errors.forEach((key, value) {
                            value.forEach((msg) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
