import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share/share.dart';

Future<Uint8List> cargarLogo() async {
  ByteData logoData = await rootBundle.load('assets/logotipo.png');
  Uint8List logoBytes = logoData.buffer.asUint8List();
  return logoBytes;
}

Future<void> compartirTransaccionPdf(
    double amount, String userName, DateTime date, String type) async {
  // Cargar el logotipo como bytes
  Uint8List logoBytes = await cargarLogo();

  // Crear el documento PDF
  final pdf = pw.Document();

  final estiloTitulo = pw.TextStyle(
      fontSize: 16, fontWeight: pw.FontWeight.bold); // Estilo para el título
  final estiloCuerpo =
      pw.TextStyle(fontSize: 12); // Tamaño de fuente para el cuerpo del texto
  final estiloAgradecimiento = pw.TextStyle(
    fontSize: 10, // Tamaño de fuente para el agradecimiento
    fontStyle: pw.FontStyle.italic,
  );

  // Obtener la ruta del logotipo desde los assets
  final logoImage = pw.MemoryImage(logoBytes);

  // Determinar el signo y texto según el tipo de transacción
  final String transaccionTexto = type == 'deposit' ? 'Depósito' : 'Retiro';
  final String amountSign = type == 'deposit' ? '+' : '-';

  // Añadir contenido al PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a6, // Tamaño de página A6
      build: (pw.Context context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(8), // Márgenes internos del contenido
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 5), // Espacio entre elementos
              pw.Image(logoImage),
              pw.SizedBox(height: 5),
              pw.Text(
                'Comprobante de $transaccionTexto',
                style: estiloTitulo,
              ), // Mostrar el logotipo
              pw.SizedBox(height: 5), // Espacio entre elementos
              pw.Divider(color: PdfColors.grey400), // Línea punteada
              pw.SizedBox(height: 5),
              pw.Text('Usuario: $userName', style: estiloCuerpo),
              pw.Divider(color: PdfColors.grey400), // Línea punteada
              pw.SizedBox(height: 5),
              pw.Text(
                'Monto $amountSign\$${amount.toStringAsFixed(2)}',
                style: estiloCuerpo,
              ),
              pw.Divider(color: PdfColors.grey400), // Línea punteada
              pw.SizedBox(height: 5),
              pw.Text(
                'Fecha: ${DateFormat('yyyy/MM/dd - HH:mm').format(date)}',
                style: estiloCuerpo,
              ),
              pw.Divider(color: PdfColors.grey400), // Línea punteada
              pw.SizedBox(height: 10), // Espacio antes del agradecimiento
              pw.Text(
                '¡Gracias por su $transaccionTexto!',
                style: estiloAgradecimiento,
              ),
            ],
          ),
        );
      },
    ),
  );

  // Obtener el directorio de documentos
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/comprobante_transaccion.pdf';
  final file = File(path);

  // Guardar el PDF en el dispositivo
  await file.writeAsBytes(await pdf.save());

  // Compartir el archivo PDF
  await Share.shareFiles([path],
      text: 'Compartiendo comprobante de $transaccionTexto');
}
