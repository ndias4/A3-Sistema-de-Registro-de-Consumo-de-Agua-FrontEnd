import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importa a biblioteca de gráficos
import 'dart:math'; // Para usar o 'max' na legenda
import 'package:intl/intl.dart'; // Para formatar as datas (meses)
import '../services/api_service.dart'; // Importa nosso serviço de API

// Importa as imagens (as mesmas da tela de login)
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
      appBar: AppBar(
        title: const Text('Relatórios de Consumo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dadosRelatorio.isEmpty
              ? const Center(child: Text('Nenhum dado de consumo encontrado.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- O GRÁFICO DE BARRAS ---
                      Text(
                        'Consumo Mensal (Últimos 12 Meses)',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 300, // Altura fixa para o gráfico
                        padding: const EdgeInsets.only(right: 16.0),
                        child: BarChart(
                          _buildBarChartData(),
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // --- TEXTO DE INSIGHT (do protótipo) ---
                      Card(
                        elevation: 0,
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
    );
  }

  // --- Função para construir os dados do gráfico ---
  BarChartData _buildBarChartData() {
    // Encontra o valor máximo de consumo para ajustar a escala do eixo Y
    double maxY = 0;
    for (var item in _dadosRelatorio) {
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
              if (index >= 0 && index < _dadosRelatorio.length) {
                // Formata a data (ex: "JAN", "FEV")
                final data = DateTime.parse(_dadosRelatorio[index]['mes']);
                text = DateFormat.MMM('pt_BR').format(data).toUpperCase();
              }
              
              return SideTitleWidget(
                // axisSide: meta.axisSide, // <-- LINHA REMOVIDA
                meta: meta, 
                child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                child: Text(text, style: const TextStyle(fontSize: 10)),
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