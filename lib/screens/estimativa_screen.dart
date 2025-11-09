import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importa nosso serviço de API

// Importa as imagens (as mesmas da tela de login)
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

  // Widget auxiliar para criar os cards de informação do protótipo
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 20),
            // Flexible permite que o texto quebre a linha se for muito grande
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
      appBar: AppBar(
        title: const Text('Estimativa Financeira'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshEstimativa(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _estimativaFuture,
          builder: (context, snapshot) {
            // --- Estado de Carregamento ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // --- Estado de Erro ---
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Erro ao carregar estimativa: ${snapshot.error}'),
                ),
              );
            }
            // --- Estado de Sucesso (Sem Dados) ---
            if (!snapshot.hasData) {
              return const Center(child: Text('Nenhuma estimativa encontrada.'));
            }

            // --- Estado de Sucesso (Com Dados) ---
            final estimativa = snapshot.data!;
            final consumoTotal = estimativa['consumo_total_litros']?.toString() ?? '0';
            final custoEstimado = estimativa['estimativa_custo'] ?? '0.00';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                    content: 'R\$ XX,XX (TODO: Atualizar API)',
                  ),

                  // --- Card 4: Economia (PLACEHOLDER) ---
                  _buildInfoCard(
                    icon: Icons.savings_outlined,
                    iconColor: Colors.purple,
                    title: 'Economia',
                    content: 'Você economizou R\$ XX,XX em relação ao mês passado. (TODO: Atualizar API)',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}