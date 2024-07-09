import 'package:FAB/presentation/screens/transaction/saldototalgeneral/saldo_total_detalle_screen.dart';
import 'package:FAB/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SaldoTotalGeneralListadoScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const SaldoTotalGeneralListadoScreen({
    Key? key,
    required this.userName,
    required this.userId,
    required String userRole,
  }) : super(key: key);

  @override
  _SaldoTotalGeneralListadoScreenState createState() =>
      _SaldoTotalGeneralListadoScreenState();
}

class _SaldoTotalGeneralListadoScreenState
    extends State<SaldoTotalGeneralListadoScreen> {
  List<Map<String, dynamic>> transactions = [];
  late String apiUrl;
  bool isLoading = false;

  double totalGeneral = 0.00;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiUrl = dotenv.env['API_URL'] ?? '';
    fetchAllTransactions();
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

  Future<void> fetchAllTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await SessionManager().getToken();
      print('Token: $token'); // Verificar el token en la consola

      var response = await http.get(
        Uri.parse('$apiUrl/transactions/all/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['transactions'];
        List<Map<String, dynamic>> tempTransactions = [
          ...(data['deposits'] as List).map((item) => {
                'user': item['user'],
                'created_at_ecuador': item['created_at_ecuador'],
                'amount': item['amount'],
                'type': 'deposit'
              }),
          ...(data['withdrawals'] as List).map((item) => {
                'user': item['user'],
                'created_at_ecuador': item['created_at_ecuador'],
                'amount': item['amount'],
                'type': 'withdrawal'
              }),
        ];

        // Ordenar las transacciones en orden inverso
        tempTransactions.sort((a, b) {
          DateTime dateA =
              DateFormat('yyyy/MM/dd - HH:mm').parse(a['created_at_ecuador']);
          DateTime dateB =
              DateFormat('yyyy/MM/dd - HH:mm').parse(b['created_at_ecuador']);
          return dateB.compareTo(dateA);
        });

        setState(() {
          transactions = tempTransactions;
        });
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
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
    await fetchAllTransactions();
    fetchTotalGeneral();
  }

  void filterTransactions(String searchText) {
    setState(() {
      transactions.forEach((transaction) {
        bool matchesUser = transaction['user']
            .toLowerCase()
            .contains(searchText.toLowerCase());
        bool matchesDate;
        try {
          DateTime transactionDate = DateFormat('yyyy/MM/dd - HH:mm')
              .parse(transaction['created_at_ecuador']);
          matchesDate = DateFormat('yyyy/MM/dd')
              .format(transactionDate)
              .contains(searchText);
        } catch (e) {
          matchesDate = false;
        }

        if (matchesUser || matchesDate) {
          transaction['isVisible'] = true;
        } else {
          transaction['isVisible'] = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.green.shade900,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Card(
                  color: Colors.green.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                child: Container(
                  color: Colors.blueGrey[50],
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Nombre o Fecha',
                      hintText: 'Ej. Juan o 2023/01/01',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      filterTransactions(value);
                    },
                  ),
                ),
              ),
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildTransactionList();
                },
                childCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    List<Map<String, dynamic>> visibleTransactions = transactions
        .where((transaction) => transaction['isVisible'] ?? true)
        .toList();

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (visibleTransactions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: visibleTransactions.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> transaction = visibleTransactions[index];
        String title = transaction['type'] == 'deposit' ? 'Depósito' : 'Retiro';
        String sign = transaction['type'] == 'deposit' ? '+' : '-';

        DateTime transactionDate;
        try {
          transactionDate = DateFormat('yyyy/MM/dd - HH:mm')
              .parse(transaction['created_at_ecuador']);
        } catch (e) {
          print('Error parsing date: $e');
          transactionDate = DateTime.now(); // Default to now in case of error
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SaldoTotalDetalleScreen(
                  transaction: transaction,
                ),
              ),
            );
          },
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$sign\$${transaction['amount']}',
                    style: TextStyle(
                      color: transaction['type'] == 'deposit'
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${transaction['user']}'),
                  Text(
                      'Fecha: ${DateFormat('yyyy/MM/dd - HH:mm').format(transactionDate)}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate({required this.child});

  @override
  double get minExtent => 70.0;

  @override
  double get maxExtent => 70.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
