import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Via Cep App',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.lightGreen,
      ),
      home: const MyHomePage(
        title: 'Via Cep App',
        icon: Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.icon});
  final String title;
  final Icon icon;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Cep {
  final String? cep;
  final String? bairro;
  final String? rua;
  final String? cidade;
  final String? estado;
  final bool erro;

  const Cep(
      {required this.cep,
      required this.bairro,
      required this.cidade,
      required this.estado,
      required this.rua,
      required this.erro});

  factory Cep.fromJson(Map<String?, dynamic> json) {
    return Cep(
        cep: json['cep'],
        bairro: json['bairro'],
        cidade: json['localidade'],
        estado: json['uf'],
        rua: json['logradouro'],
        erro: json['erro'] ?? false);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var _rua = "";
  var _bairro = "";
  var _cidade = "";
  var _estado = "";

  var text = '';
  var erroMessage = '';
  var cepInput = TextEditingController();

  Tuple2<bool, String> validarEntradaCEP(String cep) {
    if (cep.length != 8) {
      return const Tuple2(false, "O CEP deve conter 8 digitos!");
    }

    return const Tuple2(true, '');
  }

  void buscarCep(TextEditingController inputCep) async {
    var cep = inputCep.text;

    var retornoValidarEntrada = validarEntradaCEP(cep);

    if (retornoValidarEntrada.item1 == false) {
      setState(() {
        erroMessage = retornoValidarEntrada.item2;
        _rua = '';
        _bairro = '';
        _cidade = '';
        _estado = '';
      });
      return;
    }
    var response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      var returnCep = Cep.fromJson(jsonDecode(response.body));
      if (!returnCep.erro) {
        setState(() {
          _rua = 'Endereço:  ${returnCep.rua}';
          _bairro = 'Bairro: ${returnCep.bairro}';
          _cidade = 'Cidade: ${returnCep.cidade}';
          _estado = 'Estado: ${returnCep.estado}';
        });
      } else {
        setState(() {
          erroMessage = "Endereço não encontrado, por favor verifique o CEP!";
          _rua = '';
          _bairro = '';
          _cidade = '';
          _estado = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text.rich(
          WidgetSpan(
              child: Row(
            children: [
              widget.icon,
              Text(widget.title,
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Montserrat'))
            ],
          )),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.number,
              controller: cepInput,
              onFieldSubmitted: (text) async => buscarCep(cepInput),
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Digite o CEP',
                  contentPadding: EdgeInsets.all(20.0)),
            ),
            Text(
              erroMessage,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              label: const Text('Pesquisar',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
              onPressed: () => buscarCep(cepInput),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.all(10)),
                      Text(_rua,
                          style: const TextStyle(
                            fontSize: 20,
                          )),
                      Text(_bairro, style: const TextStyle(fontSize: 20)),
                      Text(
                        _cidade,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        _estado,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
