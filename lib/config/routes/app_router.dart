import 'package:FAB/presentation/screens/auth/login_screen.dart';
import 'package:FAB/presentation/screens/auth/register_screen.dart';
import 'package:FAB/presentation/screens/home.dart';
import 'package:FAB/presentation/screens/transaction/deposito/deposito_screen.dart';
import 'package:FAB/presentation/screens/transaction/retiro/retiro_screen.dart';
import 'package:FAB/presentation/screens/transaction/saldototalgeneral/saldo_total_general_listado_screen.dart';
import 'package:FAB/presentation/screens/transaction/saldopersonal/transaction_screen.dart';
import 'package:FAB/utils/token_service.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String registerRoute = '/register';
  static const String transactionRoute = '/transaction';
  static const String depositoRoute = '/deposito';
  static const String retiroRoute = '/retiro';
  static const String saldoTotalRoute = '/saldo_total';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Verificar si el usuario está logueado
    bool isLoggedIn = SessionManager().getToken() != null;

    final Map<String, WidgetBuilder> routes = {
      '/': (_) => isLoggedIn
          ? HomeScreen(
              userName: SessionManager().getUserName() ?? '',
              userId: SessionManager().getUserId()?.toString() ??
                  '', // Convertir el ID del usuario a String
              userRole: SessionManager().getUserRole() ?? '',
            )
          : LoginScreen(),
      registerRoute: (_) => RegisterScreen(),
      '/home': (_) => HomeScreen(
            userName: SessionManager().getUserName() ?? '',
            userId: SessionManager().getUserId()?.toString() ??
                '', // Convertir el ID del usuario a String
            userRole: SessionManager().getUserRole() ?? '',
          ),
      transactionRoute: (_) => TransactionScreen(
            // Agregar TransactionScreen
            userName: SessionManager().getUserName() ?? '',
            userId: SessionManager().getUserId()?.toString() ?? '',
          ),
      // Agregar más rutas aquí según sea necesario
      depositoRoute: (_) => DepositoScreen(
            userRole: SessionManager().getUserRole() ??
                '', // Obtener el userRole, predeterminado a 'user' si es nulo
            superUserId: SessionManager().getUserId() ??
                0, // Obtener el ID del superusuario o establecer como 0 si es nulo
            userId: SessionManager().getUserId()?.toString() ??
                '0', // Convertir el ID del usuario a String o establecer '0' si es nulo
          ),

      retiroRoute: (_) => RetitoScreen(
            userRole: SessionManager().getUserRole() ??
                '', // Obtener el userRole, predeterminado a 'user' si es nulo
            superUserId: SessionManager().getUserId() ??
                0, // Obtener el ID del superusuario o establecer como 0 si es nulo
            userId: SessionManager().getUserId()?.toString() ??
                '0', // Convertir el ID del usuario a String o establecer '0' si es nulo
          ),

      saldoTotalRoute: (_) => SaldoTotalGeneralListadoScreen(
            userName: SessionManager().getUserName() ?? '',
            userId: SessionManager().getUserId()?.toString() ?? '',
            userRole: SessionManager().getUserRole() ?? '',
          ), // Agregar la ruta para SaldoTotalGeneralListadoScreen
    };

    final builder = routes[settings.name];
    return builder != null ? MaterialPageRoute(builder: builder) : null;
  }
}
