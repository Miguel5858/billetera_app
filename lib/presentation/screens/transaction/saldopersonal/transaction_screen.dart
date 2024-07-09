import 'package:FAB/presentation/screens/transaction/saldopersonal/transaction_detail_screen.dart';
import 'package:FAB/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const TransactionScreen({
    Key? key,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Map<String, dynamic>> deposits = [];
  List<Map<String, dynamic>> withdrawals = [];
  late String apiUrl;
  bool isLoading = false;
  double totalBalance = 0.00;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    apiUrl = dotenv.env['API_URL'] ?? '';
    fetchDepositsAndWithdrawals();
    searchController.addListener(_updateSearchQuery);
  }

  @override
  void dispose() {
    searchController.removeListener(_updateSearchQuery);
    searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = searchController.text;
    });
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

      if (depositsResponse.statusCode == 200) {
        setState(() {
          deposits = (json.decode(depositsResponse.body)['deposits'] as List)
              .cast<Map<String, dynamic>>();
        });
        print('Deposits: $deposits');
      } else {
        throw Exception(
            'Failed to load deposits: ${depositsResponse.statusCode}');
      }

      if (withdrawalsResponse.statusCode == 200) {
        setState(() {
          withdrawals =
              (json.decode(withdrawalsResponse.body)['withdrawals'] as List)
                  .cast<Map<String, dynamic>>();
        });
        print('Withdrawals: $withdrawals');
      } else {
        throw Exception(
            'Failed to load withdrawals: ${withdrawalsResponse.statusCode}');
      }

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
      });
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
              backgroundColor: Colors.green,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Card(
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
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
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                child: Container(
                  color: Colors.blueGrey[50],
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Fecha',
                      hintText: '2023/01/01',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: Colors.green),
                    ),
                    onChanged: (value) {},
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
    List<dynamic> transactions = [
      ...deposits.map((deposit) => {...deposit, 'type': 'deposit'}),
      ...withdrawals.map((withdrawal) => {...withdrawal, 'type': 'withdrawal'})
    ];

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    transactions.sort((a, b) {
      return DateTime.parse(b['created_at_ecuador'])
          .compareTo(DateTime.parse(a['created_at_ecuador']));
    });

    List<dynamic> filteredTransactions = transactions.where((transaction) {
      String transactionType =
          transaction['type'] == 'deposit' ? 'Depósito' : 'Retiro';
      String transactionDate = DateFormat('yyyy/MM/dd - HH:mm:s')
          .format(DateTime.parse(transaction['created_at_ecuador']));

      return transactionType
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          transactionDate.contains(searchQuery);
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> transaction = filteredTransactions[index];
        bool isDeposit = transaction['type'] == 'deposit';
        String title = isDeposit ? 'Depósito' : 'Retiro';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailScreen(transaction: transaction),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey, width: 0.2),
            ),
            child: ListTile(
              title: Text(
                '$title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${DateFormat('yyyy/MM/dd - HH:mm:s').format(DateTime.parse(transaction['created_at_ecuador']))}',
                  ),
                  Text(
                    '${isDeposit ? '+' : '-'}\$${transaction['amount']}',
                    style: TextStyle(
                      color: isDeposit ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
