import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator {
  Future<void> exportToPDF(List<dynamic> subnets) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título con fondo color magenta
              pw.Container(
                width: double.infinity,
                color: PdfColor.fromHex('#8E24AA'), // Color magenta
                padding: pw.EdgeInsets.all(10),
                child: pw.Text(
                  'Resultado del cálculo VLSM',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Subred',
                  'Netmask',
                  'Hosts',
                  'Primer Host',
                  'Último Host',
                  'Broadcast',
                ],
                data:
                    subnets.map((s) {
                      return [
                        s['subnet'],
                        s['netmask'],
                        s['hosts'].toString(),
                        s['firstHost'],
                        s['lastHost'],
                        s['broadcast'],
                      ];
                    }).toList(),
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#8E24AA'), // Magenta para el borde
                  width: 1,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex(
                    '#8E24AA',
                  ), // Fondo magenta para encabezados
                ),
                cellStyle: pw.TextStyle(fontSize: 12, color: PdfColors.black),
                cellAlignment: pw.Alignment.center,
                headerAlignment: pw.Alignment.center,
              ),
              pw.SizedBox(height: 20),
              // Agregar pie de página
              pw.Container(
                alignment: pw.Alignment.center,
                padding: pw.EdgeInsets.all(8),
                color: PdfColor.fromHex('#8E24AA'),
                child: pw.Text(
                  'Generado por VLSM Calculator',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
