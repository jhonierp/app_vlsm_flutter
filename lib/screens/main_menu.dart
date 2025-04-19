import 'package:flutter/material.dart';
import 'vlsm_screen.dart';
import 'subnet_to_ip.dart';
import 'ip_info_screen.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar Módulo')),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildCard(
            context,
            'Cálculadora VLSM',
            'Calcular subredes usando VLSM',
            VLSMScreen(),
          ),
          _buildCard(
            context,
            'Máscara a IP',
            'Convertir máscara a dirección IP',
            SubnetToIPScreen(),
          ),
          _buildCard(
            context,
            'Información de la IP',
            'Obtener información de la IP',
            IPScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String description,
    Widget destination,
  ) {
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.calculate, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
