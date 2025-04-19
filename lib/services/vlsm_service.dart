import 'package:http/http.dart' as http;
import 'dart:convert';

class VLSMService {
  Future<List<dynamic>> calculateVLSM(
    String network,
    int subnetsCount,
    List<String> hosts,
  ) async {
    final hostsQuery = hosts.map((host) => 'hosts=$host').join('&');
    final url =
        'https://vlsmcalculator-production.up.railway.app/vlsm/calculate-json?network=$network&subnets=$subnetsCount&$hostsQuery';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['subnets'];
      } else {
        throw Exception('Error al conectar con la API');
      }
    } catch (e) {
      rethrow;
    }
  }
}
