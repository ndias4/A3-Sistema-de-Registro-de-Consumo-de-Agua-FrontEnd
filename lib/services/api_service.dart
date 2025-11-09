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

  // Função para registrar um novo usuário
  Future<Map<String, dynamic>> register(String nome, String email, String senha) async {
    final url = Uri.parse('$_baseUrl/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Cadastro bem-sucedido
        print('Cadastro bem-sucedido!');
        return {'success': true, 'user': data['user']};
      } else {
        // Falha no cadastro (ex: email já existe)
        print('Falha no cadastro: ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Erro desconhecido'};
      }
    } catch (e) {
      // Erro de rede ou outro problema
      print('Erro de rede no cadastro: $e');
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

  // Pega o token salvo e prepara os headers da requisição
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) {
      throw Exception('Token não encontrado, faça o login novamente.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Busca os dados para o gráfico de relatório mensal
  Future<List<dynamic>> getRelatorioMensal() async {
    final url = Uri.parse('$_baseUrl/consumo/relatorio/mensal');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna a lista de dados do relatório
      } else {
        throw Exception('Falha ao carregar relatório');
      }
    } catch (e) {
      print('Erro em getRelatorioMensal: $e');
      rethrow;
    }
  }

  // Busca os alertas do usuário
  Future<List<dynamic>> getAlertas() async {
    final url = Uri.parse('$_baseUrl/alertas');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar alertas');
      }
    } catch (e) {
      print('Erro em getAlertas: $e');
      rethrow;
    }
  }

  // Busca a estimativa de gastos do mês
  Future<Map<String, dynamic>> getEstimativaMensal() async {
    final url = Uri.parse('$_baseUrl/consumo/estimativa/mensal');
     try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar estimativa');
      }
    } catch (e) {
      print('Erro em getEstimativaMensal: $e');
      rethrow;
    }
  }

  // Busca as dicas (vamos pegar todas e o app decide qual exibir)
  Future<List<dynamic>> getDicas() async {
    final url = Uri.parse('$_baseUrl/dicas');
     try {
      // Dicas são públicas ou precisam de auth? 
      // Assumindo que precisam para este exemplo:
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar dicas');
      }
    } catch (e) {
      print('Erro em getDicas: $e');
      rethrow;
    }
  }

  // Marca um alerta específico como lido
  Future<bool> marcarAlertaComoLido(int alertaId) async {
    final url = Uri.parse('$_baseUrl/alertas/$alertaId/lido');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(url, headers: headers); // Método PATCH

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Falha ao marcar alerta como lido');
      }
    } catch (e) {
      print('Erro em marcarAlertaComoLido: $e');
      rethrow;
    }
  }

  // Deleta TODOS os alertas do usuário (para o botão "Limpar")
  Future<bool> limparAlertas() async {
    final url = Uri.parse('$_baseUrl/alertas');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(url, headers: headers); // Método DELETE

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Falha ao limpar alertas');
      }
    } catch (e) {
      print('Erro em limparAlertas: $e');
      rethrow;
    }
  }

  // Busca os dados do usuário logado (GET /api/users/me)
  Future<Map<String, dynamic>> getUserProfile() async {
    final url = Uri.parse('$_baseUrl/users/me');
    try {
      final headers = await _getAuthHeaders(); // Reutiliza nossa função de headers
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna o objeto do usuário
      } else {
        throw Exception('Falha ao carregar perfil');
      }
    } catch (e) {
      print('Erro em getUserProfile: $e');
      rethrow;
    }
  }
  // Atualiza os dados do usuário logado (PUT /api/users/me)
  Future<Map<String, dynamic>> updateUserProfile(String nome, String email) async {
    final url = Uri.parse('$_baseUrl/users/me');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'nome': nome,
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        // Erro da API (ex: email já em uso)
        throw Exception(data['message'] ?? 'Falha ao atualizar perfil');
      }
    } catch (e) {
      print('Erro em updateUserProfile: $e');
      rethrow;
    }
  }

  // Busca o consumo total do dia (GET /api/consumo/hoje)
  Future<Map<String, dynamic>> getConsumoHoje() async {
    final url = Uri.parse('$_baseUrl/consumo/hoje');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna ex: {"consumo_do_dia": 500}
      } else {
        throw Exception('Falha ao carregar consumo do dia');
      }
    } catch (e) {
      print('Erro em getConsumoHoje: $e');
      rethrow;
    }
  }

  // Busca o comparativo de gastos (GET /api/consumo/comparativo)
  Future<Map<String, dynamic>> getComparativoMensal() async {
    final url = Uri.parse('$_baseUrl/consumo/comparativo');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna o JSON com os custos
      } else {
        throw Exception('Falha ao carregar comparativo');
      }
    } catch (e) {
      print('Erro em getComparativoMensal: $e');
      rethrow;
    }
  }

  // Atualiza a senha do usuário (PUT /api/users/me/password)
  Future<Map<String, dynamic>> updatePassword(String novaSenha) async {
    final url = Uri.parse('$_baseUrl/users/me/password');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'novaSenha': novaSenha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        throw Exception(data['message'] ?? 'Falha ao atualizar senha');
      }
    } catch (e) {
      print('Erro em updatePassword: $e');
      rethrow;
    }
  }
}