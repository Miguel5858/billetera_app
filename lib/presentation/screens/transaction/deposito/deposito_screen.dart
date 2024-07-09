import 'dart:convert';
import 'package:FAB/presentation/screens/transaction/deposito/deposito_realizado_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:FAB/utils/token_service.dart'; // Importa tu servicio de tokens aquí

class DepositoScreen extends StatefulWidget {
  final String userRole;
  final String userId;

  DepositoScreen({
    required this.userRole,
    required this.userId,
    required int superUserId,
  });

  @override
  _DepositoScreenState createState() => _DepositoScreenState();
}

class _DepositoScreenState extends State<DepositoScreen> {
  TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  bool isSuperUser = false;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  List<dynamic> usuarios = [];

  String? selectedUser;
  String? selectedUserName;

  @override
  void initState() {
    super.initState();
    _controller.text = '';
    if (widget.userRole.toLowerCase() == 'superuser') {
      isSuperUser = true;
      obtenerListaUsuarios();
    }
  }

  Future<void> obtenerListaUsuarios() async {
    try {
      String? token = await SessionManager().getToken();
      final response = await http.get(
        Uri.parse('$apiUrl/users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          usuarios = jsonDecode(response.body) as List<dynamic>;
        });
      } else {
        print('Error al obtener la lista de usuarios: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al obtener la lista de usuarios: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener la lista de usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> realizarDeposito(String userId) async {
    try {
      String? token = await SessionManager().getToken();
      final response = await http.post(
        Uri.parse('$apiUrl/deposits/${widget.userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': userId,
          'type': 'deposit',
          'amount':
              double.parse(_controller.text), // Envía el monto del depósito
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Depósito realizado con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Depósito realizado con éxito'),
            backgroundColor: Colors.green,
          ),
        );

        // Navega a la pantalla de depósito exitoso
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DepositoRealizadoScreen(
              amount: double.parse(_controller.text),
              date: DateTime.now(),
              userName: selectedUserName ?? 'Nombre no disponible',
            ),
          ),
        );

        // Puedes realizar otras acciones necesarias aquí
      } else {
        print('Error al realizar el depósito: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al realizar el depósito: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar el depósito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: AlertDialog(
            title: Text('Confirmar Depósito'),
            content:
                Text('¿Estás seguro de que deseas realizar este depósito?'),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.grey, // Color verde para el botón Confirmar
                  minimumSize:
                      Size(double.infinity, 48), // Ancho máximo y altura mínima
                ),
                child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Color verde para el botón Confirmar
                  minimumSize:
                      Size(double.infinity, 48), // Ancho máximo y altura mínima
                ),
                child: Text('Confirmar', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  Navigator.of(context).pop();

                  if (isSuperUser && selectedUser != null) {
                    await realizarDeposito(selectedUser!);
                  } else if (!isSuperUser) {
                    await realizarDeposito(widget.userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor, selecciona un usuario'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Depósito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Depósito',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
                child: TextFormField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    color: _isEditing ? Colors.black : Colors.grey,
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  readOnly: !_isEditing,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '\$0.00',
                    hintStyle: TextStyle(
                      fontSize: 50,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  onChanged: (value) {
                    // Handle changes in the value
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            isSuperUser
                ? Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Seleccionar Socio',
                        ),
                        value: selectedUser,
                        items:
                            usuarios.map<DropdownMenuItem<String>>((usuario) {
                          return DropdownMenuItem<String>(
                            value: usuario['id'].toString(),
                            child: Text(usuario['name']
                                as String), // Mostrar el nombre del usuario
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUser = value;
                            selectedUserName = usuarios.firstWhere((element) =>
                                    element['id'].toString() == value)['name']
                                as String?;
                          });
                        },
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                child: Text(
                  'Realizar Depósito',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
