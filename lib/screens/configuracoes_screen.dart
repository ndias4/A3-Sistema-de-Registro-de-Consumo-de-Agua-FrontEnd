import 'package:flutter/material.dart';
import './sobre_screen.dart';

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

class ConfiguracoesScreen extends StatefulWidget {
  // Convertido para StatefulWidget para gerenciar o estado do Switch
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _notificacoesAtivas = true; // Estado do Switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Configurações'),
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
        // Usamos um SingleChildScrollView para garantir que não quebre em telas menores
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- 4. ESPAÇAMENTO PARA O TOPO ---
              SizedBox(height: kToolbarHeight + 20),
              
              // --- 5. CARD BRANCO COM AS OPÇÕES ---
              Card(
                elevation: 3.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- Título "Opções Gerais" ---
                      const ListTile(
                        leading: Icon(Icons.settings, size: 30),
                        title: Text(
                          'Opções Gerais',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),
                      
                      // --- Opção "Idioma" ---
                      ListTile(
                        title: const Text('Idioma'),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min, // Para a Row não ocupar todo o espaço
                          children: [
                            Text('Português', style: TextStyle(color: Colors.grey)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // TODO: Implementar lógica de mudança de idioma (se necessário)
                        },
                      ),
                      
                      // --- Opção "IoT" ---
                      ListTile(
                        title: const Text('IoT - Adicionar novo dispositivo'),
                        trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                        onTap: () {
                          // TODO: Implementar lógica de adicionar dispositivo IoT
                        },
                      ),

                      // --- Opção "Notificações" (com Switch) ---
                      SwitchListTile(
                        title: const Text('Notificações Gerais'),
                        value: _notificacoesAtivas,
                        onChanged: (bool value) {
                          setState(() {
                            _notificacoesAtivas = value;
                            // TODO: Salvar esta preferência (localmente ou na API)
                          });
                        },
                        secondary: const Icon(Icons.notifications_none, color: Colors.transparent), // Placeholder para alinhar
                        activeColor: Colors.blue[700],
                      ),
                      
                      // --- Opção "Sobre" ---
                      ListTile(
                        title: const Text('Sobre o Aplicativo'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        onTap: () {
                          // Navega para a tela "Sobre" que já está no Drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const SobreScreen(), // Requer import './sobre_screen.dart';
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}