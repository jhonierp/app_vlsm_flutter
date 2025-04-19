import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MaterialApp(title: 'VLSM Calculator', home: VLSMScreen()));
}

class VLSMScreen extends StatefulWidget {
  @override
  _VLSMScreenState createState() => _VLSMScreenState();
}

class _VLSMScreenState extends State<VLSMScreen> {
  final TextEditingController _networkController = TextEditingController();
  final TextEditingController _subnetsController = TextEditingController();
  List<TextEditingController> _hostControllers = [];
  List<dynamic> subnets = [];

  void _generateHostFields() {
    final count = int.tryParse(_subnetsController.text);
    if (count != null && count > 0) {
      setState(() {
        _hostControllers = List.generate(count, (_) => TextEditingController());
      });
    }
  }

  Future<void> _calculateVLSM() async {
    final network = _networkController.text;
    final subnetsCount = int.tryParse(_subnetsController.text);

    if (network.isEmpty ||
        subnetsCount == null ||
        _hostControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    final hosts = _hostControllers.map((c) => 'hosts=${c.text}').join('&');

    final url =
        'https://vlsmcalculator-production.up.railway.app/vlsm/calculate-json?network=$network&subnets=$subnetsCount&$hosts';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          subnets = data['subnets'];
        });
      } else {
        throw Exception('Error al conectar con la API');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resultado del cálculo VLSM',
                style: pw.TextStyle(fontSize: 24),
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
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora VLSM')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _networkController,
              decoration: InputDecoration(
                labelText: 'Dirección de red (ej: 172.18.0.0)',
              ),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _subnetsController,
              decoration: InputDecoration(labelText: 'Cantidad de subredes'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _generateHostFields(),
            ),
            SizedBox(height: 16),
            ..._hostControllers.asMap().entries.map(
              (entry) => TextField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: 'Hosts para subred ${entry.key + 1}',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateVLSM,
              child: Text('Calcular VLSM'),
            ),
            if (subnets.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _exportToPDF,
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Exportar a PDF'),
              ),
            SizedBox(height: 20),
            if (subnets.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    subnets.map((s) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Subred: ${s['subnet']}'),
                          subtitle: Text(
                            'Netmask: ${s['netmask']}\n'
                            'Hosts: ${s['hosts']}\n'
                            'Primer host: ${s['firstHost']}\n'
                            'Último host: ${s['lastHost']}\n'
                            'Broadcast: ${s['broadcast']}',
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
