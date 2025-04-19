import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Obtener información de subred a partir de la máscara
  static Future<String> getIPFromMask(String mask) async {
    final url =
        'https://vlsmcalculator-production.up.railway.app/vlsm/subnet-mask/$mask';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return 'Subnet Mask: ${data['subnetMask']}';
    } else {
      return 'Error al obtener datos';
    }
  }

  // Obtener información de la IP
  static Future<String> getIPInfo(String ip) async {
    final url =
        'https://vlsmcalculator-production.up.railway.app/vlsm/ip-info?ip=$ip';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return 'Network: ${data['network']}\nSubnet Mask: ${data['subnetMask']}\nClass: ${data['class']}\nBroadcast: ${data['broadcast']}';
    } else {
      return 'Error al obtener datos';
    }
  }

  // Obtener datos VLSM
  static Future<String> getVLSMInfo(String subnet) async {
    final url =
        'https://vlsmcalculator-production.up.railway.app/vlsm/vlsm-info?subnet=$subnet';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return 'VLSM Info: ${data.toString()}';
    } else {
      return 'Error al obtener datos';
    }
  }
}
