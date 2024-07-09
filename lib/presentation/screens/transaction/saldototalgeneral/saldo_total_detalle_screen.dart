import 'package:FAB/presentation/screens/transaction/saldototalgeneral/saldo_total_compartir_pdf_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaldoTotalDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const SaldoTotalDetalleScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDeposit = transaction['type'] == 'deposit';
    final String amountSign = isDeposit ? '+' : '-';
    final Color amountColor = isDeposit ? Colors.green : Colors.grey;

    DateTime transactionDate;
    try {
      transactionDate = DateFormat('yyyy/MM/dd - HH:mm')
          .parse(transaction['created_at_ecuador']);
    } catch (e) {
      print('Error parsing date: $e');
      transactionDate = DateTime.now(); // Default to now in case of error
    }
    double amount;
    try {
      amount = double.parse(transaction['amount'].toString());
    } catch (e) {
      print('Error parsing amount: $e');
      amount = 0.0; // Default to 0.0 in case of error
    }
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Detalle de la Transacción'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.asset(
                  'assets/logotipo.png', // Asegúrate de tener este recurso en tu proyecto
                  width: 125,
                  height: 125,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isDeposit ? 'Depósito' : 'Retiro'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Usuario: ${transaction['user']}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Fecha y Hora de Transacción:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat('yyyy/MM/dd - HH:mm').format(transactionDate)}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Monto $amountSign\$${transaction['amount']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await compartirTransaccionPdf(
                    amount,
                    transaction['user'],
                    transactionDate,
                    transaction['type'],
                  );
                },
                label: Text(
                  'Compartir Comprobante',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Icon(Icons.share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
