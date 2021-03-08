import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; //permite que faça as requisiçõoes
import 'dart:async'; // permite que faça as requisições e não tenha que ficar esperando receber, isso permite não travar o app
import 'dart:convert'; //convert o request em JSON

const request = 'https://api.hgbrasil.com/finance';

void main() async {
  //print(await getData());

  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  print('Get Data');
  http.Response response = await http.get(request);
  //resposta do servidor  =  espera os dados chegarem e quando chegarem mandam para a variavel "response" | Solicitando algo para o servidor, não retorna os dados na hora, retornar um dado "do Futuro"

  return json.decode(response.body);
  //Convete o requeste/response em JSON.
  //Pega o corpo dela e transforma em um arquivo JSON e transforma em um Map
  //Essa função retorna um Map de Future
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  //ATRAVÉS DESSES CONTROLLERS PODEMOS PEGAR OS TEXTOS, DECOBRIR QUANDO ELES SÃO ALTERADOS e também alterar o texto

  double dolar;
  double euro;

  void _realChanged(String text) {
    //print(text);
    double real = double.parse(text);

    dollarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);

    print(text);
  }

  void _dollarChanged(String text) {
    //print(text);
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    //print(text);
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, //cor de fundo da aplicação
      appBar: AppBar(
        title: Text('\$ Conversor de Moedas \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: FutureBuilder<Map>(
        //Widget FutureBuilder que vai conter um mapa é Map, pois o nosso JSON vai retornar um MAP
        future:
            getData(), //chama a função getData, pois ele vai retornar um dado, no futuro
        builder: (context, snapshot) {
          //Em builder nós temos que especificar o que ele deve retornar em cada um dos casos.
          //Snapshot é uma 'fotografia/'copia, dos dados momnetaneos que obtem do servidor
          switch (snapshot.connectionState) {
            // Preapar a aplicação para cada caso do SnapShot, oq eu o snapshot irá retornar
            case ConnectionState.none: //Se não estiver conectando em nada
            case ConnectionState.waiting: //Se estiver esperando os dados
              return Center(
                child: Text(
                  'Carregando Dados',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ); //Centraliza outro widget
            default:
              if (snapshot.hasError) {
                return Center(
                  //widget que centraliza outro widget
                  child: Text(
                    'Erro ao carregar os Dados :\'(',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ); //Centraliza outro widget
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      Divider(),
                      buildTextField(
                          'Dolar', 'USD ', dollarController, _dollarChanged),
                      Divider(),
                      buildTextField(
                          'Euro', 'EUR ', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          } //usa o switch porque o future irá informar qual é op estado da conexão
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController controller, Function f) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f, //toda vez que tiver alteração no campo, ele chama a função f
    keyboardType: TextInputType.number,
  );
}
