import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mercado_livro/service/model/book_model.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../config.dart';
import '../service/model/book_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? filter = false;
  bool? checkBoxAll = false;
  bool? checkBoxToSell = true;

  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Mercado Livro'),
          centerTitle: true,
          elevation: 0.0,
        ),
        bottomNavigationBar: buildMyNavBar(context),
        body: pages[pageIndex]);
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
                    Icons.home_filled,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.shopping_basket_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon: pageIndex == 2
                ? const Icon(
                    Icons.add_box_rounded,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.add_box_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            icon: pageIndex == 3
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
        ],
      ),
    );
  }
}

class Page1 extends StatefulWidget {
  const Page1({super.key});
  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool? filter = false;
  bool? checkBoxAll = false;
  bool? checkBoxToSell = true;

  Future<List<BookModel>> getBookList() async {
    String productURl = '$SERVER_URL/book/active';

    final response = await http.get(Uri.parse(productURl),
        headers: {"Content-Type": "application/json"});
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));

    return jsonResponse.map((job) => BookModel.fromJson(job)).toList();
  }

  Future<List<BookModel>> getAllBookList() async {
    String productURl = '$SERVER_URL/book';

    final response = await http.get(Uri.parse(productURl),
        headers: {"Content-Type": "application/json"});
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));

    return jsonResponse.map((job) => BookModel.fromJson(job)).toList();
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 1), () {
      completer.complete();
    });
    setState(() {});
    return completer.future.then<void>((_) {
      ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
        SnackBar(
          content: const Text('Livros atualizados'),
          action: SnackBarAction(
            label: 'Repetir',
            textColor: Colors.white,
            onPressed: () {
              _refreshIndicatorKey.currentState!.show();
            },
          ),
        ),
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LiquidPullToRefresh(
        key: _refreshIndicatorKey, // key if you want to add
        onRefresh: _handleRefresh, // refresh callback
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
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
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.indigo,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
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
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  filter! ? 0 : 20),
                                              bottomRight: Radius.circular(
                                                  filter! ? 0 : 20)),
                                          child: Image.network(
                                            snapshot.data![i].photoUrl ==
                                                        null ||
                                                    snapshot.data![i].photoUrl!
                                                        .isEmpty
                                                ? 'https://img.freepik.com/psd-premium/modelo-de-capa-de-livro_125540-572.jpg?w=2000'
                                                : snapshot.data![i].photoUrl!,
                                            fit: BoxFit.fill,
                                            height: 130,
                                          ),
                                        ),
                                        filter!
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: snapshot
                                                          .data![i].status!
                                                          .contains('VENDIDO')
                                                      ? Colors.yellow
                                                      : snapshot
                                                              .data![i].status!
                                                              .contains(
                                                                  'CANCELADO')
                                                          ? Colors.red
                                                          : snapshot.data![i]
                                                                  .status!
                                                                  .contains(
                                                                      'DELETADO')
                                                              ? Colors.blue
                                                              : Colors.green,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(
                                                      20,
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                height: 20,
                                                child: Text(
                                                  snapshot.data![i].status!,
                                                  style: TextStyle(
                                                      color: snapshot
                                                              .data![i].status!
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
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 2",
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 3",
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
          child: SingleChildScrollView(
        child: Column(children: [
          const Text(
            'Criar conta',
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 120,
          ),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Email',
              fillColor: Colors.indigo,
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Senha',
              fillColor: Colors.indigo,
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ]),
      )),
    );
  }
}
