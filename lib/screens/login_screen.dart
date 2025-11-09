import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './register_screen.dart';

// Importante: Crie a pasta 'assets' e coloque suas imagens lá.
// Declare a pasta 'assets/' no seu arquivo pubspec.yaml.
const String backgroundImagePath = 'assets/background.png';
const String logoImagePath = 'assets/logo.png';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Use const para construtores

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o email e a senha.')),
      );
      return;
    }
    setState(() { _isLoading = true; });
    try {
      // Usa o AuthProvider para tentar o login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
          _emailController.text.trim(), // Usa .trim() para remover espaços
          _senhaController.text.trim());

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
        );
      }
      // Navegação acontece automaticamente pelo main.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
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
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obter o tamanho da tela e ajustar o padding
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Evita que o conteúdo fique atrás da barra de status/notificações
      body: SafeArea(
        child: Container(
          // Define a imagem de fundo
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImagePath),
              fit: BoxFit.cover, // Cobre toda a tela
            ),
          ),
          child: Center( // Centraliza o conteúdo verticalmente
            child: SingleChildScrollView( // Permite rolar se o teclado aparecer
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    logoImagePath,
                    height: screenHeight * 0.15, // Tamanho proporcional à tela
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Título (Adaptado do seu protótipo)
                  const Text(
                    'MonitorÁgua', // Ou "NOME AQUI" como no protótipo
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)]
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Campo Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Digite seu email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none, // Sem borda visível
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next, // Pula para o próximo campo
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Campo Senha
                  TextField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua senha',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                       contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    obscureText: true, // Esconde a senha
                    textInputAction: TextInputAction.done, // Indica fim do formulário
                    onSubmitted: (_) => _handleLogin(), // Permite login com "Enter"
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Botão Entrar
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Fundo branco
                            foregroundColor: Theme.of(context).primaryColor, // Texto azul
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.03),

                  // Links
                  GestureDetector( // Usamos GestureDetector para tornar o texto clicável
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Não possui login? Cadastre-se',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ),
                   SizedBox(height: screenHeight * 0.015),
                   GestureDetector(
                    onTap: () {
                      // TODO: Implementar navegação para Tela Esqueci Senha
                       print('Ir para Esqueci Senha');
                    },
                    child: const Text(
                      'Esqueci minha senha',
                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05), // Espaço no final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}