import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:fl_chart/fl_chart.dart';

class SSHScreen extends StatefulWidget {
  @override
  _SSHScreenState createState() => _SSHScreenState();
}

class _SSHScreenState extends State<SSHScreen> {
  final ipController = TextEditingController();
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  SSHClient? _client;
  String connectionStatus = '';
  Map<String, String> commandResults = {};
  double usedRam = 0;
  double freeRam = 0;
  List<String> serviciosFiltrados = [];

  void _connectAndFetchInfo() async {
    setState(() {
      connectionStatus = 'Conectando...';
      commandResults = {};
      serviciosFiltrados = [];
    });

    try {
      final socket = await SSHSocket.connect(ipController.text, 22);
      _client = SSHClient(
        socket,
        username: userController.text,
        onPasswordRequest: () => passwordController.text,
      );

      setState(() {
        connectionStatus = 'Conexión exitosa';
      });

      final commands = {
        'Hostname': 'hostname',
        'Uptime': 'uptime',
        'Sistema': 'uname -a',
        'Memoria RAM': 'free -m',
        'Espacio en Disco': 'df -h',
        'Servicios Activos':
            'systemctl list-units --type=service --state=running',
        'CPU': "top -bn1 | grep 'Cpu'",
        'Procesos': 'ps aux --sort=-%mem | head -n 10',
        'IP': "hostname -I | awk '{print \$1}'",
        'Usuarios Conectados': 'who',
      };

      Map<String, String> results = {};

      for (var entry in commands.entries) {
        final result = await _client!.run(entry.value);
        results[entry.key] = utf8.decode(result);
      }

      _parseRam(results['Memoria RAM'] ?? '');
      _filtrarServicios(results['Servicios Activos'] ?? '');

      setState(() {
        commandResults = results;
      });

      _client!.close();
      await _client!.done;
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
        commandResults = {};
      });
    }
  }

  void _parseRam(String raw) {
    final lines = raw.split('\n');
    for (var line in lines) {
      if (line.toLowerCase().startsWith('mem:') ||
          line.toLowerCase().startsWith('mem ')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final total = double.tryParse(parts[1]) ?? 0;
          final used = double.tryParse(parts[2]) ?? 0;
          setState(() {
            usedRam = used;
            freeRam = total - used;
          });
        }
        break;
      }
    }
  }

  void _filtrarServicios(String raw) {
    final servicios = raw.split('\n');
    final claves = ['ssh', 'dhcp', 'network', 'apache', 'nginx'];
    final filtrados =
        servicios
            .where((line) => claves.any((c) => line.toLowerCase().contains(c)))
            .toList();

    setState(() {
      serviciosFiltrados = filtrados;
    });
  }

  void _logout() {
    setState(() {
      connectionStatus = '';
      commandResults.clear();
      usedRam = 0;
      freeRam = 0;
      serviciosFiltrados.clear();
      ipController.clear();
      userController.clear();
      passwordController.clear();
    });
  }

  Widget _buildCommandCard(String title, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ExpansionTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                content.trim(),
                style: TextStyle(fontFamily: 'Courier'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRamChart() {
    final total = usedRam + freeRam;
    if (total == 0) return SizedBox();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            'Uso de Memoria RAM',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: usedRam,
                    color: Colors.red,
                    title: 'Usado: ${usedRam.toInt()} MB',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: freeRam,
                    color: Colors.green,
                    title: 'Libre: ${freeRam.toInt()} MB',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text('Total: ${total.toInt()} MB'),
        ],
      ),
    );
  }

  Widget _buildServiciosCard() {
    if (serviciosFiltrados.isEmpty) return SizedBox();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text('Servicios Importantes'),
        children:
            serviciosFiltrados
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      s.trim(),
                      style: TextStyle(fontFamily: 'Courier'),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conectado = connectionStatus == 'Conexión exitosa';

    return Scaffold(
      appBar: AppBar(title: Text('Conexión SSH')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (!conectado) ...[
              TextField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: 'IP del Servidor',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _connectAndFetchInfo,
                child: Text('Conectar y obtener información'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Cerrar sesión'),
              ),
            ],
            SizedBox(height: 16),
            Text(
              connectionStatus,
              style: TextStyle(
                color: conectado ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (conectado) ...[
              _buildRamChart(),
              _buildServiciosCard(),
              ...commandResults.entries
                  .where(
                    (e) =>
                        e.key != 'Memoria RAM' && e.key != 'Servicios Activos',
                  )
                  .map((entry) => _buildCommandCard(entry.key, entry.value)),
            ],
          ],
        ),
      ),
    );
  }
}
