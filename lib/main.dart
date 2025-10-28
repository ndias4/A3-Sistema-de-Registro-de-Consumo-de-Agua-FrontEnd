import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart'; // Nosso provider
import './screens/login_screen.dart';   // Tela de Login
import './screens/dashboard_screen.dart'; // Tela Principal
import './screens/splash_screen.dart';  // Tela de Carregamento

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Envolvemos o MaterialApp com o ChangeNotifierProvider
    //    Isso torna o AuthProvider acessível em todo o app
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'MonitorÁgua',
        theme: ThemeData(
          primarySwatch: Colors.blue, // Tema básico
        ),
        // 2. Usamos o Consumer para "ouvir" as mudanças no AuthProvider
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            // 3. Decidimos qual tela mostrar com base no status
            if (auth.authStatus == AuthStatus.authenticated) {
              return DashboardScreen(); // Logado -> Mostra Dashboard
            } else if (auth.authStatus == AuthStatus.unauthenticated) {
              return LoginScreen();     // Não logado -> Mostra Login
            } else {
              return SplashScreen();    // Ainda verificando -> Mostra Carregamento
            }
          },
        ),
      ),
    );
  }
}