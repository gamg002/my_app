import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class PrintPDF extends StatefulWidget {
  double? price, sum, priceOfValue, priceOfQuantity, texRate = 0.00;
  int? sigcaAController, sigcaBController, degreeController, numberOfBottle = 0;
  bool? isClickA;
  String? product;

  PrintPDF({
    Key? key,
    this.product,
    this.price,
    this.sum,
    this.priceOfValue,
    this.priceOfQuantity,
    this.texRate,
    this.sigcaAController,
    this.sigcaBController,
    this.degreeController,
    this.numberOfBottle,
    this.isClickA,
  }) : super(key: key);

  @override
  State<PrintPDF> createState() => _PrintPDFState();
}

class _PrintPDFState extends State<PrintPDF> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: dataAllBodyPage(),
        ),
      ),
    );
  }

  dataAllBodyPage() {
    return Column(
      children: [
        headerScreen(),
        subTitle(),
        downloadButton(),
        pagePDF(),
        const SizedBox(height: 50),
      ],
    );
  }

  headerScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
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
              const SizedBox(height: 10),
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

  subTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              width: double.maxFinite,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 5),
                      buttonBack(),
                      const SizedBox(width: 5),
                      setText(
                        "ย้อนกลับ",
                        TextAlign.start,
                        FontWeight.bold,
                        Colors.black,
                        12,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pagePDF() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 18,
        left: 18,
        top: 15,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.black,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageZone(),
            headerText("สรุปภาษีสรรพสามิต"),
            const SizedBox(height: 20),
            borderWite("ชื่อสินค้า", widget.product ?? "ชื่อสินค้า"),
            const SizedBox(height: 10),
            borderBlue(
                "ราคา", "${NumberFormat("#,##0.0000").format(widget.price)} บาท"),
            taxField(),
            quantityField(),
            borderBlue("ปริมาณค่าปรับ",
                "${NumberFormat("#,##0.0000").format(widget.sum)} บาท"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  buttonBack() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: (() {
          Navigator.pop(context);
        }),
        icon: const Icon(Icons.arrow_back_ios),
        iconSize: 40,
        color: Colors.white,
      ),
    );
  }

  downloadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Center(
        child: Container(
          height: 40,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: Colors.green),
          child: MaterialButton(
            minWidth: 50,
            onPressed: (() {
              downloadPDF();
            }),
            textColor: Colors.white,
            child: const Text(
              'ดาวน์โหลด',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  pagePrintPDF() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        imageZone(),
        headerText("สรุปภาษีสรรพสามิต"),
        const SizedBox(height: 20),
        borderWite("ชื่อสินค้า", widget.product ?? "ชื่อสินค้า"),
        const SizedBox(height: 10),
        borderBlue(
            "ราคา", "${NumberFormat("#,##0.0000").format(widget.price)} บาท"),
        taxField(),
        quantityField(),
        borderBlue("ปริมาณค่าปรับ",
            "${NumberFormat("#,##0.0000").format(widget.sum)} บาท"),
        const SizedBox(height: 30),
      ],
    );
  }

  Future<Uint8List> downloadPDF() async {
    final screenShot =
        await screenshotController.captureFromWidget(pagePrintPDF());
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Center(
          child: pw.Image(
            pw.MemoryImage(screenShot),
            fit: pw.BoxFit.cover,
          ),
        ),
      ),
    );

    var date = DateTime.now().millisecondsSinceEpoch;
    final output = (await getApplicationDocumentsDirectory()).path;
    final patch = "${output}/CALCULATE-$date.pdf";
    final file = File(patch);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(patch);

    return pdf.save();
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

  imageZone() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        height: 90,
        width: 90,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/ic_logo.png',
          )
        ]),
      ),
    );
  }

  headerText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: setText(
        text,
        TextAlign.center,
        FontWeight.bold,
        Colors.black,
        15,
      ),
    );
  }

  borderBlue(String first, String second) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  first,
                  TextAlign.left,
                  FontWeight.bold,
                  Colors.white,
                  10,
                ),
                setText(
                  second,
                  TextAlign.end,
                  FontWeight.bold,
                  Colors.white,
                  10,
                ),
              ]),
        ),
      ),
    );
  }

  borderWite(String first, String second) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
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
                SizedBox(
                  width: 150,
                  child: setText(
                    first,
                    TextAlign.left,
                    FontWeight.bold,
                    Colors.black,
                    10,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: setText(
                    second,
                    TextAlign.end,
                    FontWeight.bold,
                    Colors.black,
                    10,
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  taxField() {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
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
              visible: widget.isClickA ?? true,
              child: summaryField('จำนวนมวนต่อซอง',
                  "${NumberFormat("#,###").format(widget.sigcaAController)} มวน"),
            ),
            Visibility(
              visible: widget.isClickA ?? true,
              child: summaryField('จำนวนกี่ซอง',
                  "${NumberFormat("#,###").format(widget.sigcaBController)} ซอง"),
            ),
            Visibility(
              visible: (widget.isClickA ?? true) == false,
              child: summaryField('ดีกรี',
                  "${NumberFormat("#,###").format(widget.degreeController)} ดีกรี"),
            ),
            Visibility(
              visible: (widget.isClickA ?? true) == false,
              child: summaryField('จำนวนขวด',
                  "${NumberFormat("#,###").format(widget.numberOfBottle)} ขวด"),
            ),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  quantityField() {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            taxSumField('ภาษีสรรพสามิตตามมูลค่า',
                NumberFormat("#,##0.0000").format(widget.priceOfValue)),
            taxSumField('ภาษีสรรพสามิตตามปริมาณ',
                NumberFormat("#,##0.0000").format(widget.priceOfQuantity)),
            taxSumField(
                'อัตราภาษี', NumberFormat("#,##0.0000").format(widget.texRate)),
            const SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  taxSumField(
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
                  10,
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
                      10,
                    ),
                  ],
                ),
              )
            ]),
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
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: setText(
                  title,
                  TextAlign.center,
                  FontWeight.bold,
                  Colors.black,
                  10,
                ),
              ),
              Container(
                child: setText(
                  firstline,
                  TextAlign.center,
                  FontWeight.bold,
                  Colors.black,
                  10,
                ),
              )
            ]),
      ),
    );
  }
}
