import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importa nosso serviço de API

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class EstimativaScreen extends StatefulWidget {
  const EstimativaScreen({super.key});

  @override
  State<EstimativaScreen> createState() => _EstimativaScreenState();
}

class _EstimativaScreenState extends State<EstimativaScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _estimativaFuture;

  @override
  void initState() {
    super.initState();
    _estimativaFuture = _fetchEstimativa(); // Inicia a busca pelos dados
  }

  // Função que busca os dados na API
  Future<Map<String, dynamic>> _fetchEstimativa() {
    return _apiService.getEstimativaMensal();
  }

  // Função para recarregar os dados
  void _refreshEstimativa() {
    setState(() {
      _estimativaFuture = _fetchEstimativa();
    });
  }

  // Widget auxiliar para criar os cards de informação (sem alteração)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color iconColor = Colors.black54,
  }) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white.withOpacity(0.95), // Adiciona leve transparência
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 20),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Estimativa Financeira'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // --- 2. BODY ATRÁS DA APPBAR ---
      extendBodyBehindAppBar: true, 

      // --- 3. CONTAINER COM IMAGEM DE FUNDO ---
      body: Container(
        width: double.infinity,  // Garante que o fundo preencha a tela
        height: double.infinity, // Garante que o fundo preencha a tela
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        // O FutureBuilder agora é o filho do Container
        child: RefreshIndicator(
          onRefresh: () async => _refreshEstimativa(),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _estimativaFuture,
            builder: (context, snapshot) {
              // --- Estado de Carregamento ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              // --- Estado de Erro ---
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Erro ao carregar estimativa: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                  ),
                );
              }
              // --- Estado de Sucesso (Sem Dados) ---
              if (!snapshot.hasData) {
                return const Center(child: Text('Nenhuma estimativa encontrada.', style: const TextStyle(color: Colors.white)));
              }

              // --- Estado de Sucesso (Com Dados) ---
              final estimativa = snapshot.data!;
              final consumoTotal = estimativa['consumo_total_litros']?.toString() ?? '0';
              final custoEstimado = estimativa['estimativa_custo'] ?? '0.00';

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Permite "Puxar para atualizar"
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- 4. ESPAÇAMENTO PARA O TOPO ---
                    SizedBox(height: kToolbarHeight + 20),
                    
                    // --- Card 1: Consumo total do mês ---
                    _buildInfoCard(
                      icon: Icons.show_chart_rounded,
                      iconColor: Colors.blue,
                      title: 'Consumo total do mês até hoje',
                      content: '$consumoTotal L',
                    ),

                    // --- Card 2: Conta estimada ---
                    _buildInfoCard(
                      icon: Icons.calculate_outlined,
                      iconColor: Colors.green,
                      title: 'Conta estimada',
                      content: 'Se continuar assim, sua conta será de R\$ $custoEstimado',
                    ),

                    // --- Card 3: Comparação (PLACEHOLDER) ---
                    _buildInfoCard(
                      icon: Icons.compare_arrows_rounded,
                      iconColor: Colors.orange,
                      title: 'Comparação com sua conta do mês passado',
                      content: 'R\$ XX,XX',
                    ),

                    // --- Card 4: Economia (PLACEHOLDER) ---
                    _buildInfoCard(
                      icon: Icons.savings_outlined,
                      iconColor: Colors.purple,
                      title: 'Economia',
                      content: 'Você economizou R\$ XX,XX em relação ao mês passado.',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}