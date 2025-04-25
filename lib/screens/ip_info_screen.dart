import 'package:flutter/material.dart';
import 'package:vlsm_app/services/api_service.dart';
import 'package:vlsm_app/utils/banner.dart';

class IPScreen extends StatefulWidget {
  @override
  _IPScreenState createState() => _IPScreenState();
}

class _IPScreenState extends State<IPScreen> {
  final TextEditingController _ipController = TextEditingController();
  String result = '';

  Future<void> _getIPInfo() async {
    final ip = _ipController.text;
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa una dirección IP')),
      );
      return;
    }

    final response = await ApiService.getIPInfo(ip);
    setState(() {
      result = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Obtener información de la IP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Dirección IP (ej: 192.168.1.10)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getIPInfo,
              child: Text('Obtener Información'),
            ),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      bottomNavigationBar: BannerAdWidget(), // Aquí se muestra el banner fijo
    );
  }
}
