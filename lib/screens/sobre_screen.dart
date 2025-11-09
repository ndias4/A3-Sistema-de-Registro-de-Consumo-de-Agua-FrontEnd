import 'package:flutter/material.dart';

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: const Center(
        child: Text('Tela Sobre o App - Em Construção'),
      ),
    );
  }
}