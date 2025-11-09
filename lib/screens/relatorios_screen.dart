import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importa a biblioteca de gráficos
import 'dart:math'; // Para usar o 'max' na legenda
import 'package:intl/intl.dart'; // Para formatar as datas (meses)
import '../services/api_service.dart'; // Importa nosso serviço de API

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _dadosRelatorio = []; // Armazena os dados da API

  @override
  void initState() {
    super.initState();
    _fetchRelatorio(); // Busca os dados ao carregar a tela
  }

  Future<void> _fetchRelatorio() async {
    setState(() { _isLoading = true; });
    try {
      final data = await _apiService.getRelatorioMensal();
      setState(() {
        _dadosRelatorio = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar relatório: ${e.toString()}')),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Relatórios de Consumo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Garante que o ícone "voltar" seja branco e legível
        iconTheme: const IconThemeData(color: Colors.white),
        // Garante que o título seja branco e legível
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _dadosRelatorio.isEmpty
                ? const Center(child: Text('Nenhum dado de consumo encontrado.', style: TextStyle(color: Colors.white)))
                : RefreshIndicator( // Permite "puxar para atualizar"
                    onRefresh: _fetchRelatorio,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- 4. ESPAÇAMENTO PARA O TOPO ---
                          SizedBox(height: kToolbarHeight + 20),
                          
                          // --- 5. GRÁFICO DENTRO DE UM CARD BRANCO ---
                          Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Consumo Mensal (Últimos 12 Meses)',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    height: 300, 
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: BarChart(
                                      _buildBarChartData(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),

                          // --- 6. CARD DE INSIGHT ---
                          Card(
                            elevation: 2.0,
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Percebemos que seu consumo de água está um pouco acima da média...",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Lembre-se: cada gota economizada ajuda não só no valor da conta, mas também no cuidado com o meio ambiente. Estamos aqui para te apoiar nessa jornada!"
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // --- Função para construir os dados do gráfico (COM LEGENDAS PRETAS) ---
  BarChartData _buildBarChartData() {
    double maxY = 0;
    for (var item in _dadosRelatorio) {
      final consumo = double.tryParse(item['consumo_total_litros']?.toString() ?? '0') ?? 0;
      maxY = max(maxY, consumo);
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

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
              final index = value.toInt();
              String text = '';
              if (index >= 0 && index < _dadosRelatorio.length) {
                final data = DateTime.parse(_dadosRelatorio[index]['mes']);
                text = DateFormat.MMM('pt_BR').format(data).toUpperCase();
              }
              
              return SideTitleWidget(
                meta: meta, 
                // --- 7. COR DA LEGENDA CORRIGIDA ---
                child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
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
              if (value == 0 || value == meta.max || value == (meta.max / 2)) {
                text = "${value.toInt()}L";
              }
              return SideTitleWidget(
                meta: meta, 
                space: 8.0,
                // --- 7. COR DA LEGENDA CORRIGIDA ---
                child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.black)),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.shade300,
          strokeWidth: 1,
        ),
      ),
      barGroups: _dadosRelatorio.asMap().entries.map((entry) {
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