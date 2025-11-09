import 'package:flutter/material.dart';

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class ConsumoRealScreen extends StatelessWidget {
  const ConsumoRealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo em Tempo Real'),
      ),
      body: const Center(
        child: Text('Tela de Consumo em Tempo Real - Em Construção'),
      ),
    );
  }
}