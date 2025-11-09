import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _alertasFuture;

  @override
  void initState() {
    super.initState();
    _alertasFuture = _fetchAlertas(); // Inicia a busca pelos dados
  }

  // Função que busca os dados na API
  Future<List<dynamic>> _fetchAlertas() {
    // O FutureBuilder vai gerenciar o estado de loading/erro
    return _apiService.getAlertas();
  }

  // Função para recarregar os alertas (usado no "Limpar")
  void _refreshAlertas() {
    setState(() {
      _alertasFuture = _fetchAlertas();
    });
  }

  // Função para marcar um item como lido
  Future<void> _marcarComoLido(int id) async {
    try {
      bool success = await _apiService.marcarAlertaComoLido(id);
      if (success) {
        _refreshAlertas(); // Recarrega a lista para refletir a mudança (ex: mudar a cor)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta marcado como lido.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Função para limpar TODOS os alertas
  Future<void> _limparTodosAlertas() async {
    try {
      bool success = await _apiService.limparAlertas();
      if (success) {
        _refreshAlertas(); // Recarrega a lista (que agora estará vazia)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificações limpas.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao limpar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas e Notificações'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _alertasFuture,
        builder: (context, snapshot) {
          // --- Estado de Carregamento ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- Estado de Erro ---
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar alertas: ${snapshot.error}'));
          }
          // --- Estado de Sucesso (Lista Vazia) ---
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum alerta recente.'));
          }
          
          // --- Estado de Sucesso (Com Dados) ---
          final alertas = snapshot.data!;
          
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _refreshAlertas(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];
                      final bool lido = alerta['lido'] ?? false;
                      
                      // O card de alerta individual
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        // Define a cor se já foi lido
                        color: lido ? Colors.grey[200] : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_amber_rounded,
                            color: lido ? Colors.grey[500] : Colors.orange,
                          ),
                          title: Text(
                            alerta['mensagem'] ?? 'Alerta inválido',
                            style: TextStyle(
                              color: lido ? Colors.grey[600] : Colors.black,
                              decoration: lido ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          // Botão para marcar como lido
                          trailing: lido ? null : IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: 'Marcar como lido',
                            onPressed: () => _marcarComoLido(alerta['id']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // --- Rodapé com Botões (do protótipo) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botão Marcar como Lidas (Desabilitado por enquanto)
                    ElevatedButton(
                      onPressed: null, // Desabilitado
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text('Marcar como lidas'),
                    ),
                    // Botão Limpar Notificações
                    ElevatedButton(
                      onPressed: _limparTodosAlertas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Limpar notificações'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}