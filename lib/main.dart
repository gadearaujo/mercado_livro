import 'package:flutter/material.dart';
import 'package:mercado_livro/service/model/book_model.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado Livro',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(title: 'Mercado Livro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? filter = false;
  bool? checkBoxAll = false;
  bool? checkBoxToSell = true;

  @override
  void initState() {
    super.initState();
  }

  Future<List<BookModel>> getBookList() async {
    String productURl = '$SERVER_URL/book/active';

    final response = await http.get(Uri.parse(productURl),
        headers: {"Content-Type": "application/json"});
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((job) => BookModel.fromJson(job)).toList();
  }

  Future<List<BookModel>> getAllBookList() async {
    String productURl = '$SERVER_URL/book';

    final response = await http.get(Uri.parse(productURl),
        headers: {"Content-Type": "application/json"});
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((job) => BookModel.fromJson(job)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.indigo,
                    child: Column(children: [
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: 'Pesquisar mais livros...',
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.only(left: 10),
                          hintStyle: const TextStyle(color: Colors.white),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(width: 1, color: Colors.white),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(width: 1, color: Colors.white),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          showDialogFilter();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            filter!
                                ? Text(
                                    'Filtros: Todos',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13.0,
                                    ),
                                  )
                                : Container(),
                            const Spacer(),
                            const Text(
                              'Filtrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.indigo,
                  indent: 20.0,
                  endIndent: 20.0,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: FutureBuilder<List<BookModel>>(
                    future: filter! ? getAllBookList() : getBookList(),
                    builder: (context, snapshot) {
                      // ignore: unrelated_type_equality_checks
                      if (snapshot.inState(ConnectionState.waiting) == true) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        );
                      } else if (snapshot.hasData) {
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                                itemCount: snapshot.data!.length,
                                padding: const EdgeInsets.only(top: 8.0),
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemBuilder: (BuildContext context, int i) {
                                  return Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey)),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: filter! ? 0.0 : 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data![i].name!,
                                              style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'R\$ ${snapshot.data![i].price!.toString()}',
                                              style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Image.network(
                                              'https://img.freepik.com/psd-premium/modelo-de-capa-de-livro_125540-572.jpg?w=2000',
                                              fit: BoxFit.fill,
                                            ),
                                            filter!
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    color: snapshot
                                                            .data![i].status!
                                                            .contains('VENDIDO')
                                                        ? Colors.yellow
                                                        : snapshot.data![i]
                                                                .status!
                                                                .contains(
                                                                    'CANCELADO')
                                                            ? Colors.red
                                                            : Colors.green,
                                                    height: 20,
                                                    child: Text(
                                                      snapshot.data![i].status!,
                                                      style: TextStyle(
                                                          color: snapshot
                                                                  .data![i]
                                                                  .status!
                                                                  .contains(
                                                                      'VENDIDO')
                                                              ? Colors.black
                                                              : Colors.white),
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }));
                      } else if (snapshot.hasError) {
                        return const Text("Erro ao conectar no banco.");
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  void showDialogFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Filtrar',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                CheckboxListTile(
                  value: checkBoxToSell,
                  side: const BorderSide(width: 2.0, color: Colors.white),
                  checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  checkColor: Colors.indigo,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setStateDialog(() {
                      checkBoxToSell = value;
                      checkBoxAll = false;
                    });
                  },
                  title: const Text(
                    'À venda',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Divider(
                  endIndent: 10,
                  indent: 10,
                  color: Colors.white.withOpacity(0.2),
                ),
                CheckboxListTile(
                  value: checkBoxAll,
                  side: const BorderSide(width: 2.0, color: Colors.white),
                  checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  checkColor: Colors.indigo,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setStateDialog(() {
                      checkBoxAll = value;
                      checkBoxToSell = false;
                    });
                  },
                  title: const Text(
                    'Todos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              actions: <Widget>[
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.white)),
                  child: const Text(
                    'Filtrar',
                    style: TextStyle(color: Colors.indigo),
                  ),
                  onPressed: () {
                    setStateDialog(() {
                      if (checkBoxAll!) {
                        filter = true;
                      } else {
                        filter = false;
                      }
                      Navigator.pop(context);
                      setState(() {});
                    });
                  },
                ),
                TextButton(
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        });
  }
}
