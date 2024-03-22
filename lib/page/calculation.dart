import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/data/product.dart';
import 'package:my_app/page/printPDF.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calculation extends StatefulWidget {
  const Calculation({Key? key}) : super(key: key);

  @override
  State<Calculation> createState() => _CalculationState();
}

class _CalculationState extends State<Calculation> {
  @override
  void initState() {
    productError = false;
    sigcaAController.text = "0";
    sigcaBController.text = "0";
    degreeController.text = "0";
    numberOfBottleController.text = "1";
    showPrice = 0;
    setProfile();
    getProduct();
    getAlcoholProduct();
    super.initState();
  }

  Future<void> onRefresh() async {
    setState(() {
      getProduct();
      getAlcoholProduct();
      setProfile();
      clearDataUi();
    });
  }

  void clearDataUi() {
    productError = false;
    sigcaAController.text = "0";
    sigcaBController.text = "0";
    degreeController.text = "0";
    numberOfBottleController.text = "1";
    productController.text = "";
    showPrice = 0;
    sumTax = 0;
    priceOfValue = 0;
    priceOfQuantity = 0;
    texRate = 0;
  }

  final focus = FocusNode();
  List<Product> listProduct = [];
  Product? selectProduct;
  final productController = TextEditingController();
  String showName = "ชื่อพนักงาน";
  String showRole = "ตำแหน่ง";
  final sigcaAController = TextEditingController();
  final sigcaBController = TextEditingController();
  final degreeController = TextEditingController();
  final numberOfBottleController = TextEditingController();
  bool isClickA = true;
  bool isClickB = false;
  bool isClickC = false;
  bool productError = false;
  bool searchError = false;

  int indexList = 0;
  double showPrice = 0;
  double priceOfValue = 0.000;
  double priceOfQuantity = 0.000;
  double texRate = 0.000;

