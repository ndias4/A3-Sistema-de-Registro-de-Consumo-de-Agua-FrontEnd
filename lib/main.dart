import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 

import './providers/auth_provider.dart'; 
import './screens/login_screen.dart';   
import './screens/dashboard_screen.dart'; 
import './screens/splash_screen.dart';  

// 2. TRANSFORMAR O main() EM 'async'
void main() async {
  // 3. GARANTIR QUE O FLUTTER ESTEJA PRONTO
  WidgetsFlutterBinding.ensureInitialized();
  // 4. INICIALIZAR A FORMATAÇÃO DE DATAS PARA 'pt_BR'
  await initializeDateFormatting('pt_BR', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Adicione const

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'MonitorÁgua',
        theme: ThemeData(
          primarySwatch: Colors.blue, 
        ),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            if (auth.authStatus == AuthStatus.authenticated) {
              return const DashboardScreen(); // Adicione const
            } else if (auth.authStatus == AuthStatus.unauthenticated) {
              return const LoginScreen(); // Adicione const
            } else {
              return SplashScreen(); 
            }
          },
        ),
      ),
    );
  }
}