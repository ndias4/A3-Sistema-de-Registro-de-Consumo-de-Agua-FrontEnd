import 'package:flutter/material.dart';

// Define o caminho da imagem de fundo
const String backgroundImagePath = 'assets/background.png';

// Define os caminhos dos logos (certifique-se que estão na pasta assets)
const String appLogoPath = 'assets/logo.png'; 
const String saoJudasLogoPath = 'assets/sao_judas_logo.png'; // TODO: Adicione este arquivo

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define os estilos de texto para os cards internos
    final cardTitleStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
    final cardBodyStyle = const TextStyle(color: Colors.white, fontSize: 15, height: 1.5);
    final cardColor = Colors.blue[700]; // Cor azul dos cards internos
    
    return Scaffold(
      // --- 1. AppBar TRANSPARENTE ---
      appBar: AppBar(
        title: const Text('Sobre o App'),
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
        // Usamos SafeArea para o conteúdo não vazar para a barra de status
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- 4. CARD BRANCO PRINCIPAL ---
                Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Título "Sobre" ---
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.touch_app, size: 30, color: Theme.of(context).primaryColor),
                          title: Text(
                            'Sobre',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Card "Nosso Objetivo" ---
                        Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nosso Objetivo', style: cardTitleStyle),
                                const SizedBox(height: 8),
                                Text(
                                  'O MonitorÁgua é um sistema desenvolvido para ajudar você a monitorar e economizar água, contribuindo para os Objetivos de Desenvolvimento Sustentável (ODS 6 e 13).',
                                  style: cardBodyStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Card "Equipe" ---
                        Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Equipe', style: cardTitleStyle),
                                const SizedBox(height: 12),
                                // Lista da equipe (baseada no seu protótipo 'image_a5f717.png')
                                Text(
                                  'Fernando Dias do Nascimento | RA 82325780\n'
                                  'Carlos Eduardo Santos da Silva | RA 82322485\n'
                                  'Davi Bezerra do Nascimento | RA 823216589\n'
                                  'Julia Oliveira Rapozo | RA 8232158\n'
                                  'Renan Rodrigues da Silva | RA 823210612\n'
                                  'Victor Mendes Bono | RA 823217710',
                                  style: cardBodyStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // --- Logos ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(appLogoPath, height: 60, fit: BoxFit.contain),
                            Container(width: 2, height: 50, color: Colors.grey[300]),
                            // TODO: Adicione o logo da São Judas na pasta 'assets'
                            // e descomente a linha abaixo.
                            // Image.asset(saoJudasLogoPath, height: 50, fit: BoxFit.contain),
                            Text("Logo São Judas", style: TextStyle(color: Colors.grey[400])) // Placeholder
                          ],
                        )
                      ],
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