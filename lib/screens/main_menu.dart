import 'package:flutter/material.dart';
import 'vlsm_screen.dart';
import 'subnet_to_ip.dart';
import 'ip_info_screen.dart';
import 'ssh_config_screen.dart';
import 'server_monitor.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar Módulo')),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildCard(context, 'Cálculadora VLSM', VLSMScreen()),
          _buildCard(context, 'Máscara a IP', SubnetToIPScreen()),
          _buildCard(context, 'Información de la IP', IPScreen()),
          _buildCard(context, 'DhcpSshHandle', SSHConfigScreen()),
          _buildCard(context, 'monitoreo server', SSHScreen()),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget destination) {
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
          ],
        ),
      ),
    );
  }
}
