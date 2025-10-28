import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Importa o provider

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; });
    try {
      bool success = await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _senhaController.text);

      if (!success && mounted) { // 'mounted' verifica se o widget ainda está na tela
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
        );
      }
      // Se o login for bem-sucedido, o AuthProvider notificará
      // e o main.dart trocará a tela automaticamente.
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login - MonitorÁgua')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Entrar'),
                  ),
            // Adicionar links para cadastro/esqueci senha depois
          ],
        ),
      ),
    );
  }
}