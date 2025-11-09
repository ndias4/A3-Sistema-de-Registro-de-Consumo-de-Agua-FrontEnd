// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Importa as telas placeholder que você criou
import '../screens/dashboard_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/relatorios_screen.dart';
import '../screens/alertas_screen.dart';
import '../screens/dicas_screen.dart';
import '../screens/estimativa_screen.dart';
import '../screens/perfil_screen.dart';
// Adicione os imports para as outras telas (Configurações, Sobre, etc.)

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Função auxiliar para criar um item do menu
  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Fecha o menu
        Navigator.of(context).pop(); 
        // Navega para a nova tela
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos o AuthProvider para o botão Sair
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // O AppBar automaticamente mostrará o ícone de menu (☰)
        // porque estamos adicionando um Drawer ao Scaffold.
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          // Remove qualquer padding do ListView
          padding: EdgeInsets.zero,
          children: [
            // Header customizado do Drawer (baseado no seu protótipo)
            UserAccountsDrawerHeader(
              accountName: const Text("Fernando Dias"), // TODO: Pegar nome do usuário
              accountEmail: const Text("email@exemplo.com"), // TODO: Pegar email
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "F", // Iniciais do nome
                  style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            // Itens de navegação (baseado no seu protótipo 'image_a5fabb.png')
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart,
              title: 'Relatórios',
              screen: const RelatoriosScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.warning_amber_rounded,
              title: 'Alertas e Notificações',
              screen: const AlertasScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.lightbulb_outline,
              title: 'Dicas de Economia',
              screen: const DicasScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.stacked_line_chart,
              title: 'Estimativa Financeira',
              screen: const EstimativaScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_outline,
              title: 'Perfil do Usuário',
              screen: const PerfilScreen(),
            ),
            // Adicione os outros itens aqui (Configurações, Sobre)
            
            const Divider(), // Uma linha divisória

            // Botão de Sair
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                // Fecha o menu
                Navigator.of(context).pop();
                // Chama a função de logout
                await authProvider.logout();
                // O main.dart irá automaticamente trocar para a LoginScreen
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Conteúdo do Dashboard Principal Aqui!'),
        // TODO: Começar a construir a UI do Dashboard
        // com base no protótipo (image_a5fada.png)
      ),
    );
  }
}