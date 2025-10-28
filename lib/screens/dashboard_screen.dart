import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Importa o provider

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Chama a função logout do provider
              await Provider.of<AuthProvider>(context, listen: false).logout();
              // O main.dart trocará a tela automaticamente
            },
          )
        ],
      ),
      body: Center(
        child: Text('Bem-vindo! Você está logado.'),
      ),
    );
  }
}