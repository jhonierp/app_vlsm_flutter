import 'package:flutter/material.dart';
import 'package:vlsm_app/services/api_service.dart';

class SubnetToIPScreen extends StatefulWidget {
  @override
  _SubnetToIPScreenState createState() => _SubnetToIPScreenState();
}

class _SubnetToIPScreenState extends State<SubnetToIPScreen> {
  final TextEditingController _maskController = TextEditingController();
  String result = '';

  Future<void> _getIPFromMask() async {
    final mask = _maskController.text;
    if (mask.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa una máscara de subred')),
      );
      return;
    }

    final response = await ApiService.getIPFromMask(mask);
    setState(() {
      result = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Máscara a IP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _maskController,
              decoration: InputDecoration(
                labelText: 'Máscara de subred (ej: 24)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getIPFromMask,
              child: Text('Obtener IP'),
            ),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
