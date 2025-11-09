import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart'; // Embora não façamos login, o provider pode ser útil

// Importa as imagens (as mesmas da tela de login)
const String backgroundImagePath = 'assets/background.png';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Usamos o ApiService diretamente para o registro
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>(); // Chave para validar o formulário
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    // Valida o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final result = await _apiService.register(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (result['success'] && mounted) {
        // Sucesso! Mostra aviso e volta para o Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário cadastrado com sucesso! Faça o login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior (Login)
      } else if (mounted) {
        // Mostra erro da API (ex: email já existe)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro ao cadastrar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Estilo de decoração para os campos de texto (padronizado com o login)
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      // Ajuste para o labelText não flutuar
      floatingLabelBehavior: FloatingLabelBehavior.never, 
    );

    return Scaffold(
      body: Container(
        // Imagem de Fundo
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão "Voltar" no estilo do protótipo
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // Título
                    const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)]
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // Campo Nome
                    TextFormField(
                      controller: _nomeController,
                      decoration: inputDecoration.copyWith(hintText: 'Nome Completo'),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, digite seu nome';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      decoration: inputDecoration.copyWith(hintText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value == null || !value.contains('@') || !value.contains('.')) {
                          return 'Por favor, digite um email válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Campo Senha
                    TextFormField(
                      controller: _senhaController,
                      decoration: inputDecoration.copyWith(hintText: 'Senha (mín. 6 caracteres)'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Campo Confirmar Senha
                    TextFormField(
                      controller: _confirmarSenhaController,
                      decoration: inputDecoration.copyWith(hintText: 'Confirmar Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value != _senhaController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Botão Cadastrar (estilizado)
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor, // Texto azul
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Cadastrar',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                    SizedBox(height: screenHeight * 0.05), // Espaço no final
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}