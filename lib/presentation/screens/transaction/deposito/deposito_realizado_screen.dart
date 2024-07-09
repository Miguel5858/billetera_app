import 'package:FAB/presentation/screens/transaction/deposito/compartir_deposito_pdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DepositoRealizadoScreen extends StatelessWidget {
  final double amount;
  final String userName;
  final DateTime date;

  DepositoRealizadoScreen({
    required this.amount,
    required this.userName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Comprobante de Depósito'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Image.asset(
                      'assets/logotipo.png',
                      width: 125,
                      height: 125,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Depósito',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Fecha y Hora de Transacción:',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${DateFormat('yyyy/MM/dd - HH:mm:ss').format(date)}',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Beneficiario:',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.05,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monto +\$${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.07,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Divider(color: Colors.black),
                        SizedBox(height: 10),
                        Text(
                          'Gracias por su depósito',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.045,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Recibo de depósito',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.045,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await compartirDepositoPdf(amount, userName, date);
                    },
                    label: Text(
                      'Compartir Comprobante',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.05),
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
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: Text(
                      'Realizar otro Depósito',
                      style: TextStyle(fontSize: constraints.maxWidth * 0.05),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    icon: Icon(Icons.arrow_back_outlined),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
