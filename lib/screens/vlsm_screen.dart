import 'package:flutter/material.dart';
import 'package:vlsm_app/services/vlsm_service.dart';
import 'package:vlsm_app/utils/pdf_generator.dart';

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

    final hosts = _hostControllers.map((c) => c.text).toList();

    try {
      final vlsmService = VLSMService();
      final result = await vlsmService.calculateVLSM(
        network,
        subnetsCount,
        hosts,
      );
      setState(() {
        subnets = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _exportToPDF() async {
    final pdfGenerator = PDFGenerator();
    await pdfGenerator.exportToPDF(subnets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calcular subredes usando VLSM')),
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
