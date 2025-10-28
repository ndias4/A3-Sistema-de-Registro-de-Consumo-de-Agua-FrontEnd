import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Importa nosso ApiService

// Enum para representar os estados de autenticação
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(); // Instancia nosso serviço de API
  AuthStatus _authStatus = AuthStatus.unknown; // Estado inicial
  String? _token; // Armazena o token se o usuário estiver logado

  // Getters para que as telas possam ler o estado
  AuthStatus get authStatus => _authStatus;
  String? get token => _token;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  AuthProvider() {
    _checkLoginStatus(); // Verifica o status de login ao iniciar o app
  }

  // Verifica se existe um token salvo no SharedPreferences
  Future<void> _checkLoginStatus() async {
    _token = await _apiService.getToken();
    if (_token != null) {
      _authStatus = AuthStatus.authenticated;
    } else {
      _authStatus = AuthStatus.unauthenticated;
    }
    notifyListeners(); // Notifica os Widgets que o estado mudou
  }

  // Função para realizar o login
  Future<bool> login(String email, String senha) async {
    try {
      final result = await _apiService.login(email, senha);
      if (result['success']) {
        _token = result['token'];
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return true; // Indica sucesso
      } else {
        // Falha no login, mas a API já tratou o erro
        _authStatus = AuthStatus.unauthenticated;
        notifyListeners();
        return false; // Indica falha
      }
    } catch (e) {
      print("Erro no AuthProvider.login: $e");
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false; // Indica falha
    }
  }

  // Função para realizar o logout
  Future<void> logout() async {
    await _apiService.logout();
    _token = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }
}