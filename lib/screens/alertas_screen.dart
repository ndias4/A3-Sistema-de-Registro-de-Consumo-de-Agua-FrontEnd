import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Define o caminho da imagem de fundo
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
    return _apiService.getAlertas();
  }

  // Função para recarregar os alertas
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
        _refreshAlertas(); 
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
        _refreshAlertas(); 
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
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Alertas e Notificações'),
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
        child: FutureBuilder<List<dynamic>>(
          future: _alertasFuture,
          builder: (context, snapshot) {
            // --- Estado de Carregamento ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            // --- Estado de Erro ---
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar alertas: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            
            // --- Estado de Sucesso (Com Dados ou Vazio) ---
            final alertas = snapshot.data ?? [];

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshAlertas(),
                    child: alertas.isEmpty
                      // --- Estado Vazio ---
                      ? SingleChildScrollView( // Permite "Puxar para atualizar" mesmo vazio
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            alignment: Alignment.center,
                            child: const Text(
                              'Nenhum alerta recente.', 
                              style: TextStyle(color: Colors.white, fontSize: 16)
                            ),
                          ),
                        )
                      // --- Estado com Dados ---
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            top: kToolbarHeight + 20, // --- 4. ESPAÇAMENTO DO TOPO ---
                            left: 8.0,
                            right: 8.0,
                            bottom: 8.0,
                          ),
                          itemCount: alertas.length,
                          itemBuilder: (context, index) {
                            final alerta = alertas[index];
                            final bool lido = alerta['lido'] ?? false;
                            
                            // O card de alerta individual (já é branco)
                            return Card(
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                
                // --- Rodapé com Botões ---
                // Se não houver alertas, não mostra os botões de limpar
                if (alertas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0), // Padding extra na parte de baixo
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: null, // Desabilitado
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Marcar como lidas'),
                        ),
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
      ),
    );
  }
}