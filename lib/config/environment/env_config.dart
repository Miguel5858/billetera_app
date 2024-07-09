import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late String apiUrl;

  static void initialize() {
    dotenv.env['API_URL'] != null
        ? apiUrl = dotenv.env['API_URL']!
        : throw Exception('API_URL not found in .env');
  }
}
