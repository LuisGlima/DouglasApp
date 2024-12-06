import 'package:flutter/material.dart';
import 'package:task_list/models/tarefa.dart';
import 'package:task_list/respositories/lista_repositorio.dart';
import 'package:task_list/widgets/card_tarefa.dart';

class HomePage extends StatefulWidget { // Nome da classe permanece igual
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController listItemController = TextEditingController();

  List<Tarefa> lista = [];
  ListaRepositorio listaRepositorio = ListaRepositorio();

  @override
  void initState() {
    super.initState();
    ListaRepositorio().recuperarLista().then((value) {
      setState(() {
        lista = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Lista de tarefas", // Título da página permanece igual
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: listItemController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Insira sua tarefa",
                        hintText: "Estudar",
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.all(10),
                    ),
                    onPressed: () {
                      String titulo = listItemController.text;
                      setState(() {
                        Tarefa tarefa =
                            Tarefa(titulo: titulo, dataHora: DateTime.now());
                        lista.add(tarefa);
                      });
                      listItemController.clear();
                      listaRepositorio.salvarLista(lista);
                    },
                    child: const Icon(
                      Icons.add,
                      size: 40,
                    ),
                  )
                ],
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Tarefa tarefa in lista)
                      CardTarefa(tarefa: tarefa, deletar: deletarTarefa),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Você tem ${lista.length} tarefas pendentes",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        limparLista();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.all(16)),
                      child: const Text("Limpar tudo"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deletarTarefa(Tarefa tarefa) {
    Tarefa tarefaDeletada = tarefa;
    int posicaoNaLista = lista.indexOf(tarefaDeletada);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        " A tarefa ${tarefaDeletada.titulo} foi excluída",
      ),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              lista.insert(posicaoNaLista, tarefaDeletada);
            });
            listaRepositorio.salvarLista(lista);
          }),
      duration: const Duration(seconds: 5),
    ));
    setState(() {
      lista.remove(tarefa);
    });
    listaRepositorio.salvarLista(lista);
  }

  void limparLista() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("ATENÇÃO"),
              content: const Text(
                  "Você tem certeza que quer apagar a lista toda?"),
              actions: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        lista.clear();
                      });
                      listaRepositorio.salvarLista(lista);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Sim",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Não",
                        style: TextStyle(
                          color: Colors.white,
                        )))
              ],
            ));
  }
}