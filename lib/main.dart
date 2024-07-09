import 'package:FAB/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:FAB/config/routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().initialize(); // Inicializa SessionManager

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'F.A.B App',
      initialRoute: SessionManager().getToken() != null ? '/home' : '/',
      onGenerateRoute: AppRouter.generateRoute,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
