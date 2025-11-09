import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Importa o pacote do carrossel
import '../services/api_service.dart'; // Importa nosso serviço de API

// Importa as imagens (as mesmas da tela de login)
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
            color: (Theme.of(context).primaryColor)
                .withOpacity(_currentCard == entry.key ? 0.9 : 0.3),
          ),
        );
      }).toList(),
    );
  }

  // Constrói um card de dica individual
  Widget _buildDicaCard(Map<String, dynamic> dica) {
    // URL da imagem (placeholder, já que a API não retorna imagem)
    // TODO: Adicionar um campo 'imagemUrl' na sua API de dicas
    final String imageUrl = 'https://i.imgur.com/example.png'; // Substitua por um placeholder real

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      clipBehavior: Clip.antiAlias, // Para o conteúdo não vazar das bordas arredondadas
      child: SingleChildScrollView( // Permite rolar o conteúdo do card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do Card (Placeholder)
            Image.network(
              imageUrl, // TODO: Usar dica['imageUrl'] quando existir
              height: 200,
              fit: BoxFit.cover,
              // Mostra um loading enquanto a imagem da web carrega
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : const Center(heightFactor: 4, child: CircularProgressIndicator());
              },
              // Mostra um ícone de erro se a imagem falhar
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                );
              },
            ),

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
                textAlign: TextAlign.justify, // Para um texto mais alinhado
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
      appBar: AppBar(
        title: const Text('Dicas de Economia'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dicas.isEmpty
              ? const Center(child: Text('Nenhuma dica de economia encontrada.'))
              : Column(
                  children: [
                    // O Carrossel de Cards
                    CarouselSlider(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.75, // Ocupa 75% da altura
                        viewportFraction: 0.85, // Mostra um pouco dos cards laterais
                        enlargeCenterPage: true, // Aumenta o card central
                        enableInfiniteScroll: false, // Não volta ao início
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
                    
                    // As bolinhas indicadoras
                    _buildPageIndicator(),
                  ],
                ),
    );
  }
}