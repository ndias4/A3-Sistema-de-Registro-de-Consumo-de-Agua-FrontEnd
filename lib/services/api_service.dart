import 'dart:convert'; // Para codificar/decodificar JSON
import 'package:http/http.dart' as http; // O pacote http que instalamos
import 'package:shared_preferences/shared_preferences.dart'; // Para salvar/ler o token

class ApiService {
  // A URL base da sua API no Render
  final String _baseUrl = 'https://monitoragua-api.onrender.com/api';

  // Função para fazer o login
  Future<Map<String, dynamic>> login(String email, String senha) async {
    final url = Uri.parse('$_baseUrl/users/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        // Login bem-sucedido
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Salva o token localmente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        print('Login bem-sucedido, token salvo!');
        return {'success': true, 'token': token, 'user': data['user']};
      } else {
        // Falha no login (ex: senha errada)
        final errorData = jsonDecode(response.body);
        print('Falha no login: ${errorData['message']}');
        return {'success': false, 'message': errorData['message'] ?? 'Erro desconhecido'};
      }
    } catch (e) {
      // Erro de rede ou outro problema
      print('Erro de rede no login: $e');
      return {'success': false, 'message': 'Erro de conexão com o servidor.'};
    }
  }

  // Função para fazer logout (limpar o token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('Token removido (logout)');
  }

  // Função para verificar se existe um token salvo
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Aqui adicionaremos outras funções depois (buscar consumo, dicas, etc.)
  // Exemplo:
  // Future<List<dynamic>> getConsumos() async { ... }
}