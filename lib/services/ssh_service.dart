import 'package:dartssh2/dartssh2.dart';
import 'package:http/http.dart' as http;

class SSHService {
  late SSHClient client;
  final String ip;
  final String username;
  final String password;

  SSHService({
    required this.ip,
    required this.username,
    required this.password,
  });

  Future<String> configurarDHCP({
    required String network,
    required List<int> hosts,
  }) async {
    try {
      final uri = Uri.parse(
        'https://vlsmcalculator-production.up.railway.app/vlsm/calculate?network=$network'
        '&subnets=${hosts.length}&${hosts.map((h) => 'hosts=$h').join('&')}',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Error al consultar la API: ${response.body}');
      }

      final configDHCP = response.body;

      final client = SSHClient(
        await SSHSocket.connect(ip, 22),
        username: username,
        onPasswordRequest: () => password,
      );

      await client.execute(
        'echo $password | sudo -S cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak',
      );

      await client.execute(
        'echo $password | sudo -S cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak',
      );

      const interfaz = 'INTERFACEv4="enp0s3"';
      await client.execute(
        'echo $password | sudo -S bash -c \'echo -e "$interfaz" > /etc/default/isc-dhcp-server\'',
      );

      final configFinal = '''
authoritative;
$configDHCP


''';

      await client.execute(
        'echo $password | sudo -S bash -c \'echo -e "$configFinal" >> /etc/dhcp/dhcpd.conf\'',
      );

      final result = await client.execute(
        'echo $password | sudo -S systemctl restart isc-dhcp-server',
      );

      client.close();

      return '✅ Configuración realizada:\n$result';
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}
