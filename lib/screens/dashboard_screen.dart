import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart'; // Importa nosso serviço de API
import 'package:fl_chart/fl_chart.dart'; // Para o gráfico
import 'package:intl/intl.dart'; // Para formatar os meses
import 'dart:math'; // Para a função 'max'

// Importa as telas do menu (para o Drawer)
import './relatorios_screen.dart';
import './consumo_real_screen.dart';
import './alertas_screen.dart';
import './dicas_screen.dart';
import './estimativa_screen.dart';
import './perfil_screen.dart';
import './configuracoes_screen.dart';
import './sobre_screen.dart';

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  // Estados para armazenar os dados da API
  bool _isLoading = true;
  Map<String, dynamic>? _estimativa;
  List<dynamic>? _relatorio;
  List<dynamic>? _alertas;
  Map<String, dynamic>? _dicaDoDia;
  // TODO: Adicionar estado para o Consumo do Dia (requer API nova)

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // Carrega os dados ao iniciar a tela
  }

  // Função para carregar todos os dados do dashboard em paralelo
  Future<void> _loadDashboardData() async {
    setState(() { _isLoading = true; });
    try {
      // Roda todas as chamadas de API ao mesmo tempo
      final results = await Future.wait([
        _apiService.getEstimativaMensal(),
        _apiService.getRelatorioMensal(),
        _apiService.getAlertas(),
        _apiService.getDicas(),
      ]);

      // Atualiza o estado com os resultados
      setState(() {
        _estimativa = results[0] as Map<String, dynamic>;
        _relatorio = results[1] as List<dynamic>;
        _alertas = results[2] as List<dynamic>;
        
        // Pega a primeira dica como "Dica do Dia"
        final dicas = results[3] as List<dynamic>;
        _dicaDoDia = dicas.isNotEmpty ? dicas.first : null;
        
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados do dashboard: $e')),
        );
        setState(() { _isLoading = false; });
      }
    }
  }

  // Função auxiliar para criar os itens do menu
  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => screen),
        );
      },
    );
  }

  // Widget auxiliar para os cards de informação do protótipo
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.black54,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      // --- 1. MUDANÇA APLICADA (AppBar transparente) ---
      // (Você já tinha feito isso)
      appBar: AppBar(
        title: const Text('Início'),
        backgroundColor: Colors.transparent, // Deixa a AppBar transparente
        elevation: 0, // Remove a sombra
      ),
      
      // --- 2. DRAWER (Sem mudanças) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Fernando Dias"), 
              accountEmail: const Text("Carregando..."), 
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("F", style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor)),
              ),
              decoration: BoxDecoration(
                color: Colors.blue[700], 
              ),
            ),
            _buildDrawerItem(context, icon: Icons.bar_chart, title: 'Relatórios', screen: const RelatoriosScreen()),
            _buildDrawerItem(context, icon: Icons.timelapse, title: 'Consumo em Tempo Real', screen: const ConsumoRealScreen()),
            _buildDrawerItem(context, icon: Icons.warning_amber_rounded, title: 'Alertas e Notificações', screen: const AlertasScreen()),
            _buildDrawerItem(context, icon: Icons.lightbulb_outline, title: 'Dicas de Economia', screen: const DicasScreen()),
            _buildDrawerItem(context, icon: Icons.stacked_line_chart, title: 'Estimativa Financeira', screen: const EstimativaScreen()),
            _buildDrawerItem(context, icon: Icons.person_outline, title: 'Perfil do Usuário', screen: const PerfilScreen()),
            _buildDrawerItem(context, icon: Icons.settings_outlined, title: 'Configurações', screen: const ConfiguracoesScreen()),
            _buildDrawerItem(context, icon: Icons.info_outline, title: 'Sobre o App', screen: const SobreScreen()),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
              },
            ),
          ],
        ),
      ),

      // --- 3. MUDANÇA APLICADA (Permite o body ficar atrás da AppBar) ---
      extendBodyBehindAppBar: true,

      // --- 4. MUDANÇA APLICADA (Body agora é um Container com o fundo) ---
      body: Container(
        // Define a imagem de fundo para a tela inteira
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath), // Constante que já importamos
            fit: BoxFit.cover,
          ),
        ),
        // O filho do container é a lógica que você já tinha
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator( 
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- 5. MUDANÇA APLICADA (Espaçamento no topo) ---
                      // Adiciona um padding para o conteúdo não ficar atrás da AppBar
                      SizedBox(height: kToolbarHeight + 20),

                      // --- Resto do seu conteúdo ---
                      Card(
                        color: Colors.blue[700],
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            "Consumo do dia: 50L", // TODO: Conectar ao GET /api/consumo/hoje
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12.0),
                        color: Colors.green.shade100,
                        child: const Text(
                          "EXCELENTE, você está no caminho certo!",
                          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- 6. MUDANÇA APLICADA (Cor do Título) ---
                      Card(
                        elevation: 2.0,
                        // Usando o mesmo margin e shape dos info cards
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // Padding interno
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Consumo Mensal (Últimos Meses)",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87, // <-- Cor PRETA para o fundo branco
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                height: 200,
                                padding: const EdgeInsets.only(right: 16.0),
                                child: (_relatorio == null || _relatorio!.isEmpty)
                                    ? const Center(child: Text("Sem dados para exibir o gráfico."))
                                    : BarChart(
                                        _buildBarChartData(),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildInfoCard(
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.orange,
                        title: "Alerta Recente",
                        subtitle: _alertas != null && _alertas!.isNotEmpty
                            ? _alertas!.first['mensagem']
                            : "Nenhum alerta. Tudo certo!",
                      ),
                      _buildInfoCard(
                        icon: Icons.monetization_on_outlined,
                        iconColor: Colors.green,
                        title: "Gasto Total no Mês",
                        subtitle: _estimativa != null
                            ? "Estimativa de R\$ ${_estimativa!['estimativa_custo']}"
                            : "Calculando...",
                      ),
                       _buildInfoCard(
                        icon: Icons.lightbulb_outline,
                        iconColor: Colors.blue,
                        title: "Dica do Dia",
                        subtitle: _dicaDoDia != null
                            ? _dicaDoDia!['titulo']
                            : "Sem dicas hoje.",
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

BarChartData _buildBarChartData() {
    // Encontra o valor máximo de consumo para ajustar a escala do eixo Y
    double maxY = 0;
    for (var item in _relatorio!) {
      final consumo = double.tryParse(item['consumo_total_litros']?.toString() ?? '0') ?? 0;
      maxY = max(maxY, consumo);
    }
    // Adiciona uma margem de 20% no topo do gráfico
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100; // Evita gráfico zerado se não houver dados

    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              // 'value' será o índice (0, 1, 2...)
              final index = value.toInt();
              String text = '';
              if (index >= 0 && index < _relatorio!.length) {
                // Formata a data (ex: "JAN", "FEV")
                final data = DateTime.parse(_relatorio![index]['mes']);
                text = DateFormat.MMM('pt_BR').format(data).toUpperCase();
              }
              
              return SideTitleWidget(
                // axisSide: meta.axisSide, // <-- LINHA REMOVIDA
                meta: meta, 
                child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black,)),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45, 
            getTitlesWidget: (double value, TitleMeta meta) {
              String text = '';
              // Mostra apenas alguns valores no eixo Y
              if (value == 0 || value == meta.max || value == (meta.max / 2)) {
                text = "${value.toInt()}L";
              }
              return SideTitleWidget(
                // axisSide: meta.axisSide, // <-- LINHA REMOVIDA
                meta: meta, 
                space: 8.0,
                child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.black,)),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4, // Linhas horizontais
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 1,
        ),
      ),
      barGroups: _relatorio!.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final consumo = double.tryParse(item['consumo_total_litros']?.toString() ?? '0') ?? 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: consumo,
              color: Colors.lightBlue,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}