  double sumTax = 0.000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => onRefresh(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                headerScreen(),
                //headProfile(showName, showRole),
                const SizedBox(height: 18),
                dataSection(focus, isClickA),
              ],
            ),
          ),
        ),
      ),
    );
  }

  headerScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
          child: Container(
            width: double.maxFinite,
            height: 90,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
                color: Colors.blue),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/ic_logo.png',
                scale: 8,
              )
            ]),
          ),
        ),
      ],
    );
  }

  headProfile(String name, String role) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 1, offset: Offset(0, 1))],
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
                colors: [Color.fromARGB(255, 76, 181, 252), Colors.white],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight)),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
                child: Container(
                  width: double.maxFinite,
                  height: 23,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 1, 77, 139),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: const Center(
                    child: Text(
                      "ข้อมูลเจ้าพนักงาน",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 4, 116, 207)),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.network(
                        'https://www.thailandplus.tv/wp-content/uploads/2019/02/99.png',
                        scale: 15,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      setText(
                        "ตำแหน่ง",
                        TextAlign.end,
                        FontWeight.w800,
                        Color.fromARGB(255, 19, 158, 128),
                        20,
                      ),
                      setText(
                        "เจ้าพนักงานภาษี",
                        TextAlign.end,
                        FontWeight.w800,
                        Color.fromARGB(255, 173, 20, 20),
                        32,
                      ),
                      setText(
                        role,
                        TextAlign.end,
                        FontWeight.w800,
                        Color.fromARGB(255, 0, 0, 0),
                        15,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 18,
            )
          ],
        ),
      ),
    );
  }

  dataSection(FocusNode focus, bool isA) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 18),
      child: Container(
        decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 1, offset: Offset(0, 0.5))],
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        child: Column(
          children: [
            const SizedBox(height: 18),
            setText(
              "โปรแกรมคำนวณค่าเปรียบเทียบในคดีกรมสรรพสามิต",
              TextAlign.center,
              FontWeight.w700,
              Colors.black,
              14,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 10),
              child: Container(
                alignment: Alignment.bottomRight,
                child: setText(
                  showName,
                  TextAlign.end,
                  FontWeight.w700,
                  Colors.black,
                  14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 10),
              child: Container(
                alignment: Alignment.bottomRight,
                child: setText(
                  showRole,
                  TextAlign.end,
                  FontWeight.w700,
                  Colors.black,
                  14,
                ),
              ),
            ),
            searchSection(focus),
            buttonSearch(),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 2, 106, 175),
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        setText(
                          "ราคา",
                          TextAlign.left,
                          FontWeight.bold,
                          Colors.white,
                          15,
                        ),
                        setText(
                          "${NumberFormat("#,##0.0000").format(showPrice)} บาท",
                          TextAlign.end,
                          FontWeight.bold,
                          Colors.white,
                          15,
                        ),
                      ]),
                ),
              ),
            ),
            selectMethod(),
            showSelectMethod(),
            setText(
              "สรุปภาษีสรรพสามิต",
              TextAlign.center,
              FontWeight.bold,
              Colors.black,
              14,
            ),
            const SizedBox(height: 8),
            taxSummaryfield(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 2, 106, 175),
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        setText(
                          "ประมาณการค่าปรับ",
                          TextAlign.left,
                          FontWeight.bold,
                          Colors.white,
                          15,
                        ),
                        setText(
                          "${NumberFormat("#,##0.0000").format(sumTax)} บาท",
                          TextAlign.end,
                          FontWeight.bold,
                          Colors.white,
                          15,
                        ),
                      ]),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 8),
                      child: Center(
                        child: Container(
                          height: 30,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              color: Colors.blue),
                          child: MaterialButton(
                            minWidth: 50,
                            onPressed: (() {
                              geSummaryTaxTen();
                            }),
                            textColor: Colors.white,
                            child: const Text(
                              'คำนวณอัตราภาษี 10 เท่า',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 8),
                      child: Center(
                        child: Container(
                          height: 25,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              color: Colors.blue),
                          child: MaterialButton(
                            minWidth: 50,
                            onPressed: (() {
                              geSummaryTaxFifteen();
                            }),
                            textColor: Colors.white,
                            child: const Text(
                              'คำนวณอัตราภาษี 15 เท่า',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 5, right: 8),
                  child: Center(
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          color: Colors.blue),
                      child: MaterialButton(
                        minWidth: 50,
                        onPressed: (() {
                          navigateToPrintPDF();
                        }),
                        textColor: Colors.white,
                        child: const Text(
                          'พิมพ์เอกสาร',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  searchSection(FocusNode focus) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchField(
        focusNode: focus,
        controller: productController,
        suggestions: listProduct
            .map((e) => SearchFieldListItem(e.prouctName ?? "Not Have"))
            .toList(),
        searchInputDecoration: const InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
        ),
        suggestionStyle: const TextStyle(fontSize: 16, color: Colors.black),
        hint: "ค้นหา",
        maxSuggestionsInViewPort: 3,
        itemHeight: 45,
        onTap: () {
          setState(() {
            clearDataUi();
          });
        },
        onTapOutside: (x) {
          focus.unfocus();
        },
      ),
    );
  }

  buttonSearch() {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Center(
        child: Container(
          height: 25,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.blue),
          child: MaterialButton(
            minWidth: 50,
            onPressed: (() {
              if (productController.text.isEmpty) {
                getProductError();
              } else {
                getSelectProduct();
              }
            }),
            textColor: Colors.white,
            child: const Text(
              'ค้นหา',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  selectMethod() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (() {
                    setState(() {
                      isClickA = !isClickA;
                      isClickB = false;
                      isClickC = false;
                    });
                  }),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all<Size>(const Size(80, 10)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          isClickA == false ? Colors.blue : Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          isClickA == false ? Colors.white : Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: isClickA == false
                                      ? Colors.blue
                                      : Colors.black),
                              borderRadius: BorderRadius.circular(30)))),
                  child: const Text(
                    'บุหรี่',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (() {
                    setState(() {
                      isClickB = !isClickB;
                      isClickA = false;
                      isClickC = false;
                    });
                  }),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all<Size>(const Size(80, 10)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          isClickB == false ? Colors.blue : Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          isClickB == false ? Colors.white : Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: isClickB == false
                                      ? Colors.blue
                                      : Colors.black),
                              borderRadius: BorderRadius.circular(30)))),
                  child: const Text(
                    'วิสกี้',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (() {
                    setState(() {
                      isClickC = !isClickC;
                      isClickA = false;
                      isClickB = false;
                    });
                  }),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all<Size>(const Size(80, 10)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          isClickC == false ? Colors.blue : Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          isClickC == false ? Colors.white : Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: isClickC == false
                                      ? Colors.blue
                                      : Colors.black),
                              borderRadius: BorderRadius.circular(30)))),
                  child: const Text(
                    'ไวน์',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  showSelectMethod() {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Visibility(
              visible: isClickA,
              child: visibilitiContainer(
                  'จำนวนต่อมวนต่อซอง', 'มวน', sigcaAController),
            ),
            Visibility(
              visible: isClickA,
              child:
                  visibilitiContainer('จำนวนกี่ซอง', 'ซอง', sigcaBController),
            ),
            Visibility(
              visible: isClickB || isClickC,
              child: visibilitiContainer('ดีกรี', 'ดีกรี', degreeController),
            ),
            Visibility(
              visible: isClickB || isClickC,
              child: visibilitiContainer(
                  'จำนวนขวด', 'ขวด', numberOfBottleController),
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  setText(
    String text,
    TextAlign textAlign,
    FontWeight? weigh,
    Color textColor,
    double size,
  ) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: weigh,
        color: textColor,
        fontSize: size,
      ),
      maxLines: 3,
    );
  }

  visibilitiContainer(
    String title,
    String unit,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            setText(
              title,
              TextAlign.center,
              FontWeight.bold,
              Colors.black,
              15,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height: 25,
                        width: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          controller: controller,
                        ),
                      )),
                  Container(
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: setText(
                          unit,
                          TextAlign.center,
                          FontWeight.bold,
                          Colors.white,
                          15,
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  taxSummaryfield() {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            summaryField('ภาษีสรรพสามิตตามมูลค่า',
                NumberFormat("#,##0.0000").format(priceOfValue)),
            summaryField('ภาษีสรรพสามิตตามปริมาณ',
                NumberFormat("#,##0.0000").format(priceOfQuantity)),
            summaryField(
                'อัตราภาษี', NumberFormat("#,##0.0000").format(texRate)),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  summaryField(
    String title,
    String firstline,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: setText(
                  title,
                  TextAlign.center,
                  FontWeight.bold,
                  Colors.black,
                  15,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    setText(
                      '$firstline บาท',
                      TextAlign.center,
                      FontWeight.bold,
                      Colors.black,
                      15,
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }

  Future setProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? name = preferences.getString('prefs_name');
    String? role = preferences.getString('prefs_role');

    if (name != null && role != null) {
      setState(() {
        showName = name;
        showRole = role;
      });
    }
  }

  Future<List<Product>> getProduct() async {
    String url =
        "https://script.google.com/macros/s/AKfycbx5hcmpXG-hEDmACOlp5ffo852lSksFCYJJBbDNqtEsd3C6g4K2VcGm0NStyTR_1lt1/exec";

    final response = await http.get(Uri.parse(url));
    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in result) {
        listProduct.add(Product.fromJson(index));
      }

      return listProduct;
    } else {
      setState(() {
        productError = true;
      });
      getProductErrorInternet();

      return listProduct;
    }
  }

  Future getProductError() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shadowColor: Colors.red,
        actionsAlignment: MainAxisAlignment.center,
        title: Image.asset(
          'assets/ic_error.png',
          height: 70,
          width: 70,
        ),
        content: Container(
          height: 30,
          alignment: Alignment.center,
          child: const Text(
            'ไม่พบสินค้า',
            style: TextStyle(
              fontSize: 20,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              side: MaterialStateProperty.all<BorderSide>(
                  const BorderSide(color: Colors.blue, width: 2)),
            ),
            onPressed: () {
              searchError = false;
              indexList = 0;
              Navigator.pop(context, 'OK');
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<List<Product>> getAlcoholProduct() async {
    String url =
        "https://script.google.com/macros/s/AKfycbzCuW-YsREgwME70wzasSNila2KIbm2XfjYQ-LDAGTfr2gH9CsnnZoHGISHmORy57qGPQ/exec";

    final response = await http.get(Uri.parse(url));
    var result = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in result) {
        listProduct.add(Product.fromJson(index));
      }

      return listProduct;
    } else {
      setState(() {
        productError = true;
      });
      getProductErrorInternet();

      return listProduct;
    }
  }

  Future getProductErrorInternet() async {
    if (productError) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.red,
          actionsAlignment: MainAxisAlignment.center,
          title: Image.asset(
            'assets/ic_error.png',
            height: 70,
            width: 70,
          ),
          content: Container(
            height: 30,
            alignment: Alignment.center,
            child: const Text(
              'Internet Error',
              style: TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.blue, width: 2)),
              ),
              onPressed: () {
                productError = true;
                Navigator.pop(context, 'OK');
                getProduct();
                getAlcoholProduct();
              },
              child: const Text(
                'reload',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future getSelectProduct() async {
    indexList = 0;
    for (var index in listProduct) {
      if (index.prouctName == productController.text) {
        setState(() {
          searchError = false;
          selectProduct = Product(
              prouctName: index.prouctName,
              price: index.price,
              priceTax: index.priceTax,
              lite: index.lite);
          showPrice = double.parse(index.price ?? "0");
        });
      } else {
        indexList++;
        if (indexList == listProduct.length) {
          getProductError();
          setState(() {
            selectProduct = Product(
              prouctName: null,
              price: null,
              priceTax: null,
              lite: null,
            );
          });
        }
      }
    }
  }

  Future getDataCigarette() async {
    if (double.parse(selectProduct?.price ?? '0') >= 72.000) {
      priceOfQuantity = double.parse(sigcaAController.text) * 1.25;
      priceOfValue = double.parse(selectProduct?.price ?? '0') * 0.42;

      texRate = (priceOfQuantity + priceOfValue) *
          double.parse(sigcaBController.text);
    } else {
      priceOfQuantity = double.parse(sigcaAController.text) * 1.25;
      priceOfValue = double.parse(selectProduct?.price ?? '0') * 0.25;

      texRate = (priceOfQuantity + priceOfValue) *
          double.parse(sigcaBController.text);
    }
  }

  Future getDataVisky() async {
    double price = double.parse(selectProduct?.price ?? '0');
    double lite = double.parse(selectProduct?.lite ?? '0');
    double degree = double.parse(degreeController.text);
    double bottle = double.parse(numberOfBottleController.text);

    priceOfValue = price * 0.20;
    priceOfQuantity = (lite * degree * 255) * 0.01;
    texRate = (lite * (priceOfQuantity + priceOfValue)) * bottle;
  }

  Future getDataWine() async {
    double price = double.parse(selectProduct?.price ?? '0');
    double lite = double.parse(selectProduct?.lite ?? '0');
    double degree = double.parse(degreeController.text);
    double bottle = double.parse(numberOfBottleController.text);

    if (price > 1000.00) {
      priceOfValue = price * 0.10;
      priceOfQuantity = (lite * degree * 1500) * 0.01;
      texRate = (lite * (priceOfQuantity + priceOfValue)) * bottle;
    }

    if (price <= 1000.00) {
      priceOfValue = price * 0.0;
      priceOfQuantity = (lite * degree * 1500) * 0.01;
      texRate = (lite * (priceOfQuantity + priceOfValue)) * bottle;
    }
  }

  void geSummaryTaxTen() async {
    if (isClickA) {
      getDataCigarette();
    }
    if (isClickB) {
      getDataVisky();
    }
    if (isClickC) {
      getDataWine();
    }

    setState(() {
      sumTax = texRate * 10;
    });
  }

  void geSummaryTaxFifteen() async {
    if (isClickA) {
      getDataCigarette();
    }
    if (isClickB) {
      getDataVisky();
    }
    if (isClickC) {
      getDataWine();
    }

    setState(() {
      sumTax = texRate * 15;
    });
  }

  void navigateToPrintPDF() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PrintPDF(
              product: productController.text,
              price: showPrice,
              sum: sumTax,
              priceOfValue: priceOfValue,
              priceOfQuantity: priceOfQuantity,
              texRate: texRate,
              sigcaAController: int.parse(sigcaAController.text),
              sigcaBController: int.parse(sigcaBController.text),
              degreeController: int.parse(degreeController.text),
              isClickA: isClickA,
              numberOfBottle: int.parse(numberOfBottleController.text),
            )));
  }
}
