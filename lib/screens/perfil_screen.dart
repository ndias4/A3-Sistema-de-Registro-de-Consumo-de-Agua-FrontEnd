import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Importa nosso serviço de API

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController(); // Usado apenas para 'nova senha'

  bool _isLoading = true;
  bool _notificacoesAtivas = true; // Estado do Switch

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Carrega os dados do usuário ao iniciar a tela
  }

  // Busca os dados do perfil na API
  Future<void> _loadUserProfile() async {
    setState(() { _isLoading = true; });
    try {
      final userProfile = await _apiService.getUserProfile();
      setState(() {
        _nomeController.text = userProfile['nome'] ?? '';
        _emailController.text = userProfile['email'] ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // Salva as alterações (Nome e Email)
  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Se o formulário for inválido, não faz nada
    }
    
    FocusScope.of(context).unfocus(); // Esconde o teclado
    setState(() { _isLoading = true; });

    try {
      await _apiService.updateUserProfile(
        _nomeController.text.trim(),
        _emailController.text.trim(),
      );
      
      // TODO: Adicionar lógica para 'atualizar senha' se _senhaController.text não estiver vazio
      // Isso exigiria um novo endpoint no backend: PUT /api/users/me/password

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if (mounted) {
        setState(() { _isLoading = false; });
       }
    }
  }

  @override
  void dispose() {
    // Limpa os controladores quando a tela é destruída
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator( // Adicionado RefreshIndicator
                onRefresh: _loadUserProfile,
                child: SingleChildScrollView( // Permite rolar a tela
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- 4. ESPAÇAMENTO PARA O TOPO ---
                      SizedBox(height: kToolbarHeight + 20),
                      
                      // --- 5. TODO O CONTEÚDO DENTRO DE UM CARD BRANCO ---
                      Card(
                        elevation: 3.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // --- Avatar e Botão Editar ---
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey.shade200,
                                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () { /* TODO: Lógica de upload */ },
                                        icon: const Icon(Icons.edit, size: 14),
                                        label: const Text('Editar foto'),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // --- Campo Nome ---
                                TextFormField(
                                  controller: _nomeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  validator: (value) => value!.isEmpty ? 'Nome não pode ser vazio' : null,
                                ),
                                const SizedBox(height: 16),

                                // --- Campo Email ---
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => (value == null || !value.contains('@')) ? 'Email inválido' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                // --- Campo Senha ---
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nova Senha',
                                    hintText: 'Deixe em branco para não alterar',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.edit),
                                  ),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 24),
                                
                                // --- Switch Notificações ---
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Notificações Pop-up'),
                                  trailing: Switch(
                                    value: _notificacoesAtivas,
                                    onChanged: (value) {
                                      setState(() {
                                        _notificacoesAtivas = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // --- Botão Excluir Conta ---
                                TextButton(
                                  onPressed: () { /* TODO: Diálogo de confirmação */ },
                                  child: const Text(
                                    'Excluir conta',
                                    style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // --- Botão Salvar ---
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSaveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700], 
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Salvar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}