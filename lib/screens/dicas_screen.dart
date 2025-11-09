import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Importa o pacote do carrossel
import '../services/api_service.dart'; // Importa nosso serviço de API

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class DicasScreen extends StatefulWidget {
  const DicasScreen({super.key});

  @override
  State<DicasScreen> createState() => _DicasScreenState();
}

class _DicasScreenState extends State<DicasScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _dicas = [];
  int _currentCard = 0; // Para controlar o indicador de página (bolinhas)

  @override
  void initState() {
    super.initState();
    _fetchDicas();
  }

  Future<void> _fetchDicas() async {
    setState(() { _isLoading = true; });
    try {
      final data = await _apiService.getDicas();
      setState(() {
        _dicas = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dicas: ${e.toString()}')),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  // Constrói o indicador de bolinhas
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _dicas.asMap().entries.map((entry) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // --- 6. MUDANÇA: Cor das bolinhas para branco ---
            color: Colors.white.withOpacity(_currentCard == entry.key ? 0.9 : 0.3),
          ),
        );
      }).toList(),
    );
  }

  // Constrói um card de dica individual
  Widget _buildDicaCard(Map<String, dynamic> dica) {
    final String? imageUrl = dica['imagem_url']; 

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      clipBehavior: Clip.antiAlias, 
      child: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do Card
           // Se a URL for nula ou vazia, mostra o ícone de erro imediatamente
            (imageUrl == null || imageUrl.isEmpty) 
              ? Container( // Placeholder se não houver imagem
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                )
              : Image.network( // Se houver imagem, tenta carregá-la
                  imageUrl, 
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : const Center(heightFactor: 4, child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Mostra erro se o link estiver quebrado
                    return Container( 
                      height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                    );
                  },
                ),
            // ... (Resto do conteúdo do card, títulos, textos, botões - sem mudança)
             // Título da Dica
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                dica['titulo'] ?? 'Dica de Economia',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Descrição da Dica
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Text(
                dica['descricao'] ?? 'Descrição da dica não disponível.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.justify, 
              ),
            ),

            // Ações do Card (Salvar, Compartilhar)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () { /* TODO: Implementar lógica de salvar */ },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () { /* TODO: Implementar lógica de compartilhar */ },
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
        title: const Text('Dicas de Economia'),
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
          child: _isLoading
              // --- 4. Cor do Loading e Texto de Erro ---
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _dicas.isEmpty
                  ? const Center(child: Text('Nenhuma dica de economia encontrada.', style: TextStyle(color: Colors.white)))
                  : Column(
                      // --- 5. Centraliza o Carrossel na Tela ---
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // O Carrossel de Cards
                        CarouselSlider(
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.75, // Ocupa 75% da altura
                            viewportFraction: 0.85, 
                            enlargeCenterPage: true, 
                            enableInfiniteScroll: false, 
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCard = index; // Atualiza as bolinhas
                              });
                            },
                          ),
                          items: _dicas.map((dica) {
                            return _buildDicaCard(dica as Map<String, dynamic>);
                          }).toList(),
                        ),
                        
                        // As bolinhas indicadoras (agora serão brancas)
                        _buildPageIndicator(),
                      ],
                    ),
        ),
      ),
    );
  }
}