import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mercado_livro/service/model/book_model.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/model/customer_model.dart';
import '../service/response/api_response.dart';
import '../service/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int pageIndex = 0;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  bool? filter = false;
  bool? checkBoxAll = false;
  bool? checkBoxToSell = true;
  bool? showPassword = true;
  bool? showLoading = false;
  bool? isLogged = false;
  bool? goToLogin = false;
  bool? seePasswordProfile = false;

  SharedPreferences? prefs;

  CustomerModel? customer;

  List<Map<String, dynamic>>? customerLogin;

  TextEditingController? nameController;
  TextEditingController? emailController;
  TextEditingController? passwordController;

  List? dataFromResponse;

  BookModel? allBooks;

  ApiResponse _apiResponse = ApiResponse();
  final _service = Service();

  double _crossAxisSpacing = 8, _mainAxisSpacing = 12, _aspectRatio = 2;
  int _crossAxisCount = 2;

  @override
  void initState() {
    super.initState();

    initSharedPreferences();

    getBookList();

    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs!.containsKey("logged")) {
      if (prefs!.getBool('logged')!) {
        setState(() {
          emailController!.text = prefs!.getString("email")!;
          passwordController!.text = prefs!.getString("password")!;
          loginCustomer();
          isLogged = false;
        });
      } else {
        setState(() {
          isLogged = false;
        });
      }
    }
  }

  void getBookList() async {
    _apiResponse = await _service.getBooks(true);

    setState(() {
      allBooks = _apiResponse.book!;
    });
  }

  void getAllBookList() async {
    _apiResponse = await _service.getBooks(false);

    setState(() {
      allBooks = _apiResponse.book!;
    });
  }

  void registerCustomer() async {
    _apiResponse = await _service.registerCustomer(
        nameController!.text, passwordController!.text, emailController!.text);

    if (_apiResponse.apiErrorT == null) {
      setState(() {
        prefs!.setBool("logged", true);
        showLoading = false;
        isLogged = true;
        customer = _apiResponse.customer!;
      });
    } else {
      setState(() {
        isLogged = false;
        showLoading = false;
      });
      ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text(
            ('Erro: ${utf8.decode(_apiResponse.apiError!.message!.codeUnits)}'),
            style: const TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          behavior: SnackBarBehavior.floating,
          // ignore: use_build_context_synchronously
          width: MediaQuery.of(context).size.width - 20,
        ),
      );
    }
  }

  void loginCustomer() async {
    _apiResponse = await _service.loginCustomer(
        passwordController!.text, emailController!.text);

    if (_apiResponse.apiErrorT == null) {
      setState(() {
        prefs!.setBool("logged", true);
        showLoading = false;
        isLogged = true;
        prefs!.setString("email", emailController!.text);
        prefs!.setString("password", passwordController!.text);
        print(_apiResponse.customerLogin!);
        customerLogin = _apiResponse.customerLogin!;
      });
    } else {
      setState(() {
        showLoading = false;
      });
      ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text(
            ('Erro: ${utf8.decode(_apiResponse.apiError!.message!.codeUnits)}'),
            style: const TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          behavior: SnackBarBehavior.floating,
          // ignore: use_build_context_synchronously
          width: MediaQuery.of(context).size.width - 20,
        ),
      );
    }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          behavior: SnackBarBehavior.floating,
          // margin: const EdgeInsets.only(bottom: 10.0),
          width: MediaQuery.of(context).size.width - 20,
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
                        getAllBookList();
                      } else {
                        filter = false;
                        getBookList();
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
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Mercado Livro',
            style: TextStyle(fontFamily: 'Sono', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        bottomNavigationBar: buildMyNavBar(context),
        body: pageIndex == 0
            ? homePage()
            : pageIndex == 1
                ? shopping()
                : pageIndex == 2
                    ? publishBook()
                    : isLogged!
                        ? profilePage()
                        : registerPage());
  }

  Widget profilePage() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Material(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.indigo, width: 1),
                ),
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    color: Colors.indigo,
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(20),
                          height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Nome: ${customerLogin![0]['name']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Email: ${customerLogin![0]['email']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  seePasswordProfile!
                                      ? Text(
                                          'Senha: ${customerLogin![0]['password']}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          'Senha: ********',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        seePasswordProfile =
                                            !seePasswordProfile!;
                                      });
                                    },
                                    child: Row(children: [
                                      Icon(
                                        seePasswordProfile!
                                            ? Icons.visibility
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
              ),
              Container(
                height: 60.0,
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      prefs!.setBool("logged", false);
                      showLoading = false;
                      isLogged = false;
                      customer = null;
                    });
                  },
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(10),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                      padding: const MaterialStatePropertyAll(
                        EdgeInsets.all(0.0),
                      )),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.red[700]!],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          tileMode: TileMode.repeated),
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 20,
                          minHeight: 50.0),
                      alignment: Alignment.center,
                      child: const Text(
                        "SAIR",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget homePage() {
    double screenWidth = MediaQuery.of(context).size.width;

    var width = (screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;
    var height = width / _aspectRatio;
    return LiquidPullToRefresh(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.indigo, width: 1),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Colors.indigo,
                ),
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
            _apiResponse == null
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount:
                            allBooks == null ? 0 : allBooks!.data!.length,
                        padding: const EdgeInsets.only(top: 8.0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: _aspectRatio / 3.0,
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
                                padding:
                                    EdgeInsets.only(top: filter! ? 0.0 : 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      utf8.decode(allBooks!.data![i]["name"]
                                          .toString()
                                          .codeUnits),
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${allBooks!.data![i]["price"].toString()}',
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        allBooks!.data![i]['customer'] == null
                                            ? const Text('',
                                                style: TextStyle(
                                                    color: Colors.black))
                                            : Text(
                                                'Por: ${allBooks!.data![i]["customer"]["name"]}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                )),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                          child: Image.network(
                                            allBooks!.data![i]["photoUrl"] ==
                                                        null ||
                                                    allBooks!.data![i]
                                                            ["photoUrl"]
                                                        .toString()
                                                        .isEmpty
                                                ? 'https://img.freepik.com/psd-premium/modelo-de-capa-de-livro_125540-572.jpg?w=2000'
                                                : allBooks!.data![i]["photoUrl"]
                                                    .toString(),
                                            fit: BoxFit.cover,
                                            height: 160,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                          ),
                                        ),
                                        filter!
                                            ? Positioned(
                                                bottom: 0,
                                                right: 0,
                                                left: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: allBooks!.data![i]
                                                                ["status"]
                                                            .toString()
                                                            .contains('VENDIDO')
                                                        ? Colors.yellow
                                                        : allBooks!.data![i]
                                                                    ["status"]
                                                                .toString()
                                                                .contains(
                                                                    'CANCELADO')
                                                            ? Colors.red
                                                            : allBooks!.data![i]
                                                                        [
                                                                        "status"]
                                                                    .toString()
                                                                    .contains(
                                                                        'DELETADO')
                                                                ? Colors.blue
                                                                : Colors.green,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight: Radius.circular(
                                                        20,
                                                      ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  child: Text(
                                                    allBooks!.data![i]
                                                        ['status']!,
                                                    style: TextStyle(
                                                        color: allBooks!
                                                                .data![i]
                                                                    ["status"]
                                                                .toString()
                                                                .contains(
                                                                    'VENDIDO')
                                                            ? Colors.black
                                                            : Colors.white),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                    Container(
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                        color: Colors.indigo,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(_scaffoldKey
                                                  .currentState!.context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.indigo,
                                              content: Text(
                                                '${allBooks!.data![i]["name"]} adicionado ao carrinho!',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  20,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Adicionar ao carrinho',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.add_shopping_cart,
                                              size: 18,
                                              color: Colors.white,
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
                        },
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget shopping() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text(
              "Carrinho",
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    'R\$ 0.00',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '   Itens: 0   ',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: 60.0,
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(10),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                      ),
                    ),
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.all(0.0),
                    )),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 52, 52, 52),
                          Color.fromARGB(255, 29, 29, 29)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.repeated),
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 20,
                        minHeight: 50.0),
                    alignment: Alignment.center,
                    child: const Text(
                      "PAGAMENTO",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget publishBook() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Publicar livro",
          style: TextStyle(
            color: Colors.indigo,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Text(
          "Para isso, você precisa se registrar.",
          style: TextStyle(
            color: Colors.indigo,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          height: 50.0,
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            style: ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      50.0,
                    ),
                  ),
                ),
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.all(0.0),
                )),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.indigo, Color.fromARGB(255, 5, 22, 137)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      tileMode: TileMode.repeated),
                  borderRadius: BorderRadius.circular(30.0)),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: const Text(
                  "Registrar",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget registerPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: showLoading!
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Text(
                      goToLogin! ? 'Entrar' : 'Criar conta',
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Image.asset(
                      'assets/login-image.webp',
                      height: 250,
                      width: 250,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          goToLogin = !goToLogin!;
                        });
                      },
                      child: Text(
                        goToLogin!
                            ? 'Ainda não tem uma conta? Clique aqui'
                            : 'Já possui conta? Clique aqui.',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    goToLogin!
                        ? Container()
                        : TextFormField(
                            controller: nameController,
                            textInputAction: TextInputAction.next,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: 'Nome',
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
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.emailAddress,
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
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword!
                                ? Icons.remove_red_eye_rounded
                                : Icons.remove_red_eye,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword!;
                            });
                          },
                        ),
                        hintText: 'Senha',
                        fillColor: Colors.indigo,
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50.0,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showLoading = true;
                          });

                          if (goToLogin!) {
                            loginCustomer();
                          } else {
                            if (nameController!.text.isNotEmpty &&
                                emailController!.text.isNotEmpty &&
                                passwordController!.text.isNotEmpty) {
                              registerCustomer();
                            } else {
                              ScaffoldMessenger.of(
                                      _scaffoldKey.currentState!.context)
                                  .showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red[700],
                                  content: const Text(
                                    'Todos os campos devem ser preenchidos',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  width: MediaQuery.of(context).size.width - 20,
                                ),
                              );
                            }
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  50.0,
                                ),
                              ),
                            ),
                            padding: const MaterialStatePropertyAll(
                              EdgeInsets.all(0.0),
                            )),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Colors.indigo,
                                    Color.fromARGB(255, 5, 22, 137)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  tileMode: TileMode.repeated),
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 250.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              goToLogin! ? "Logar" : "Registrar",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.indigo,
              Colors.indigo,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            tileMode: TileMode.repeated),
        borderRadius: BorderRadius.only(
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

              filter! ? getAllBookList() : getBookList();
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
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.shopping_cart_outlined,
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
                showLoading = false;
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
