import 'package:flutter/material.dart';

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: const Center(
        child: Text('Tela de Configurações - Em Construção'),
      ),
    );
  }
}