import 'package:flutter/material.dart';
import './dicas_screen.dart'; // Para o link "Dicas de Economia"

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class ConsumoRealScreen extends StatelessWidget {
  const ConsumoRealScreen({super.key});

  // --- WIDGETS AUXILIARES PARA OS CARDS ---

  // Card "Consumo Atual" (do protótipo)
  Widget _buildConsumoAtualCard() {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: ListTile(
          leading: Icon(Icons.water_drop_outlined, color: Colors.blue, size: 40),
          title: Text('Consumo atual', style: TextStyle(fontSize: 16)),
          subtitle: Text(
            '0,8 L/min', // DADO DE EXEMPLO (MOCK)
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // Card "Últimas Medições" (do protótipo)
  Widget _buildUltimasMedicoesCard() {
    // Dados de exemplo (mock)
    final medicoes = [
      {'time': '12:00', 'valor': '5.0 Litros'},
      {'time': '09:00', 'valor': '2.0 Litros'},
      {'time': '08:00', 'valor': '15.0 Litros'},
    ];

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.list_alt_rounded),
              title: Text('Últimas medições', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            // Gera a lista de medições
            ...medicoes.map((medicao) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(medicao['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(medicao['valor']!),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Card "Indicador de Consumo" (do protótipo)
  Widget _buildIndicadorConsumoCard() {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.speed_outlined),
              title: Text('Indicador de Consumo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.circle, color: Colors.orange[600], size: 40),
                const SizedBox(width: 16),
                const Flexible( // Evita overflow de texto
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AMARELO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Seu consumo está acima da média!'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Card "Dicas de Economia" (do protótipo)
  Widget _buildDicasCard(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 30),
        title: const Text('Dicas de Economia'),
        subtitle: const Text('Receba sugestões para reduzir gastos'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Reutiliza a navegação para a tela de Dicas
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const DicasScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Consumo em Tempo Real'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // --- 2. BODY ATRÁS DA APPBAR ---
      extendBodyBehindAppBar: true, 

      // --- 3. CONTAINER COM IMAGEM DE FUNDO ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        // Usamos SafeArea para o conteúdo não vazar para a barra de status
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Não precisamos do SizedBox(kToolbarHeight) aqui 
                // porque o SafeArea já cuida do espaçamento do topo.

                _buildConsumoAtualCard(),
                const SizedBox(height: 16),
                _buildUltimasMedicoesCard(),
                const SizedBox(height: 16),
                _buildIndicadorConsumoCard(),
                const SizedBox(height: 16),
                _buildDicasCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}