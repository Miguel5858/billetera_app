import 'package:flutter/material.dart';
import 'package:FAB/config/routes/app_router.dart';
import 'package:FAB/feactures/services/services.dart';
import 'package:FAB/presentation/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginAuthService authService = LoginAuthService();
  String email = '';
  String password = '';
  Map<String, List<String>> errors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/logotipo.png',
                    width: 350, // Ajusta el ancho según sea necesario
                    height: 200, // Ajusta la altura según sea necesario
                  ),
                  SizedBox(height: 40),
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
                    text: 'Ingresar',
                    onPressed: () async {
                      var response = await authService.login(email, password);
                      if (response['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ingreso exitoso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Navigate to home screen after successful login
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        setState(() {
                          errors = response['errors'] ?? {};
                        });
                        if (response['message'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message']),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No tienes una cuenta?',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.registerRoute);
                        },
                        child: Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
