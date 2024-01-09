import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _titulo = "Lista de Tarefas";
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = {};
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = {};
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }
  _lerArquivo() async {
    try{
      var arquivo = await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lerArquivo().then( (dadosLista){
      setState(() {
        _listaTarefas = json.decode(dadosLista);
      });
    } );
  }

  Widget criarItemLista(context, index){
    //final item = _listaTarefas[index]["titulo"];
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        _ultimaTarefaRemovida = _listaTarefas[index];
        _listaTarefas.removeAt(index);
        _salvarArquivo();
        final snackbar = SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Tarefa Removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: (){
              setState(() {
                _listaTarefas.insert(index, _ultimaTarefaRemovida);
              });
              _salvarArquivo();
            }
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'],
        onChanged: (valorAlterado){
          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    //_salvarArquivo();
    //print("Itens: ${DateTime.now().millisecondsSinceEpoch.toString()}");

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.lightGreenAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.lightGreenAccent,
        child: const Icon(Icons.add),
        onPressed: (){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: const Text("Adicionar Tarefa"),
              content: TextField(
                controller: _controllerTarefa,
                decoration: const InputDecoration(
                  labelText: "Digite a Nova Tarefa"
                ),
                onChanged: (text){},
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                      "Cancelar",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.lightGreen),
                  ),
                  onPressed: ( ){
                    //Salvar
                    _salvarTarefa();
                    _controllerTarefa.clear();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Salvar",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                )
              ],
            );
          });
        }
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItemLista
            )
          )
        ],
      ),
    );
  }
}
