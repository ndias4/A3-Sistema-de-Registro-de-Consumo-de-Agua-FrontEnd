# MonitorÁgua App (Frontend Flutter) 💧📱

![Status do Projeto](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)

Aplicativo mobile desenvolvido em Flutter para o projeto MonitorÁgua, sistema de monitoramento de consumo de água residencial. Este repositório contém o código do frontend, responsável pela interface do usuário e interação com a API backend.

**[Link para o Protótipo Visual](https://www.canva.com/design/DAG0Myw-HWQ/8dOOj4H42q4hcQmAGWDanA/edit)**

---

## ✨ Funcionalidades Planejadas (Baseadas no Protótipo)

* **Autenticação:** Telas de Login e Cadastro seguras.
* **Dashboard:** Visão geral do consumo diário, gráfico mensal, alertas recentes, estimativa de custo e dica do dia.
* **Relatórios:** Gráficos detalhados do histórico de consumo com insights.
* **Alertas:** Lista de notificações sobre consumo elevado ou bandeiras tarifárias.
* **Dicas de Economia:** Carrossel interativo com dicas práticas.
* **Estimativa Financeira:** Detalhamento dos custos e potencial de economia.
* **Perfil do Usuário:** Visualização e edição de dados cadastrais.
* **Configurações:** Opções de personalização do app.

---

## 💻 Tecnologias Utilizadas

* **Framework:** Flutter (v3.x)
* **Linguagem:** Dart (v3.x)
* **Gerenciamento de Estado:** Provider
* **Requisições HTTP:** Pacote `http`
* **Armazenamento Local:** `shared_preferences`
* **Componentes de UI:** Widgets Material Design (Flutter SDK)

---

## ⚙️ Backend API

Este aplicativo consome a API RESTful do MonitorÁgua, responsável por toda a lógica de negócio e persistência de dados.

* **URL da API (Produção):** `https://monitoragua-api.onrender.com/api`
* **Repositório do Backend:** [https://github.com/ndias4/A3-GQS-Sistema-de-Registro-de-Consumo-de-Agua]

---

## 🚀 Como Executar o Projeto Localmente

**Pré-requisitos:**
* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado.
* Um Emulador Android configurado ou um dispositivo físico Android.
* O [Backend do MonitorÁgua]([Link para o seu repositório do backend AQUI]) deve estar em execução (localmente ou na nuvem).

**Passos:**

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/ndias4/A3-Sistema-de-Registro-de-Consumo-de-Agua-FrontEnd]
    ```

2.  **Acesse a pasta do projeto:**
    ```bash
    cd monitoragua_flutter
    ```

3.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

4.  **Execute o aplicativo:**
    * Certifique-se de que um emulador esteja rodando ou um dispositivo conectado.
    * Execute o comando:
    ```bash
    flutter run
    ```

---

## 🧑‍💻 Autor(es)

* **[SEU NOME COMPLETO AQUI]** - [Seu RA AQUI]

Desenvolvido como parte do projeto A3 da disciplina de Gestão de Qualidade de Software - [Universidade São Judas Tadeu - Análise e Desenvolvimento de Sistemas, Ciência da Computação].

[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)]([LINK_PARA_SEU_LINKEDIN_AQUI])
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)]([LINK_PARA_SEU_GITHUB_AQUI])