import 'package:flutter/material.dart';
import 'package:vlsm_app/services/ssh_service.dart';

class SSHConfigScreen extends StatefulWidget {
  @override
  _SSHConfigScreenState createState() => _SSHConfigScreenState();
}

class _SSHConfigScreenState extends State<SSHConfigScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _networkController = TextEditingController(
    text: '172.18.0.0',
  );
  final TextEditingController _subnetsController = TextEditingController();

  List<TextEditingController> _hostControllers = [];
  bool _isLoading = false;
  String _statusMessage = '';

  void _generateHostFields() {
    final count = int.tryParse(_subnetsController.text);
    if (count != null && count > 0) {
      setState(() {
        _hostControllers = List.generate(count, (_) => TextEditingController());
      });
    } else {
      setState(() {
        _hostControllers.clear();
      });
    }
  }

  Future<void> _configureDHCP() async {
    final ip = _ipController.text.trim();
    final user = _userController.text.trim();
    final pass = _passwordController.text;
    final network = _networkController.text.trim();
    final subnetsCount = int.tryParse(_subnetsController.text);

    if (ip.isEmpty ||
        user.isEmpty ||
        pass.isEmpty ||
        network.isEmpty ||
        subnetsCount == null ||
        _hostControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Conectando por SSH...';
    });

    try {
      final hosts = _hostControllers.map((c) => int.parse(c.text)).toList();
      final sshService = SSHService(ip: ip, username: user, password: pass);

      setState(() => _statusMessage = 'Configurando DHCP...');

      final result = await sshService.configurarDHCP(
        network: network,
        hosts: hosts,
      );

      setState(() {
        _statusMessage = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: ${e.toString()}')));
      setState(() => _statusMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _networkController.dispose();
    _subnetsController.dispose();
    _hostControllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar DHCP por SSH')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: 'IP del servidor'),
            ),
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'Usuario SSH'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña SSH'),
              obscureText: true,
            ),
            TextField(
              controller: _networkController,
              decoration: InputDecoration(labelText: 'Dirección de red'),
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hosts para subred ${entry.key + 1}',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _configureDHCP,
              child: Text('Configurar DHCP'),
            ),
            if (_isLoading) ...[
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(_statusMessage),
            ] else if (_statusMessage.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(_statusMessage),
            ],
          ],
        ),
      ),
    );
  }
}
