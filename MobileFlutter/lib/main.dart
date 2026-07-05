// ===========================================================================
// App MOBILE do ERP em FLUTTER (linguagem Dart).
//
// Diferenças em relação ao Delphi (para você comparar mentalmente):
//   - Delphi: você "desenha" a tela (.dfm) e escreve Object Pascal.
//   - Flutter: a tela é escrita EM CÓDIGO, montando "widgets" (componentes).
//     Tudo é widget: texto, botão, campo, a tela inteira.
//
// Assim como os módulos desktop, o celular NÃO acessa o Firebird direto.
// Ele conversa com uma API REST (um servidor) que é quem acessa o banco.
// Aqui fazemos chamadas HTTP para essa API.
//
// Como rodar:
//   1) Instale o Flutter (flutter.dev).
//   2) Nesta pasta:  flutter pub get   depois   flutter run
// ===========================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ErpApp());
}

// Widget raiz do aplicativo.
class ErpApp extends StatelessWidget {
  const ErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ERP Mobile',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const TelaPrincipal(),
    );
  }
}

// Tela com estado (os campos e a lista mudam, por isso é "Stateful").
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // "Controllers" seguram o texto digitado em cada campo (como o .Text no Delphi).
  final _servidor = TextEditingController(text: 'http://10.0.2.2:8080');
  final _login = TextEditingController();
  final _senha = TextEditingController();

  String _status = 'Informe o servidor e consulte os produtos.';
  List<dynamic> _produtos = [];
  bool _carregando = false;

  // Faz um GET na API e devolve o corpo já convertido de JSON.
  Future<void> _consultarProdutos() async {
    setState(() {
      _carregando = true;
      _status = 'Consultando...';
    });

    try {
      final url = Uri.parse('${_servidor.text}/produtos');
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        // Converte o texto JSON numa lista do Dart
        setState(() {
          _produtos = jsonDecode(resposta.body);
          _status = 'Produtos carregados: ${_produtos.length}';
        });
      } else {
        setState(() => _status = 'Erro HTTP ${resposta.statusCode}');
      }
    } catch (e) {
      // Erro de conexão é esperado enquanto a API REST não estiver no ar.
      setState(() => _status =
          'Falha ao conectar (a API REST precisa estar rodando).\n$e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERP Mobile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _servidor,
              decoration: const InputDecoration(labelText: 'URL da API REST'),
            ),
            TextField(
              controller: _login,
              decoration: const InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregando ? null : _consultarProdutos,
              child: Text(_carregando ? 'Aguarde...' : 'Consultar produtos'),
            ),
            const SizedBox(height: 12),
            Text(_status),
            const Divider(),
            // Lista de produtos retornada pela API
            Expanded(
              child: ListView.builder(
                itemCount: _produtos.length,
                itemBuilder: (context, i) {
                  final p = _produtos[i];
                  return ListTile(
                    title: Text(p['DESCRICAO']?.toString() ?? '(sem nome)'),
                    trailing: Text('R\$ ${p['PRECO_VENDA'] ?? '0'}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
