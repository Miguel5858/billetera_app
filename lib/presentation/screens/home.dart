import 'package:FAB/config/routes/app_router.dart';
import 'package:FAB/feactures/services/auth/logout_auth.dart';
import 'package:FAB/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final String userRole;

  const HomeScreen({
    Key? key,
    required this.userName,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalBalance = 0.00;
  double totalGeneral = 0.00;

  late String apiUrl;
  bool isLoading = false;
  bool isSuperUser = false;

  @override
  void initState() {
    super.initState();

    apiUrl = dotenv.env['API_URL'] ?? '';

    // Inicialmente establecer el estado del superusuario
    if (widget.userRole.toLowerCase() == 'superuser') {
      isSuperUser = true;
    }

    fetchDepositsAndWithdrawals();
    fetchTotalGeneral();
  }

  Future<void> fetchTotalGeneral() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = SessionManager().getToken();
      print('Token: $token');

      var response = await http.get(
        Uri.parse('$apiUrl/total-general'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          totalGeneral = data['total_general'].toDouble(); // Convertir a double
        });
      } else {
        throw Exception('Failed to load total general');
      }
    } catch (e) {
      print('Error fetching total general: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDepositsAndWithdrawals() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = SessionManager().getToken();
      print('Token: $token');

      var depositsResponse = await http.get(
        Uri.parse('$apiUrl/user/deposits/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      var withdrawalsResponse = await http.get(
        Uri.parse('$apiUrl/user/withdrawals/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (depositsResponse.statusCode == 200 &&
          withdrawalsResponse.statusCode == 200) {
        List<Map<String, dynamic>> deposits =
            (json.decode(depositsResponse.body)['deposits'] as List)
                .cast<Map<String, dynamic>>();
        List<Map<String, dynamic>> withdrawals =
            (json.decode(withdrawalsResponse.body)['withdrawals'] as List)
                .cast<Map<String, dynamic>>();

        double totalDeposits = deposits.fold(0.0, (sum, item) {
          double amount = item['amount'] is double
              ? item['amount']
              : item['amount'] is int
                  ? item['amount'].toDouble()
                  : double.tryParse(item['amount'].toString()) ?? 0.0;
          return sum + amount;
        });

        double totalWithdrawals = withdrawals.fold(0.0, (sum, item) {
          double amount = item['amount'] is double
              ? item['amount']
              : item['amount'] is int
                  ? item['amount'].toDouble()
                  : double.tryParse(item['amount'].toString()) ?? 0.0;
          return sum + amount;
        });

        print('Total Deposits: $totalDeposits');
        print('Total Withdrawals: $totalWithdrawals');

        setState(() {
          totalBalance = totalDeposits - totalWithdrawals;

          // Actualizar el estado del superusuario
          if (widget.userRole.toLowerCase() == 'superuser') {
            isSuperUser = true;
          } else {
            isSuperUser = false;
          }
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchDepositsAndWithdrawals();
    await fetchTotalGeneral();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await LogoutAuthService().logout();

              Navigator.pushReplacementNamed(context, AppRouter.initialRoute);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  SizedBox(height: 10),
                  Image.asset(
                    'assets/logotipo.png',
                    width: 125, // Ajusta el ancho según sea necesario
                    height: 125, // Ajusta la altura según sea necesario
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hola, ${widget.userName}',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      shadowColor: Colors.transparent,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey[350]!, // Color del borde gris
                          width: 1, // Ancho del borde
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isSuperUser)
                                  Navigator.pushNamed(context, '/saldo_total');
                              },
                              child: Card(
                                color: Colors.green.shade900,
                                margin: EdgeInsets.all(16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Saldo Total:',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '\$${totalGeneral.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/transaction');
                              },
                              child: Card(
                                color: Colors.green,
                                margin: EdgeInsets.all(16.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mi Saldo:',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '\$${totalBalance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isSuperUser)
                    Card(
                      color: Colors.white,
                      shadowColor: Colors.transparent,
                      margin: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey[350]!, // Color del borde gris
                          width: 1, // Ancho del borde
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '¿Qué quieres hacer?',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.depositoRoute,
                                        arguments: {
                                          'userRole':
                                              SessionManager().getUserRole(),
                                          'userId':
                                              SessionManager().getUserId(),
                                        },
                                      );
                                    },
                                    child: Card(
                                      shadowColor: Colors.transparent,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey[
                                              350]!, // Color del borde gris
                                          width: 1, // Ancho del borde
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Depósito',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Icon(
                                              Icons.account_balance_wallet,
                                              size: 50,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.retiroRoute,
                                        arguments: {
                                          'userRole':
                                              SessionManager().getUserRole(),
                                          'userId':
                                              SessionManager().getUserId(),
                                        },
                                      );
                                    },
                                    child: Card(
                                      shadowColor: Colors.transparent,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey[
                                              350]!, // Color del borde gris
                                          width: 1, // Ancho del borde
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Retiro',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Icon(
                                              Icons.money_off,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
