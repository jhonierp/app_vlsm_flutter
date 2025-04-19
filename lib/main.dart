import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(VLSMApp());
}

class VLSMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLSM Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VLSMScreen(),
    );
  }
}

class VLSMScreen extends StatefulWidget {
  @override
  _VLSMScreenState createState() => _VLSMScreenState();
}

class _VLSMScreenState extends State<VLSMScreen> {
  final TextEditingController _networkController = TextEditingController();
  final TextEditingController _subnetsController = TextEditingController();

  List<TextEditingController> _hostControllers = [];

  String result = '';
  List<dynamic> subnets = [];

  void _generateHostFields(int count) {
    _hostControllers = List.generate(count, (index) => TextEditingController());
  }

  Future<void> fetchVLSM(
    String network,
    int subnetsCount,
    List<int> hostsList,
  ) async {
    final baseUrl =
        'https://vlsmcalculator-production.up.railway.app/vlsm/calculate-json?';
    final hostsParams = hostsList.map((h) => 'hosts=$h').join('&');

    final url =
        '$baseUrl'
        'network=$network&subnets=$subnetsCount&$hostsParams';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          subnets = data['subnets'];
          result = "Cálculo de subredes exitoso. Ver detalles abajo.";
        });
      } else {
        setState(() {
          result = 'Error: ${response.statusCode}';
          subnets = [];
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error de conexión: $e';
        subnets = [];
      });
    }
  }

  void _handleGenerateFields() {
    final subnetsCount = int.tryParse(_subnetsController.text.trim());
    if (subnetsCount != null && subnetsCount > 0) {
      setState(() {
        _generateHostFields(subnetsCount);
        result = '';
        subnets = [];
      });
    } else {
      setState(() {
        result = 'Por favor, ingresa un número válido de subredes.';
        _hostControllers = [];
      });
    }
  }

  void _handleSubmit() {
    final network = _networkController.text.trim();
    final subnetsCount = _hostControllers.length;

    if (network.isEmpty || subnetsCount == 0) {
      setState(() {
        result = "Por favor, completa todos los campos correctamente.";
        subnets = [];
      });
      return;
    }

    final hostsList =
        _hostControllers
            .map((c) => int.tryParse(c.text.trim()))
            .where((e) => e != null)
            .cast<int>()
            .toList();

    if (hostsList.length != subnetsCount) {
      setState(() {
        result =
            "Todos los campos de hosts deben estar llenos con números válidos.";
        subnets = [];
      });
      return;
    }

    fetchVLSM(network, subnetsCount, hostsList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora VLSM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _networkController,
              decoration: InputDecoration(
                labelText: 'Dirección de red (ej. 172.18.0.0)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subnetsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número de subredes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleGenerateFields,
                  child: Text("Generar campos"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: List.generate(_hostControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: _hostControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Hosts para subred ${index + 1}',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Calcular VLSM'),
            ),
            SizedBox(height: 20),
            Text(result),
            SizedBox(height: 10),
            if (subnets.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: subnets.length,
                itemBuilder: (context, index) {
                  final subnet = subnets[index];
                  return Card(
                    child: ListTile(
                      title: Text('Subred ${subnet['subnet']}'),
                      subtitle: Text(
                        'Netmask: ${subnet['netmask']}\n'
                        'Hosts: ${subnet['hosts']}\n'
                        'First Host: ${subnet['firstHost']}\n'
                        'Last Host: ${subnet['lastHost']}\n'
                        'Broadcast: ${subnet['broadcast']}',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
